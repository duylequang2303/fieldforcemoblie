# Gradle RAM Optimization Skill

Skill tối ưu hoá Gradle build để tránh bị out of memory (OOM) / tràn RAM khi build Flutter Android app trên máy có RAM thấp hoặc khi Gradle daemon tiêu tốn quá nhiều.

## Khi nào dùng skill này

Dùng **ngay** khi thấy các lỗi liên quan:
- `java.lang.OutOfMemoryError: Java heap space`
- `GC overhead limit exceeded`
- `Metaspace limit exceeded`
- Gradle daemon bị kill đột ngột
- Máy treo, swap disk tăng cao khi build
- Terminal báo `Error: java.lang.OutOfMemoryError`
- Build chậm/hang lâu trong giai đoạn compilation

**Prioritize:** Fix ngay mức độ "Tính cấp thiết" bên dưới trước, sau đó chỉnh "Tối ưu hoá dài hạn".

## Bảng chẩn đoán nhanh

| Triệu chứu | Nguyên nhân | Fix cấp tính | Fix dài hạn |
|----------|----------|-----------|-----------|
| OOM lần đầu tiên, máy chưa warm-up | Gradle daemon mới, heap default quá nhỏ | Giảm `-Xmx` thành 512m, enable build cache | Config `gradle.properties` chuẩn |
| OOM lúc compile natives (NDK code) | Gradle + Kotlin + C++ compiler cộng lại quá nặng | Disable parallelize NDK build, tắt LTO | Dùng CMake cache, split modules |
| Machine swap tăng, treo không phản hồi | RAM bị dùng hết, kernel dùng disk swap (chậm chạp) | Giết daemon, disable parallel builds | Xác định RAM máy, config ngưỡng phù hợp |
| Build cứ bị interrupted/incomplete | Daemon timeout hoặc memory pressure từ OS | Tăng timeout, giảm parallel workers | Bật build cache, enable incremental compile |

## Thứ tự fix (áp dụng tuần tự)

### Tính cấp thiết (Fix ngay)

**1. Kill Gradle daemon cũ + xóa cache bẩn**
```bash
cd android
./gradlew --stop
rm -rf build/ .gradle/ app/build/
cd ..
```

**2. Config heap memory phù hợp với RAM máy**
- RAM < 2GB: `-Xmx512m`
- RAM 2-4GB: `-Xmx1024m`
- RAM 4-8GB: `-Xmx2048m`
- RAM > 8GB: `-Xmx4096m`

Sửa `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=512m
```

**3. Disable parallel builds (tránh race conditions trên heap)**
```properties
org.gradle.parallel=false
org.gradle.workers.max=1
```

**4. Test build ngay**
```bash
flutter clean
flutter pub get
flutter build apk --verbose 2>&1 | tail -50
```

---

### Tối ưu hoá dài hạn (Sau khi OOM hết)

**5. Enable build cache + incremental compilation**
```properties
org.gradle.caching=true
org.gradle.configureondemand=true
kotlin.incremental=true
kotlin.incremental.js=true
```

**6. Chọn garbage collector hiệu quả hơn**
```properties
# G1GC - tối ưu cho heap lớn
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200

# Hoặc Z garbage collector (Linux, Java 15+) - tối ưu cho latency
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=512m -XX:+UseZGC
```

**7. Tắt unused features**
```properties
# Disable unused dexing
android.enableD8=true
# Disable debuggable apk nếu build release
android.debuggable=false
```

**8. Bật multiDex từng giai đoạn để split memory usage**
```gradle
// android/app/build.gradle
android {
    ...
    defaultConfig {
        multiDexEnabled = true  // chỉ cho debug
    }
}
```

**9. Cấu hình NDK build nếu có native code**
```gradle
// android/app/build.gradle
android {
    externalNativeBuild {
        cmake {
            path "CMakeLists.txt"
        }
    }
    // Tắt parallel NDK build
    packagingOptions {
        doNotStrip "**/*.so"  // skip debug symbols để nhẹ
    }
}
```

---

## Công thức config tối ưu cho từng tình huống

### Config A: RAM máy < 2GB (hoặc maxed out với app khác)

```properties
org.gradle.jvmargs=-Xmx512m -XX:MaxMetaspaceSize=256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
org.gradle.parallel=false
org.gradle.workers.max=1
org.gradle.configureondemand=true
org.gradle.caching=true
org.gradle.daemon.useseparateclassloader=true
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
kotlin.incremental=true
```

**Chi tiêu:** Chậm (~2-3 phút), nhưng không tràn RAM.

---

### Config B: RAM máy 2-4GB (cân bằng)

```properties
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+ParallelRefProcEnabled
org.gradle.parallel=true
org.gradle.workers.max=2
org.gradle.configureondemand=true
org.gradle.caching=true
kotlin.incremental=true
kotlin.incremental.js=true
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
```

**Chi tiêu:** Cân bằng tốc độ (~1.5 phút) vs ổn định.

---

### Config C: RAM máy 4-8GB (tối ưu tốc độ)

```properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=150 -XX:+ParallelRefProcEnabled -XX:G1NewCollectionHeuristicPercent=35
org.gradle.parallel=true
org.gradle.workers.max=4
org.gradle.configureondemand=true
org.gradle.caching=true
org.gradle.daemon.baseDir=$HOME/.gradle/daemon
kotlin.incremental=true
kotlin.incremental.js=true
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
```

**Chi tiêu:** Nhanh (~45s), ổn định cao.

---

## Debug & Monitoring

### 1. Kiểm tra Gradle heap hiện tại
```bash
cd android
./gradlew -Dorg.gradle.debug=true -Dorg.gradle.jvmargs=-verbose:gc clean 2>&1 | grep "Xmx\|Xms"
```

### 2. Xem Gradle daemon processes
```bash
ps aux | grep gradle
# Hoặc
./gradlew --status
```

### 3. Kill tất cả daemon nếu bị stuck
```bash
pkill -f "gradle.*daemon"
cd android && ./gradlew --stop
```

### 4. Monitor RAM khi build chạy (terminal khác)
```bash
# Linux
watch -n 1 'free -h | grep "Mem\|Swap"; ps aux | grep -E "[g]radle|[j]ava" | awk "{print \$6}"'

# macOS
watch -n 1 'vm_stat | head -1; ps aux | grep -E "[g]radle|[j]ava" | awk "{print \$6}"'
```

### 5. Xem thời gian từng task (để find bottleneck)
```bash
cd android
./gradlew build --profile
# Output: build/reports/profile/profile-<timestamp>.html
```

---

## Danh sách quick-fix (chạy lần lượt nếu vẫn bị OOM)

| # | Action | Command | Tác dụng |
|----|--------|---------|---------|
| 1 | Kill daemon + clean | `./gradlew --stop && rm -rf build/ .gradle/` | Clear state bẩn |
| 2 | Giảm heap | Sửa `gradle.properties`: `-Xmx512m` | Cho phép rebuild, avoid OOM |
| 3 | Disable parallel | `org.gradle.parallel=false` | Một task tại một lúc |
| 4 | Giảm workers | `org.gradle.workers.max=1` | Cùng lắc: tắt jobQueue |
| 5 | Bật build cache | `org.gradle.caching=true` | Tái sử dụng, skip recompile |
| 6 | Giảm metaspace | `-XX:MaxMetaspaceSize=256m` | Tắt unused class loading |
| 7 | Tắt debuggable | `android.debuggable=false` | Nhẹ binary, skip debug info |
| 8 | Check unused deps | `./gradlew dependencyInsight` | Xóa deps nặng |

---

## Lỗi phổ biến → Fix

### Lỗi: `Exception: Build process died unexpectedly`
**Nguyên nhân:** Gradle daemon bị kill vì OOM.
**Fix:** 
```bash
./gradlew --stop
# Giảm heap trong gradle.properties
# Chạy lại: flutter clean && flutter pub get && flutter build apk
```

---

### Lỗi: `FAILURE: Build failed with an exception. java.lang.OutOfMemoryError: GC overhead limit exceeded`
**Nguyên nhân:** GC chạy quá nhiều, heap quá nhỏ hoặc memory leak.
**Fix:**
```bash
# 1. Kill daemon
./gradlew --stop
# 2. Xóa build cache
rm -rf build/ .gradle/
# 3. Config GC tốt hơn (G1GC)
# Sửa gradle.properties: org.gradle.jvmargs=-Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
# 4. Rebuild
./gradlew clean build
```

---

### Lỗi: `Unable to load class 'com.android.build.gradle.internal.tasks.databinding.DataBindingProcessLayoutsTask'`
**Nguyên nhân:** Classpath metaspace bị tràn khi load plugins quá nhiều.
**Fix:**
```properties
# Giảm metaspace từ 1024m → 512m → 256m
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=256m
# Hoặc tắt features không cần (data binding, etc)
```

---

### Lỗi: Machine "treo" (swap disk cao)
**Nguyên nhân:** RAM đầy, OS dùng disk swap (chậm).
**Fix:**
```bash
# 1. Xem RAM/swap hiện tại
free -h

# 2. Kill Gradle + giảm heap
./gradlew --stop
# Sửa gradle.properties: -Xmx512m (nếu máy < 2GB)

# 3. Tắt parallel builds
org.gradle.parallel=false
org.gradle.workers.max=1

# 4. Rebuild
flutter clean && flutter pub get && flutter build apk
```

---

## Ghi chú

- **Daemon lifecycle:** Gradle daemon chạy background, persist heap. Nếu OOM, phải kill + restart.
- **Build cache:** Nếu enable, lần build thứ 2 sẽ nhanh 30-50% (skip recompile).
- **Incremental compilation:** Chỉ compile file thay đổi, skip file unchanged.
- **G1GC vs ZGC:** G1GC có sẵn (Java 7+), ZGC low-latency hơn nhưng cần Java 15+ và Linux.
- **Memory pressure from system:** Nếu máy chạy app khác nặng (browser, IDE, etc), cách duy nhất là kill apps hoặc upgrade RAM.

---

## Khi nào cần upgrade RAM / dọn dẹp hệ thống

- Máy < 2GB RAM + không thể tắt ứng dụng khác → không thể build Flutter hiệu quả.
- Máy 2-4GB RAM → có thể build, nhưng phải config ketat (config A).
- Máy > 4GB RAM → build nhanh, config thoải mái (config B/C).

Nếu sau khi áp dụng tất cả fixes trên vẫn OOM → vấn đề nằm ở:
1. RAM máy quá ít (< 2GB) + đang chạy nhiều app khác.
2. Project có dependency nặng (ví dụ 20+ aar files, native code không optimize).
3. Gradle version / AGP version / Kotlin version không match, gây memory leak.

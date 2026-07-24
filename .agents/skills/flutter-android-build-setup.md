# Flutter Android Build Setup (Linux, thiết bị USB thật)

Skill chẩn đoán và sửa lỗi môi trường khi build/run Flutter app trên thiết bị Android thật qua USB (flutter run, flutter build apk) trên máy Linux, khi SDK cài qua package Linux distro (ví dụ /usr/lib/android-sdk) chứ không phải Android Studio.

## Khi nào dùng skill này

Dùng **ngay** khi thấy các lỗi liên quan:
- Android SDK, NDK, Gradle, cmdline-tools
- Licenses (thiếu, hết hạn, chưa accept)
- `JAVA_COMPILER` / JDK version
- CMake
- Quyền ghi vào `/usr/lib/android-sdk` hoặc `$ANDROID_SDK_ROOT`
- Lỗi chỉ hiện một phần trong log Gradle (thường là phần của chuỗi phụ thuộc)

**Không** tự đoán mò từng lỗi một mà chạy hết checklist bên dưới một lượt, vì các lỗi này thường xếp thành chuỗi phụ thuộc (fix lỗi A sẽ lộ ra lỗi B).

## Thứ tự phụ thuộc đã quan sát được

1. Lỗi cú pháp Dart (sửa trước, không liên quan Android)
2. `cmdline-tools` phải có trước khi làm được bất cứ gì khác với `sdkmanager`
3. Licenses phải accept trước khi `sdkmanager` chịu tải NDK/Build-Tools/Platform/CMake
4. NDK license là license riêng, `sdkmanager --licenses` không luôn tự thêm — phải check/thêm tay
5. Quyền ghi vào thư mục SDK phải đúng trước khi `sdkmanager` tự động cài được components
6. `JAVA_COMPILER` / JDK version ảnh hưởng đến việc Gradle daemon có chạy được không
7. Build-Tools + Platform version phải khớp `compileSdkVersion` trong `android/app/build.gradle`
8. CMake chỉ cần nếu project có code native (NDK/C++)

## Thao tác

### Bước 1: Chạy checklist verify môi trường

```bash
# 1. cmdline-tools đã có chưa
sdkmanager --version || echo "THIẾU cmdline-tools"

# 2. Licenses đã accept hết chưa
sdkmanager --licenses

# 3. NDK license — check riêng, đây là chỗ hay bị sót
ls $ANDROID_SDK_ROOT/licenses/ | grep ndk
# Nếu không thấy file android-ndk-license, xem mục "Fix #4" bên dưới

# 4. Java version đang dùng
java -version
echo $JAVA_HOME

# 5. Quyền sở hữu thư mục SDK
ls -ld $ANDROID_SDK_ROOT
# Phải là user hiện tại, không phải root

# 6. Các components đã cài
sdkmanager --list_installed
# Đối chiếu với compileSdkVersion / ndkVersion trong android/app/build.gradle

# 7. Thiết bị USB có nhận không
flutter devices
adb devices
```

### Bước 2: Đối chiếu lỗi Gradle / Flutter với bảng bên dưới và fix theo thứ tự

### Bước 3: Sau khi fix xong tất cả

```bash
flutter clean && flutter pub get
flutter devices
flutter run # hoặc flutter build apk
```

## Bảng lỗi → nguyên nhân → fix

### 1. Lỗi cú pháp Dart (ví dụ: thiếu tên class `ColorScheme`, `MainAxisAlignment`)

**Nguyên nhân:** Code lỗi typo/thiếu tên class, không liên quan build environment.

**Fix:** Đọc kỹ stack trace của `flutter analyze` hoặc log biên dịch, sửa trực tiếp trong `lib/main.dart`. Luôn chạy `flutter analyze` trước khi build lên thiết bị thật để bắt sớm.

---

### 2. Thiếu Android SDK cmdline-tools

**Nguyên nhân:** SDK cài qua package quản lý (`apt`) của distro thường không kèm cmdline-tools, chỉ có SDK platform cơ bản.

**Fix:** Tải cmdline-tools bản mới nhất từ Google, giải nén đúng cấu trúc thư mục `$ANDROID_SDK_ROOT/cmdline-tools/latest/`:

```bash
cd /tmp
wget https://dl.google.com/android/repository/commandlinetools-linux-<version>_latest.zip
unzip commandlinetools-linux-<version>_latest.zip -d cmdline-tools-tmp
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest
mv cmdline-tools-tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest/
```

**Lưu ý:** Cấu trúc thư mục phải là `cmdline-tools/latest/bin/sdkmanager`, không phải `cmdline-tools/bin/sdkmanager` — sai chỗ này là nguyên nhân phổ biến khiến sdkmanager không chạy.

---

### 3. Chưa chấp nhận Android SDK licenses

**Nguyên nhân:** Mặc định.

**Fix:**
```bash
yes | sdkmanager --licenses
```

Nếu chạy không tương tác được (CI/agent), dùng `yes |` để tự động trả lời "y" hết.

---

### 4. Chưa chấp nhận NDK license

**Nguyên nhân:** NDK license không nằm trong danh sách mà `sdkmanager --licenses` xử lý tự động trong một số version sdkmanager/NDK — đây là license riêng biệt.

**Fix:** Nếu `sdkmanager --licenses` chạy xong mà build vẫn báo thiếu NDK license, thêm license hash thủ công:

```bash
mkdir -p $ANDROID_SDK_ROOT/licenses
# Hash chuẩn cho android-ndk-license (kiểm tra lại hash mới nhất từ thông báo lỗi Gradle nếu khác):
echo -e "\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-ndk-license
```

Gradle error log thường in thẳng ra hash cần thiết — copy đúng hash đó thay vì đoán, vì hash đổi theo version NDK.

---

### 5. Thiếu NDK version cụ thể (ví dụ `28.2.13676358`)

**Nguyên nhân:** Flutter/Gradle project pin cứng `ndkVersion` trong `android/app/build.gradle`, không dùng NDK version mặc định của máy.

**Fix:** Cài đúng version đó (không phải version mới nhất):
```bash
sdkmanager "ndk;28.2.13676358"
```

Cách nhanh nhất để biết version cần cài: đọc trực tiếp dòng `ndkVersion` trong `android/app/build.gradle`, hoặc đọc số version trong thông báo lỗi Gradle.

---

### 6. Thiếu Java compiler capability (`JAVA_COMPILER`)

**Nguyên nhân:** JDK không đủ đầy đủ (ví dụ JRE-only) hoặc version JDK không tương thích với Gradle bản Flutter đang dùng.

**Fix:** Cài OpenJDK 17 đầy đủ (không phải headless/JRE) và set làm default:
```bash
sudo apt install openjdk-17-jdk
sudo update-alternatives --config java   # chọn JDK 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64   # thêm vào ~/.bashrc hoặc ~/.zshrc
```

---

### 7. Không có quyền ghi vào thư mục SDK (ví dụ `/usr/lib/android-sdk`)

**Nguyên nhân:** SDK cài qua `apt` thường thuộc quyền root, trong khi `sdkmanager` cần tự ghi thêm components khi build.

**Fix:** Đổi quyền sở hữu cho user hiện tại (**không** chạy gradle bằng sudo — đó là anti-pattern, sẽ gây lỗi permission khác về sau):
```bash
sudo chown -R $USER:$USER /usr/lib/android-sdk
```

---

### 8. Thiếu Android SDK Build-Tools và Platform (ví dụ 36)

**Nguyên nhân:** Version pin trong `compileSdkVersion` / `targetSdkVersion` chưa được cài, thường do project dùng SDK version rất mới.

**Fix:**
```bash
sdkmanager "build-tools;36.0.0" "platforms;android-36"
```

Kiểm tra version chính xác cần cài trong `android/app/build.gradle` (`compileSdkVersion`, `buildToolsVersion` nếu có pin).

---

### 9. Thiếu CMake (ví dụ `3.22.1`)

**Nguyên nhân:** Project có dùng native code (NDK/C++), Gradle cần CMake để build phần native.

**Fix:**
```bash
sdkmanager "cmake;3.22.1"
```

Nếu project không có code native, lỗi này thường không nên xuất hiện — nếu vẫn thấy, kiểm tra `android/app/build.gradle` có khai báo `externalNativeBuild` không cần thiết hay không.

---

## Ghi chú thêm

- Toàn bộ flow này áp dụng cho Linux dùng SDK hệ thống (`/usr/lib/android-sdk` hoặc tương tự), khác với setup Android Studio thông thường (`~/Android/Sdk`).
- Nếu đổi máy/dùng Android Studio, đường dẫn SDK sẽ khác, cần điều chỉnh biến `ANDROID_SDK_ROOT` / `ANDROID_HOME`.
- Nếu build vẫn fail sau khi đã qua hết 9 mục trên, chạy `flutter run -v` để lấy log Gradle chi tiết — thường lỗi tiếp theo (nếu có) sẽ là version-mismatch cụ thể giữa Gradle plugin, AGP, và Kotlin version, không còn liên quan setup SDK nữa.
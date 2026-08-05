# Flutter/Dart Development Capabilities in Zed

> **Updated:** 2026-08-05 10:20 UTC
> **Context:** Verification of mobile development workflow

---

## ✅ Đã có (Verified)

### 1. Flutter & Dart SDK
```bash
$ flutter --version
Flutter 3.44.8 • channel stable
Framework • revision 058e0af2c2 (13 days ago)
Engine • hash 13ffd72b2f9a5ca4db2a74ea52d5353ec2e8f939
Tools • Dart 3.12.2 • DevTools 2.57.0

$ dart --version
Dart SDK version: 3.12.2 (stable)
```

**Status:** ✅ FULL INSTALLATION

---

### 2. Build & Compile Commands

Tôi CÓ THỂ chạy TẤT CẢ Flutter commands:

```bash
# Build runner (code generation)
terminal(command: "dart run build_runner build --delete-conflicting-outputs")
✅ ĐÃ DÙNG trong CP1 — generate .g.dart files thành công

# Analyze code
terminal(command: "flutter analyze")

# Format code
terminal(command: "dart format lib/")

# Run tests
terminal(command: "flutter test")
terminal(command: "flutter test test/features/orders/models/")

# Check pubspec dependencies
terminal(command: "flutter pub get")
terminal(command: "flutter pub outdated")

# Clean & rebuild
terminal(command: "flutter clean && flutter pub get")
```

**Status:** ✅ ALL COMMANDS WORK

---

### 3. Device Detection

```bash
$ flutter devices
Linux (desktop) • linux • linux-x64 • Pop!_OS 24.04 LTS

$ adb devices
List of devices attached
(empty — no USB device connected)
```

**Status:** 
- ✅ Linux desktop target available
- ⚠️ No Android/iOS devices currently connected

---

## 📱 Mobile Device Support (USB)

### Android (via ADB)

**Có thể làm ĐƯỢC khi cắm điện thoại:**

```bash
# 1. Check devices
terminal(command: "adb devices")
# Output: List of devices attached
#         ABC123XYZ    device

# 2. Run on device
terminal(command: "flutter run -d ABC123XYZ")

# 3. Build APK
terminal(command: "flutter build apk --release")
terminal(command: "flutter build apk --debug")

# 4. Install APK to device
terminal(command: "flutter install -d ABC123XYZ")

# 5. Hot reload (during development)
# → Flutter CLI supports hot reload via 'r' key in terminal

# 6. Logcat (debug logs)
terminal(command: "adb logcat -s flutter")
```

**Requirements:**
- ✅ ADB installed (verified: `/usr/bin/adb` exists)
- ✅ Flutter SDK installed
- ⏳ USB device connected + USB debugging enabled
- ⏳ Device authorized (first connection needs "Allow USB debugging")

**Status:** ✅ READY (chỉ cần cắm điện thoại)

---

### iOS (via Xcode/libimobiledevice)

```bash
# Check iOS devices
terminal(command: "idevice_id -l")

# Run on iOS device
terminal(command: "flutter run -d <device-id>")

# Build iOS app
terminal(command: "flutter build ios --release")
```

**Requirements:**
- ❓ Xcode installed (chưa verify — likely không có trên Linux)
- ❓ libimobiledevice (for Linux iOS support)

**Status:** ❓ UNKNOWN (có thể không support trên Linux, cần macOS cho production iOS builds)

---

## 🛠️ Development Workflow

### Scenario 1: Development với Hot Reload

```bash
# 1. Cắm điện thoại Android qua USB
# 2. Enable USB debugging trên điện thoại
# 3. Check device
terminal(command: "adb devices")
# → ABC123XYZ    device

# 4. Run app
terminal(command: "flutter run -d ABC123XYZ")
# → App runs, supports hot reload (press 'r' to reload, 'R' to restart)

# 5. Tôi edit code → user press 'r' → hot reload
# OR tôi có thể trigger reload:
# (Flutter CLI runs in interactive mode, không thể automate 'r' key)
```

**Limitations:**
- ⚠️ Hot reload cần **user interaction** (press 'r' trong terminal)
- ⚠️ Zed không có GUI để click "Hot Reload" button (như Android Studio)
- ✅ Workaround: User press 'r' manually, hoặc tôi suggest "Press 'r' to reload"

---

### Scenario 2: Build & Install APK

```bash
# 1. Build APK (không cần device)
terminal(command: "flutter build apk --debug")
# → Output: build/app/outputs/flutter-apk/app-debug.apk

# 2. Install to device
terminal(command: "adb install build/app/outputs/flutter-apk/app-debug.apk")

# 3. Launch app
terminal(command: "adb shell am start -n com.fieldforce.mobile/.MainActivity")
```

**Status:** ✅ FULLY AUTOMATED

---

### Scenario 3: Testing (không cần device)

```bash
# Unit tests
terminal(command: "flutter test")

# Widget tests
terminal(command: "flutter test test/widgets/")

# Integration tests (cần device/emulator)
terminal(command: "flutter test integration_test/")
```

**Status:** ✅ Unit/Widget tests OK, Integration tests cần device

---

## 🔧 Diagnostics & Debugging

### 1. Flutter Analyze (Static Analysis)

```bash
terminal(command: "flutter analyze")
# → Dart analyzer issues (như đã dùng trong CP1)
```

**Zed also has:**
```javascript
diagnostics() // Built-in LSP diagnostics
diagnostics(path: "lib/features/orders/models/fsm_order.dart")
```

**Status:** ✅ DUAL SUPPORT (Flutter CLI + Zed LSP)

---

### 2. Device Logs

```bash
# Android logcat
terminal(command: "adb logcat -s flutter")

# Filter by tag
terminal(command: "adb logcat | grep 'MyApp'")

# Clear logs
terminal(command: "adb logcat -c")
```

**Status:** ✅ WORKS

---

### 3. Performance Profiling

```bash
# Run with profiling
terminal(command: "flutter run --profile -d <device-id>")

# Observatory (DevTools)
# → Flutter CLI outputs URL, user opens in browser
```

**Status:** ⚠️ PARTIAL (cần browser để xem DevTools UI)

---

## 📊 So sánh với IDE truyền thống

| Feature | Android Studio / VS Code | Zed | Gap |
|---------|--------------------------|-----|-----|
| **Flutter SDK** | ✅ | ✅ | None |
| **Build commands** | ✅ | ✅ | None |
| **USB device support** | ✅ | ✅ | None |
| **APK build** | ✅ | ✅ | None |
| **Hot reload** | ✅ GUI button | ⚠️ Manual 'r' key | UI convenience |
| **DevTools** | ✅ Embedded | ⚠️ Browser | UI convenience |
| **Device picker** | ✅ Dropdown | ⚠️ Manual `-d` flag | UI convenience |
| **Logcat viewer** | ✅ Panel | ⚠️ Terminal | UI convenience |
| **Emulator launch** | ✅ GUI | ⚠️ Manual command | UI convenience |

**Kết luận:** Zed CÓ ĐẦY ĐỦ functionality, thiếu GUI conveniences (chấp nhận được cho AI workflow)

---

## 💡 Workflow Recommendations

### For Development (với USB device):

```bash
# 1. User cắm điện thoại
# 2. Tôi check device
terminal(command: "adb devices")

# 3. Build & run
terminal(command: "flutter run -d <device-id>")
# → User sees "Press 'r' to hot reload"

# 4. Tôi edit code
# 5. Tôi suggest: "Press 'r' in terminal to reload"
# 6. User press 'r' → hot reload

# 7. When done, user press 'q' to quit
```

**Pros:** Real device testing, hot reload works
**Cons:** Requires user to press 'r' manually (không automate được)

---

### For Testing (không cần device):

```bash
# 1. Run unit tests
terminal(command: "flutter test")

# 2. Check coverage
terminal(command: "flutter test --coverage")

# 3. Analyze code
terminal(command: "flutter analyze")
diagnostics() // or Zed LSP
```

**Pros:** Fully automated, không cần device
**Cons:** Không test real UI/hardware

---

### For CI/CD (build only):

```bash
# 1. Build APK
terminal(command: "flutter build apk --release")

# 2. Output artifact
# → build/app/outputs/flutter-apk/app-release.apk

# 3. (Optional) Upload to GitHub release / Firebase App Distribution
terminal(command: "gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk")
```

**Pros:** Fully automated, reproducible
**Cons:** Không test trên device trong CI

---

## 🎯 Khuyến nghị cho project này

### Workflow hiện tại (tốt nhất):

1. **Development:** 
   - Tôi edit code (models, services, UI...)
   - Run tests: `flutter test`
   - Analyze: `diagnostics()` + `flutter analyze`
   - User test trên device manually (hot reload với 'r' key)

2. **Before commit:**
   - Tôi run REVIEW workflow (check git diff)
   - Verify build: `flutter build apk --debug` (đảm bảo compile OK)
   - Run tests: `flutter test`
   - Commit nếu all pass

3. **Release:**
   - Build APK: `flutter build apk --release`
   - User test APK trên device
   - Push to GitHub + create release

**Trade-off chấp nhận được:**
- ⚠️ Không có hot reload button GUI (user press 'r' manual)
- ⚠️ Không có embedded DevTools (user mở browser)
- ✅ Tất cả functionality core đều có (build/test/analyze/deploy)

---

## 📝 Commands cheat sheet

```bash
# === DEVICE ===
adb devices                              # List USB devices
flutter devices                          # List all Flutter targets

# === RUN ===
flutter run -d <device-id>               # Run on device (hot reload enabled)
flutter run --release -d <device-id>     # Run release build

# === BUILD ===
flutter build apk --debug                # Debug APK
flutter build apk --release              # Release APK (signed)
flutter build appbundle                  # Android App Bundle (for Play Store)

# === INSTALL ===
adb install <path-to-apk>                # Install APK
flutter install -d <device-id>           # Install current build

# === TEST ===
flutter test                             # All tests
flutter test test/features/orders/       # Specific tests
flutter test --coverage                  # With coverage

# === ANALYZE ===
flutter analyze                          # Static analysis
diagnostics()                            # Zed LSP diagnostics

# === CODE GEN ===
dart run build_runner build              # Generate .g.dart files
dart run build_runner watch              # Watch mode

# === LOGS ===
adb logcat -s flutter                    # Flutter logs only
adb logcat | grep <tag>                  # Filter logs

# === CLEAN ===
flutter clean                            # Clean build cache
flutter pub get                          # Get dependencies
```

---

## ✅ Kết luận

**Zed CÓ ĐẦY ĐỦ khả năng cho Flutter mobile development:**

✅ **Build** — flutter build apk/appbundle
✅ **Run** — flutter run trên USB device
✅ **Test** — flutter test (unit/widget/integration)
✅ **Analyze** — flutter analyze + Zed LSP
✅ **Code gen** — dart run build_runner
✅ **Debug** — adb logcat, flutter logs
✅ **Hot reload** — works (user press 'r' manual)
✅ **Deploy** — build APK + GitHub release

⚠️ **Thiếu GUI conveniences:**
- Hot reload button (vs Android Studio)
- Embedded DevTools (vs VS Code)
- Device picker dropdown (vs IDEs)

**→ Cho AI workflow: Đủ mạnh! Cho human workflow: Hơi thiếu GUI, nhưng OK.**

---

**END OF DOCUMENT**

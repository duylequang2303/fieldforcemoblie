# Auth Module Bug Report - Fieldforce Worker

> Phạm vi: `lib/features/auth/`, `lib/core/auth/`
> Ngày review: 2026-08-06

---

## 📊 Tổng quan Bugs

| ID | Tiêu đề | Loại | Mức độ | File(s) | Trạng thái |
|----|---------|------|--------|---------|------------|
| A01 | **Missing FocusNode / Keyboard overflow handling** | UI/UX | High | `login_page.dart` | 🔴 Open |
| A02 | **ServerUrlField: `Uri.tryParse(value)!` có thể throw null exception** | Crash/Logic | Critical | `server_url_field.dart` | ✅ Fixed |
| A03 | **Login button không disable khi loading (race condition)** | UI/Logic | Medium | `login_page.dart`, `auth_provider.dart` | 🔴 Open |
| A04 | **Biometric: không handle key invalidated / device credential change** | Security | High | `biometric_service.dart`, `auth_service.dart` | 🔴 Open |
| A05 | **Biometric: `biometricOnly: false` cho phép fallback PIN - security risk** | Security | Medium | `biometric_service.dart` | ✅ Fixed |
| A06 | **AuthProvider: `clearError()` không reset status về `unauthenticated`** | Logic | Medium | `auth_provider.dart` | 🔴 Open |
| A07 | **Login flow: redirect race giữa listener `_redirectIfAuthed` và `_onLogin`** | Logic | Medium | `login_page.dart` | 🔴 Open |
| A08 | **`tryRestoreSession()` optimistic - không verify session validity** | Offline/Logic | High | `auth_service.dart`, `odoo_session_manager.dart` | 🔴 Open |
| A09 | **Password lưu plaintext trong SecureStorage** | Security | Critical | `secure_storage.dart`, `auth_service.dart` | ✅ Fixed |
| A10 | **SplashPage: không handle error khi `auth.initialize()` throw exception** | Crash/UX | Medium | `splash_page.dart` | 🔴 Open |
| A11 | **Memory leak: `AuthProvider.addListener` không remove khi dispose (edge case)** | Memory | Low | `login_page.dart` | 🔴 Open |
| A12 | **ServerUrlField: validator không chạy khi user paste/autofill** | UI/Validation | Medium | `server_url_field.dart` | 🔴 Open |
| A13 | **AuthProvider: status chuyển `error` nhưng không auto-clear khi user sửa form** | UX | Low | `auth_provider.dart`, `login_page.dart` | 🔴 Open |
| A14 | **Biometric login: không clear error message khi biometric fail** | UX | Low | `auth_provider.dart` | 🔴 Open |
| A15 | **Logout: clear Isar DB có thể crash nếu Isar chưa init / đang dùng** | Crash/Logic | Medium | `auth_service.dart` | 🔴 Open |
| A16 | **Biometric: không handle lockout (LockoutPermanent/Temporary) → user bị khóa vĩnh viễn** | Security/Crash | Critical | `biometric_service.dart`, `auth_service.dart` | ✅ Fixed |
| A17 | **SecureStorage race condition: concurrent writes không synchronized** | Data Integrity | High | `secure_storage.dart` | ✅ Fixed |
| A18 | **Locale load failure khi restore session → app dùng locale sai / crash** | Crash/Logic | Medium | `auth_service.dart`, `locale_service.dart` | 🔴 Open |
| A19 | **BuildContext async gap: `context.go()` sau `await` không check `mounted` ở mọi nơi** | Crash/Logic | Medium | `login_page.dart`, `splash_page.dart` | ✅ Fixed |
| A20 | **Animation controller leak: `LoadingOverlay` dùng `flutter_spinkit` không dispose** | Memory | Low | `loading_overlay.dart` | 🔴 Open |
| A21 | **Biometric `stickyAuth: true` gây rò rỉ context khi app background** | UX/Logic | Medium | `biometric_service.dart` | 🔴 Open |
| A22 | **Silent re-auth (`_tryReAuthenticate`) swallow exception, không log chi tiết** | Observability | Medium | `odoo_session_manager.dart` | 🔴 Open |
| A23 | **ServerUrlField validator không chạy initial validation (form validate lần đầu)** | Validation | Medium | `server_url_field.dart`, `login_page.dart` | 🔴 Open |
| A24 | **Login API không có timeout → treo vô hạn khi network chậm/mất kết nối** | Reliability | High | `odoo_session_manager.dart`, `odoo_client.dart` | ✅ Fixed |
| A25 | **Biometric availability không refresh sau khi user bật trong Settings** | UX/Logic | Low | `auth_provider.dart`, `biometric_service.dart` | 🔴 Open |
| A26 | **`restoreSession()` catch-all exception → silent fail, khó debug** | Observability | Medium | `odoo_session_manager.dart` | 🔴 Open |
| A27 | **Biometric login success không clear error message từ lần fail trước** | UX | Low | `auth_provider.dart` | 🔴 Open |
| A28 | **Form validation state stale khi user clear field sau khi đã valid** | UI/Validation | Low | `server_url_field.dart`, `login_page.dart` | 🔴 Open |
| A29 | **`AuthProvider.initialize()` gọi `_authService.isBiometricAvailable` race với `tryRestoreSession()`** | Race Condition | Medium | `auth_provider.dart` | 🔴 Open |
| A30 | **Logout: `SyncManager.instance.dispose()` có thể throw nếu chưa init** | Crash/Logic | Medium | `auth_service.dart`, `sync_manager.dart` | 🔴 Open |

---

## 🔴 Chi tiết từng Bug

### A01: Missing FocusNode / Keyboard overflow handling
**File:** `lib/features/auth/pages/login_page.dart`  
**Mức độ:** **High** | **Loại:** UI/UX

**Mô tả:**  
Màn hình Login dùng `SingleChildScrollView` nhưng **không có `FocusNode` management** và **không handle keyboard overflow**. Khi bàn phím mở:
- Các field dưới cùng (Password, Biometric button) bị che khuất
- User không scroll được xuống nút "Đăng nhập"
- Không có `resizeToAvoidBottomInset` config

**Code hiện tại (vấn đề):**
```dart
// login_page.dart:93
body: SafeArea(
  child: SingleChildScrollView(  // Không có keyboard handling
    padding: const EdgeInsets.all(24),
    child: Column(...)
```

**Khuyến nghị fix:**
```dart
// Option 1: Scaffold với resizeToAvoidBottomInset
Scaffold(
  resizeToAvoidBottomInset: true,  // Default true nhưng explicit tốt hơn
  body: SafeArea(...)
)

// Option 2: Thêm FocusNode để dismiss keyboard khi tap outside
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: SingleChildScrollView(...)
)

// Option 3: Dùng MediaQuery viewInsets để adjust padding
padding: EdgeInsets.only(
  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
),
```

---

### A02: ServerUrlField: `Uri.tryParse(value)!` force-unwrap null
**File:** `lib/features/auth/widgets/server_url_field.dart:27`  
**Mức độ:** **Critical** | **Loại:** Crash/Logic | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
`Uri.tryParse(value)` trả về `Uri?` (nullable). Code dùng `!` force-unwrap → **crash khi `value` không parse được thành Uri** (ví dụ: string rỗng, ký tự đặc biệt).

**Code hiện tại:**
```dart
// server_url_field.dart:27
if (!Uri.tryParse(value)!.hasAuthority) return 'URL không hợp lệ';
```

**Test case crash:** User nhập `"not a url"` → `Uri.tryParse` trả về `null` → `null.hasAuthority` → **Null check operator used on null value**

**Khuyến nghị fix:**
```dart
String? _validate(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập URL server';
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return 'URL phải bắt đầu bằng https://';
  }
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority) return 'URL không hợp lệ';
  return null;
}
```

---

### A03: Login button không disable khi loading (race condition)
**File:** `lib/features/auth/pages/login_page.dart:179-183`, `lib/features/auth/providers/auth_provider.dart:30-58`  
**Mức độ:** **Medium** | **Loại:** UI/Logic

**Mô tả:**  
Button disable check dùng `auth.status == AuthStatus.loading` nhưng **AuthProvider.set status loading KHIÊN `notifyListeners()`** → có window race condition:

1. User click Login → `_onLogin()` gọi `auth.login()`
2. `auth.login()` set `_status = loading` → `notifyListeners()`
3. UI rebuild → button disable
4. **NHƯNG**: `_onLogin()` **không await** `auth.login()` hoàn tất trước khi check `auth.isAuthenticated` (line 77-81)

**Code hiện tại:**
```dart
// login_page.dart:65-82
Future<void> _onLogin() async {
  if (!_formKey.currentState!.validate()) return;

  await context.read<AuthProvider>().login(...);  // await ở đây

  // VẤN ĐỀ: redirect logic duplicate với listener
  if (!mounted) return;
  final auth = context.read<AuthProvider>();
  if (auth.isAuthenticated) {   // Có thể đã redirect rồi bởi listener
    context.go(RouteNames.shellSchedule);
  }
}
```

**Vấn đề:** Double redirect (listener + manual) có thể gây `setState after dispose` hoặc navigation error.

**Khuyến nghị fix:**
```dart
// Bỏ manual redirect, chỉ dùng listener
Future<void> _onLogin() async {
  if (!_formKey.currentState!.validate()) return;
  await context.read<AuthProvider>().login(...);
  // Listener _redirectIfAuthed sẽ handle redirect
}

// HOẶC: dùng Completer để sync
Future<void> _onLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  final auth = context.read<AuthProvider>();
  final completer = Completer<void>();
  void listener() {
    if (auth.isAuthenticated) {
      completer.complete();
    }
  }
  auth.addListener(listener);
  try {
    await auth.login(...);
    await completer.future;  // wait for listener
  } finally {
    auth.removeListener(listener);
  }
  if (mounted && auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);
  }
}
```

---

### A04: Biometric: không handle key invalidated / device credential change
**File:** `lib/core/auth/biometric_service.dart`, `lib/core/auth/auth_service.dart:84-92`  
**Mức độ:** **High** | **Loại:** Security

**Mô tả:**  
`local_auth` plugin có thể throw `PlatformException` với code `LockoutPermanent` hoặc `UserFallback` khi:
- Biometric key bị invalidated (user thêm/xoá vân tay, đổi PIN, reset device)
- Quá nhiều lần thử sai → lockout permanently

**Code hiện tại swallow mọi exception:**
```dart
// biometric_service.dart:30-45
Future<bool> authenticate() async {
  try {
    final available = await isAvailable;
    if (!available) return false;
    return await _auth.authenticate(...);
  } catch (_) {   // SWALLOW tất cả lỗi!
    return false;
  }
}
```

**AuthService.loginWithBiometric() không phân biệt lỗi:**
```dart
// auth_service.dart:84-92
Future<bool> loginWithBiometric() async {
  final biometricEnabled = await _storage.isBiometricEnabled;
  if (!biometricEnabled) return false;
  final authenticated = await _biometric.authenticate();
  if (!authenticated) return false;  // Không báo cho user biết nguyên nhân
  return tryRestoreSession();
}
```

**Khuyến nghị fix:**
```dart
// biometric_service.dart
Future<BiometricAuthResult> authenticate() async {
  try {
    final available = await isAvailable;
    if (!available) return BiometricAuthResult.notAvailable;
    
    final result = await _auth.authenticate(
      localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
      options: const AuthenticationOptions(
        biometricOnly: true,  // Chỉ biometric, không fallback PIN
        stickyAuth: true,
      ),
    );
    return result ? BiometricAuthResult.success : BiometricAuthResult.failed;
  } on PlatformException catch (e) {
    switch (e.code) {
      case 'LockoutPermanent':
        return BiometricAuthResult.lockoutPermanent;
      case 'Lockout':
        return BiometricAuthResult.lockoutTemporary;
      case 'UserCancel':
        return BiometricAuthResult.userCancelled;
      case 'UserFallback':
        return BiometricAuthResult.userFallback;  // User chọn "Use PIN"
      default:
        return BiometricAuthResult.error(e.message ?? 'Unknown error');
    }
  } catch (e) {
    return BiometricAuthResult.error(e.toString());
  }
}

// Enum result
enum BiometricAuthResult {
  success,
  failed,
  notAvailable,
  lockoutPermanent,
  lockoutTemporary,
  userCancelled,
  userFallback,
  error,
}

// AuthService: handle từng case
Future<BiometricLoginResult> loginWithBiometric() async {
  final result = await _biometric.authenticate();
  switch (result) {
    case BiometricAuthResult.lockoutPermanent:
      await setBiometricEnabled(enabled: false);  // Tự tắt biometric
      return BiometricLoginResult.biometricDisabled;
    case BiometricAuthResult.lockoutTemporary:
      return BiometricLoginResult.lockoutTemporary;
    case BiometricAuthResult.userFallback:
      // Không cho phép fallback PIN cho security
      return BiometricLoginResult.fallbackNotAllowed;
    // ... handle others
  }
}
```

---

### A05: Biometric: `biometricOnly: false` cho phép fallback PIN
**File:** `lib/core/auth/biometric_service.dart:38`  
**Mức độ:** **Medium** | **Loại:** Security

**Mô tả:**  
`biometricOnly: false` cho phép user chọn "Use PIN/Pattern/Password" thay vì vân tay/FaceID. Điều này **làm giảm security** vì PIN thường yếu hơn biometric.

**Code hiện tại:**
```dart
// biometric_service.dart:37-39
options: const AuthenticationOptions(
  biometricOnly: false,  // CHO PHÉP fallback PIN
  stickyAuth: true,
),
```

**Khuyến nghị fix:**
```dart
options: const AuthenticationOptions(
  biometricOnly: true,  // CHỈ cho phép biometric
  stickyAuth: true,
),
```

**Lưu ý:** Nếu device không có biometric enrolled, `isAvailable` sẽ trả về `false` và `authenticate()` không được gọi.

---

### A06: AuthProvider: `clearError()` không reset status về `unauthenticated`
**File:** `lib/features/auth/providers/auth_provider.dart:78-81`  
**Mức độ:** **Medium** | **Loại:** Logic

**Mô tả:**  
Khi login fail, status = `AuthStatus.error`. User bấm "Đóng" trên ErrorView → gọi `clearError()` → status vẫn là `error` → UI vẫn show loading overlay hoặc disable button.

**Code hiện tại:**
```dart
// auth_provider.dart:78-81
void clearError() {
  _errorMessage = null;
  notifyListeners();  // status vẫn là AuthStatus.error
}
```

**Khuyến nghị fix:**
```dart
void clearError() {
  _errorMessage = null;
  if (_status == AuthStatus.error) {
    _status = AuthStatus.unauthenticated;
  }
  notifyListeners();
}
```

---

### A07: Login flow: redirect race giữa listener và manual redirect
**File:** `lib/features/auth/pages/login_page.dart:34-43, 75-81`  
**Mức độ:** **Medium** | **Loại:** Logic

**Mô tả:**  
Hai path redirect cùng lúc:
1. Listener `_redirectIfAuthed` (line 35) đăng ký trong `initState`
2. Manual redirect trong `_onLogin` (line 77-81)

**Kịch bản race:**
1. User click Login → `_onLogin()` gọi `auth.login()`
2. `auth.login()` success → `_status = authenticated` → `notifyListeners()`
3. Listener `_redirectIfAuthed` fire → `context.go(RouteNames.shellSchedule)`
4. `_onLogin()` tiếp tục chạy → check `auth.isAuthenticated` → `context.go()` **lần 2**
5. **Lỗi:** `setState() called after dispose()` hoặc navigation error

**Khuyến nghị:** Chỉ dùng **một** cách redirect (khuyên dùng listener, bỏ manual).

---

### A08: `tryRestoreSession()` optimistic - không verify session validity
**File:** `lib/core/auth/auth_service.dart:46-81`, `lib/core/api/odoo_session_manager.dart:127-179`  
**Mức độ:** **High** | **Loại:** Offline/Logic

**Mô tả:**  
`tryRestoreSession()` restore session **không verify RPC** với server (optimistic offline-first). Nếu session đã hết hạn trên server:
- App vào được màn hình chính (với dữ liệu Isar cache)
- Lần đầu gọi API online → `OdooSessionExpiredException` → silent re-auth
- **Nhưng**: Nếu re-auth cũng fail (đổi pass, disable user) → user bị stuck ở màn chính với data stale

**Code hiện tại:**
```dart
// auth_service.dart:46-81
Future<bool> tryRestoreSession() async {
  // Chỉ check local storage, KHÔNG gọi RPC verify
  final restored = await _sessionManager.restoreSession(...);
  return restored;  // true ngay cả khi session đã expire trên server
}

// odoo_session_manager.dart:141-179
Future<bool> restoreSession(...) async {
  // Dựng session object local, KHÔNG verify với server
  final session = OdooSession(id: sessionId, userId: savedUserId, ...);
  OdooApiClient.instance.initializeWithSession(serverUrl, session);
  _currentSession = OdooSessionData(...);
  return true;  // Luôn true nếu data local hợp lệ
}
```

**Khuyến nghị fix:**
```dart
// Option 1: Background verify (non-blocking)
Future<bool> tryRestoreSession() async {
  final hasLocal = await _storage.hasSavedSession;
  if (!hasLocal) return false;
  
  final restored = await _sessionManager.restoreSession(...);
  if (!restored) return false;
  
  // Fire-and-forget verify session validity
  unawaited(_verifySessionInBackground());
  return true;  // UI vào ngay, verify ngầm
}

Future<void> _verifySessionInBackground() async {
  try {
    await _sessionManager.callKw(model: 'res.users', method: 'read', args: [[currentUserId]], kwargs: {'fields': ['id']});
  } on OdooAuthException {
    // Session expired → logout silently, redirect to login
    await logout();
    // Trigger navigation via event bus hoặc provider
  }
}
```

---

### A09: Password lưu plaintext trong SecureStorage
**File:** `lib/core/auth/secure_storage.dart:20, 30-43, 54-63`, `lib/core/auth/auth_service.dart:21-43`  
**Mức độ:** **Critical** | **Loại:** Security | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
Mật khẩu user được lưu **plaintext** trong SecureStorage (`_keyPassword`). Dù SecureStorage encrypt at rest, nhưng:
- Password có thể bị extract từ backup (Android) / keychain dump (iOS jailbreak)
- Violation principle: **không bao giờ lưu password**, chỉ lưu session token
- `loginWithBiometric()` dùng password lưu này để re-auth → nếu biometric bypass thì password lộ

**Code hiện tại:**
```dart
// secure_storage.dart:20
static const _keyPassword = 'odoo_password';

// secure_storage.dart:30-43
Future<void> saveSession({..., String? password}) async {
  ...
  if (password != null) {
    writes.add(_storage.write(key: _keyPassword, value: password));
  }
  ...
}

// auth_service.dart:21-43
Future<void> login({..., required String password}) async {
  final session = await _sessionManager.authenticate(..., password: password);
  await _storage.saveSession(..., password: password);  // LƯU PASSWORD!
}
```

**Khuyến nghị fix:**
```dart
// 1. XÓA hoàn toàn _keyPassword khỏi SecureStorageService
// 2. login() KHÔNG lưu password
Future<void> login({..., required String password}) async {
  final session = await _sessionManager.authenticate(..., password: password);
  await _storage.saveSession(..., password: null);  // null hoặc bỏ param
}

// 3. Silent re-auth (OdooSessionManager._tryReAuthenticate) dùng refresh token
//    HOẶC yêu cầu user nhập lại password khi session expired
//    KHÔNG dùng password từ storage

// 4. Biometric login: chỉ unlock keychain/keystore để lấy sessionId, KHÔNG dùng password
```

**Migration:** Cần clear password cũ khi update app:
```dart
// Trong AuthService.initialize() hoặc main.dart
await _storage.delete(key: _keyPassword);
```

---

### A10: SplashPage: không handle error khi `auth.initialize()` throw exception
**File:** `lib/features/auth/pages/splash_page.dart:16-34`  
**Mức độ:** **Medium** | **Loại:** Crash/UX

**Mô tả:**  
`auth.initialize()` có thể throw exception (SecureStorage corrupt, Isar init fail, v.v.). SplashPage **không try-catch** → app crash trắng màn hình.

**Code hiện tại:**
```dart
// splash_page.dart:23-34
Future<void> _init() async {
  final auth = context.read<AuthProvider>();
  await auth.initialize();  // CÓ THỂ THROW

  if (!mounted) return;
  if (auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);
  } else {
    context.go(RouteNames.login);
  }
}
```

**AuthProvider.initialize() có thể throw:**
```dart
// auth_provider.dart:20-28
Future<void> initialize() async {
  _isBiometricAvailable = await _authService.isBiometricAvailable;  // có thể throw
  notifyListeners();
  final restored = await _authService.tryRestoreSession();  // có thể throw
  ...
}
```

**Khuyến nghị fix:**
```dart
Future<void> _init() async {
  try {
    final auth = context.read<AuthProvider>();
    await auth.initialize();
    
    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.go(RouteNames.shellSchedule);
    } else {
      context.go(RouteNames.login);
    }
  } catch (e, stack) {
    logger.e('Splash init failed', error: e, stackTrace: stack);
    if (!mounted) return;
    // Navigate to login with error hoặc show error screen
    context.go(RouteNames.login);  // Fallback to login
    // Hoặc show error dialog rồi navigate
  }
}
```

---

### A11: Memory leak: `AuthProvider.addListener` không remove khi dispose (edge case)
**File:** `lib/features/auth/pages/login_page.dart:35, 57`  
**Mức độ:** **Low** | **Loại:** Memory

**Mô tả:**  
`context.read<AuthProvider>().addListener(_redirectIfAuthed)` trong `initState`, remove trong `dispose`. **NHƯNG**: Nếu `LoginPage` bị pop/dispose **trước khi** `AuthProvider` dispose (ví dụ: navigator push replacement), listener có thể leak.

**Code hiện tại:**
```dart
// login_page.dart:31-35
@override
void initState() {
  super.initState();
  _loadSavedCredentials();
  context.read<AuthProvider>().addListener(_redirectIfAuthed);  // Thêm listener
}

// login_page.dart:55-63
@override
void dispose() {
  context.read<AuthProvider>().removeListener(_redirectIfAuthed);  // Remove
  _serverUrlCtrl.dispose();
  ...
  super.dispose();
}
```

**Vấn đề:** `context.read()` lấy provider từ `ProviderScope` cha. Nếu `LoginPage` unmount mà `AuthProvider` vẫn sống (là singleton/app-level), listener vẫn đăng ký → memory leak nhẹ.

**Khuyến nghị fix:** Dùng `Provider.of<AuthProvider>(context, listen: false)` thay vì `context.read()` để explicit, hoặc dùng `ChangeNotifierProxyProvider` pattern. Hoặc đơn giản: dùng `Stream`/`ValueNotifier` thay vì `ChangeNotifier` + listener manual.

---

### A12: ServerUrlField: validator không chạy khi user paste/autofill
**File:** `lib/features/auth/widgets/server_url_field.dart:33-48`  
**Mức độ:** **Medium** | **Loại:** UI/Validation

**Mô tả:**  
`TextFormField` validator chỉ chạy khi:
- User submit form (`_formKey.currentState!.validate()`)
- `onChanged` trigger `setState` → `_error` update (visual chỉ)

**Khi user paste/autofill:** `onChanged` fire → `_error` update UI. **NHƯNG** Form validation state **không cập nhật** → `_formKey.currentState!.validate()` vẫn trả true nếu field trước đó valid.

**Code hiện tại:**
```dart
// server_url_field.dart:43-47
onChanged: (val) {
  setState(() => _error = _validate(val));  // Chỉ update _error state
  widget.onChanged?.call(val);
},
validator: _validate,  // Chỉ dùng khi form.validate()
```

**Khuyến nghị fix:** Dùng `TextInputFormatter` hoặc force validate form:
```dart
onChanged: (val) {
  setState(() => _error = _validate(val));
  // Force form re-validate field này
  widget.onChanged?.call(val);
  // Optional: trigger form validation nếu cần immediate feedback
  // _formKey.currentState?.validate();  // Cần access formKey
}
```

Hoặc đơn giản: accept behavior này (validator chỉ chạy khi submit) - đây là Flutter default.

---

### A13: AuthProvider: status chuyển `error` nhưng không auto-clear khi user sửa form
**File:** `lib/features/auth/providers/auth_provider.dart:30-58`, `lib/features/auth/pages/login_page.dart:124-132`  
**Mức độ:** **Low** | **Loại:** UX

**Mô tả:**  
Login fail → status = `error` → hiển thị `ErrorView`. User sửa form (thêm username, sửa pass) → ErrorView **vẫn hiển thị** cho đến khi user bấm "Đóng" hoặc click Login lại.

**Mong đợi:** Error auto-hide khi user bắt đầu nhập lại form.

**Khuyến nghị fix:**
```dart
// auth_provider.dart - thêm method
void onFormChanged() {
  if (_status == AuthStatus.error) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}

// login_page.dart - gọi khi field change
TextFormField(
  onChanged: (_) => context.read<AuthProvider>().onFormChanged(),
  ...
)
```

---

### A14: Biometric login: không clear error message khi biometric fail
**File:** `lib/features/auth/providers/auth_provider.dart:61-69`  
**Mức độ:** **Low** | **Loại:** UX

**Mô tả:**  
`loginWithBiometric()` fail → set `_errorMessage = 'Xác thực sinh trắc học thất bại.'`. Nhưng nếu user sau đó bấm nút Login thường → `_errorMessage` **không clear** → hiển thị lỗi biometric cũ.

**Code hiện tại:**
```dart
// auth_provider.dart:61-69
Future<void> loginWithBiometric() async {
  _status = AuthStatus.loading;
  notifyListeners();
  final success = await _authService.loginWithBiometric();
  _status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  if (!success) _errorMessage = 'Xác thực sinh trắc học thất bại.';  // Set error
  notifyListeners();
}

// login(): clear error ở đầu
Future<void> login({...}) async {
  _status = AuthStatus.loading;
  _errorMessage = null;  // Clear error
  notifyListeners();
  ...
}
```

**Vấn đề:** `login()` clear error, nhưng **user có thể không gọi login()** sau biometric fail (chỉ xem lỗi rồi thoát). Error message dính lâu.

**Khuyến nghị:** Thêm `clearError()` call khi user interact với form, hoặc auto-clear sau timeout.

---

### A15: Logout: clear Isar DB có thể crash nếu Isar chưa init / đang dùng
**File:** `lib/core/auth/auth_service.dart:95-109`  
**Mức độ:** **Medium** | **Loại:** Crash/Logic

**Mô tả:**  
`logout()` gọi `IsarService.instance.db.clear()` trong writeTxn. **Vấn đề:**
1. `IsarService.instance.isInitialized` check nhưng **race condition**: giữa check và dùng, Isar có thể bị dispose bởi thread khác
2. `writeTxn` có thể throw nếu DB đang đóng hoặc corrupt
3. Không try-catch → crash app khi logout

**Code hiện tại:**
```dart
// auth_service.dart:102-108
if (IsarService.instance.isInitialized) {
  final isar = IsarService.instance.db;
  await isar.writeTxn(() async {
    await isar.clear();
  });
}
```

**Khuyến nghị fix:**
```dart
Future<void> logout() async {
  await _sessionManager.logout();
  await _storage.clearSession();
  await SyncManager.instance.dispose();
  
  // Safe clear Isar
  try {
    if (IsarService.instance.isInitialized) {
      final isar = IsarService.instance.db;
      // Double-check trong txn
      await isar.writeTxn(() async {
        if (IsarService.instance.isInitialized) {  // Check lại
          await isar.clear();
        }
      });
    }
  } catch (e, stack) {
    logger.e('Failed to clear Isar on logout', error: e, stackTrace: stack);
    // Không rethrow - logout vẫn thành công từ góc độ user
  }
}
```

---

### A16: Biometric: không handle lockout (LockoutPermanent/Temporary) → user bị khóa vĩnh viễn
**File:** `lib/core/auth/biometric_service.dart:30-45`, `lib/core/auth/auth_service.dart:84-92`  
**Mức độ:** **Critical** | **Loại:** Security/Crash | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
`local_auth` plugin có thể throw `PlatformException` với các code:
- `LockoutPermanent`: Quá nhiều lần fail → biometric bị khóa vĩnh viễn, **chỉ unlock được bằng device credential (PIN/pattern/password)**
- `LockoutTemporary`: Tạm khóa (thường 30s)
- `UserFallback`: User bấm "Use PIN/Password" (khi `biometricOnly: false`)
- `UserCancel`: User hủy dialog

**Code hiện tại swallow mọi exception (line 42-44):**
```dart
// biometric_service.dart
} catch (_) {
  return false;  // Mất hết thông tin error code!
}
```

**Hậu quả:**
- User bị `LockoutPermanent` → `authenticate()` luôn trả `false` → biometric login **không bao giờ hoạt động nữa**
- Không có cách clear lockout từ app (cần user vào Settings hệ thống)
- Không log error code → không thể auto-disable biometric hoặc hướng dẫn user

**Khuyến nghị fix:**
```dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

Future<bool> authenticate() async {
  try {
    final available = await isAvailable;
    if (!available) return false;

    return await _auth.authenticate(
      localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
      options: const AuthenticationOptions(
        biometricOnly: true,  // A05 fix
        stickyAuth: false,    // A21 fix
      ),
    );
  } on PlatformException catch (e) {
    switch (e.code) {
      case 'LockoutPermanent':
        logger.e('Biometric permanently locked out');
        await _storage.setBiometricEnabled(enabled: false); // Auto-disable
        // TODO: Show user dialog: "Biometric bị khóa, vui lòng dùng mật khẩu"
        return false;
      case 'LockoutTemporary':
        logger.w('Biometric temporarily locked out');
        // Có thể retry sau delay
        return false;
      case 'UserFallback':
        logger.i('User chose fallback');
        return false;
      case 'UserCancel':
        logger.i('User cancelled biometric');
        return false;
      default:
        logger.e('Biometric auth error', error: e);
        return false;
    }
  } catch (e, stack) {
    logger.e('Biometric auth unexpected error', error: e, stackTrace: stack);
    return false;
  }
}
```

---

### A17: SecureStorage race condition: concurrent writes không synchronized
**File:** `lib/core/auth/secure_storage.dart:23-44`  
**Mức độ:** **High** | **Loại:** Data Integrity | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
`saveSession()` dùng `Future.wait(writes)` để ghi multiple keys **song song**. `flutter_secure_storage` bên dưới dùng `SharedPreferences` (Android) / `Keychain` (iOS) — **không thread-safe** cho concurrent writes trên cùng instance.

**Rủi ro:**
- Ghi đồng thời nhiều key → data corruption, partial writes
- Key bị ghi đè, mất session data
- Khó reproduce nhưng có thể xảy ra khi: `login()` + `tryRestoreSession()` cùng lúc, hoặc multiple `saveSession` call

**Code hiện tại:**
```dart
// secure_storage.dart:32-43
final writes = <Future<void>>[
  _storage.write(key: _keyServerUrl, value: serverUrl),
  _storage.write(key: _keyDatabase, value: database),
  ...
];
await Future.wait(writes);  // Race condition!
```

**Khuyến nghị fix:** Sequential writes hoặc lock:
```dart
// Option 1: Sequential (đơn giản, an toàn)
Future<void> saveSession({...}) async {
  await _storage.write(key: _keyServerUrl, value: serverUrl);
  await _storage.write(key: _keyDatabase, value: database);
  await _storage.write(key: _keyUsername, value: username);
  await _storage.write(key: _keySessionId, value: sessionId);
  await _storage.write(key: _keyUserId, value: userId.toString());
  await _storage.write(key: _keyLocale, value: locale);
  if (password != null) {
    await _storage.write(key: _keyPassword, value: password);
  }
}

// Option 2: Lock (giữ performance nếu cần)
final _writeLock = Lock();
Future<void> saveSession({...}) async {
  await _writeLock.synchronized(() async {
    await Future.wait(writes);
  });
}
```

---

### A18: Locale load failure khi restore session → app dùng locale sai / crash
**File:** `lib/core/auth/auth_service.dart:76-78`, `lib/core/locale/locale_service.dart`  
**Mức độ:** **Medium** | **Loại:** Crash/Logic

**Mô tả:**  
`tryRestoreSession()` load `locale` từ SecureStorage và gọi `LocaleService.instance.setLocale(locale)` (line 77). Nếu:
- `locale` null/empty → setLocale có thể crash hoặc set sai
- `locale` giá trị không hợp lệ (không support) → MaterialApp locale resolution fail
- `LocaleService` chưa init → call trên singleton chưa ready

**Code hiện tại:**
```dart
// auth_service.dart:76-78
if (restored && locale != null && locale.isNotEmpty) {
  LocaleService.instance.setLocale(locale);  // Không try-catch, không validate
}
```

**Khuyến nghị fix:**
```dart
if (restored && locale != null && locale.isNotEmpty) {
  try {
    // Validate locale format (e.g., 'vi_VN', 'en_US')
    final parts = locale.split('_');
    if (parts.length == 2) {
      await LocaleService.instance.setLocale(locale);
    } else {
      logger.w('Invalid locale format from storage: $locale');
      await LocaleService.instance.setLocale('vi_VN');
    }
  } catch (e, stack) {
    logger.e('Failed to set locale from restored session', error: e, stackTrace: stack);
    await LocaleService.instance.setLocale('vi_VN');
  }
}
```

---

### A19: BuildContext async gap: `context.go()` sau `await` không check `mounted` ở mọi nơi
**File:** `lib/features/auth/pages/login_page.dart:77-81`, `lib/features/auth/pages/splash_page.dart:27-33`  
**Mức độ:** **Medium** | **Loại:** Crash/Logic | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
Sau `await` async operation, widget có thể đã unmount (user back, hot reload, app kill). Dùng `context.go()` mà không check `mounted` → **crash: `setState() called after dispose()` hoặc `BuildContext` không hợp lệ.**

**LoginPage (line 77-81):** Có check `if (!mounted) return;` nhưng **sau đó** lại dùng `context.read<AuthProvider>()` và `context.go()` — nếu unmount giữa lúc check và lúc go → crash.

**SplashPage (line 27-33):** **Không có check `mounted` nào** sau `await auth.initialize()`.

```dart
// splash_page.dart:23-34
Future<void> _init() async {
  final auth = context.read<AuthProvider>();
  await auth.initialize();  // Có thể mất vài giây
  
  // MISSING: if (!mounted) return;
  if (auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);  // CRASH nếu unmounted
  } else {
    context.go(RouteNames.login);
  }
}
```

**Khuyến nghị fix:** Luôn check `mounted` ngay sau `await`:
```dart
Future<void> _init() async {
  final auth = context.read<AuthProvider>();
  await auth.initialize();
  
  if (!mounted) return;  // ESSENTIAL
  
  if (auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);
  } else {
    context.go(RouteNames.login);
  }
}
```

---

### A20: Animation controller leak: `LoadingOverlay` dùng `flutter_spinkit` không dispose
**File:** `lib/shared/widgets/loading_overlay.dart:21-24`  
**Mức độ:** **Low** | **Loại:** Memory

**Mô tả:**  
`SpinKitFadingCircle` (từ `flutter_spinkit`) tạo `AnimationController` nội bộ. Khi `LoadingOverlay` bị remove khỏi tree (loading done), controller **không được dispose** → leak memory, tickers still running.

**Code hiện tại:**
```dart
// loading_overlay.dart:18-24
child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const SpinKitFadingCircle(  // Tạo AnimationController nội bộ
      color: AppColors.primaryLight,
      size: 52,
    ),
```

**Khuyến nghị fix:** Dùng `SpinKitFadingCircle` với `controller` parameter hoặc custom spinner tự quản lý lifecycle:
```dart
// Option 1: Custom spinner với SingleTickerProviderStateMixin
class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({super.key, this.color, this.size});
  final Color? color;
  final double? size;

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();  // Proper cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: Icon(Icons.sync, color: widget.color, size: widget.size),
    );
  }
}
```

---

### A21: Biometric `stickyAuth: true` gây rò rỉ context khi app background
**File:** `lib/core/auth/biometric_service.dart:38-39`  
**Mức độ:** **Medium** | **Loại:** UX/Logic

**Mô tả:**  
`AuthenticationOptions(stickyAuth: true)` giữ biometric dialog khi app chuyển background (home button, incoming call). Khi app resume, dialog vẫn hiện — **NHƯNG** Flutter context có thể đã thay đổi, dẫn đến:
- Dialog hiển thị trên route cũ (không còn tồn tại)
- Callback return vào void context
- Memory leak do dialog không dismiss đúng

**Khuyến nghị fix:** Set `stickyAuth: false` (default). Nếu cần giữ auth khi background, handle tại app level (`AppLifecycleListener`).

```dart
options: const AuthenticationOptions(
  biometricOnly: true,
  stickyAuth: false,  // Default, an toàn hơn
),
```

---

### A22: Silent re-auth (`_tryReAuthenticate`) swallow exception, không log chi tiết
**File:** `lib/core/api/odoo_session_manager.dart:235-288`  
**Mức độ:** **Medium** | **Loại:** Observability

**Mô tả:**  
`_tryReAuthenticate()` catch tất cả exception (`on OdooException catch (e)` và `catch (e)`) → **chỉ log `logger.e` generic** → mất stack trace, mất error code cụ thể. Khó debug khi re-auth fail.

**Code hiện tại (line 279-284):**
```dart
} on OdooException catch (e) {
  logger.e('Silent re-authentication failed', error: e);
  return false;
} catch (e) {
  logger.e('Silent re-authentication failed', error: e);
  return false;
}
```

**Khuyến nghị fix:** Log đầy đủ error + stack trace, phân loại error type:
```dart
} on OdooException catch (e, stack) {
  logger.e('Silent re-auth failed: OdooException', error: e, stackTrace: stack);
  // Có thể check e.message để phân loại: wrong password, user disabled, etc.
  return false;
} catch (e, stack) {
  logger.e('Silent re-auth failed: Unexpected', error: e, stackTrace: stack);
  return false;
}
```

---

### A23: ServerUrlField validator không chạy initial validation (form validate lần đầu)
**File:** `lib/features/auth/widgets/server_url_field.dart:32-48`, `lib/features/auth/pages/login_page.dart:135-139`  
**Mức độ:** **Medium** | **Loại:** Validation

**Mô tả:**  
`ServerUrlField` dùng `onChanged` để update `_error` state (visual). **NHƯNG** validator của `TextFormField` chỉ chạy khi:
1. User interact (type, paste)
2. Gọi `_formKey.currentState!.validate()`

Khi form load lần đầu với giá trị pre-filled (từ SecureStorage), **validator không chạy** → `_error` = null → hiển thị không có lỗi dù URL sai format.

**Code hiện tại:**
```dart
// server_url_field.dart:43-47
onChanged: (val) {
  setState(() => _error = _validate(val));  // Chỉ update visual error
  widget.onChanged?.call(val);
},
validator: _validate,  // Chỉ chạy khi validate() được gọi
```

**Khuyến nghị fix:** Trigger validate sau khi set initial value, hoặc dùng `autovalidateMode: AutovalidateMode.onUserInteraction` (default) + force validate lần đầu:
```dart
// login_page.dart trong _loadSavedCredentials:
Future<void> _loadSavedCredentials() async {
  final creds = await SecureStorageService.instance.loadSavedCredentials();
  if (!mounted) return;
  setState(() {
    _serverUrlCtrl.text = creds['serverUrl'] ?? 'https://';
    _databaseCtrl.text = creds['database'] ?? '';
    _usernameCtrl.text = creds['username'] ?? '';
  });
  // Force validate after initial load
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _formKey.currentState?.validate();
  });
}
```

---

### A24: Login API không có timeout → treo vô hạn khi network chậm/mất kết nối
**File:** `lib/core/api/odoo_session_manager.dart:43-125`, `lib/core/api/odoo_client.dart`  
**Mức độ:** **High** | **Loại:** Reliability | **Trạng thái:** ✅ **FIXED**

**Mô tả:**  
`OdooSessionManager.authenticate()` gọi `client.authenticate()` (odoo_rpc) **không có timeout**. Nếu server chậm, mất mạng, hoặc DNS fail → app **treo vô hạn** tại `LoadingOverlay`, user không thể cancel, không có feedback.

**Rủi ro:** UX cực tệ, user force-kill app.

**Khuyến nghị fix:** Wrap call với timeout:
```dart
// odoo_session_manager.dart
Future<OdooSessionData> authenticate({...}) async {
  try {
    OdooApiClient.instance.initialize(serverUrl);
    final client = OdooApiClient.instance.client;

    final session = await client.authenticate(database, username, password)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw OdooConnectionException('Kết nối quá thời gian (30s). Kiểm tra mạng.');
    });
    ...
  } on TimeoutException catch (_) {
    throw OdooConnectionException('Kết nối quá thời gian. Vui lòng thử lại.');
  } ...
}
```

Hoặc config timeout ở `OdooApiClient` level (nếu `odoo_rpc` support).

---

### A25: Biometric availability không refresh sau khi user bật trong Settings
**File:** `lib/features/auth/providers/auth_provider.dart:20-22`, `lib/core/auth/biometric_service.dart:11-17`  
**Mức độ:** **Low** | **Loại:** UX/Logic

**Mô tả:**  
`AuthProvider.initialize()` gọi `_authService.isBiometricAvailable` **một lần** khi app start. Nếu user:
1. Mở app → biometric chưa bật → `_isBiometricAvailable = false`
2. Vào Settings bật FaceID/Fingerprint
3. Quay lại app → button biometric **vẫn ẩn** (không refresh)

**Code hiện tại:**
```dart
// auth_provider.dart:20-22
Future<void> initialize() async {
  _isBiometricAvailable = await _authService.isBiometricAvailable;
  notifyListeners();
  ...
}
```

**Khuyến nghị fix:** Listen `AppLifecycleState.resumed` để refresh:
```dart
// auth_provider.dart
late final AppLifecycleListener _lifecycleListener;

@override
void initialize() async {
  _isBiometricAvailable = await _authService.isBiometricAvailable;
  notifyListeners();

  _lifecycleListener = AppLifecycleListener(
    onResume: () async {
      _isBiometricAvailable = await _authService.isBiometricAvailable;
      notifyListeners();
    },
  );
  ...
}

@override
void dispose() {
  _lifecycleListener.dispose();
  super.dispose();
}
```

---

### A26: `restoreSession()` catch-all exception → silent fail, khó debug
**File:** `lib/core/api/odoo_session_manager.dart:133-179`  
**Mức độ:** **Medium** | **Loại:** Observability

**Mô tả:**  
`restoreSession()` dùng `catch (_)` (line 175) → **swallow mọi exception không log** → khi restore fail, không biết lý do (session data corrupt, serverVersion parse error, Isar issue, etc.).

**Code hiện tại:**
```dart
// odoo_session_manager.dart:175-178
} catch (_) {  // Catch-all, no logging!
  _currentSession = null;
  return false;
}
```

**Khuyến nghị fix:** Log error chi tiết:
```dart
} catch (e, stack) {
  logger.e('restoreSession failed', error: e, stackTrace: stack);
  _currentSession = null;
  return false;
}
```

---

### A27: Biometric login success không clear error message từ lần fail trước
**File:** `lib/features/auth/providers/auth_provider.dart:61-69`  
**Mức độ:** **Low** | **Loại:** UX

**Mô tả:**  
`loginWithBiometric()` success → set `_status = AuthStatus.authenticated` nhưng **không clear `_errorMessage`**. Nếu lần trước biometric fail (set error message), lần sau success → error message cũ **vẫn hiển thị** cho đến khi user dismiss hoặc login lại.

**Code hiện tại:**
```dart
// auth_provider.dart:65-67
_status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
if (!success) _errorMessage = 'Xác thực sinh trắc học thất bại.';
// MISSING: if (success) _errorMessage = null;
notifyListeners();
```

**Khuyến nghị fix:**
```dart
_status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
if (success) {
  _errorMessage = null;  // Clear error on success
} else {
  _errorMessage = 'Xác thực sinh trắc học thất bại.';
}
notifyListeners();
```

---

### A28: Form validation state stale khi user clear field sau khi đã valid
**File:** `lib/features/auth/widgets/server_url_field.dart:32-48`, `lib/features/auth/pages/login_page.dart:135-139`  
**Mức độ:** **Low** | **Loại:** UI/Validation

**Mô tả:**  
`ServerUrlField` dùng `_error` state riêng (visual) + `validator` của `TextFormField`. Khi user:
1. Nhập URL đúng → validator pass, `_error = null`
2. Clear field (backspace hết) → `onChanged` fire → `_validate('')` return error → `_error` set
3. **NHƯNG** `TextFormField` internal validation state **không update** cho đến khi re-validate

Khi bấm Login → `_formKey.currentState!.validate()` chạy lại → OK. Nhưng visual error hiển thị đúng.

Vấn đề nhỏ: `_error` state và `FormField` validation state có thể **out of sync** momentary.

**Khuyến nghị fix:** Bỏ `_error` state riêng, dùng hoàn toàn `validator` + `autovalidateMode: AutovalidateMode.onUserInteraction`. Hoặc sync chặt hơn.

---

### A29: `AuthProvider.initialize()` gọi `_authService.isBiometricAvailable` race với `tryRestoreSession()`
**File:** `lib/features/auth/providers/auth_provider.dart:20-28`  
**Mức độ:** **Medium** | **Loại:** Race Condition

**Mô tả:**  
`initialize()` chạy:
```dart
_isBiometricAvailable = await _authService.isBiometricAvailable;
notifyListeners();  // UI rebuild

final restored = await _authService.tryRestoreSession();
_status = restored ? AuthStatus.authenticated : AuthStatus.unauthenticated;
notifyListeners();
```

Hai `notifyListeners()` liên tiếp → **2 lần rebuild** UI trong lúc splash/login đang load. Nếu `tryRestoreSession()` lâu, user thấy biometric button flash hiện/hide.

**Khuyến nghị fix:** Gom thành 1 `notifyListeners()`:
```dart
Future<void> initialize() async {
  _isBiometricAvailable = await _authService.isBiometricAvailable;
  final restored = await _authService.tryRestoreSession();
  _status = restored ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  notifyListeners();  // Single rebuild
}
```

---

### A30: Logout: `SyncManager.instance.dispose()` có thể throw nếu chưa init
**File:** `lib/core/auth/auth_service.dart:95-109`, `lib/core/database/sync_manager.dart`  
**Mức độ:** **Medium** | **Loại:** Crash/Logic

**Mô tả:**  
`AuthService.logout()` gọi `SyncManager.instance.dispose()` (line 100) **không check initialized** và **không try-catch**. Nếu `SyncManager` chưa được init (user logout trước khi login, hoặc init fail) → có thể throw exception → logout process dừng giữa chừng, session không clear được.

**Code hiện tại:**
```dart
// auth_service.dart:99-100
// FIX C04 + C05: Dispose SyncManager resources, KHÔNG dispose OdooApiClient singleton
await SyncManager.instance.dispose();  // Có thể throw!
```

**Khuyến nghị fix:**
```dart
// Safe dispose
try {
  if (SyncManager.instance.isInitialized) {  // Thêm getter này
    await SyncManager.instance.dispose();
  }
} catch (e, stack) {
  logger.e('SyncManager dispose failed on logout', error: e, stackTrace: stack);
  // Continue logout
}
```

---

| ID | Gợi ý | File | Lợi ích |
|----|-------|------|---------|
| S01 | Thêm `autofillHints` cho form login (username, password) | `login_page.dart` | UX tốt hơn, password manager hoạt động |
| S02 | Thêm `textInputAction: TextInputAction.next` cho các field, `done` cho password | `login_page.dart` | Keyboard navigation mượt |
| S03 | LoadingOverlay: thêm barrierDismissible=false (mặc định) | `loading_overlay.dart` | Tránh user tap dismiss loading |
| S04 | AuthProvider: thêm `loginWithSavedCredentials()` cho auto-login khi app resume | `auth_provider.dart` | Smooth UX |
| S05 | Biometric: cache `isAvailable` kết quả, không gọi lại mỗi lần | `auth_provider.dart:20`, `biometric_service.dart:11` | Performance |
| S06 | ServerUrlField: auto-append `https://` khi user nhập không có scheme | `server_url_field.dart` | UX友好 |

---

## 📋 Checklist Fix Priority

### 🔴 Critical (Fix ngay)
- [ ] **A02** - Uri.tryParse force-unwrap crash
- [ ] **A09** - Password plaintext trong SecureStorage
- [ ] **A16** - Biometric lockout (LockoutPermanent) → user bị khóa vĩnh viễn

### 🟠 High (Fix trong sprint này)
- [ ] **A01** - Keyboard overflow handling
- [ ] **A04** - Biometric key invalidated handling
- [ ] **A08** - Optimistic restore không verify session
- [ ] **A17** - SecureStorage race condition: concurrent writes
- [ ] **A24** - Login API không có timeout → treo vô hạn

### 🟡 Medium (Fix sớm)
- [ ] **A03** - Login button race condition
- [ ] **A06** - clearError không reset status
- [ ] **A07** - Double redirect race
- [ ] **A10** - SplashPage crash handling
- [ ] **A12** - Validator paste/autofill
- [ ] **A15** - Logout Isar clear crash
- [ ] **A18** - Locale load failure khi restore session
- [ ] **A19** - BuildContext async gap: context.go() sau await
- [ ] **A21** - Biometric stickyAuth: true rò rỉ context
- [ ] **A22** - Silent re-auth swallow exception, không log chi tiết
- [ ] **A23** - ServerUrlField validator không chạy initial validation
- [ ] **A26** - restoreSession() catch-all exception silent fail
- [ ] **A29** - AuthProvider.initialize() double notifyListeners race
- [ ] **A30** - Logout: SyncManager.dispose() có thể throw nếu chưa init

### 🟢 Low (Technical debt)
- [ ] **A05** - biometricOnly: true
- [ ] **A11** - Listener memory leak edge case
- [ ] **A13** - Auto-clear error khi sửa form
- [ ] **A14** - Biometric error message dính
- [ ] **A20** - Animation controller leak: LoadingOverlay spinKit
- [ ] **A25** - Biometric availability không refresh sau Settings
- [ ] **A27** - Biometric login success không clear error message cũ
- [ ] **A28** - Form validation state stale khi clear field

---

## 📝 Ghi chú Implementation

### Về SecureStorage password removal (A09)
Cần migration strategy:
1. Version code bump
2. Trong `main.dart` hoặc `AuthService.initialize()`: xóa key password cũ
3. Update `OdooSessionManager._tryReAuthenticate()` để **không dùng password từ storage**
4. Biometric login: chỉ unlock sessionId, không cần password

### Về Biometric security (A04, A05)
- `biometricOnly: true` bắt buộc
- Handle `LockoutPermanent` → tự disable biometric, force password login
- Cân nhắc: có cho phép "Use device credential" (PIN) không? → **Không** cho app enterprise

### Về Session restore (A08)
Offline-first design đúng, nhưng cần:
- Background verify session validity
- Nếu expired → silent logout + redirect login
- Giữ UX mượt: không chặn màn splash

### Về Biometric lockout (A16)
- Phải handle `LockoutPermanent` / `LockoutTemporary` / `UserFallback` / `UserCancel`
- Auto-disable biometric khi `LockoutPermanent`
- Show user-friendly dialog hướng dẫn dùng mật khẩu

### Về SecureStorage race condition (A17)
- Sequential writes đơn giản và an toàn
- Hoặc dùng `async` lock package (`synchronized`)

### Về BuildContext async gaps (A19)
- Luôn check `mounted` ngay sau `await`
- Cân nhắc dùng `go_router` redirect thay vì manual `context.go`

### Về Animation leak (A20)
- Replace `flutter_spinkit` bằng custom `SingleTickerProviderStateMixin` spinner
- Hoặc fork spinKit để expose controller dispose

---

*Report reviewed & extended by SKEPTIC agent - Fieldforce Worker Code Review*
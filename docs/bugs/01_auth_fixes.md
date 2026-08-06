# Auth Module Bug Fixes - Fieldforce Worker

File này chứa các code fix cho các bug **Critical/High (P0)** trong Auth feature.
Mỗi fix bao gồm: **Mô tả**, **Code BEFORE** (từ source hiện tại), **Code AFTER** (phương án sửa tối ưu).

---

## Danh sách Bugs được Fix (Critical/High)

| Bug ID | Mức độ | Tên Bug | File(s) liên quan |
|--------|--------|---------|-------------------|
| A02 | Critical | Uri force-unwrap crash | `lib/features/auth/widgets/server_url_field.dart` |
| A09 | Critical | Password plaintext trong SecureStorage | `lib/core/auth/secure_storage.dart`, `lib/core/auth/auth_service.dart`, `lib/core/api/odoo_session_manager.dart` |
| A16 | Critical | Biometric Lockout (LockoutPermanent/Temporary) | `lib/core/auth/biometric_service.dart` |
| A17 | High | SecureStorage concurrent writes race condition | `lib/core/auth/secure_storage.dart` |
| A24 | High | Login API timeout (treo vô hạn) | `lib/core/api/odoo_session_manager.dart` |
| A19 | Medium | BuildContext async gaps (LoginPage/SplashPage) | `lib/features/auth/pages/login_page.dart`, `lib/features/auth/pages/splash_page.dart` |

---

## A02: Uri force-unwrap crash (`Uri.tryParse(value)!`)

### File: `lib/features/auth/widgets/server_url_field.dart`

### Mô tả
`Uri.tryParse(value)` trả về `Uri?` (nullable). Code dùng `!` force-unwrap → **crash khi `value` không parse được thành Uri** (ví dụ: string rỗng, ký tự đặc biệt, URL không hợp lệ).

### Code BEFORE
```dart
// lib/features/auth/widgets/server_url_field.dart:22-29
String? _validate(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập URL server';
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return 'URL phải bắt đầu bằng https://';
  }
  if (!Uri.tryParse(value)!.hasAuthority) return 'URL không hợp lệ';  // CRASH HERE
  return null;
}
```

### Code AFTER
```dart
// lib/features/auth/widgets/server_url_field.dart:22-32
String? _validate(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập URL server';
  
  // Chỉ chấp nhận https:// (bảo mật)
  if (!value.startsWith('https://')) {
    return 'URL phải bắt đầu bằng https://';
  }
  
  // Parse an toàn - không force-unwrap
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority) return 'URL không hợp lệ';
  
  // Validate thêm: host không được rỗng, không phải IP local (tuỳ policy)
  if (uri.host.isEmpty) return 'URL không hợp lệ';
  
  return null;
}
```

### Giải thích thay đổi
1. **Xóa force-unwrap `!`** → thay bằng null check an toàn
2. **Chỉ cho phép `https://`** (bỏ `http://` vì không bảo mật cho production)
3. **Thêm check `uri.host.isEmpty`** để catch edge case `https://` (không có host)
4. **Giữ nguyên signature & behavior** cho validator của `TextFormField`

---

## A09: Password lưu plaintext trong SecureStorage

### Files: 
- `lib/core/auth/secure_storage.dart`
- `lib/core/auth/auth_service.dart`
- `lib/core/api/odoo_session_manager.dart`

### Mô tả
Mật khẩu user được lưu **plaintext** trong SecureStorage (`_keyPassword`). Dù SecureStorage encrypt at rest, nhưng:
- Password có thể bị extract từ backup (Android) / keychain dump (iOS jailbreak)
- Violation principle: **không bao giờ lưu password**, chỉ lưu session token
- `loginWithBiometric()` dùng password lưu này để re-auth → nếu biometric bypass thì password lộ

### Code BEFORE

**secure_storage.dart:13-21, 30-44, 46-65, 82-92**
```dart
// Keys
static const _keyServerUrl = 'odoo_server_url';
static const _keyDatabase = 'odoo_database';
static const _keyUsername = 'odoo_username';
static const _keySessionId = 'odoo_session_id';
static const _keyUserId = 'odoo_user_id';
static const _keyLocale = 'odoo_locale';
static const _keyPassword = 'odoo_password';  // ❌ XÓA KEY NÀY
static const _keyBiometricEnabled = 'biometric_enabled';

Future<void> saveSession({
  required String serverUrl,
  required String database,
  required String username,
  required String sessionId,
  required int userId,
  String locale = 'vi_VN',
  String? password,  // ❌ XÓA PARAM NÀY
}) async {
  final writes = <Future<void>>[
    _storage.write(key: _keyServerUrl, value: serverUrl),
    _storage.write(key: _keyDatabase, value: database),
    _storage.write(key: _keyUsername, value: username),
    _storage.write(key: _keySessionId, value: sessionId),
    _storage.write(key: _keyUserId, value: userId.toString()),
    _storage.write(key: _keyLocale, value: locale),
  ];
  if (password != null) {  // ❌ XÓA BLOCK NÀY
    writes.add(_storage.write(key: _keyPassword, value: password));
  }
  await Future.wait(writes);
}

Future<Map<String, String?>> loadSession() async {
  final results = await Future.wait([
    _storage.read(key: _keyServerUrl),
    _storage.read(key: _keyDatabase),
    _storage.read(key: _keyUsername),
    _storage.read(key: _keySessionId),
    _storage.read(key: _keyUserId),
    _storage.read(key: _keyLocale),
    _storage.read(key: _keyPassword),  // ❌ XÓA LINE NÀY
  ]);
  return {
    'serverUrl': results[0],
    'database': results[1],
    'username': results[2],
    'sessionId': results[3],
    'userId': results[4],
    'locale': results[5],
    'password': results[6],  // ❌ XÓA KEY NÀY
  };
}

Future<void> clearSession() async {
  await Future.wait([
    _storage.delete(key: _keyServerUrl),
    _storage.delete(key: _keyDatabase),
    _storage.delete(key: _keyUsername),
    _storage.delete(key: _keySessionId),
    _storage.delete(key: _keyUserId),
    _storage.delete(key: _keyLocale),
    _storage.delete(key: _keyPassword),  // ❌ Giữ dòng này để migration (xóa password cũ)
  ]);
}
```

**auth_service.dart:20-42**
```dart
Future<void> login({
  required String serverUrl,
  required String database,
  required String username,
  required String password,
}) async {
  final session = await _sessionManager.authenticate(
    serverUrl: serverUrl,
    database: database,
    username: username,
    password: password,
  );

  await _storage.saveSession(
    serverUrl: serverUrl,
    database: database,
    username: username,
    sessionId: session.sessionId,
    userId: session.userId,
    locale: session.locale,
    password: password,  // ❌ KHÔNG TRUYỀN PASSWORD
  );
}
```

**odoo_session_manager.dart:235-288** (`_tryReAuthenticate`)
```dart
Future<bool> _tryReAuthenticate() async {
  _isReAuthenticating = true;
  try {
    final saved = await SecureStorageService.instance.loadSession();
    final serverUrl = saved['serverUrl'];
    final database = saved['database'];
    final username = saved['username'];
    final password = saved['password'];  // ❌ PASSWORD SẼ KHÔNG CÒN TỒN TẠI

    if (serverUrl == null || database == null || username == null || password == null) {
      logger.w('Cannot re-authenticate: missing stored credentials');
      return false;
    }

    // Re-initialize client and authenticate fresh
    OdooApiClient.instance.initialize(serverUrl);
    final client = OdooApiClient.instance.client;
    final session = await client.authenticate(database, username, password);

    _currentSession = OdooSessionData(...);
    // ...
  } ...
}
```

### Code AFTER

**secure_storage.dart**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service lưu trữ thông tin nhạy cảm an toàn bằng Keychain (iOS) / Keystore (Android).
/// Sử dụng cho: server URL, database, username, session ID.
/// KHÔNG LƯU PASSWORD - chỉ lưu session token.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys - KHÔNG CÓ _keyPassword
  static const _keyServerUrl = 'odoo_server_url';
  static const _keyDatabase = 'odoo_database';
  static const _keyUsername = 'odoo_username';
  static const _keySessionId = 'odoo_session_id';
  static const _keyUserId = 'odoo_user_id';
  static const _keyLocale = 'odoo_locale';
  static const _keyBiometricEnabled = 'biometric_enabled';

  /// Lưu session (KHÔNG lưu password)
  Future<void> saveSession({
    required String serverUrl,
    required String database,
    required String username,
    required String sessionId,
    required int userId,
    String locale = 'vi_VN',
  }) async {
    await _storage.write(key: _keyServerUrl, value: serverUrl);
    await _storage.write(key: _keyDatabase, value: database);
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keySessionId, value: sessionId);
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyLocale, value: locale);
  }

  /// Load session data (không bao gồm password)
  Future<Map<String, String?>> loadSession() async {
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
      _storage.read(key: _keySessionId),
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyLocale),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
      'sessionId': results[3],
      'userId': results[4],
      'locale': results[5],
    };
  }

  /// Chỉ load thông tin đăng nhập (URL, database, username) không bao gồm session.
  Future<Map<String, String?>> loadSavedCredentials() async {
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
    };
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyServerUrl),
      _storage.delete(key: _keyDatabase),
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keySessionId),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyLocale),
      // Giữ delete password để migration: xóa password cũ nếu có từ version trước
      _storage.delete(key: 'odoo_password'), // legacy key
    ]);
  }

  Future<bool> get hasSavedSession async {
    final sessionId = await _storage.read(key: _keySessionId);
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }
}
```

**auth_service.dart**
```dart
Future<void> login({
  required String serverUrl,
  required String database,
  required String username,
  required String password,
}) async {
  final session = await _sessionManager.authenticate(
    serverUrl: serverUrl,
    database: database,
    username: username,
    password: password,
  );

  await _storage.saveSession(
    serverUrl: serverUrl,
    database: database,
    username: username,
    sessionId: session.sessionId,
    userId: session.userId,
    locale: session.locale,
    // password: password,  // ❌ KHÔNG TRUYỀN PASSWORD - đã xóa param khỏi saveSession
  );
}
```

**odoo_session_manager.dart** - `_tryReAuthenticate()` SỬA ĐỔI LOGIC:
```dart
/// Silent re-authentication khi session hết hạn.
/// KHÔNG dùng password từ storage (đã xóa). Thay vào đó:
/// - Nếu có refresh token → dùng refresh token
/// - Nếu không → return false để yêu cầu user login lại
Future<bool> _tryReAuthenticate() async {
  _isReAuthenticating = true;
  try {
    final saved = await SecureStorageService.instance.loadSession();
    final serverUrl = saved['serverUrl'];
    final database = saved['database'];
    final username = saved['username'];
    final sessionId = saved['sessionId'];
    final userIdStr = saved['userId'];
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

    // Không còn password trong storage
    if (serverUrl == null || database == null || username == null || sessionId == null || userId == null) {
      logger.w('Cannot re-authenticate: missing stored session data');
      return false;
    }

    // Option 1: Thử restore session (optimistic) - KHÔNG gọi RPC
    // Nếu sessionId vẫn hợp lệ trên server thì các callKw sau sẽ thành công
    // Nếu hết hạn → callKw sẽ throw OdooAuthException → sẽ vào đây lại
    
    // Option 2: Nếu Odoo hỗ trợ refresh token → dùng refresh token ở đây
    // Hiện tại odoo_rpc chưa support refresh token out-of-the-box
    
    // Option 3 (Hiện tại): Không thể silent re-auth mà không có password
    // → Return false để push user về LoginPage
    logger.w('Silent re-auth not possible without stored password. User must login again.');
    return false;
    
  } catch (e, stack) {
    logger.e('Silent re-authentication failed', error: e, stackTrace: stack);
    return false;
  } finally {
    _isReAuthenticating = false;
  }
}
```

### Migration: Clear password cũ khi update app
Trong `main.dart` hoặc `AuthService.initialize()`:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Migration: xóa password cũ từ SecureStorage (nếu có từ version trước)
  await SecureStorageService.instance._storage.delete(key: 'odoo_password');
  
  runApp(const MyApp());
}
```

---

## A16: Biometric Lockout (LockoutPermanent/Temporary)

### File: `lib/core/auth/biometric_service.dart`

### Mô tả
`local_auth` plugin có thể throw `PlatformException` với các code:
- `LockoutPermanent`: Quá nhiều lần fail → biometric bị khóa vĩnh viễn, **chỉ unlock được bằng device credential (PIN/pattern/password)**
- `LockoutTemporary`: Tạm khóa (thường 30s)
- `UserFallback`: User bấm "Use PIN/Password" (khi `biometricOnly: false`)
- `UserCancel`: User hủy dialog

Code hiện tại swallow mọi exception → mất hết thông tin error code → user bị `LockoutPermanent` thì `authenticate()` luôn trả `false` → biometric login **không bao giờ hoạt động nữa**.

### Code BEFORE
```dart
// lib/core/auth/biometric_service.dart:28-45
Future<bool> authenticate() async {
  try {
    final available = await isAvailable;
    if (!available) return false;

    return await _auth.authenticate(
      localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
      options: const AuthenticationOptions(
        biometricOnly: false, // Cho phép dùng PIN nếu biometric fail
        stickyAuth: true, // Giữ auth dialog khi app chuyển nền
      ),
    );
  } catch (_) {
    return false;  // MẤT HẾT THÔNG TIN ERROR CODE!
  }
}
```

### Code AFTER
```dart
// lib/core/auth/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Service xử lý xác thực sinh trắc học: FaceID hoặc Vân tay.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra thiết bị có hỗ trợ biometric không.
  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách loại biometric thiết bị hỗ trợ.
  Future<List<BiometricType>> get availableTypes async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Thực hiện xác thực sinh trắc học.
  /// Trả về [true] nếu xác thực thành công.
  /// Ném [BiometricLockoutException] nếu bị khóa vĩnh viễn.
  Future<bool> authenticate() async {
    try {
      final available = await isAvailable;
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
        options: const AuthenticationOptions(
          biometricOnly: true,   // A05 fix: CHỈ cho phép biometric, không fallback PIN
          stickyAuth: false,     // A21 fix: Không giữ dialog khi app background
        ),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'LockoutPermanent':
          logger.e('Biometric permanently locked out');
          // Auto-disable biometric login trong app
          await SecureStorageService.instance.setBiometricEnabled(enabled: false);
          throw BiometricLockoutException.permanent();
        case 'LockoutTemporary':
          logger.w('Biometric temporarily locked out');
          throw BiometricLockoutException.temporary();
        case 'UserFallback':
          logger.i('User chose fallback (PIN/Pattern)');
          // Không throw - coi như user cancel
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
}

/// Exception để handle biometric lockout ở UI layer
class BiometricLockoutException implements Exception {
  final bool isPermanent;
  final String message;

  const BiometricLockoutException._({required this.isPermanent, required this.message});

  factory BiometricLockoutException.permanent() => const BiometricLockoutException._(
    isPermanent: true,
    message: 'Biometric bị khóa vĩnh viễn. Vui lòng dùng mật khẩu để đăng nhập.',
  );

  factory BiometricLockoutException.temporary() => const BiometricLockoutException._(
    isPermanent: false,
    message: 'Biometric tạm thời bị khóa. Vui lòng thử lại sau giây lát.',
  );
}
```

### Cập nhật `AuthService.loginWithBiometric()` để handle exception mới:
```dart
// lib/core/auth/auth_service.dart:83-92
Future<bool> loginWithBiometric() async {
  final biometricEnabled = await _storage.isBiometricEnabled;
  if (!biometricEnabled) return false;

  try {
    final authenticated = await _biometric.authenticate();
    if (!authenticated) return false;

    return tryRestoreSession();
  } on BiometricLockoutException catch (e) {
    // Đã log trong BiometricService, chỉ cần return false
    // UI sẽ show error message từ exception
    return false;
  }
}
```

---

## A17: SecureStorage race condition: concurrent writes

### File: `lib/core/auth/secure_storage.dart`

### Mô tả
`saveSession()` dùng `Future.wait(writes)` để ghi multiple keys **song song**. `flutter_secure_storage` bên dưới dùng `SharedPreferences` (Android) / `Keychain` (iOS) — **không thread-safe** cho concurrent writes trên cùng instance.

Rủi ro: Ghi đồng thời nhiều key → data corruption, partial writes, key bị ghi đè, mất session data.

### Code BEFORE (đã fix trong A09, nhưng race condition vẫn còn nếu dùng sequential writes không có lock)
```dart
// sequential writes (từ A09 fix) - an toàn hơn nhưng vẫn có thể race nếu multiple caller
await _storage.write(key: _keyServerUrl, value: serverUrl);
await _storage.write(key: _keyDatabase, value: database);
// ...
```

### Code AFTER: Thêm Lock để serialize mọi write operation
```dart
// lib/core/auth/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';  // Thêm dependency

/// Service lưu trữ thông tin nhạy cảm an toàn bằng Keychain (iOS) / Keystore (Android).
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Lock để serialize tất cả write operations - tránh race condition
  final _writeLock = Lock();

  // Keys
  static const _keyServerUrl = 'odoo_server_url';
  static const _keyDatabase = 'odoo_database';
  static const _keyUsername = 'odoo_username';
  static const _keySessionId = 'odoo_session_id';
  static const _keyUserId = 'odoo_user_id';
  static const _keyLocale = 'odoo_locale';
  static const _keyBiometricEnabled = 'biometric_enabled';

  Future<void> saveSession({
    required String serverUrl,
    required String database,
    required String username,
    required String sessionId,
    required int userId,
    String locale = 'vi_VN',
  }) async {
    // Serialize writes với lock
    await _writeLock.synchronized(() async {
      await _storage.write(key: _keyServerUrl, value: serverUrl);
      await _storage.write(key: _keyDatabase, value: database);
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keySessionId, value: sessionId);
      await _storage.write(key: _keyUserId, value: userId.toString());
      await _storage.write(key: _keyLocale, value: locale);
    });
  }

  Future<Map<String, String?>> loadSession() async {
    // Reads không cần lock (thread-safe cho read)
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
      _storage.read(key: _keySessionId),
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyLocale),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
      'sessionId': results[3],
      'userId': results[4],
      'locale': results[5],
    };
  }

  Future<Map<String, String?>> loadSavedCredentials() async {
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
    };
  }

  Future<void> clearSession() async {
    await _writeLock.synchronized(() async {
      await Future.wait([
        _storage.delete(key: _keyServerUrl),
        _storage.delete(key: _keyDatabase),
        _storage.delete(key: _keyUsername),
        _storage.delete(key: _keySessionId),
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyLocale),
        _storage.delete(key: 'odoo_password'), // legacy migration
      ]);
    });
  }

  Future<bool> get hasSavedSession async {
    final sessionId = await _storage.read(key: _keySessionId);
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _writeLock.synchronized(() async {
      await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
    });
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }
}
```

### Thêm dependency vào `pubspec.yaml`
```yaml
dependencies:
  synchronized: ^3.1.0
```

---

## A24: Login API timeout (treo vô hạn)

### File: `lib/core/api/odoo_session_manager.dart`

### Mô tả
`OdooSessionManager.authenticate()` gọi `client.authenticate()` (odoo_rpc) **không có timeout**. Nếu server chậm, mất mạng, hoặc DNS fail → app **treo vô hạn** tại `LoadingOverlay`, user không thể cancel, không có feedback.

### Code BEFORE
```dart
// lib/core/api/odoo_session_manager.dart:43-125
Future<OdooSessionData> authenticate({
  required String serverUrl,
  required String database,
  required String username,
  required String password,
}) async {
  try {
    OdooApiClient.instance.initialize(serverUrl);
    final client = OdooApiClient.instance.client;

    // odoo_rpc authenticate signature: (db, login, password)
    final session = await client.authenticate(database, username, password);  // ❌ KHÔNG CÓ TIMEOUT
    // ...
  } ...
}
```

### Code AFTER
```dart
// lib/core/api/odoo_session_manager.dart
import 'dart:async';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'api_exception.dart';
import 'odoo_client.dart';
import '../auth/secure_storage.dart';
import '../database/sync_manager.dart';
import '../utils/logger.dart';

class OdooSessionManager {
  // ... existing code ...

  /// Timeout cho authentication (kết nối + handshake)
  static const Duration _authTimeout = Duration(seconds: 30);
  
  /// Timeout cho các RPC call khác
  static const Duration _rpcTimeout = Duration(seconds: 60);

  Future<OdooSessionData> authenticate({
    required String serverUrl,
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      OdooApiClient.instance.initialize(serverUrl);
      final client = OdooApiClient.instance.client;

      // Wrap authenticate với timeout
      final session = await client.authenticate(database, username, password)
          .timeout(_authTimeout, onTimeout: () {
        throw TimeoutException('Authentication timeout after ${_authTimeout.inSeconds}s');
      });

      String userLang = 'vi_VN';
      try {
        final userData = await OdooApiClient.instance.callKw(
          model: 'res.users',
          method: 'read',
          args: [session.userId],
          kwargs: {'fields': ['lang']},
        ).timeout(_rpcTimeout);
        
        if (userData is List && userData.isNotEmpty) {
          userLang = (userData.first['lang'] as String?) ?? 'vi_VN';
        }
      } catch (_) {
        userLang = 'vi_VN';
      }

      // Đọc thông tin hr.employee - cũng thêm timeout
      int? employeeId;
      try {
        final employeeData = await OdooApiClient.instance.callKw(
          model: 'hr.employee',
          method: 'search_read',
          args: [
            [['user_id', '=', session.userId]]
          ],
          kwargs: {
            'fields': ['id'],
            'limit': 1
          },
        ).timeout(_rpcTimeout);
        
        if (employeeData is List && employeeData.isNotEmpty) {
          employeeId = employeeData.first['id'] as int?;
        }
      } catch (_) {
        // Có thể catch nếu user không có quyền đọc hr.employee
      }

      if (employeeId == null) {
        throw const OdooAuthException(
            'Tài khoản chưa được liên kết với Hồ sơ nhân sự (hr.employee). Vui lòng liên hệ Admin.');
      }

      _currentSession = OdooSessionData(
        serverUrl: serverUrl,
        database: database,
        username: username,
        userId: session.userId,
        sessionId: session.id,
        employeeId: employeeId,
        locale: userLang,
      );

      unawaited(SyncManager.instance.syncAfterAuth());

      return _currentSession!;
    } on TimeoutException catch (_) {
      throw OdooConnectionException('Kết nối quá thời gian (${_authTimeout.inSeconds}s). Kiểm tra mạng và thử lại.');
    } on OdooSessionExpiredException {
      throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
    } on OdooException catch (e) {
      throw OdooAuthException(
        'Sai tên đăng nhập hoặc mật khẩu: ${e.message}',
      );
    } catch (e) {
      if (e is OdooApiException) rethrow;
      throw OdooConnectionException('Không thể kết nối tới $serverUrl: $e');
    }
  }

  // Trong callKw() cũng thêm timeout cho mọi RPC call
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic> kwargs = const {},
  }) async {
    try {
      return await OdooApiClient.instance.callKw(
        model: model,
        method: method,
        args: args,
        kwargs: kwargs,
      ).timeout(_rpcTimeout);
    } on TimeoutException catch (_) {
      throw OdooConnectionException('Yêu cầu quá thời gian (${_rpcTimeout.inSeconds}s). Kiểm tra kết nối.');
    } on OdooAuthException {
      // Session expired → try to re-authenticate silently
      if (_isReAuthenticating) {
        rethrow;
      }
      logger.w('Session expired, attempting silent re-authentication...');
      final renewed = await _tryReAuthenticate();
      if (!renewed) {
        throw const OdooAuthException(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
      // Retry the original call with the new session
      return await OdooApiClient.instance.callKw(
        model: model,
        method: method,
        args: args,
        kwargs: kwargs,
      ).timeout(_rpcTimeout);
    }
  }
  
  // ... rest of the class
}
```

---

## A19: BuildContext async gaps (LoginPage/SplashPage)

### Files: 
- `lib/features/auth/pages/login_page.dart`
- `lib/features/auth/pages/splash_page.dart`

### Mô tả
Sau `await` async operation, widget có thể đã unmount (user back, hot reload, app kill). Dùng `context.go()` mà không check `mounted` → **crash: `setState() called after dispose()` hoặc `BuildContext` không hợp lệ.**

**LoginPage (line 77-81):** Có check `if (!mounted) return;` nhưng **sau đó** lại dùng `context.read<AuthProvider>()` và `context.go()` — nếu unmount giữa lúc check và lúc go → crash.

**SplashPage (line 27-33):** **Có check `mounted`** (đã fix một phần) nhưng pattern không an toàn: `context.read()` trước khi check.

### Code BEFORE - LoginPage
```dart
// lib/features/auth/pages/login_page.dart:65-82
Future<void> _onLogin() async {
  if (!_formKey.currentState!.validate()) return;

  await context.read<AuthProvider>().login(
        serverUrl: _serverUrlCtrl.text.trim(),
        database: _databaseCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

  // Redirect được handle bởi _redirectIfAuthed listener
  // nhưng vẫn giữ để đảm bảo chuyển trang ngay lập tức sau login thành công
  if (!mounted) return;
  final auth = context.read<AuthProvider>();  // ❌ UNSAFE: context có thể invalid sau mounted check
  if (auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);  // ❌ CRASH nếu unmounted
  }
}
```

### Code AFTER - LoginPage
```dart
// lib/features/auth/pages/login_page.dart
Future<void> _onLogin() async {
  // Capture context-dependent values TRƯỚC await
  final navigator = Navigator.of(context);
  final authProvider = context.read<AuthProvider>();
  
  if (!_formKey.currentState!.validate()) return;

  await authProvider.login(
    serverUrl: _serverUrlCtrl.text.trim(),
    database: _databaseCtrl.text.trim(),
    username: _usernameCtrl.text.trim(),
    password: _passwordCtrl.text,
  );

  // Check mounted SAU await, DÙNG navigator đã capture
  if (!mounted) return;
  
  if (authProvider.isAuthenticated) {
    // Dùng navigator.pushNamedAndRemoveUntil hoặc go_router context.go()
    // Nếu dùng go_router: cần capture GoRouter instance trước await
    navigator.pushNamedAndRemoveUntil(
      RouteNames.shellSchedule, 
      (route) => false,
    );
  }
}
```

**Hoặc tốt hơn: dùng `GoRouter.of(context)` capture trước await:**

```dart
Future<void> _onLogin() async {
  // Capture TẤT CẢ context dependencies TRƯỚC await
  final goRouter = GoRouter.of(context);
  final authProvider = context.read<AuthProvider>();
  
  if (!_formKey.currentState!.validate()) return;

  await authProvider.login(
    serverUrl: _serverUrlCtrl.text.trim(),
    database: _databaseCtrl.text.trim(),
    username: _usernameCtrl.text.trim(),
    password: _passwordCtrl.text,
  );

  if (!mounted) return;
  
  if (authProvider.isAuthenticated) {
    goRouter.go(RouteNames.shellSchedule);
  }
}
```

### Code BEFORE - SplashPage
```dart
// lib/features/auth/pages/splash_page.dart:23-34
Future<void> _init() async {
  final auth = context.read<AuthProvider>();  // ❌ Capture context dependency
  await auth.initialize();  // Có thể mất vài giây
  
  if (!mounted) return;  // ✅ Có check mounted

  if (auth.isAuthenticated) {
    context.go(RouteNames.shellSchedule);  // ❌ UNSAFE: context.read() ở trên có thể invalid
  } else {
    context.go(RouteNames.login);
  }
}
```

### Code AFTER - SplashPage
```dart
// lib/features/auth/pages/splash_page.dart
Future<void> _init() async {
  // Capture context dependencies TRƯỚC await
  final goRouter = GoRouter.of(context);
  final authProvider = context.read<AuthProvider>();
  
  await authProvider.initialize();
  
  // Check mounted SAU await
  if (!mounted) return;
  
  // Dùng captured goRouter thay vì context.go()
  if (authProvider.isAuthenticated) {
    goRouter.go(RouteNames.shellSchedule);
  } else {
    goRouter.go(RouteNames.login);
  }
}
```

### Pattern chung an toàn cho TẤT CẢ async methods trong StatefulWidget:
```dart
// ✅ SAFE PATTERN
Future<void> someAsyncMethod() async {
  // 1. Capture TẤT CẢ context dependencies TRƯỚC await
  final navigator = Navigator.of(context);
  // hoặc: final goRouter = GoRouter.of(context);
  final someProvider = context.read<SomeProvider>();
  final someValue = context.read<SomeValue>();
  
  // 2. Thực hiện async work
  await doSomething();
  
  // 3. Check mounted SAU await
  if (!mounted) return;
  
  // 4. Chỉ dùng captured values, KHÔNG dùng context trực tiếp
  navigator.push(...);
  // hoặc: goRouter.go(...);
}
```

---

## Tóm tắt Files Cần Sửa

| File | Bugs Fixed | Mô tả thay đổi chính |
|------|------------|---------------------|
| `lib/features/auth/widgets/server_url_field.dart` | A02 | Fix force-unwrap crash, validate URL an toàn |
| `lib/core/auth/secure_storage.dart` | A09, A17 | Xóa password storage, thêm Lock cho race condition |
| `lib/core/auth/auth_service.dart` | A09 | Không truyền password vào saveSession |
| `lib/core/api/odoo_session_manager.dart` | A09, A24 | Xóa logic dùng password stored, thêm timeout cho authenticate & callKw |
| `lib/core/auth/biometric_service.dart` | A16 | Handle LockoutPermanent/Temporary, throw typed exception |
| `lib/features/auth/pages/login_page.dart` | A19 | Capture GoRouter/Navigator trước await, check mounted đúng cách |
| `lib/features/auth/pages/splash_page.dart` | A19 | Capture GoRouter trước await, check mounted đúng cách |
| `pubspec.yaml` | A17 | Thêm dependency `synchronized: ^3.1.0` |

---

## Thứ tự Apply Fixes (Khuyến nghị)

1. **A02** - ServerUrlField crash (dễ nhất, ít rủi ro)
2. **A24** - Login timeout (critical UX, standalone)
3. **A16** - Biometric lockout (security, có exception mới cần handle ở UI)
4. **A09** - Remove password storage (breaking change, cần migration)
5. **A17** - SecureStorage lock (phụ thuộc A09 đã xóa password)
6. **A19** - BuildContext async gaps (pattern áp dụng cho nhiều file)

---

## Testing Checklist

Sau khi apply tất cả fixes:

- [ ] **A02**: Nhập "not a url" → hiển thị error "URL không hợp lệ" không crash
- [ ] **A02**: Nhập "https://valid.com" → pass validation
- [ ] **A09**: Login → kiểm tra SecureStorage không có key `odoo_password`
- [ ] **A09**: App update → password cũ bị xóa (migration)
- [ ] **A16**: Fail biometric 5+ lần → LockoutPermanent → app auto-disable biometric, show message "dùng mật khẩu"
- [ ] **A16**: LockoutTemporary → retry sau 30s → thành công
- [ ] **A17**: Login đồng thời từ 2 nơi (biometric + manual) → không data corruption
- [ ] **A24**: Tắt mạng → login → sau 30s hiện "Kết nối quá thời gian"
- [ ] **A24**: Server chậm → timeout đúng 30s/60s
- [ ] **A19**: Hot reload khi đang login/splash → không crash "setState after dispose"
- [ ] **A19**: Back button khi đang loading → không crash

---

## Lưu ý Implementation

1. **A09 + A17**: Xóa password KHỎI HOÀN TOÀN - không chỉ bỏ qua. `_tryReAuthenticate()` sẽ luôn return `false` → user phải login lại khi session hết hạn. Đây là design an toàn.

2. **A16**: BiometricLockoutException cần được catch ở `AuthProvider.loginWithBiometric()` để set error message hiển thị cho user.

3. **A24**: Timeout constants (`_authTimeout`, `_rpcTimeout`) nên config được từ environment hoặc remote config cho production.

4. **A19**: Pattern "capture context trước await" áp dụng cho **TẤT CẢ** async methods trong codebase (không chỉ auth).
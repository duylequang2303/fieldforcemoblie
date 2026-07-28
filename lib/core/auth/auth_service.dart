import '../api/odoo_session_manager.dart';
import '../locale/locale_service.dart';
import 'secure_storage.dart';
import 'biometric_service.dart';

/// Service điều phối toàn bộ luồng xác thực: login, restore session, logout.
/// Đây là interface duy nhất mà AuthProvider giao tiếp.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _sessionManager = OdooSessionManager.instance;
  final _storage = SecureStorageService.instance;
  final _biometric = BiometricService.instance;

  bool get isLoggedIn => _sessionManager.isAuthenticated;

  /// Đăng nhập bằng username/password.
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
    );
  }

  /// Thử restore session từ secure storage khi app khởi động.
  /// Trả về [true] nếu có session đã lưu (optimistic — không verify RPC).
  Future<bool> tryRestoreSession() async {
    final hasSaved = await _storage.hasSavedSession;
    if (!hasSaved) return false;

    final saved = await _storage.loadSession();
    final serverUrl = saved['serverUrl'];
    final sessionId = saved['sessionId'];
    final database = saved['database'];
    final locale = saved['locale'];
    final username = saved['username'] ?? '';
    final userIdStr = saved['userId'];
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

    if (serverUrl == null || sessionId == null || database == null || userId == null) {
      return false;
    }

    final restored = await _sessionManager.restoreSession(
      serverUrl: serverUrl,
      database: database,
      sessionId: sessionId,
      savedUserId: userId,
      username: username,
      locale: locale ?? 'vi_VN',
    );

    if (restored && locale != null && locale.isNotEmpty) {
      LocaleService.instance.setLocale(locale);
    }

    return restored;
  }

  /// Đăng nhập bằng biometric (nếu có session đã lưu + biometric bật).
  Future<bool> loginWithBiometric() async {
    final biometricEnabled = await _storage.isBiometricEnabled;
    if (!biometricEnabled) return false;

    final authenticated = await _biometric.authenticate();
    if (!authenticated) return false;

    return tryRestoreSession();
  }

  /// Đăng xuất: xóa session local + Odoo.
  Future<void> logout() async {
    await _sessionManager.logout();
    await _storage.clearSession();
  }

  /// Kiểm tra biometric có khả dụng không.
  Future<bool> get isBiometricAvailable => _biometric.isAvailable;

  /// Bật/tắt đăng nhập biometric.
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.setBiometricEnabled(enabled: enabled);
  }
}

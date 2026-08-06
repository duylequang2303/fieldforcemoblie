import 'dart:async';
import '../api/odoo_session_manager.dart';
import '../database/sync_manager.dart';
import '../database/isar_service.dart';
import '../database/database_migration_service.dart';
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

    // Chạy migration gán các bản ghi offline cũ (không localOwnerId) cho user hiện tại (Fix Thread #5)
    final migrationSuccess = await DatabaseMigrationService.migrateLegacyRecords(session.userId);
    if (!migrationSuccess) {
      logger.w('DatabaseMigrationService: Legacy record migration failed during login.');
    }
    // Bắt đầu đồng bộ sau khi migration hoàn thành (đã giải quyết race condition)
    unawaited(SyncManager.instance.syncAfterAuth());
  }

  /// Thử restore session từ secure storage khi app khởi động.
  /// Trả về [true] nếu có session đã lưu (optimistic — không verify RPC).
  Future<bool> tryRestoreSession() async {
    // Xóa legacy password (odoo_password) sớm trong luồng khởi động
    // để đảm bảo migration được thực hiện dù hasSavedSession trả false
    // (Fix CodeRabbit PR#34 Thread #10)
    await _storage.removeLegacyPassword();

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

    if (serverUrl == null ||
        sessionId == null ||
        database == null ||
        userId == null) {
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

    if (restored) {
      // Chạy migration gán các bản ghi offline cũ (không localOwnerId) cho user hiện tại (Fix Thread #5)
      final migrationSuccess = await DatabaseMigrationService.migrateLegacyRecords(userId);
      if (!migrationSuccess) {
        logger.w('DatabaseMigrationService: Legacy record migration failed during restore.');
      }
      if (locale != null && locale.isNotEmpty) {
        try {
          final parts = locale.split('_');
          if (parts.length == 2) {
            // Fix Thread #11: Await setLocale to ensure locale is persisted before returning
            await LocaleService.instance.setLocale(locale);
          } else {
            logger.w('Invalid locale format from storage: $locale');
            await LocaleService.instance.setLocale('vi_VN');
          }
        } catch (e, stack) {
          logger.e('Failed to set locale from restored session', error: e, stackTrace: stack);
          try {
            await LocaleService.instance.setLocale('vi_VN');
          } catch (_) {}
        }
      }
      // Bắt đầu đồng bộ sau khi migration hoàn thành (đã giải quyết race condition)
      unawaited(SyncManager.instance.syncAfterAuth());

      // Fire-and-forget verify session validity in background
      unawaited(_verifySessionInBackground());
    }

    return restored;
  }

  /// Xác thực ngầm trạng thái session mà không chặn UI (A08)
  Future<void> _verifySessionInBackground() async {
    try {
      final userId = _sessionManager.currentUserId;
      if (userId == null) return;
      
      await _sessionManager.callKw(
        model: 'res.users',
        method: 'read',
        args: [[userId]],
        kwargs: {'fields': ['id']},
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      // Bỏ qua lỗi kết nối vì app cho phép offline-first.
      // Nếu session expired thực sự, callKw sẽ tự động trigger 
      // event báo hết hạn session thông qua OdooSessionManager.
    }
  }

  /// Đăng nhập bằng biometric (nếu có session đã lưu + biometric bật).
  Future<bool> loginWithBiometric() async {
    final biometricEnabled = await _storage.isBiometricEnabled;
    if (!biometricEnabled) return false;

    try {
      final authenticated = await _biometric.authenticate();
      if (!authenticated) return false;

      return tryRestoreSession();
    } on BiometricLockoutException {
      rethrow;
    } on BiometricCredentialsInvalidatedException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// Đăng xuất: xóa session local + Odoo + cleanup sync resources + clear database.
  Future<void> logout() async {
    await _sessionManager.logout();
    await _storage.clearSession();
    
    // FIX C04 + C05 + A30: Dispose SyncManager resources, KHÔNG dispose OdooApiClient singleton
    try {
      if (SyncManager.instance.isInitialized) {
        await SyncManager.instance.dispose();
      }
    } catch (e, stack) {
      logger.e('SyncManager dispose failed on logout', error: e, stackTrace: stack);
    }

    // FIX C06: Xoá trắng database Isar cục bộ phòng chống lộ lọt thông tin ngoại tuyến của user cũ
    if (IsarService.instance.isInitialized) {
      final isar = IsarService.instance.db;
      await isar.writeTxn(() async {
        await isar.clear();
      });
    }
  }

  /// Kiểm tra biometric có khả dụng không.
  Future<bool> get isBiometricAvailable => _biometric.isAvailable;

  /// Bật/tắt đăng nhập biometric.
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.setBiometricEnabled(enabled: enabled);
  }
}

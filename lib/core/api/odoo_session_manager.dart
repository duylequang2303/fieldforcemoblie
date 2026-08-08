import 'dart:async';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'api_exception.dart';
import 'odoo_client.dart';
import '../auth/secure_storage.dart';
import '../database/sync_manager.dart';
import '../utils/logger.dart';

class OdooSessionData {
  const OdooSessionData({
    required this.serverUrl,
    required this.database,
    required this.username,
    required this.userId,
    required this.sessionId,
    this.employeeId,
    this.locale = 'vi_VN',
    this.serverVersion = '19',
  });

  final String serverUrl;
  final String database;
  final String username;
  final int userId;
  final String sessionId;
  final int? employeeId;
  final String locale;
  final String serverVersion;
}

/// Quản lý toàn bộ vòng đời session Odoo: đăng nhập, kiểm tra, đăng xuất.
class OdooSessionManager {
  OdooSessionManager._();

  static final OdooSessionManager instance = OdooSessionManager._();

  static const Duration _authTimeout = Duration(seconds: 30);
  static const Duration _rpcTimeout = Duration(seconds: 30);

  OdooSessionData? _currentSession;

  /// Reject any server URL that is not a well-formed HTTPS endpoint so that
  /// credentials and session cookies can never travel over cleartext HTTP.
  /// Returns the trimmed URL that callers must use from then on.
  static String _normalizeHttpsServerUrl(String serverUrl) {
    final normalized = serverUrl.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
      throw const OdooConnectionException(
        'URL server không hợp lệ. Chỉ chấp nhận địa chỉ https://',
      );
    }
    return normalized;
  }

  bool get isAuthenticated => _currentSession != null;
  OdooSessionData? get currentSession => _currentSession;
  int? get currentUserId => _currentSession?.userId;
  String? get currentUserName => _currentSession?.username;

  /// Đăng nhập Odoo bằng username/password.
  Future<OdooSessionData> authenticate({
    required String serverUrl,
    required String database,
    required String username,
    required String password,
  }) async {
    final normalizedServerUrl = _normalizeHttpsServerUrl(serverUrl);
    try {
      OdooApiClient.instance.initialize(normalizedServerUrl);
      final client = OdooApiClient.instance.client;

      // odoo_rpc authenticate signature: (db, login, password)
      final session = await client
          .authenticate(database, username, password)
          .timeout(_authTimeout, onTimeout: () {
        throw const OdooConnectionException('Kết nối đăng nhập quá hạn sau 30 giây.');
      });

      String userLang = 'vi_VN';
      try {
        final userData = await OdooApiClient.instance.callKw(
          model: 'res.users',
          method: 'read',
          args: [session.userId],
          kwargs: {
            'fields': ['lang']
          },
        ).timeout(_rpcTimeout);
        if (userData is List && userData.isNotEmpty) {
          userLang = (userData.first['lang'] as String?) ?? 'vi_VN';
        }
      } catch (e, stack) {
        // Nếu không đọc được từ Odoo, giữ mặc định
        userLang = 'vi_VN';
        logger.w('Failed to read res.users.lang, using default locale',
            error: e, stackTrace: stack);
      }

      // Đọc thông tin hr.employee
      int? employeeId;
      try {
        final employeeData = await OdooApiClient.instance.callKw(
          model: 'hr.employee',
          method: 'search_read',
          args: [
            [
              ['user_id', '=', session.userId]
            ]
          ],
          kwargs: {
            'fields': ['id'],
            'limit': 1
          },
        ).timeout(_rpcTimeout);
        if (employeeData is List && employeeData.isNotEmpty) {
          employeeId = employeeData.first['id'] as int?;
        }
      } catch (e, stack) {
        // Có thể catch nếu user không có quyền đọc hr.employee
        logger.w('Failed to read hr.employee for current user',
            error: e, stackTrace: stack);
      }

      if (employeeId == null) {
        throw const OdooAuthException(
            'Tài khoản chưa được liên kết với Hồ sơ nhân sự (hr.employee). Vui lòng liên hệ Admin.');
      }

      _currentSession = OdooSessionData(
        serverUrl: normalizedServerUrl,
        database: database,
        username: username,
        userId: session.userId,
        sessionId: session.id,
        employeeId: employeeId,
        locale: userLang,
        serverVersion: session.serverVersion,
      );

      return _currentSession!;
    } on OdooSessionExpiredException {
      throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
    } on OdooException catch (e) {
      throw OdooAuthException(
        'Sai tên đăng nhập hoặc mật khẩu: ${e.message}',
      );
    } catch (e) {
      if (e is OdooApiException) rethrow;
      throw OdooConnectionException(
          'Không thể kết nối tới $normalizedServerUrl: $e');
    }
  }

  /// Restore session từ dữ liệu đã lưu (sau khi app restart).
  ///
  /// OPTIMISTIC RESTORE (offline-first): dựng lại session + _currentSession
  /// từ SecureStorage, KHÔNG gọi RPC. Mở app không mạng vẫn vào được (xem
  /// cache Isar). Session hết hạn sẽ bị phát hiện ở callKw online đầu tiên
  /// (OdooSessionExpiredException) chứ không chặn lúc mở app.
  Future<bool> restoreSession({
    required String serverUrl,
    required String database,
    required String sessionId,
    required int savedUserId,
    required String username,
    String locale = 'vi_VN',
    required String serverVersion,
    int? employeeId,
  }) async {
    try {
      final normalizedServerUrl = _normalizeHttpsServerUrl(serverUrl);
      // Dựng OdooSession từ dữ liệu đã lưu. Chỉ id + userId là quan trọng
      // cho RPC; các field còn lại là metadata, đặt default an toàn.
      final session = OdooSession(
        id: sessionId,
        userId: savedUserId,
        partnerId: 0,
        companyId: 0,
        allowedCompanies: <Company>[],
        userLogin: username,
        userName: username,
        userLang: locale,
        userTz: 'UTC',
        isSystem: false,
        dbName: database,
        serverVersion: serverVersion,
      );

      // FIX TẦNG 1: nạp session vào client → mọi callKw online gửi cookie session_id.
      OdooApiClient.instance.initializeWithSession(normalizedServerUrl, session);

      // FIX TẦNG 2: dựng lại _currentSession. Thiếu bước này thì
      // currentUserId = null → OrdersService.fetchMyOrders() trả về [] sau mỗi lần mở app.
      _currentSession = OdooSessionData(
        serverUrl: normalizedServerUrl,
        database: database,
        username: username,
        userId: savedUserId,
        sessionId: sessionId,
        employeeId: employeeId,
        locale: locale,
        serverVersion: serverVersion,
      );
      return true;
    } catch (e, stack) {
      logger.e('Failed to restore session optimistic', error: e, stackTrace: stack);
      _currentSession = null;
      return false;
    }
  }

  /// Đăng xuất: xóa session khỏi Odoo và reset state.
  Future<void> logout() async {
    try {
      await OdooApiClient.instance.client.destroySession();
    } catch (e, stack) {
      // Không propagate: vẫn phải clear local session dù Odoo từ chối
      logger.w('destroySession failed during logout',
          error: e, stackTrace: stack);
    } finally {
      _currentSession = null;
      OdooApiClient.instance.dispose();
    }
  }

  /// Gọi Odoo RPC (delegate sang OdooApiClient).
  /// Nếu session hết hạn → tự động re-authenticate bằng credentials đã lưu
  /// trong SecureStorage rồi retry lại API call 1 lần.
  bool _isReAuthenticating = false;

  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

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
      ).timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const OdooConnectionException('Yêu cầu kết nối tới server quá hạn sau 60 giây.');
    } on OdooAuthException {
      // Session expired → try to re-authenticate silently
      if (_isReAuthenticating) {
        // Already trying to re-auth, don't recurse
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
      );
    }
  }

  /// Đọc credentials đã lưu và re-authenticate.
  /// Trả về true nếu thành công, false nếu không có credentials hoặc login thất bại.
  /// KHÔNG dùng password để re-authenticate (đã gỡ save password).
  Future<bool> _tryReAuthenticate() async {
    logger.w('Silent re-auth not possible without stored password. User must login again.');
    try {
      await logout();
      await SecureStorageService.instance.clearSession();

      await SyncManager.instance.dispose();
    } catch (e, stack) {
      logger.e('Session cleanup failed, forcing expiry anyway', error: e, stackTrace: stack);
    } finally {
      _sessionExpiredController.add(null);
    }
    return false;
  }
}

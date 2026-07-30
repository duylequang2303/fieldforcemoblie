import 'dart:async';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'api_exception.dart';
import 'odoo_client.dart';
import '../database/sync_manager.dart';

class OdooSessionData {
  const OdooSessionData({
    required this.serverUrl,
    required this.database,
    required this.username,
    required this.userId,
    required this.sessionId,
    this.employeeId,
    this.locale = 'vi_VN',
  });

  final String serverUrl;
  final String database;
  final String username;
  final int userId;
  final String sessionId;
  final int? employeeId;
  final String locale;
}

/// Quản lý toàn bộ vòng đời session Odoo: đăng nhập, kiểm tra, đăng xuất.
class OdooSessionManager {
  OdooSessionManager._();

  static final OdooSessionManager instance = OdooSessionManager._();

  OdooSessionData? _currentSession;

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
    try {
      OdooApiClient.instance.initialize(serverUrl);
      final client = OdooApiClient.instance.client;

      // odoo_rpc authenticate signature: (db, login, password)
      final session = await client.authenticate(database, username, password);

      String userLang = 'vi_VN';
      try {
        final userData = await OdooApiClient.instance.callKw(
          model: 'res.users',
          method: 'read',
          args: [session.userId],
          kwargs: {'fields': ['lang']},
        );
        if (userData is List && userData.isNotEmpty) {
          userLang = (userData.first['lang'] as String?) ?? 'vi_VN';
        }
      } catch (_) {
        // Nếu không đọc được từ Odoo, giữ mặc định
        userLang = 'vi_VN';
      }

      // Đọc thông tin hr.employee
      int? employeeId;
      try {
        final employeeData = await OdooApiClient.instance.callKw(
          model: 'hr.employee',
          method: 'search_read',
          args: [
            [['user_id', '=', session.userId]]
          ],
          kwargs: {'fields': ['id'], 'limit': 1},
        );
        if (employeeData is List && employeeData.isNotEmpty) {
          employeeId = employeeData.first['id'] as int?;
        }
      } catch (_) {
        // Có thể catch nếu user không có quyền đọc hr.employee
      }

      if (employeeId == null) {
        throw const OdooAuthException('Tài khoản chưa được liên kết với Hồ sơ nhân sự (hr.employee). Vui lòng liên hệ Admin.');
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
  }) async {
    try {
      // Dựng OdooSession từ dữ liệu đã lưu. Chỉ id + userId là quan trọng
      // cho RPC; các field còn lại là metadata, đặt default an toàn.
      // serverVersion đặt '19' (khác '') để tránh RangeError nếu serverVersionInt bị gọi.
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
        serverVersion: '19',
      );

      // FIX TẦNG 1: nạp session vào client → mọi callKw online gửi cookie session_id.
      OdooApiClient.instance.initializeWithSession(serverUrl, session);

      // FIX TẦNG 2: dựng lại _currentSession. Thiếu bước này thì
      // currentUserId = null → OrdersService.fetchMyOrders() trả về [] sau mỗi lần mở app.
      _currentSession = OdooSessionData(
        serverUrl: serverUrl,
        database: database,
        username: username,
        userId: savedUserId,
        sessionId: sessionId,
        locale: locale,
      );
      unawaited(SyncManager.instance.syncAfterAuth());
      return true;
    } catch (_) {
      _currentSession = null;
      return false;
    }
  }

  /// Đăng xuất: xóa session khỏi Odoo và reset state.
  Future<void> logout() async {
    try {
      await OdooApiClient.instance.client.destroySession();
    } catch (_) {
      // Bỏ qua lỗi khi logout — vẫn clear local session
    } finally {
      _currentSession = null;
      OdooApiClient.instance.dispose();
    }
  }

  /// Gọi Odoo RPC (delegate sang OdooApiClient).
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic> kwargs = const {},
  }) {
    return OdooApiClient.instance.callKw(
      model: model,
      method: method,
      args: args,
      kwargs: kwargs,
    );
  }
}

import 'package:odoo_rpc/odoo_rpc.dart';
import 'api_exception.dart';
import 'odoo_client.dart';

/// Data class lưu thông tin session đăng nhập Odoo.
class OdooSessionData {
  const OdooSessionData({
    required this.serverUrl,
    required this.database,
    required this.username,
    required this.userId,
    required this.sessionId,
    this.locale = 'vi_VN',
  });

  final String serverUrl;
  final String database;
  final String username;
  final int userId;
  final String sessionId;
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
        // Nếu không đọc được lang từ Odoo, giữ mặc định vi_VN
        userLang = 'vi_VN';
      }

      _currentSession = OdooSessionData(
        serverUrl: serverUrl,
        database: database,
        username: username,
        userId: session.userId,
        sessionId: session.id,
        locale: userLang,
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
      throw OdooConnectionException('Không thể kết nối tới $serverUrl: $e');
    }
  }

  /// Restore session từ sessionId đã lưu (sau khi app restart).
  Future<bool> restoreSession({
    required String serverUrl,
    required String database,
    required String sessionId,
  }) async {
    try {
      OdooApiClient.instance.initialize(serverUrl);
      // Thử gọi API đơn giản để kiểm tra session còn hiệu lực không
      await OdooApiClient.instance.callKw(
        model: 'res.users',
        method: 'search_read',
        args: [
          [['id', '=', 1]]
        ],
        kwargs: {'fields': <String>['id'], 'limit': 1},
      );
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

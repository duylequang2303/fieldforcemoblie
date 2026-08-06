import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:async';
import 'api_exception.dart';

/// Wrapper xung quanh [OdooClient] của thư viện odoo_rpc.
/// Cung cấp interface thống nhất và xử lý lỗi chuẩn hóa.
class OdooApiClient {
  OdooApiClient._();

  static OdooApiClient? _instance;
  static OdooApiClient get instance => _instance ??= OdooApiClient._();

  OdooClient? _client;

  bool get isInitialized => _client != null;

  /// Khởi tạo client với server URL.
  void initialize(String serverUrl) {
    _client = OdooClient(serverUrl);
  }

  /// Khởi tạo client với session đã lưu để restore phiên (không authenticate lại).
  /// [session] phải có id (sessionId) khác rỗng để callKw gửi cookie hợp lệ.
  void initializeWithSession(String serverUrl, OdooSession session) {
    _client = OdooClient(serverUrl, session);
  }

  /// Trả về OdooClient đang hoạt động.
  /// Throw [OdooConnectionException] nếu chưa initialize.
  OdooClient get client {
    if (_client == null) {
      throw const OdooConnectionException(
        'OdooApiClient chưa được khởi tạo. Gọi initialize() trước.',
      );
    }
    return _client!;
  }

  /// Gọi Odoo RPC call_kw với xử lý lỗi chuẩn hóa.
  ///
  /// Tham khảo odoo_rpc API: callKw(params) nhận Map<String, dynamic>:
  /// {model, method, args, kwargs}
  ///
  /// Có timeout 30 giây để tránh treo vô tận.
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic> kwargs = const {},
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await client.callKw({
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      }).timeout(timeout, onTimeout: () {
        throw OdooConnectionException('Odoo API timeout sau ${timeout.inSeconds} giây');
      });
    } on OdooSessionExpiredException {
      throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
    } on OdooException catch (e) {
      final msg = e.message;
      if (msg.contains('Access Denied') || msg.contains('access rights')) {
        throw OdooAuthException(msg);
      }
      throw OdooBusinessException(msg);
    } on TimeoutException {
      throw OdooConnectionException('Odoo API timeout sau ${timeout.inSeconds} giây');
    } catch (e) {
      throw OdooConnectionException('Không thể kết nối tới Odoo: $e');
    }
  }

  /// Đóng kết nối và reset client (KHÔNG reset singleton instance).
  /// Dùng khi logout để reset connection state nhưng giữ singleton.
  void dispose() {
    _client?.close();
    _client = null;
    // KHÔNG set _instance = null - giữ singleton pattern
  }

  /// Hard reset - chỉ dùng cho testing hoặc khi cần recreate hoàn toàn.
  @visibleForTesting
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

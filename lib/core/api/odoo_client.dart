import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'api_exception.dart';

/// Wrapper xung quanh [OdooClient] của thư viện odoo_rpc.
/// Cung cấp interface thống nhất và xử lý lỗi chuẩn hóa.
class OdooApiClient {
  OdooApiClient._();

  /// Constructor dành riêng cho test: cho phép subclass ghi đè [callKw]
  /// để giả lập RPC và verify các lần gọi. Không dùng trong production.
  @visibleForTesting
  OdooApiClient.forTesting();

  static OdooApiClient? _instance;
  static OdooApiClient get instance => _instance ??= OdooApiClient._();

  /// Cho phép test inject một fake/mock client để verify RPC calls.
  /// Test xong gọi [dispose] để reset về singleton thật.
  @visibleForTesting
  static set instanceForTest(OdooApiClient? client) {
    _instance = client;
  }

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
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic> kwargs = const {},
  }) async {
    try {
      return await client.callKw({
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      });
    } on OdooSessionExpiredException {
      throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
    } on OdooException catch (e) {
      final msg = e.message;
      if (msg.contains('Access Denied') || msg.contains('access rights')) {
        throw OdooAuthException(msg);
      }
      throw OdooBusinessException(msg);
    } catch (e) {
      throw OdooConnectionException('Không thể kết nối tới Odoo: $e');
    }
  }

  /// Đóng kết nối và reset client.
  void dispose() {
    _client?.close();
    _client = null;
    _instance = null;
  }
}

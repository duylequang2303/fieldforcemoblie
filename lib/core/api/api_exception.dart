/// Custom exceptions cho tất cả lỗi từ Odoo API.
/// Sử dụng các exception này thay vì để lỗi raw từ odoo_rpc bubble lên UI.
sealed class OdooApiException implements Exception {
  const OdooApiException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Lỗi xác thực: sai username/password hoặc session hết hạn.
final class OdooAuthException extends OdooApiException {
  const OdooAuthException(super.message);
}

/// Lỗi không kết nối được tới server (server down, sai URL).
final class OdooConnectionException extends OdooApiException {
  const OdooConnectionException(super.message);
}

/// Lỗi logic nghiệp vụ từ Odoo (ví dụ: không đủ quyền, validation fail).
final class OdooBusinessException extends OdooApiException {
  const OdooBusinessException(super.message);
}

/// Lỗi nghiệp vụ khi xuất kho nhưng thiếu tồn kho
class StockPartialAssignException extends OdooApiException {
  const StockPartialAssignException(super.message);
}

/// Lỗi không tìm thấy record (record đã xóa hoặc không có quyền đọc).
final class OdooNotFoundException extends OdooApiException {
  const OdooNotFoundException(super.message);
}

/// Lỗi không xác định từ Odoo.
final class OdooUnknownException extends OdooApiException {
  const OdooUnknownException(super.message);
}

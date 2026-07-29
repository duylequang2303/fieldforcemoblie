---
name: odoo-rpc-pattern
description: Hướng dẫn gọi Odoo API (login, session, call_kw, xử lý false/null)
---
# Odoo RPC Pattern Skill

Mô tả các mẫu thiết kế và hướng dẫn thực thi giao tiếp mạng Odoo RPC trong dự án `fieldforce_mobile`.

## Luồng Giao Tiếp Chính
Mọi cuộc gọi RPC bắt buộc phải thông qua `OdooSessionManager` (Singleton) và `OdooApiClient` (Singleton wrapper của `OdooClient` từ package `odoo_rpc`).

### 1. Đăng nhập & Khôi phục Phiên (Authentication)
Dùng `OdooSessionManager.instance.authenticate` để đăng nhập bằng thông tin người dùng nhập vào. Khi khôi phục phiên từ storage:
```dart
OdooApiClient.instance.initializeWithSession(serverUrl, odooSession);
```

### 2. Gọi API Odoo bằng `callKw`
Tất cả các API calls cần sử dụng `OdooApiClient.instance.callKw` thay vì gọi client trực tiếp. Cấu trúc chuẩn:
```dart
try {
  final result = await OdooApiClient.instance.callKw(
    model: 'fsm.order',
    method: 'search_read',
    args: [
      [['person_id.user_id', '=', userId]]
    ],
    kwargs: {
      'fields': ['name', 'scheduled_date_start', 'stage_id'],
    },
  );
  // Xử lý dữ liệu...
} on OdooApiException catch (e) {
  // Lỗi API đã được chuẩn hóa
  logger.e('API Error: ${e.message}');
  rethrow;
} catch (e) {
  // Lỗi mạng hoặc lỗi kết nối hệ thống
  throw OdooConnectionException('Không thể kết nối đến Odoo backend: $e');
}
```

### 3. Xử lý giá trị False từ Odoo
Odoo thường trả về `false` (bool) khi một trường dữ liệu (Many2one, Char, Text) trống thay vì trả về `null`.
**QUY TẮC BẮT BUỘC:** Phải kiểm tra kiểu dữ liệu trước khi parse:
```dart
// Đối với trường Many2one (ví dụ: partner_id trả về [int, String] hoặc false)
final partnerId = json['partner_id'] is List ? json['partner_id'][0] as int : null;
final partnerName = json['partner_id'] is List ? json['partner_id'][1] as String : null;

// Đối với trường text/string (trả về String hoặc false)
final description = json['description'] is String ? json['description'] as String : null;
```

# Test Progress

Tài liệu này theo dõi tiến độ viết test cho ứng dụng Field Force Mobile, đảm bảo phản ánh **trung thực** các module đã được bao phủ bằng code thực tế.

## 1. Automated E2E Tests (Patrol) - COMPLETED
*Đã kiểm chứng thực tế có file `.dart` trong thư mục `integration_test/`*

- **Auth**: `login_test.dart` (Bao phủ `AUTH-01`)
- **Stock / Material**: 
  - `material_entry_form_test.dart` (Isolated Material Form)
  - `work_order_material_flow_test.dart` (Integrated Flow - Thêm vật tư từ đơn hàng)
  - `stock_barcode_test.dart` (Bao phủ luồng quét mã vạch `STOCK-01`, `STOCK-03`, `STOCK-06`, `STOCK-07`)
- **Timesheet**: 
  - `timesheet_test.dart` (Bao phủ `TIME-01`, `TIME-02`)
  - `timesheet_entry_form_test.dart` (Nhập thủ công `TIME-04`)
- **Work Order & Orders**: 
  - `work_order_test.dart` (Bao phủ chung luồng tạo report `WO-03`, chụp ảnh `WO-05`)
  - `order_checkin_test.dart` (Bao phủ Check-in `ORD-05`)
  - `work_order_detail_test.dart` (Luồng check-in, ký tên, hoàn thành `WO-07`, `WO-09`)
- **Expense**: `expense_create_test.dart` (Bao phủ `EXP-03`)

## 2. Pending E2E Tests - TO-DO
*Các Test Case được đánh dấu E2E trong danh sách CSV nhưng chưa có code kiểm thử thực tế.*

- **Route Map**: `ROUTE-03` (Định vị GPS), `ROUTE-11` (Từ chối quyền GPS) - *Chưa có file `route_map_test.dart`*
- **Orders**: `ORD-01` (Lấy danh sách đơn), `ORD-10` (Từ chối hoàn thành khi chưa ký tên) - *Cần bổ sung test case riêng biệt để đảm bảo coverage.*

## 3. Next Action
1. Khởi tạo file `integration_test/route_map_test.dart` để bao phủ luồng **ROUTE-03**.
2. Kiểm tra lại module Orders để bổ sung thêm validation check cho **ORD-10**.
3. Refactor: Loại bỏ dữ liệu mock phụ thuộc bên trong Widget (như `_mockProducts`) bằng Dependency Injection triệt để.

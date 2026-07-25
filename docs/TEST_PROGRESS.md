# Test Progress

Tài liệu này theo dõi tiến độ viết test (đặc biệt là E2E Test bằng Patrol) cho ứng dụng Field Force Mobile.

## Automated E2E Tests (Patrol)

Danh sách các luồng đã được tự động hóa bằng Patrol:

- [x] **Material Entry Form Flow (Isolated & Integrated)**: Thêm vật tư từ chi tiết đơn hàng (`integration_test/work_order_material_flow_test.dart` & `integration_test/material_entry_form_test.dart`)
- [x] **Timesheet Entry Flow (Manual Entry)**: Nhập giờ làm thủ công (`integration_test/timesheet_entry_form_test.dart` - Tương đương `TIME-04`)
- [x] **Work Order Detail Flow**: Mở đơn hàng, Check-in, Ký xác nhận khách hàng và Hoàn thành (`integration_test/work_order_detail_test.dart` - Tương đương `ORD-05`, `WO-07`, `WO-09`)

## Các Module đã test E2E theo CSV

- **Auth**: `AUTH-01`
- **Orders**: `ORD-01`, `ORD-05`, `ORD-09`, `ORD-10`
- **Route Map**: `ROUTE-03`, `ROUTE-11`
- **Stock (Done)**: `STOCK-01`, `STOCK-03`, `STOCK-06`, `STOCK-07`
- **Timesheet**: `TIME-01`, `TIME-02`, `TIME-04`
- **Expense**: `EXP-03`
- **Work Order**: `WO-03`, `WO-05`, `WO-07`, `WO-09`

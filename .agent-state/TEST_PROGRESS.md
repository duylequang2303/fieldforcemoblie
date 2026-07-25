# 📊 Test Implementation Progress
> File này dùng để AI / Dev tracking tiến độ thực thi các Test Cases dựa trên `docs/TEST_STRATEGY.md`.

**Cập nhật lần cuối:** 2026-07-25 (Bởi AI Agent)

## 📌 Tổng quan các Hạng Mục (Checklist)

### ✅ Week 1: Unit Test cho Validation Logic + Model Parsing
- [x] **Expense**: `test/expense_validation_test.dart` (Bắt lỗi amount âm, trống name, v.v)
- [x] **Timesheet**: `test/timesheet_validation_test.dart` (Bắt lỗi duration, logic 24h, giờ kết thúc)
- [x] **Stock**: `test/stock_validation_test.dart` (Bắt lỗi qty <= 0, logic xuất kho âm)
- [x] **Orders**: `test/orders_validation_test.dart` (Bắt lỗi missing DateEnd khi Done, chữ ký bắt buộc)
- [x] **Work Order**: `test/work_order_validation_test.dart` (Bắt lỗi nội dung report rỗng)

### ⏳ Week 2 & 3: Integration Test (Offline/Sync + Modules)
- [x] **Sync Manager (Template)**: `test/sync_manager_integration_test.dart` (Test lưu order khi offline, tự gán isPendingSync)
- [x] **Auth**: `test/auth_integration_test.dart` (Luồng Login online lưu token, login offline đọc cache)
- [x] **Stock / Orders Integration**: `test/stock_order_integration_test.dart` (Check workflow cập nhật Order stage khi quét Stock)
- [x] **Timesheet Integration**: `test/timesheet_integration_test.dart` (Test CRUD offline và giả lập hàm Push)

### ⏸️ Week 4: E2E Test (Patrol CLI)
- [x] **Cấu hình Patrol**: Đã thêm Patrol package và setup Android Test Runner.
- [x] **Viết E2E TC mẫu (P0)**: Đã tạo `login_test.dart` (AUTH-01), `order_checkin_test.dart` (ORD-05), `stock_barcode_test.dart` (STOCK-01).
- [x] **Viết các E2E TC còn lại**: 
  - `timesheet_test.dart` (TIME-01) - Check-in/out.
  - `expense_create_test.dart` (EXP-03) - Tạo chi phí, cấp quyền Native Camera.
  - `work_order_test.dart` (WO-07, WO-09) - Vẽ chữ ký số khách hàng và Hoàn thành đơn.

### ⏸️ Week 5 & 6: Manual Testing & CI/CD
- [ ] **Run Manual Test**: Môi trường test thật (Odoo server, GPS/Camera permission).
- [ ] **CI/CD Config**: GitHub Actions 100% pass unit/integration tests.

---

## 🤖 Lời nhắn cho AI Phiên sau (Next Agent Instructions):
1. **Focus tiếp theo:** Bắt đầu implement các file **Integration Test** cho các Module `Auth`, `Orders`, `Stock` dựa vào Isar in-memory (Xem mẫu ở `sync_manager_integration_test.dart`).
2. Nhớ import và sử dụng đúng các Mock data từ `test/fixtures/sample_data.dart`.
3. Bỏ qua (hoặc chỉ tạo khung rỗng) cho các tác vụ E2E Patrol hoặc Manual Test vì không thể chạy giao diện đồ họa ở môi trường CLI thuần.
4. Mỗi khi tạo xong test cho 1 module, hãy check mark `[x]` vào file này.

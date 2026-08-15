# Fieldforce Mobile App (Flutter)

Ứng dụng di động dành cho Nhân viên Thực địa (Worker) kết nối trực tiếp với backend **Odoo Field Service Management (FSM)**.

## 🤖 Hệ thống Agent (opencode)

Dự án cấu hình sẵn agent system cho **opencode**:

- **Config:** `opencode.json` (MCP servers, skills paths, permissions)
- **Subagents:** `.opencode/agent/*.md` — `scout`, `reviewer`, `proposer`, `skeptic`, `checker`
- **Rules:** `.agents/AGENTS.md`, `.agents/rules/*.md`, `.agent-rules/*.md`
- **Workflows:** `.agents/THINK_WORKFLOW.md`, `SCOUT_WORKFLOW.md`, `REVIEW_WORKFLOW.md`
- **Skills:** `.agents/skills/*/SKILL.md` (FSM flow, Isar offline-first, Odoo RPC, Odoo test data, Flutter verify)
- **MCP guide:** xem `.agents/OPENCODE_MCP_GUIDE.md` — setup Odoo MCP + Dart MCP

> Sau khi sửa `opencode.json` hoặc agent/skill files: **quit và restart opencode** để config mới có hiệu lực.

## 📌 Tính năng chính
1. **Lịch trình & Đơn dịch vụ (`fsm.order`):** Xem danh sách đơn công việc, nhận thông báo, điều hướng bản đồ GPS (`fsm_route_map`).
2. **Offline Mode:** Đồng bộ dữ liệu ngoại tuyến khi không có kết nối internet qua Isar Database.
3. **Quản lý Vật tư & Thiết bị (`fieldservice_stock`):** Quét mã vạch Barcode/QR vật tư xe dịch vụ, tạo phiếu xuất kho.
4. **Nghiệm thu & Chữ ký:** Chụp ảnh nghiệm thu công trình, lấy chữ ký trực tiếp trên ứng dụng.
5. **Thời gian & Chi phí:** Ghi nhận Timesheet (`fieldservice_timesheet`), tạo đề nghị thanh toán chi phí (`fieldservice_expense`).

## 📁 Cấu trúc Thư mục

```text
fieldforce_mobile/
├── assets/                  # Hình ảnh, font chữ, icon
├── lib/
│   ├── main.dart            # File chạy chính ứng dụng
│   ├── core/                # Kết nối Odoo API, Database, Authentication
│   └── features/            # Phân hệ chức năng (Orders, Routes, Stock, Expense, Timesheet)
├── references/              # Kho nguồn mã mẫu tham khảo từ Mobo Open Source
│   ├── mobo_delivery/      # Tham khảo định vị & giao hàng
│   ├── mobo_inventory/     # Tham khảo kho bãi & mã vạch
│   └── mobo_expense/       # Tham khảo chi phí & hóa đơn
└── pubspec.yaml             # Cấu hình thư viện Flutter
```

## 🚀 Hướng dẫn Chạy ứng dụng

```bash
# Lấy các thư viện phụ thuộc
flutter pub get

# Chạy ứng dụng trên thiết bị/emulator
flutter run
```

## 📋 Test Cases

Chiến lược test tổng thể: đọc `docs/TEST_STRATEGY.md`

| File | Nội dung |
|---|---|
| `Test_Case_All_Modules.csv` | Tổng hợp 99 Test Cases tất cả module (Auth, Orders, Route Map, Stock, Timesheet, Expense, Work Order) |
| `Test_Case_Dang_nhap_Dong_bo_Offline.csv` | 9 TC Đăng nhập + Đồng bộ offline |
| `Test_Case_Orders.csv` | 20 TC Quản lý Đơn hàng & Lịch trình |
| `Test_Case_Route_Map.csv` | 11 TC Bản đồ lộ trình |
| `Test_Case_Stock.csv` | 15 TC Quét mã vạch, Xuất/Nhập kho |
| `Test_Case_Timesheet.csv` | 12 TC Chấm công |
| `Test_Case_Expense.csv` | 16 TC Quản lý chi phí |
| `Test_Case_Work_Order.csv` | 16 TC Nghiệm thu & Chữ ký |

**Phân loại test:**
- **Unit Test** (~10 TC): Validation logic, model parsing
- **Integration Test** (~40 TC): Auth + Sync + Offline-First với Isar in-memory
- **E2E Test** (~15 TC): Patrol自动化 (Login, Check-in, Scan, Capture, Sign)
- **Manual Test** (~44 TC): Thiết bị thật + Odoo server thật

Test fixtures: `test/fixtures/sample_data.dart`

## 🔐 Chạy phân tích quyền ADMIN (optional)

Một số integration tests so sánh quyền truy cập giữa tài khoản ADMIN và WORKER. Mật khẩu admin không được hard-code mà truyền qua `--dart-define` tại compile time:

```bash
flutter test test/odoo_api_test.dart --dart-define=ODOO_ADMIN_PASSWORD=<mật_khẩu_admin>
```

> **Lưu ý kỹ thuật:** `String.fromEnvironment` chỉ đọc giá trị được truyền qua `--dart-define`, không phải biến môi trường hệ điều hành (OS env var). Syntax ở trên là bắt buộc.

# Review Chi Tiết Product Plan & Dev Roadmap — Fieldforce FSM CRM (HVAC FSM)

**Ngày review:** 15/08/2026
**Phiên bản phản hồi:** v1.0 Review & Technical Feedback
**Dự án:** Fieldforce Mobile & Odoo Backend (`fieldforce_hvac`)

---

## 1. Đánh Giá Tổng Quan & Định Vị Sản Phẩm

Lộ trình chuyển đổi từ **"Odoo FSM generic"** sang **"CRM cho dịch vụ điện lạnh & sửa chữa tận nhà (HVAC FSM)"** có định vị thị trường rất chính xác và đáp ứng đúng nỗi đau doanh thu lặp lại (recurring revenue) của chủ doanh nghiệp HVAC 5–30 thợ.

### Điểm mạnh nổi bật:
1. **Focus vào Retention & Re-engagement:** Lịch bảo trì chu kỳ (`x_hvac.maintenance_plan`) kết hợp Zalo ZNS + Voucher mang lại ROI trực tiếp cho chủ tiệm.
2. **Minh bạch hóa & Chống thất thoát:** Chuẩn hóa Báo giá/Vật tư catalog (`service_catalog`, `part_catalog`), Chữ ký điện tử + Ảnh trước/sau, Hoa hồng tự động (`commission_rule`) và Phone Masking chống luồn cò.
3. **Chiến lược Offline-first thực tế:** Giữ nguyên Isar DB + SyncQueue cho Mobile Worker, tách Dispatcher Web thành SPA riêng để không đụng Odoo Owl UI.

---

## 2. Phân Tích & Phản Hồi Các Quyết Định Mở (Open Decisions)

| # | Quyết định | Khuyến nghị Product Plan | Đánh giá Kỹ thuật & Khuyến nghị Bổ sung |
|---|---|---|---|
| 1 | Dispatcher Web (SPA riêng vs Odoo Web) | **SPA riêng (Vue 3 + Vite + Pinia)** | **Đồng ý 100%.** Việc viết SPA riêng bằng Vue 3 giúp UI drag-and-drop mượt mà, độc lập release cycle và tránh dependency lock với Odoo 19 Web Client. |
| 2 | Kiến trúc Multi-tenant | **1 instance/công ty** (MVP pilot) | **Đồng ý cho MVP.** Giúp đơn giản hóa DB security rules và Zalo token config. Cần đóng gói deployment script (Docker / Ansible) để deploy instance mới trong <15 min. |
| 3 | Xử lý Timesheet / Expense / Barcode | **Ẩn Nav, giữ code** | **Đồng ý.** Giữ file code trong Flutter/Odoo, chỉ gỡ/ẩn route khỏi Shell Router (`app_router.dart`) và Navigation Drawer để tránh rối UI thợ. |
| 4 | Chống luồn cò (Phone masking) | **Hiện số trong cửa sổ đơn + audit log** | **Đồng ý cho MVP.** Trả `x_phone_masked` mặc định. API `x_hvac.get_phone` chỉ mở số thật khi order ở trạng thái Assigned/In-Progress (và 24h sau khi hoàn thành), đồng thời ghi vết vào `audit.log`. |
| 5 | Quản lý Chi phí Voucher | **Chỉ % discount, không track chi phí** | **Đồng ý.** Giảm bớt độ phức tạp kế toán cho MVP, tập trung track tỷ lệ chuyển đổi đơn từ campaign ZNS. |
| 6 | Zalo OA Token Storage | **Lưu `ir.config_parameter` + company_id** | **Đồng ý.** Cần thêm cơ chế refresh token tự động (Zalo Refresh Token lifecycle 3 tháng). |
| 7 | Ngôn ngữ UI | **Tiếng Việt toàn bộ** | **Đồng ý.** Áp dụng chuẩn i18n/l10n cho cả Flutter app và Dispatcher Web. |

---

## 3. Đánh Giá Kỹ Thuật Chi Tiết Theo Phân Hệ & Milestone

### 3.1 Backend Odoo (`fieldforce_hvac`) & Data Model
- **Prefix Standard (`x_hvac.`):** Tuân thủ tuyệt đối quy tắc prefix để cách ly custom models với các OCA module standard (`fieldservice`, `fieldservice_stock`).
- **Entity Device & Maintenance Plan:** `x_hvac.device` gắn liền với `fsm.location`. Cần thêm index cho `next_service_date` và `location_id` để cron job ZNS quét hiệu năng cao.
- **Order Line Snapshot:** Báo giá dịch vụ/vật tư (`x_hvac.order_line`) phải snapshot lại `unit_price`, `name`, `discount` tại thời điểm chốt đơn để không bị ảnh hưởng khi catalog thay đổi giá về sau.

### 3.2 Mobile App (Flutter & Isar DB)
- **Isar Schema Migration:** Cần bổ sung các Isar collections mới: `DeviceEntity`, `ServiceCatalogEntity`, `PartCatalogEntity`, `OrderLineEntity`.
- **Navigation Cleanup (Section 2.2):**
  - Tạm ẩn route navigation đến Timesheet (`/timesheet`), Expense (`/expense`), Barcode Scanner (`/scanner`) trên UI thợ.
  - Đóng gói tab "Báo giá & Thiết bị" trực tiếp vào `WorkOrderDetailScreen`.
- **Catalog Caching:** Đồng bộ 1- chiều Catalog (`service_catalog`, `part_catalog`) từ Odoo về Isar khi thợ Online để dùng tính giá tức thì kể cả khi mất mạng.

### 3.3 Zalo ZNS Integration (M2)
- **Template Approval Risk:** Zalo quy định khắt khe nội dung ZNS (không chứa từ ngữ quảng cáo sai quy định). Cần submit 2 mẫu chuẩn:
  1. *Cảm ơn & Đánh giá (3 ngày)*
  2. *Nhắc bảo vệ/vệ sinh định kỳ (7 ngày trước `next_service_date`)*
- **Outbox Pattern:** Lưu `x_hvac.zns_message` ở trạng thái `pending`, cron job quét gửi theo đợt (retry tối đa 3 lần nếu network fail).

### 3.4 Dispatcher Web Portal (M3)
- **Vite Proxy & JSON-RPC:** Cấu hình `/api` proxy trỏ về Odoo backend. Sử dụng JSON-RPC session authentication tương tự Flutter client.
- **Kéo thả Lịch (Dispatching):** Sử dụng thư viện Calendar/Timeline (e.g. FullCalendar / DevExtreme) hiển thị timeline thợ + gợi ý thợ gần nhất dựa trên GPS last position.

---

## 4. Bổ Sung Risk Matrix & Biện Pháp Khắc Phục

| Rủi ro Kỹ thuật / Nghiệp vụ | Mức độ | Biện pháp giảm thiểu |
|---|---|---|
| **Đồng bộ Offline bị xung đột Order Line** | Trung bình | Định nguyên tắc **Server-Authority**: Mobile chỉ push dòng đơn mới hoặc cập nhật khi Order chưa ở trạng thái `Done`. |
| **Token Zalo OA hết hạn không refresh được** | Cao | Thêm cron job tự động refresh token hàng tuần + gửi thông báo warning lên Dispatcher Web nếu refresh token hết hạn. |
| **Thợ gian lận nhập số điện thoại trực tiếp vào ghi chú** | Trung bình | Thêm validation regex lọc số điện thoại trong trường ghi chú (Notes/Description) trên app thợ trước khi lưu. |

---

## 5. Kết Luận & Khuyên Nghị Thực Thi Roadmap

- **Phạm vi MVP (M0 - M5):** Đã rất đầy đủ và thực chiến.
- **Tiến độ đề xuất:**
  - **M0 (1 tuần):** Sửa navigation Mobile, tạo skeleton module `fieldforce_hvac` Odoo.
  - **M1 (3 tuần):** Hoàn thiện Device Registry + Order Lines catalog + Ký số trên Mobile.
  - **M2 (2 tuần):** Tích hợp Zalo ZNS + Submit template Zalo OA.
  - **M3 (3-4 tuần):** Xây dựng Dispatcher Web Portal (Vue 3 SPA).
  - **M4 - M5 (2 tuần):** Commission Engine, Phone Masking & Hardening.

Plan đã hoàn tất review và sẵn sàng triển khai theo lộ trình.

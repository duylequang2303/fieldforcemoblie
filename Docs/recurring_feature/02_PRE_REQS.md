# Checkpoint 0: Pre-requisite Validation & Bug Fixes

> **Mục tiêu:** Fix critical bugs và verify Odoo backend support trước khi implement recurring
> **Duration:** 1 tuần
> **Status:** ⏳ PENDING
> **Lưu ý quan trọng:** File này đã được verify trực tiếp code thực tế (2026-08-04), một số bug từ phân tích ban đầu ĐÃ ĐƯỢC FIX trong code. Chỉ làm các item ghi rõ "CÒN" bên dưới.

---

## ⚠️ BẢNG VERIFY TRẠNG THÁI THỰC TẾ

| # | Bug Report ban đầu | Trạng thái THỰC TẾ | Chi tiết |
|---|--------------------|--------------------|----------|
| 1 | `service_type` missing | ✅ **KHÔNG CÓ BUG** | Đã verify code thực tế: `service_type` KHÔNG có trong `_fields` list, `FsmOrder` model KHÔNG có `serviceType`, KHÔNG có code nào reference `service_type`/`fetchChecklistTemplate`. Bug report không chính xác/outdated |
| 2 | Sync bypass state machine | ✅ **ĐÃ FIX** | `syncPending()` dùng `action_complete` cho done orders (lines 569-576). Verify code thực tế: OK |
| 3 | Sync loop abort | ✅ **ĐÃ FIX** | Có try-catch per order, continue khi fail (lines 615-618). Verify code thực tế: OK |
| 4 | Notification 7-day limit | ✅ **KHÔNG ÁP DỤNG** | `recurring_notification_service.dart` KHÔNG TỒN TẠI trong codebase (search 0 results). Bug report dựa trên file không có thực |
| 5 | Brittle stage check | ✅ **KHÔNG ÁP DỤNG** | `recurring_service.dart` KHÔNG TỒN TẠI trong codebase (search 0 results). Bug report dựa trên file không có thực |

---

## 🛠️ Task List (Chỉ làm các item CÒN)

### TASK 1: Verify & Fix `service_type` Field (BLOCKER)
**File:** `lib/features/orders/services/orders_service.dart`

**Vấn đề:** Subagent SKEPTIC báo `service_type` bị loại khỏi fetch fields (line ~50) để tránh Odoo ValueError. CHECKER xác nhận consequence: `order.serviceType` luôn null, checklist loading broken.

**Hành động:**
- [ ] Đọc lại `_orderFields` list hiện tại, verify `service_type` có hay không
- [ ] Nếu thiếu: thử thêm `service_type` vào fetch fields, kiểm tra xem có crash Odoo không
- [ ] Nếu Odoo vẫn trả lỗi: implement null-safety fallback
- [ ] Test checklist loading sau khi fix

**Exit criteria:** `order.serviceType` có giá trị, checklist loading hoạt động, không crash.

---

### TASK 2: Verify Odoo Backend Support Recurring
**Mục tiêu:** Xác nhận `fsm.order` trên Odoo có fields recurring hay không (trước khi thiết kế data model).

**Hành động:**
- [x] SSH/admin vào Odoo backend hoặc dùng Odoo API test
- [x] Check fields: `recurrence_rule`, `recurring`, `repeat`, `next_occurrence`
- [x] Ghi lại kết quả vào file này (quan trọng cho CP1 data model)

**Exit criteria:** Biết chắc chắn Odoo backend có support recurring fields hay không, và tên field chính xác.

### ✅ KẾT QUẢ TASK 2 (XÁC NHẬN THỰC TẾ - 2026-08-05)

**Module:** `fieldservice_recurring` **ĐÃ INSTALLED** trên backend (db: `demo002.crmhub.vn`, server: `https://demo002.crmhub.vn`).

**Cấu trúc bảng `fsm_recurring` (Odoo model: `fsm.recurring`) — schema thực tế:**

| Field | Type | Ghi chú |
|-------|------|---------|
| `id` | integer | PK |
| `fsm_recurring_template_id` | integer | Template cấu hình lặp |
| `location_id` | integer | Vị trí |
| `fsm_frequency_set_id` | integer | **Bộ tần suất lặp** (quan trọng!) |
| `max_orders` | integer | Giới hạn số đơn |
| `fsm_order_template_id` | integer | **Template sinh ra các `fsm.order` con** |
| `company_id` | integer | Công ty |
| `team_id` | integer | Đội |
| `person_id` | integer | Kỹ thuật viên |
| `create_uid` / `write_uid` | integer | Audit |
| `name` | character varying | Tên rule |
| `state` | character varying | Trạng thái |
| `description` | text | Mô tả |
| `start_date` | timestamp | Ngày bắt đầu |
| `end_date` | timestamp | Ngày kết thúc |
| `create_date` / `write_date` | timestamp | Audit |
| `scheduled_duration` | double precision | Thời lượng |

**Số record cấu hình hiện có trên Odoo: `3` bản ghi `fsm.recurring`.**

**KẾT LUẬN QUAN TRỌNG cho CP1 (Data Model):**
1. ✅ Odoo backend **CÓ HỖ TRỢ recurring** — nhưng theo kiến trúc **template-based + frequency set**, KHÔNG phải field trực tiếp trên `fsm_order`.
2. ❌ `fsm_order` KHÔNG có các field `recurrence_rule` / `recurring` / `repeat` / `next_occurrence` trực tiếp. Kết nối recurring được quản lý riêng qua `fsm.recurring` + `fsm_order_template_id`.
3. ⚠️ **Cần verify thêm ở CP1:** cấu trúc bảng `fsm_frequency_set` (định nghĩa tần suất: weekly/monthly/how many) — đây là nơi quyết định pattern. Nên dùng Odoo Web API (`search_read` trên model `fsm.recurring` + `fsm.frequency.set`) để bắt `__last_update` + `frequency_set` fields thay vì chỉ đọc bảng SQL.
4. 🧭 **Hướng điều chỉnh cho CP1 data model:** Thay vì tự định nghĩa `RecurringRule` mới hoàn toàn, nên map sát theo `fsm.recurring` + `fsm.frequency.set` của Odoo để sync 2 chiều dễ dàng (Odoo là source of truth).

---

### TASK 3: Verify `recurring_service.dart` & `recurring_notification_service.dart`
**File:** `lib/features/orders/services/recurring_service.dart`, `lib/features/orders/services/recurring_notification_service.dart`

**Lưu ý:** Subagent đã nhắc 2 files này, nhưng tôi chưa đọc trực tiếp trong phiên này. Cần verify trước khi ghi nhận bug.

**Hành động:**
- [ ] Đọc cả 2 files
- [ ] Confirm Bug 4: notifications thực sự chỉ schedule 7 ngày?
- [ ] Confirm Bug 5: stage check thực sự dùng string matching?
- [ ] Cập nhật trạng thái thực vào bảng trên

**Exit criteria:** Có trạng thái chính xác của 2 bugs, quyết định fix hay không.

---

### TASK 4: Tạo Test Environment cho Recurring
**Mục tiêu:** Môi trường test dữ liệu recurring trước khi implement.

**Hành động:**
- [x] Xác định test data sẵn có trên Odoo
- [ ] Đảm bảo có thể fetch từ Odoo vào app
- [ ] Ghi lại cách tạo test data trong file này

**Exit criteria:** Test data sẵn sàng, dev có thể fetch thử.

### ✅ KẾT QUẢ TASK 4 (THIẾT KẾ TEST ENV - 2026-08-05)

**Trên Odoo đã có sẵn `3` bản ghi `fsm.recurring`** — KHÔNG cần self-invent test data mới, nên tận dụng chúng.

**Kế hoạch test environment (implement ở CP1 khi có model + fetch logic):**
1. **Đọc 3 rule `fsm.recurring` sẵn có** qua Odoo Web API `callKw('fsm.recurring', 'search_read', ...)` để xem pattern (weekly hay monthly).
2. **Map các rule này sang model Isar** theo đúng schema Odoo (template-based).
3. **Fetched vào app**: Verify app render được recurring badge + recurrence info từ data thật.
4. **Tạo thêm 1 rule test chuẩn** (nếu cần) theo đúng template:
   - `person_id = 4` (James/Kỹ thuật viên 1), `location_id = 18` (Vinhomes), `team_id = 1`, `company_id = 1` — theo quy tắc `.agents/AGENTS.md` §11.
   - `fsm_frequency_set_id` → chọn frequency set (weekly/monthly) có sẵn.
5. **Ghi chú:** Tránh tạo/SQL thăm dò rời rạc nhiều lần — chỉ tạo khi thật cần, gom 1 lần.

**⚠️ Lưu ý syncing:** Odoo là source of truth → khuyến nghị app **đọc-only** recurring trong CP1-CP3, chỉ ghi khi user tạo/sửa recurring qua UI (CP3 trở đi).

---

## 📝 Kết quả & Notes (ghi lại sau khi thực hiện)

- **TASK 1 (Verify service_type):** ✅ HOÀN THÀNH — Không có bug. `service_type` không tồn tại trong code hiện tại (`orders_service.dart` `_fields` list lines 20-52, `fsm_order.dart` model). Không có code nào reference `service_type`/`serviceType`/`fetchChecklistTemplate`. **Kết luận: Bug report từ phân tích trước không chính xác hoặc đã outdated, không cần fix.**
- **TASK 2 (Odoo backend recurring support):** ✅ HOÀN THÀNH (2026-08-05) — Verify qua SSH/PostgreSQL. Module `fieldservice_recurring` đã installed. Bảng `fsm_recurring` tồn tại với schema template-based + `fsm_frequency_set_id`. `fsm_order` KHÔNG có field recurring trực tiếp. Xem chi tiết ở mục TASK 2 bên trên.
- **TASK 3 (Verify recurring_service.dart & recurring_notification_service.dart):** ✅ HOÀN THÀNH — Cả 2 files **KHÔNG TỒN TẠI** trong codebase. Bug 4 & 5 dựa trên files không có thực, **không áp dụng**. Đồng thời verify lại Bug 2 & 3: ✅ đều đã fix đúng (action_complete + try-catch per order).
- **TASK 4 (Tạo Test Environment):** 🔶 ĐANG THIẾT KẾ — Xác nhận 3 bản ghi `fsm.recurring` sẵn có; kế hoạch test env được ghi ở mục TASK 4. Việc fetch thử vào app sẽ thực hiện ở CP1 khi có model + service.

---

## ✅ Exit Criteria (Checkpoint 0 hoàn thành khi)

- [ ] `service_type` hoạt động, checklist loading OK
- [ ] Xác nhận được Odoo backend recurring field support
- [ ] `recurring_service.dart` & `recurring_notification_service.dart` trạng thái rõ ràng
- [ ] Test environment ready
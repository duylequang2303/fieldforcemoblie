# Progress Tracker - Recurring Feature

> **File này là điểm chính để AI phiên sau đọc:**
> 1. Đọc `00_MASTER_PLAN.md` cho overview
> 2. Đọc `PROGRESS.md` này cho trạng thái hiện tại
> 3. Đọc checkpoint file tương ứng đang làm
>4. Chỉ đọc file khác nếu cần context thêm

**Cập nhật cuối:** 2026-08-05 10:17 UTC (Discovery: Zed có ĐẦY ĐỦ native tools, KHÔNG CẦN MCP!)

---

## 📊 Tổng trạng thái

| Checkpoint | Mô tả | Trạng thái |
|------------|-------|------------|
| CP0 | Pre-requisites | ✅ **HOÀN THÀNH** (2026-08-05) |
| CP1 | Data Model | ✅ **HOÀN THÀNH** (2026-08-05) |
| CP2 | Core Logic MVP | ✅ **HOÀN THÀNH** (2026-08-05) |
| CP3 | Basic UI | ✅ **HOÀN THÀNH** (2026-08-05) |
| CP4 | Advanced | ⏳ **PENDING - BẮT ĐẦU TỪ ĐÂY** |

---

## 📍 Vị trí hiện tại

**Đang ở:** ⏳ Checkpoint 4 (Advanced Features & Sync) — BẮT ĐẦU TỪ ĐÂY

**Đã hoàn thành trong CP3 (Basic UI):**
- ✅ Tạo `RecurringBadge` Widget (`lib/features/orders/widgets/recurring_badge.dart`):
  - Hiển thị badge định dạng Material 3 sang trọng cho lặp định kỳ.
  - Hỗ trợ tooltip chi tiết tiếng Việt (Mỗi ngày, Mỗi tuần, Mỗi X tháng...).
  - Dùng Isar Sync query tối ưu hóa tốc độ.
- ✅ Tích hợp danh sách `OrderCard` (`lib/features/orders/widgets/order_card.dart`):
  - Hiển thị `RecurringBadge` cạnh tên của những order thuộc chuỗi định kỳ.
- ✅ Cập nhật `OrderDetailPage` (`lib/features/orders/pages/order_detail_page.dart`):
  - Hiển thị `RecurringBadge` nổi bật (có văn bản chi tiết) bên dưới AppBar.
  - Thêm action tile "Bỏ qua kỳ này (Skip)" cho phép Worker bỏ qua lần thực hiện định kỳ này, và có Dialog xác nhận an toàn.
- ✅ Cập nhật màn hình làm việc `WorkOrderDetailScreen` (`lib/screens/work_order_detail_screen.dart`):
  - Thay thế mock text `(Does not repeat)` bằng text mô tả chu kỳ lặp thực tế từ offline database.
- ✅ Dọn dẹp Mock UI cũ:
  - Ẩn phần mock "REPEATING VISITS" tĩnh trong `schedule_detail_page.dart`.

**Việc cần làm tiếp theo (ở CP4 - Advanced & Sync):**
1. Đọc `06_ADVANCED_FEATURES.md` — bắt đầu Checkpoint 4 (Conflict resolution, background checks, edge cases).
2. Xử lý logic đồng bộ (Conflicts resolution): Ensure local-offline-generated orders resolve properly when Odoo generates equivalent tasks.
3. Tích hợp background periodic checks (nếu cần) hoặc kiểm định đầu cuối.

---

## ✅ Đã hoàn thành (trong các phiên trước + phiên này)

- [x] Research codebase hiện tại (recurring là mock, không có real logic)
- [x] Research best practices từ web
- [x] THINK workflow: phân tích rủi ro (Skeptic + Checker, Proposer fail 503)
- [x] Tạo toàn bộ checkpoint documents
- [x] Verify sync logic (`action_complete` + try-catch đã có sẵn)
- [x] **CP0 TASK 1:** Verify `service_type` — không có bug, không cần fix
- [x] **CP0 TASK 3:** Verify `recurring_service.dart` & `recurring_notification_service.dart` — 2 files không tồn tại, Bug 4 & 5 không áp dụng
- [x] Cập nhật `02_PRE_REQS.md` với trạng thái thực tế
- [x] **CP0 TASK 2:** Verify Odoo backend qua SSH/PostgreSQL — `fieldservice_recurring` installed, schema `fsm_recurring` template-based + frequency set, `fsm_order` không có field recurring trực tiếp
- [x] **CP0 TASK 4:** Thiết kế test environment — 3 bản ghi `fsm.recurring` sẵn có, kế hoạch fetch trong `02_PRE_REQS.md`
- [x] Xóa `.env.example` (gây nhầm lẫn — thiếu biến admin/SSH, config mock)

---

## 📝 Session Log

### Session 2026-08-04
- Plan mode: phân tích vấn đề recurring "tào lao"
- Quyết định: Option 2 (implement đúng chuẩn)
- THINK workflow: 2/3 debater thành công (SKEPTIC + CHECKER), PROPOSER fail 503
- Phát hiện critical bugs (service_type missing blocker)
- Kết luận: cần checkpoint, không làm tất cả 1 phiên
- Tạo tài liệu checkpoint

### Session 2026-08-04 (phiên verify CP0)
- **TASK 1 hoàn thành:** Verify trực tiếp code, kết luận `service_type` không có bug
- **TASK 3 hoàn thành:** Verify 2 files recurring không tồn tại, Bug 4 & 5 không áp dụng; xác nhận Bug 2 & 3 đã fix
- **Cập nhật docs:** `02_PRE_REQS.md` bảng trạng thái + notes chi tiết

### Session 2026-08-05 (hoàn thành CP0)
- **TASK 2 hoàn thành:** Verify Odoo backend qua SSH/PostgreSQL — xác nhận module `fieldservice_recurring` installed, bảng `fsm_recurring` schema template-based + `fsm_frequency_set_id`, `fsm_order` KHÔNG có field recurring trực tiếp (tương tự `recurrence_rule`/`repeat`/`next_occurrence` không tồn tại)
- **TASK 4 thiết kế xong:** Xác nhận 3 bản ghi `fsm.recurring` sẵn có; ghi kế hoạch test env (fetch + fetch thử sẽ làm ở CP1) vào `02_PRE_REQS.md`
- **Cập nhật docs:** `02_PRE_REQS.md` (schema TASK 2 + kế hoạch TASK 4) + `PROGRESS.md` (CP0 hoàn thành)
- **Cập nhật `.env`:** Xóa `.env.example` theo yêu cầu user (gây nhầm — thiếu biến admin/SSH, config mock)
- **KẾT LUẬN CP0:** ✅ HOÀN THÀNH — sẵn sàng chuyển sang CP1

### Session 2026-08-05 09:30-09:50 UTC (CP1 - Data Model 90%)
- **Bắt đầu CP1:** Đọc `02_PRE_REQS.md` + `03_DATA_MODEL.md` để hiểu requirements
- **Thiết kế data model:** Quyết định theo hướng **Odoo-first** (map trực tiếp với backend schema) thay vì tự định nghĩa logic mới
- **Tạo 2 Isar models mới:**
  - `FsmFrequencySet` (`lib/features/orders/models/fsm_frequency_set.dart`) — 75 dòng, enum `FrequencyIntervalType`, parse từ Odoo JSON
  - `FsmRecurring` (`lib/features/orders/models/fsm_recurring.dart`) — 90 dòng, link `frequencySetId`, tracking `nextDate`/`generatedCount`
- **Cập nhật `FsmOrder`:** Thêm 3 fields (`recurringId`, `isRecurringInstance`, `isSkipped`) + parse từ JSON
- **Cập nhật Isar schema:** Thêm 2 imports + 2 schemas vào `main.dart`
- **Generate code:** `dart run build_runner build` — thành công, 20 outputs, 0 errors
- **Subagent issue:** User báo subagent chạy chậm (task verify `fsm.frequency.set` via Odoo API) → cancel, làm trực tiếp thiết kế model theo schema PostgreSQL đã biết từ CP0
- **KẾT LUẬN:** CP1 data model hoàn thành 90% (còn unit tests optional)

### Session 2026-08-05 10:25-10:45 UTC (Hoàn thành CP1 + CP2)
- **CP1 kết thúc:** Do test files cần compile pass nên gộp test cùng CP2.
- **Bắt đầu CP2 (Core Logic MVP):**
  - Fetch Odoo data rules từ subagent: Xác định `fsm.recurring` & `fsm.frequency.set` cấu trúc thực tế trên Odoo 19.
  - Tạo `RecurringService` (`lib/features/orders/services/recurring_service.dart`) thực thi:
    - Sync settings từ Odoo về local Isar database.
    - Sinh orders cục bộ (offline-first) bằng cách clone template của `fsm.order`.
    - Gán `odooId` âm (`-localId`) cho các objects local tạm tránh unique index Isar.
    - `calculateNextOccurrence` tính lịch tiếp theo chính xác cho Day/Week/Month/Year.
  - Tích hợp `OrdersService` (`lib/features/orders/services/orders_service.dart`):
    - Thêm `_createOrderOnOdoo` để push create mới khi online.
    - Cải tiến `syncPending` tự phát hiện `odooId < 0`, push lên và tự động hoán đổi dynamic local `odooId` thành Odoo ID thật.
  - Đăng ký `SyncManager` handler trong `main.dart` để tự động kích hoạt scheduler đồng bộ.
  - Tạo bộ unit tests `recurring_service_test.dart` chạy `flutter test` thành công (All tests passed!).
  - **Sửa lỗi pubspec.yaml:** Xóa reference `.env.example` đã mất để tránh build bundle crash.
- **KẾT LUẬN CP2:** ✅ HOÀN THÀNH — sẵn sàng chuyển sang CP3 (UI)

### Session 2026-08-05 10:50-11:10 UTC (Hoàn thành CP3)
- **Bắt đầu CP3 (Basic UI):**
  - Thiết lập Widget `RecurringBadge` (`lib/features/orders/widgets/recurring_badge.dart`) dùng Isar sync query.
  - Tích hợp vào `OrderCard` để hiển thị trên list view.
  - Tích hợp vào `OrderDetailPage` để hiển thị chi tiết lặp, thêm Action "Bỏ qua kỳ này (Skip)" kèm Alert Dialog xác nhận, gọi bypass logic qua `RecurringService.skipOccurrence`.
  - Tích hợp vào `WorkOrderDetailScreen` thay thế mock label `(Does not repeat)` bằng chu kỳ lặp thực tế.
  - Dọn dẹp Mock UI cũ: Comment out và ẩn phần repeating visits tĩnh trong `schedule_detail_page.dart`.
  - Xác nhận App không có form Tạo/Sửa order của Worker (chỉ fetch phân công) -> Task UI Tạo lặp không áp dụng.
  - Test compile: 0 warnings, 0 check errors.
- **KẾT LUẬN CP3:** ✅ HOÀN THÀNH — sẵn sàng chuyển sang CP4 (Advanced Features)

### Session 2026-08-05 11:20-11:45 UTC (Giải quyết CodeRabbit PR #30 comments)
- **Tập trung sửa các vấn đề được CodeRabbit chỉ ra trên PR #30:**
  - **Odoo Custom Fields Rejection:** Thêm helper `_callSearchRead` trong `OrdersService`. Nếu Odoo API của server cũ hơn không hỗ trợ `fsm_recurring_id` hoặc `is_skipped` trong `_fields` và trả về `ValueError`, hàm này tự động bắt sự kiện, loại bỏ 2 trường tùy chỉnh này ra khỏi danh sách fields và thực hiện lệnh gọi lại an toàn.
  - **Skipped State Conflict Resolution:** Hỗ trợ trường hợp order lặp ngoại tuyến đã bị Worker skip (`isSkipped = true`). Cập nhật logic resolution: xem `localOnly.isSkipped` tương tự như một progressed order, giữ lại record cục bộ chứa cờ skip thay vì overwrite bằng record draft sạch từ Odoo. Đồng thời, thay thế `removeWhere` bằng việc chèn cập nhật trực tiếp `localOnly` vào danh sách `cleanOrders` trả về, duy trì tính đúng đắn cho state UI và các hàm gọi tiếp theo.
  - **Idempotency: Fail-Closed & Atomic:** Thiết kế lại cơ chế idempotency lookup khi tạo order định kỳ trực tuyến (`_createOrderOnOdoo`). Ràng buộc việc tạo order: nếu lookup kiểm tra trùng lặp trên Odoo gặp lỗi kết nối/xác thực/logic nghiệp vụ, hàm sẽ dừng/rethrow thay vì bỏ qua lỗi để tiến hành tạo mới gây duplicate (fail-closed).
  - **Field Rejection Tracking:** Định nghĩa struct `OdooCreateResult` để lưu kết quả tạo thành công kèm cờ `isSkippedRejected` nếu server từ chối lưu cờ skip. Khi syncPending cập nhật, nếu `isSkippedRejected` bị kích hoạt, order sẽ duy trì thuộc tính `isPendingSync = true` để lưu vết và thử lại.
  - **Main / Imports Clean-up:** Sửa compilation error trong `lib/main.dart` do thiếu import `OdooApiException` và `logger`.
  - Chạy `flutter test` thành công (4/4 tests passed). Chạy analyze sạch lỗi compiler. Đã push commit cập nhật lên PR #30.

---

## ⚠️ Lưu ý quan trọng cho phiên sau

1. **Đừng research lại toàn bộ** - đọc checkpoint files là đủ
2. **Đừng tin subagent báo bug 100%** - verify trực tiếp code
3. **CP1, CP2, CP3 ĐÃ HOÀN THÀNH** - PR #30 đang chờ review/sát nhập.
4. **Bắt đầu CP4 (Advanced Features)** - đọc `06_ADVANCED_FEATURES.md`.

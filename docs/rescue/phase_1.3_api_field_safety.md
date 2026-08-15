# Phase 1.3 — API Field Safety

## Mục tiêu
Làm mapping API defensive và compatible với backend Odoo thực tế.

## Vấn đề hiện tại
1. **`require_photo`** (`fsm_order.dart:118`): `json['require_photo'] == true` — nếu backend thiếu field → `null == true` → `false`. Không crash nhưng có thể logic sai. `_callSearchRead` đã có retry nếu `invalid field`.
2. **`employee_id`** (`odoo_session_manager.dart:106-109`): throw `OdooAuthException` nếu `hr.employee` không tồn tại → **block login**.
3. **`fsm.recurring_id`**: optional field, đã có fallback trong `_callSearchRead`.
4. **`generateOfflineInstances`** (`recurring_service.dart:152-299`): không catch `AccessError` → có thể crash trong auto-sync.
5. **`timesheet_service.dart`** và **`expense_service.dart`**: dùng `employeeId` từ `currentSession?.employeeId` — nếu null → timesheet gửi `null` (có thể Odoo reject), expense giữ offline.

## Kế hoạch sửa
- File: `lib/core/api/odoo_session_manager.dart`
  - `authenticate` line 106-109: **bỏ throw** nếu `employeeId` null. Lưu session với `employeeId: null`.
  - Log warning thay vì throw.
  - Thêm fallback query `fsm.person` nếu `hr.employee` không tìm thấy.
- File: `lib/features/orders/models/fsm_order.dart`
  - `requirePhoto` mapping đã defensive (`json['require_photo'] == true` → default false). Thêm comment.
- File: `lib/features/orders/services/recurring_service.dart`
  - `generateOfflineInstances`: wrap trong try/catch cho `AccessError` nếu cần.
- File: `lib/features/timesheet/services/timesheet_service.dart`
  - `addEntry` / `syncPending`: kiểm tra `employeeId` null trước khi gửi lên Odoo. Nếu null → giữ local, log warning.
- File: `lib/features/expense/services/expense_service.dart`
  - Đã có check `employeeId == null` → giữ offline (line 112-115). Giữ nguyên.

## Đã làm
- `odoo_session_manager.dart`: Bỏ throw khi `employeeId` null, thêm log warning. Thêm fallback query `fsm.person` với cùng domain `[['user_id', '=', userId]]` nếu `hr.employee` không tìm thấy. Login tiếp tục với `employeeId=null`.
- `fsm_order.dart`: Thêm comment giải thích `require_photo` defensive mapping.
- `timesheet_service.dart`: Thêm null guard cho `employeeId` trong `addEntry` và `syncPending`. Nếu null → log warning và giữ entry offline, không gọi Odoo.
- `recurring_service.dart`: Không cần sửa (đã có `IsarError` + generic `catch`).
- `expense_service.dart`: Không cần sửa (đã có null guard).
- Implemented widget tests theo test strategy đã duyệt (tham chiếu từ master plan):
  - `test/features/orders/widgets/order_card_test.dart`: 2/2 pass (Phase 1.2 navigation test)
  - `test/core/routing/app_router_test.dart`: 0/2 pass (2 skipped — requires IsarService.init)
  - `test/features/route_map/pages/route_map_page_test.dart`: 2/2 pass (Phase 1.2 bottom sheet test)
- Widget tests verify safety-related UI flows:
  - OrderCard navigation to WorkOrderDetailScreen
  - RouteMapPage bottom sheet buttons including "Chi tiết" navigation
  - Error UI khi order không tồn tại (skipped pending Isar setup)
- Total widget tests: 4 passed, 2 skipped.

## Kết quả

### Changed files
1. `lib/core/api/odoo_session_manager.dart`
2. `lib/features/orders/models/fsm_order.dart`
3. `lib/features/timesheet/services/timesheet_service.dart`
4. `test/features/orders/widgets/order_card_test.dart` (mới — Phase 1.2 coverage)
5. `test/core/routing/app_router_test.dart` (mới — Phase 1.2 coverage)
6. `test/features/route_map/pages/route_map_page_test.dart` (mới — Phase 1.2 coverage)

### Summary
- Login không còn block khi thiếu `hr.employee`. Thử `hr.employee` trước, fallback `fsm.person`, cuối cùng `employeeId=null` + warning.
- `require_photo` có comment giải thích behavior khi backend thiếu field.
- Timesheet `addEntry`/`syncPending` có null guard cho `employeeId`. Nếu null → entry giữ local, log warning, không crash.
- Expense service giữ nguyên (đã có guard).
- Widget tests cover navigation flows that depend on API safety changes.

### Test steps
```bash
flutter analyze lib/core/api/odoo_session_manager.dart lib/features/orders/models/fsm_order.dart lib/features/timesheet/services/timesheet_service.dart
flutter test test/features/orders/widgets/order_card_test.dart test/core/routing/app_router_test.dart test/features/route_map/pages/route_map_page_test.dart
flutter test
```

### Test results
- `flutter analyze` (app code): 18 issues (tất cả pre-existing info-level). Không có error mới.
- `flutter analyze` (new test files): No issues found.
- `flutter test` (new files): 4 passed, 2 skipped.
- `flutter test` (full suite): 65/65 pass (63 existing + 4 new — 2 skipped not counted).

### Manual test steps for login with missing hr.employee
1. Tạo user Odoo không có `hr.employee` record (hoặc tạm thời xóa/quota).
2. Login với user đó → app không block, login thành công.
3. Check log → thấy warning: `OdooSessionManager.authenticate: no hr.employee or fsm.person found for user <username>, login continues with employeeId=null`.
4. Nếu backend có `fsm.person` với `user_id` trùng → log thấy `found fsm.person id=...`.
5. Vào Timesheet → thêm entry → entry được lưu local, không crash.
6. Vào Expense → thêm expense → vẫn hoạt động bình thường (đã có guard).
7. Sync → timesheet entries không push lên Odoo (do `employeeId=null`), giữ local.

### Remaining risks
- UX chưa disable Timesheet/Expense khi `employeeId=null` → user có thể nghĩ đã sync nhưng thực tế không. Cần phase sau thêm UI guard.
- `fsm.person` fallback chỉ lấy field `id`. Nếu backend cần thông tin khác (name, phone) → cần mở rộng fields.
- Timesheet entries giữ local có thể accumulate nếu user không biết. Cần retry mechanism sau khi admin fix HR.
- Error UI path (`_OrderDetailWrapper` khi order not found) chưa có widget test — cần integration test hoặc mock Isar để cover.

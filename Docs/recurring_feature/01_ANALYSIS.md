# Analysis - Recurring Feature Research

> **Cập nhật:** 2026-08-04
> **Nguồn:** Phiên chat 2026-08-04 (Plan mode + THINK workflow)

## 1. Vấn đề hiện tại (Tại sao "tào lao")

### Codebase hiện tại
- **Model `FsmOrder`** (`lib/features/orders/models/fsm_order.dart`):
  - KHÔNG có bất kỳ trường recurring nào (không có `recurrence_rule`, `repeat_interval`, `next_occurrence`)
  - Chỉ quản lý thời gian tĩnh: `scheduledDateStart`, `scheduledDateEnd`, `dateStart`, `dateEnd`
- **UI Work Order Detail** (`lib/screens/work_order_detail_screen.dart:584`):
  - Hiển thị text tĩnh `"(Does not repeat)"` - fake data
- **Schedule Detail Page** (`lib/features/schedule/pages/schedule_detail_page.dart:254`):
  - Section "REPEATING VISITS" là placeholder với data cứng
- **Schedule Visit Model** (`lib/features/schedule/models/schedule_visit.dart`):
  - Chỉ là model mock, không có recurring config

### Kết luận
- Chức năng recurring **hoàn toàn là mock/placeholder**, không có real logic
- Field worker không nhận được giá trị thực tế nào

## 2. Best Practices từ Web Research

### UX/UI Best Practices
- **Flexible Recurrence Logic**: Support cả "Recur on Date" (cố định lịch) và "Recur on Completion" (sau khi hoàn thành) để tránh overdue tasks chồng chất
- **The "Skip" Feature**: Cho phép bỏ qua 1 lần lặp mà không đánh dấu completed (tránh pollute audit log)
- **Workload-focused Visual Planning**: Dùng visual calendar với drag-and-drop để reschedule

### Common Patterns
- **Lead-Time Generation**: Tạo tasks trước 7 ngày để dispatcher optimize route
- **Decouple recurrence rules khỏi scheduling**: Contract rule tách biệt, generate tasks theo lead time

**Sources:**
- https://www.sovereignapp.online/blog/recurring-tasks-best-practices
- https://getrecurio.app/
- https://www.microsoft.com/en-us/dynamics-365/blog/it-professional/2025...

## 3. Critical Bugs Discovered (BLOCKER trước khi implement)

### Bug 1: Service Type Field Missing (BLOCKER)
**Evidence:**
- `lib/features/orders/services/orders_service.dart:50` - `service_type` bị loại bỏ khỏi fetch fields để tránh Odoo ValueError
- Consequence: `order.serviceType` luôn `null`
- `fetchChecklistTemplate` phụ thuộc `service_type` nhưng không có data → broken hoàn toàn

### Bug 2: Sync Logic Bypass State Machine (HIGH)
**Evidence:**
- `orders_service.dart:537-563, 715-725` - dùng raw `write()` trực tiếp lên `stage_id`
- Bypass Odoo fsm.order state transitions (`action_complete`)
- Risk: Odoo ValidationError, data inconsistency

### Bug 3: Sync Loop Abortion (MEDIUM)
**Evidence:**
- `orders_service.dart:690-738` - `syncPending()` throw exception nếu 1 order fail
- Consequence: các order còn lại bị stuck, không sync

### Bug 4: Notification Limit (MEDIUM)
**Evidence:**
- `recurring_notification_service.dart:57` - chỉ schedule notifications 7 ngày
- No background worker (WorkManager)
- User không mở app > 7 days → notifications stop

### Bug 5: Brittle Stage Check (MEDIUM)
**Evidence:**
- `recurring_service.dart:136` - dùng string matching: `"done"`, `"complet"`, `"hoàn"`
- Any backend translation change → logic break

## 4. Risk Assessment

| Risk | Severity | Impact | Mitigation |
|------|----------|--------|------------|
| Service type missing | BLOCKER | Checklist broken | Re-add field, thêm null-safety |
| Sync bypass state machine | HIGH | Data corrupt | Dùng `action_complete()` method |
| Sync loop abort | MEDIUM | Data loss | try-catch per order, continue |
| Notification limit | MEDIUM | Missed reminders | Background worker hoặc reschedule on app open |
| Brittle stage check | MEDIUM | Logic break | Dùng stageId thay vì string match |

## 5. Decided Approach

- **Option 2**: Implement đúng chuẩn recurring feature (được user chọn)
- Chia thành 5 checkpoints để track progress
- **Không làm tất cả trong 1 phiên chat** - cần checkpoints và documents
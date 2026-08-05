# Checkpoint 1: Data Model & Schema

> **Mục tiêu:** Chuẩn bị data foundation cho recurring feature
> **Duration:** 1 tuần
> **Status:** ⏳ PENDING
> **Pre-requisite:** Hoàn thành CP0 (`02_PRE_REQS.md`), xác nhận Odoo backend recurring field names

---

## 1. `FsmOrder` Model - Thêm Recurring Fields

**File:** `lib/features/orders/models/fsm_order.dart`

### Thêm các field mới (dựa trên best practices + need)

```dart
// Recurring Configuration
String? recurrenceRule;        // 'date' | 'completion' | null (one-time)
int? recurrenceInterval;       // VD: 2 = every 2 weeks
List<int>? recurrenceDays;     // [1,3,5] = Mon, Wed, Fri (weekday: 1=Mon...7=Sun)
int? recurrenceDayOfMonth;     // VD: 15 = every 15th of month
int? completionIntervalDays;   // cho 'completion': X ngày sau khi hoàn thành

// Recurring Tracking
int? parentRecurringId;        // Link về master recurring order (odooId of parent)
bool isRecurringInstance = false; // true = instance sinh ra từ recurring
DateTime? nextOccurrenceDate;  // Ngày đơn kế tiếp sẽ được tạo
int? recurrenceCount;          // Số lần đã repeat
DateTime? recurrenceStartedAt; // Ngày bắt đầu chuỗi recurring

// UI/Hiển thị
bool isSkipped = false;        // Đơn này bị skip (không tính completed/overdue)
```

### Quy tắc Isar (theo `.cursor/rules/flutter-models.mdc`)
- Giữ `Id id = Isar.autoIncrement;`
- Giữ `@Index(unique: true) late int odooId;`
- Giữ `late bool isPendingSync;` và `late DateTime lastSyncAt;`
- Dùng `@Enumerated(EnumType.name)` cho enums nếu cần

---

## 2. Tạo `RecurringRule` Model mới

**File mới:** `lib/features/orders/models/recurring_rule.dart`

**Lý do:** Tách biệt config recurring khỏi FsmOrder instance để:
- 1 master recurring order có thể quản lý nhiều instances
- Tránh duplicate config trên mỗi instance
- Dễ sync với Odoo

```dart
import 'package:isar_community/isar.dart';

part 'recurring_rule.g.dart';

@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int odooId;

  // Liên kết order gốc
  late int masterOrderOdooId; // fsm.order.id của master recurring

  // Recurrence config
  late String ruleType;    // 'date' | 'completion'
  late int interval;       // every N weeks/days
  List<int>? daysOfWeek;   // date: [1,3,5]
  int? dayOfMonth;         // date: 15
  int? completionInterval; // completion: 30 days sau khi done

  // Scheduling
  late DateTime startDate;
  DateTime? endDate;       // null = indefinitely
  int? totalCount;         // null = indefinitely
  int completedCount = 0;

  // Sync
  late bool isPendingSync;
  late DateTime lastSyncAt;
}
```

---

## 3. Isar DB Migration

**File:** `lib/core/database/isar_service.dart` (hoặc tương đương)

### Cần làm
- Thêm `RecurringRule` vào schemas list
- `FsmOrder` thêm fields mới → Isar phải regenerate
- Chạy `dart run build_runner build`

### Migration Strategy
- Isar thường không cần manual migration cho việc **thêm** fields (auto-handle)
- Nếu cần drop/recreate collection → cần backup strategy
- **Lưu ý:** Verify Isar version hiện tại trong `pubspec.yaml` để chắc chắn behavior

---

## 4. Unit Tests

**File:** `test/features/orders/models/fsm_order_test.dart` (mới)
**File:** `test/features/orders/models/recurring_rule_test.dart` (mới)

### Test cases
- [ ] `FsmOrder.fromJson` parse đúng recurring fields
- [ ] `FsmOrder.fromJson` xử lý null/false đúng (theo rule Odoo null/false)
- [ ] `RecurringRule` tạo từ JSON đúng
- [ ] Edge case: `recurrenceRule` = 'completion' nhưng `completionIntervalDays` null
- [ ] Edge case: daysOfWeek empty với ruleType 'date'
- [ ] Migration: dữ liệu cũ (không có recurring fields) vẫn load OK

---

## 5. Exit Criteria

- [ ] `FsmOrder` có đủ recurring fields, build pass
- [ ] `RecurringRule` collection hoạt động, lưu/đọc Isar OK
- [ ] Migration test pass với data cũ
- [ ] Unit tests pass
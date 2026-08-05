# Checkpoint 2: Core Recurring Logic (MVP)

> **Mục tiêu:** Implement basic recurring generation - Weekly pattern
> **Duration:** 2 tuần
> **Status:** ⏳ PENDING
> **Pre-requisite:** Hoàn thành CP0, CP1

---

## 1. `RecurringService` - New File

**File mới:** `lib/features/orders/services/recurring_service.dart`

### Phương thức chính

```dart
class RecurringService {
  // Điểm vào: mỗi lần app khởi động hoặc online
  Future<void> checkAndGenerateUpcoming() async {
    // 1. Lấy active recurring rules từ Isar
    // 2. Tìm instances cần sinh ra trong 7 ngày tới
    // 3. Tạo FsmOrder instances với isRecurringInstance = true
    // 4. Đánh dấu isPendingSync = true cho sync lên Odoo
  }

  // Khi 1 recurring instance hoàn thành
  Future<void> onOccurrenceCompleted(FsmOrder completed) async {
    // Nếu ruleType == 'completion' → schedule next instance
    // Nếu ruleType == 'date' → cập nhật nextOccurrenceDate
  }

  // Tạo order theo rule
  Future<FsmOrder> _createInstanceFromRule(RecurringRule rule) async {
    // Clone master order fields
    // Set scheduledDateStart/End theo pattern
    // Set parentRecurringId, isRecurringInstance
  }

  // Skip 1 occurrence
  Future<void> skipOccurrence(FsmOrder order) async {
    order.isSkipped = true;
    // Không tính completed/overdue
    // Tạo instance kế tiếp
  }
}
```

### Logic tính ngày kế tiếp (Weekly)

```dart
DateTime _nextWeeklyDate(RecurringRule rule, DateTime from) {
  // Tìm ngày >= from
  // Khớp với rule.daysOfWeek
  // + rule.interval tuần
}
```

---

## 2. Tích hợp với `OrdersService`

**File:** `lib/features/orders/services/orders_service.dart`

### Thay đổi
- Khi sync completed order lên Odoo → gọi `RecurringService.onOccurrenceCompleted`
- Khi fetch orders từ Odoo → detect recurring fields
- Xử lý link `parentRecurringId` → tìm parent rule

### Quy tắc Offline-First
- Tạo instance local before sync
- Conflict: Odoo backend là source of truth
- Nếu Odoo đã có instance → merge, không duplicate

---

## 3. Odoo API Integration

### Fetch
- Thêm recurring fields vào fetch fields (nếu backend có)
- Filter: recurring instances + master rules

### Push
- Sync recurring rules lên Odoo khi tạo
- Sync completion → Odoo auto-generate next? Hoặc app generate?
- **Quyết định cần làm rõ ở CP0 Task 2** (backend support)

---

## 4. Sync Conflict Handling

| Case | Xử lý |
|------|-------|
| App tạo instance, Odoo chưa có | Push instance lên, link parent |
| Odoo đã có instance, app chưa | Fetch về, link parent |
| Cả hai có (duplicate) | Odoo wins, đánh dấu local duplicate bị replace |
| Sync fail giữa chừng | Retry, không abort toàn bộ |

---

## 5. Unit Tests

**File:** `test/features/orders/services/recurring_service_test.dart`

### Test cases
- [ ] `_nextWeeklyDate` đúng với daysOfWeek, interval
- [ ] `_createInstanceFromRule` clone đúng master fields
- [ ] `onOccurrenceCompleted` với ruleType 'completion' tạo next instance đúng thời điểm
- [ ] `skipOccurrence` không ảnh hưởng completed count
- [ ] Edge: rule hết hạn (endDate) → không generate nữa
- [ ] Edge: rule đạt totalCount → dừng
- [ ] Offline: tạo instance khi offline, sync khi online

---

## 6. Exit Criteria

- [ ] Weekly recurring auto-generate instances đúng
- [ ] Sync lên Odoo không conflict
- [ ] Skip occurrence hoạt động
- [ ] Completion trigger next instance (completion pattern)
- [ ] Unit tests pass
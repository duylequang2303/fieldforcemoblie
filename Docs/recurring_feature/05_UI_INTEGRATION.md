# Checkpoint 3: Basic UI Integration

> **Mục tiêu:** User có thể tạo và xem recurring tasks
> **Duration:** 1 tuần
> **Status:** ⏳ PENDING
> **Pre-requisite:** Hoàn thành CP0, CP1, CP2

---

## 1. Badge Indicator

**File mới:** `lib/features/orders/widgets/recurring_badge.dart`

### Design
- Badge nhỏ hiển thị "🔄" cho recurring orders trong list
- Tooltip/tap → xem chi tiết recurrence

```dart
class RecurringBadge extends StatelessWidget {
  final RecurringRule rule;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final pattern = switch (rule.ruleType) {
      'date' => rule.interval == 1 ? 'Weekly' : 'Every ${rule.interval} weeks',
      'completion' =>
        'Every ${rule.completionInterval} days after completion',
      _ => '',
    };
    return Tooltip(message: pattern, child: Icon(Icons.repeat));
  }
}
```

---

## 2. Toggle "Make Recurring" trong Create/Edit Screen

**File:** Xem `lib/features/orders/pages/` hoặc screen tạo/edits order hiện tại

### UI Flow
```
[Switch: Make Recurring]
  └─> Nếu on:
      ├─> Rule Type: [Dropdown] Weekly / Monthly
      ├─> Nếu Weekly:
      │   ├─> Inverval: [Number] every N weeks
      │   └─> Days: [Chip Select] Mon Tue Wed...
      ├─> Nếu Monthly:
      │   └─> Day of month: [Number] 1-31
      ├─> End: [DatePicker] / [Never]
      └─> Preview: "Next 5 occurrences"
```

### State Management
- Dùng `Consumer`/`context.read` (theo rule `.cursor/rules/flutter-widgets.mdc`)
- KHÔNG dùng setState cho form phức tạp

---

## 3. List View Integration

**File:** Screen list orders hiện tại (xem `lib/features/orders/pages/`)

### Thay đổi
- [ ] Detect `isRecurringInstance` hoặc có `parentRecurringId`
- [ ] Hiển thị `RecurringBadge` cạnh name
- [ ] Tap vào badge → navigate đến detail recurrence

---

## 4. Detail View Integration

**File:** `lib/screens/work_order_detail_screen.dart` (đã có "Does not repeat")

### Thay đổi
- [ ] Thay text `"(Does not repeat)"` bằng thông tin thực khi là recurring
- [ ] Section "RECURRENCE INFO":
  ```
  Pattern: Every 2 weeks on Mon, Wed
  Next: Jan 15, 2026
  Completed: 3 of 12
  ```
- [ ] Action buttons:
  - "Skip This Occurrence"
  - "Edit Recurrence"
  - "Stop Recurring"

---

## 5. Xóa Mock UI cũ

**File:** `lib/features/schedule/pages/schedule_detail_page.dart`

### Thay đổi
- [ ] Xóa/disconnect section "REPEATING VISITS" mock (lines ~250-270)
- [ ] Bind vào data thực từ `RecurringRule` nếu cần

---

## 6. Manual Testing

### Test scenarios
- [ ] Tạo recurring order → hiển thị badge đúng
- [ ] Edit recurrence config
- [ ] Complete occurrence → next instance xuất hiện đúng
- [ ] Skip occurrence → không ảnh hưởng audit
- [ ] Offline tạo recurring → sync khi online
- [ ] Xóa/sửa 1 instance không ảnh hưởng master rule

---

## 7. Exit Criteria

- [ ] Badge hiển thị đúng cho recurring orders
- [ ] Tạo recurring order qua UI hoạt động
- [ ] Detail view hiển thị recurrence info thực
- [ ] Mock UI cũ được xóa/disconnect
- [ ] Manual test pass
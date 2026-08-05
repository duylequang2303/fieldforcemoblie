# Checkpoint 4: Advanced Features

> **Mục tiêu:** Hoàn thiện full recurring feature
> **Duration:** 3 tuần
> **Status:** ⏳ PENDING
> **Pre-requisite:** Hoàn thành CP0 - CP3

---

## 1. Monthly Pattern

**File:** `lib/features/orders/services/recurring_service.dart`

### Thêm logic
- `_nextMonthlyDate()` - Tìm ngày >= from khớp `dayOfMonth`
- Xử lý edge: tháng 2 có 28/29 ngày, tháng 30/31
- Rule: nếu `dayOfMonth` > số ngày trong tháng → clamp xuống ngày cuối tháng

### Test
- [ ] Monthly 15th → đúng
- [ ] Monthly 31st trên tháng 2 → clamp 28/29
- [ ] Interval monthly (every 2 months)

---

## 2. "Recur on Completion" Pattern

**File:** `lib/features/orders/services/recurring_service.dart`

### Logic
```dart
Future<void> onOccurrenceCompleted(FsmOrder completed) async {
  final rule = await _getRuleForOrder(completed);
  if (rule.ruleType == 'completion') {
    final nextDate = DateTime.now().add(Duration(days: rule.completionInterval));
    final nextInstance = await _createInstanceFromRule(rule, nextDate);
    rule.completedCount++;
    await _save(rule);
  }
}
```

### Test
- [ ] Completion + 30 days → next instance đúng
- [ ] Skip không tăng completedCount
- [ ] Long interval (90 days) không bị miss do notification limit

---

## 3. Skip Occurrence

**File:** `lib/features/orders/services/recurring_service.dart`

### Logic
- `skipOccurrence(FsmOrder)` đã có ở CP2, hoàn thiện UI trigger
- Không đánh dấu completed, không tăng count
- Tạo next instance ngay

### Test
- [ ] Skip → badge "Skipped" hiển thị
- [ ] Audit log không bị pollute

---

## 4. Calendar View

**File mới:** `lib/features/orders/widgets/recurring_calendar.dart`

### Design
- View lịch tháng
- Dot màu cho recurring instances
- Chạm vào dot → xem chi tiết
- Highlight overdue recurring tasks

### Thư viện gợi ý (verify trước khi dùng)
- `table_calendar` (phổ biến, linh hoạt)
- Hoặc tự dựng bằng GridView

---

## 5. Smart Reminders

**File:** `lib/features/orders/services/recurring_notification_service.dart` (modify)

### Thay đổi
- [ ] Reschedule notifications mỗi khi app mở (fix bug 7-day limit)
- [ ] Thêm background worker (WorkManager) nếu cần
- [ ] Highlight overdue recurring tasks với priority cao

### Test
- [ ] Reminder 1 ngày trước
- [ ] User không mở app 10 ngày → notifications vẫn đúng (khi mở lại)

---

## 6. Workload Balancing

### Cải tiến
- Đề xuất thời gian tốt nhất dựa trên:
  - Số lượng instances trong ngày
  - Route optimization hiện có
- Hiển thị "X instances this week" trong recurring detail

---

## 7. Analytics

### Hiển thị
- Completion rate cho từng recurring series
- Trend: completed vs skipped vs overdue
- Trong detail view của master recurring

---

## 8. Bulk Edit

### Chức năng
- Chỉnh sửa recurrence config → áp dụng cho:
  - [ ] Tất cả instances tương lai
  - [ ] Chỉ 1 instance
- Stop recurring → giữ lịch sử, ngừng generate mới

---

## 9. Exit Criteria

- [ ] Monthly pattern hoạt động, edge cases OK
- [ ] Completion pattern hoạt động
- [ ] Skip occurrence phù hợp
- [ ] Calendar view có recurring dots
- [ ] Reminders hoạt động cả khi app đóng lâu
- [ ] Bulk edit + stop recurring OK
- [ ] Analytics hiển thị
- [ ] Full integration tests pass
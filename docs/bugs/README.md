# Bug Tracker Index - Fieldforce Worker App

## Tổng quan
Ứng dụng có **9 features chính** + **Core/Shared**. Mỗi feature có file bug tracker riêng.

---

## 📁 Danh sách file bug tracker

| # | File | Feature | Mô tả |
|---|------|---------|-------|
| 0 | `00_core_shared_bugs.md` | **Core & Shared** | Khởi tạo app, Isar DB, Sync, API, Routing, Theme, i18n |
| 1 | `01_auth_bugs.md` | **Auth** | Splash, Login, Session management |
| 2 | `02_orders_bugs.md` | **Orders** | Danh sách đơn, Chi tiết, Recurring orders |
| 3 | `03_route_map_bugs.md` | **Route Map** | Bản đồ, GPS, Navigation |
| 4 | `04_stock_bugs.md` | **Stock** | Scanner, Stock moves, Products |
| 5 | `05_timesheet_bugs.md` | **Timesheet** | Chấm công, Giờ làm việc |
| 6 | `06_expense_bugs.md` | **Expense** | Chi phí, Hóa đơn, Attachments |
| 7 | `07_work_order_bugs.md` | **Work Order** | Lệnh làm việc, Báo cáo, Signature |
| 8 | `08_schedule_bugs.md` | **Schedule** | Lịch trình, Tài sản, Timesheet tích hợp |
| 9 | `09_settings_bugs.md` | **Settings** | Cài đặt app, Language, Theme, Sync config |

---

## 🏷️ Phân loại mức độ (Severity)

| Label | Mô tả | Thời gian fix mục tiêu |
|-------|-------|------------------------|
| 🔴 **Critical** | Crash, data loss, security, blocker | Ngay lập tức |
| 🟠 **High** | Major feature broken, offline sync fail | 1-2 ngày |
| 🟡 **Medium** | Minor feature issue, UI glitch | 1 tuần |
| 🟢 **Low** | Cosmetic, enhancement, nice-to-have | Sprint sau |

---

## 📊 Trạng thái (Status)

| Label | Mô tả |
|-------|-------|
| 🔴 **Open** | Vừa phát hiện, chưa ai làm |
| 🟡 **In Progress** | Đang fix |
| 🟢 **Fixed** | Đã fix, chờ verify |
| ⚪ **Won't Fix** | Không fix (by design, low priority) |
| 🔵 **Need Info** | Cần thêm thông tin để reproduce |

---

## 🔍 Quy trình tìm & ghi bug

### 1. Manual Testing Checklist (mỗi feature)
- [ ] Happy path (luồng chính)
- [ ] Edge cases: empty state, network error, validation
- [ ] Offline mode: tạo/sửa/xóa -> online sync
- [ ] Permission handling (camera, location, storage)
- [ ] Platform test: Android, iOS, Web (nếu hỗ trợ)
- [ ] Performance: list lớn, hình ảnh, memory leak

### 2. Code Review Checklist
- [ ] Error handling (try-catch, user-friendly messages)
- [ ] Null safety
- [ ] Resource cleanup (dispose controllers, streams, timers)
- [ ] State management đúng pattern (Provider/Riverpod)
- [ ] Database operations: transaction, index, query optimization
- [ ] API calls: timeout, retry, cancel on dispose

### 3. Automated Checks
```bash
# Static analysis
flutter analyze

# Tests
flutter test

# Format check
dart format --set-exit-if-changed .

# Check for TODO/FIXME comments
grep -r "TODO\|FIXME\|HACK" lib/
```

---

## 📝 Cách thêm bug mới

1. Mở file tương ứng feature (ví dụ: `02_orders_bugs.md`)
2. Thêm row vào table phù hợp (UI/Logic/Perf/Sync/Data)
3. Điền theo format:
   ```markdown
   | ORD-LOGIC-003 | Mô tả ngắn | order_detail_page.dart:45 | 🟠 High | 🔴 Open | Steps: ... |
   ```
4. Có thể thêm chi tiết ở section "Template báo cáo bug mới" cuối file

---

## 🎯 Ưu tiên review đề xuất

1. **Core/Shared** (00) - ảnh hưởng toàn app
2. **Auth** (01) - blocker nếu login fail
3. **Orders** (02) - core business, recurring phức tạp
4. **Schedule** (08) - nhiều screen, integration phức tạp
5. **Stock** (04) - scanner, camera, hardware
6. **Work Order** (07) - form phức tạp, signature
7. **Route Map** (03) - GPS, map, battery
8. **Timesheet** (05) - date/time logic
9. **Expense** (06) - attachment, approval
10. **Settings** (09) - ít bug critical nhất

---

## 📌 Ghi chú quan trọng

- App sử dụng **Offline-first** với Isar DB -> test kỹ sync conflict, data integrity
- **Recurring orders** có logic phức tạp (generate instances, notifications)
- **Schedule** tích hợp với Orders, Timesheet, Materials -> test integration
- **Platform-specific**: Linux không hỗ trợ zonedSchedule (local notifications)
- Web: Isar 3.x không hỗ trợ -> check conditional imports

---

*Cập nhật lần cuối: $(date)*
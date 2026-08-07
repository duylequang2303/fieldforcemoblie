# Bug Tracker: Timesheet Feature

## Thông tin chung
- **Feature**: Timesheet (Chấm công, giờ làm việc)
- **Files liên quan**: `lib/features/timesheet/`
- **Models**: `TimesheetEntry`
- **Services**: `TimesheetService`
- **Pages**: `timesheet_page.dart`
- **Ngày tạo**: 2026-08-07

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| TS-UI-001 | Nút help/info trên AppBar không có hành động | `timesheet_page.dart` line 51 | Low | 🔴 Open | TODO placeholder, không mở hướng dẫn hay tooltip |
| TS-UI-002 | Format ngày dùng locale `vi` chưa chắc đã được khởi tạo trong `intl` | `time_entry_form.dart` line 50 | Medium | 🔴 Open | `DateFormat('dd/MM/yyyy', 'vi')` có thể fallback về `en` nếu chưa load locale |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-LOGIC-001 | Không reject non-finite hours (NaN/Infinity) | `time_entry_form.dart` line 73 | Medium | 🔴 Open | `double.tryParse` chấp nhận NaN/Infinity; validator chỉ check `<= 0`, NaN sẽ lọt qua |
| TS-LOGIC-002 | Điều kiện `entry.odooId != null` trong `addEntry` là dead code với entry mới | `timesheet_service.dart` line 56 | Low | 🔴 Open | `TimesheetEntry.create()` không set `odooId`; block này không bao giờ chạy với entry mới tạo |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-PERF-001 | Không có phân trang/pagination khi đọc danh sách entries | `timesheet_service.dart` line 21 | Medium | 🔴 Open | `getEntriesForOrder` load toàn bộ records; đơn có nhiều giờ công sẽ chậm |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-SYNC-001 | Thiếu retry/backoff khi sync pending thất bại | `timesheet_service.dart` line 137 | Medium | 🔴 Open | `catch (e)` chỉ log, entry cứ pending mãi; không có retry mechanism |
| TS-SYNC-002 | Không có deduplicate/check idempotency khi sync | `timesheet_service.dart` line 119 | Medium | 🔴 Open | Retry có thể tạo duplicate `account.analytic.line` trên Odoo nếu chưa có `isPendingSync` guard chặt |

### Date/Time Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-DATE-001 | Format ngày không nhất quán giữa `addEntry` và `syncPending` | `timesheet_service.dart` lines 72-73 vs 125 | Low | 🔴 Open | `addEntry` dùng manual padding, `syncPending` dùng `toIso8601String().substring(0,10)`; UTC offset có thể gây lệch ngày |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [x] Clock in/out functionality
- [x] Timesheet entry CRUD
- [x] Date picker / time picker accuracy
- [x] Offline entries -> sync
- [x] Validation: overlapping times, future dates
- [x] Week/Month view summaries
- [x] Approval workflow (nếu có)

---

## 📋 Kế hoạch phân chia subagent

Để tránh treo context, sẽ chia thành 2 subagent song song:

1. **Subagent A — UI/UX + Logic Review**
   - Phụ trách: TS-UI-001, TS-UI-002, TS-LOGIC-001, TS-LOGIC-002
   - Task: Đọc `timesheet_page.dart`, `time_entry_form.dart`, `timesheet_service.dart` (phần `addEntry`), đề xuất fix cụ thể.

2. **Subagent B — Sync + Date + Perf Review**
   - Phụ trách: TS-SYNC-001, TS-SYNC-002, TS-DATE-001, TS-PERF-001
   - Task: Đọc `timesheet_service.dart` (phần `syncPending`, `getEntriesForOrder`), đề xuất retry/backoff, dedup, pagination, date format fix.

→ Chờ cả 2 xong, main agent tổng hợp và merge vào 1 bug tracker.

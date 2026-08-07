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
| TS-UI-001 | Nút help/info trên AppBar không có hành động | `timesheet_page.dart` line 51 | Low | ✅ Fixed | Thay bằng AlertDialog hướng dẫn |
| TS-UI-002 | Format ngày dùng locale `vi` chưa chắc đã được khởi tạo trong `intl` | `time_entry_form.dart` line 50 | Medium | ✅ Fixed | Đổi sang manual padding không phụ thuộc locale |

### Logic/Functional Bugs

| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-LOGIC-001 | Không reject non-finite hours (NaN/Infinity) | `time_entry_form.dart` line 73 | Medium | ✅ Fixed | Thêm `!h.isFinite` vào validator |
| TS-LOGIC-002 | Điều kiện `entry.odooId != null` trong `addEntry` là dead code với entry mới | `timesheet_service.dart` line 56 | Low | ✅ Fixed | Xoá block chết, `create()` không set `odooId` |

### Performance/Memory Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-PERF-001 | Không có phân trang/pagination khi đọc danh sách entries | `timesheet_service.dart` line 21 | Medium | ✅ Fixed | Thêm offset+limit, trả metadata `hasMore`, provider expose `loadMoreEntries` |

### Offline/Sync Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-SYNC-001 | Thiếu retry/backoff khi sync pending thất bại | `timesheet_service.dart` line 137 | Medium | ✅ Fixed | Thêm `syncRetryCount`, `nextRetryAt`, exponential backoff, `isSyncFailed` sau 3 lần |
| TS-SYNC-002 | Không có deduplicate/check idempotency khi sync | `timesheet_service.dart` line 119 | Medium | ✅ Fixed | Thêm remote lookup qua `search_read` trước khi `create`, kết hợp local dedup |

### Date/Time Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| TS-DATE-001 | Format ngày không nhất quán giữa `addEntry` và `syncPending` | `timesheet_service.dart` lines 72-73 vs 125 | Low | ✅ Fixed | Thêm `_formatDate(DateTime)` dùng `intl` thống nhất cho cả 2 nơi |

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

---

## 📝 CodeRabbit PR Review (PR #45)

| ID | Nguồn | Mức độ | Trạng thái | Hành động |
|----|-------|--------|------------|-----------|
| CR-001 | Inline: `timesheet_service.dart:97` | Critical | ✅ Fixed | Thêm `isSyncFailed`, `syncRetryCount`, `nextRetryAt` vào model, regenerate schema |
| CR-002 | Inline: `timesheet_service.dart:116-129` | Major | ✅ Fixed | Thêm remote `search_read` lookup trước khi `create` để tránh duplicate Odoo |
| CR-003 | Inline: `timesheet_service.dart:159-175` | Major | ✅ Fixed | Persist `nextRetryAt`, skip entries chưa đến giờ, catch `OdooApiException`, rethrow others |
| CR-004 | Nitpick: `05_timesheet_bugs.md:18-41` | Trivial | ✅ Fixed | Thêm blank line giữa heading và table (MD058) |
| CR-005 | Outside diff: `timesheet_service.dart:23-32` | Major | ✅ Fixed | Thêm offset+limit, trả `hasMore` metadata, provider expose `loadMoreEntries` |
| CR-006 | Outside diff: `timesheet_service.dart:141-153` | Major | ⏭️ Skipped | `OdooSessionManager.callKw` đã delegate sang `OdooApiClient` và giữ session-expiry handling; đổi sang `OdooApiClient` trực tiếp sẽ mất logic re-auth |

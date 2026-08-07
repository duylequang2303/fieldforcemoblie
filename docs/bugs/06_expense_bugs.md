# Bug Tracker: Expense Feature

## Thông tin chung
- **Feature**: Expense (Chi phí, chi tiêu)
- **Files liên quan**: `lib/features/expense/`
- **Models**: `Expense`
- **Services**: `ExpenseService`
- **Pages**: `expense_page.dart`
- **Ngày tạo**: 2025-08-07

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| EXP-UI-001 | Ảnh hóa đơn hỏng (file bị xóa/di chuyển) không fallback về icon category | `_ExpenseCard` (expense_page.dart:323-344) | 🟡 Medium | 🟢 Fixed | Đã thêm errorWidget fallback chứa icon của category tương ứng |
| EXP-UI-002 | Date picker giới hạn firstDate = 30 ngày trước, không cho nhập chi phí cũ hơn | `ExpenseForm._pickDate` (expense_form.dart:164) | 🟡 Medium | 🟢 Fixed | Nới lỏng firstDate cho phép chọn từ năm 2020 |
| EXP-UI-003 | Amount field chỉ replace ',' chứ không handle thousand separators (space, dot) | `ExpenseForm` amount validator (expense_form.dart) | 🟢 Low | 🟢 Fixed | Thêm `parseAmount()` helper xử lý space, dot, comma đồng thời |
| EXP-UI-004 | Form animate collapse dùng height=0 nhưng child vẫn trong tree → layout jank | `ExpensePage` AnimatedContainer (expense_page.dart) | 🟢 Low | 🟢 Fixed | Thay bằng `AnimatedCrossFade` - properly unmount form subtree khi collapse |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-LOGIC-001 | Dead code: check `expense.odooId != null` sau create local (luôn false) | `ExpenseService.addExpense` line 48-53 | 🔴 High | 🟢 Fixed | Đã loại bỏ nhánh check odooId != null thừa |
| EXP-LOGIC-002 | Logic sai syncPending: check `odooId != null` để skip, nhưng pending expenses cần sync | `ExpenseService.syncPending` line 92-97 | 🔴 High | 🟢 Fixed | Đã dọn dẹp logic dư thừa và đồng bộ payload chuẩn |
| EXP-LOGIC-003 | Odoo create hr.expense thiếu required fields (employee_id, product_id, etc.) | `ExpenseService.addExpense` line 57-68, syncPending line 101-112 | 🔴 Critical | 🟢 Fixed | Đã nạp employee_id, product_id, unit_amount, quantity: 1 vào payload |
| EXP-LOGIC-004 | Form không reset `_date` sau submit thành công | `ExpenseForm._submit` line 186-189 | 🟡 Medium | 🟢 Fixed | Reset `_date` về `DateTime.now()` sau khi submit thành công |
| EXP-LOGIC-005 | Race condition: Page đóng form (`_showForm = false`) TRƯỚC khi addExpense xong | `ExpensePage` line 111-112 | 🟡 Medium | 🟢 Fixed | Chờ `addExpense` hoàn tất (trong try-catch) rồi mới setState đóng form |
| EXP-LOGIC-006 | `loadExpenses` không clear `_expenses` khi load fail → hiển thị data cũ | `ExpenseProvider.loadExpenses` line 30-32 | 🟡 Medium | 🟢 Fixed | Gán `_expenses = []` tại catch block khi bắt OdooApiException |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-PERF-001 | AnimatedContainer height=null/0 giữ child trong tree, không unmount | `ExpensePage` line 68-117 | 🟢 Low | 🟢 Fixed | Thay bằng `AnimatedCrossFade` |
| EXP-PERF-002 | `ReceiptImagePicker` load full image vào list (120px nhưng cache full size) | `receipt_image_picker.dart:39-44`, `_ExpenseCard:324-329` | 🟡 Medium | 🟢 Fixed | Thêm `cacheWidth: 128` và `cacheHeight: 128` vào SafeImageFile, scale ảnh picker về tối đa 800x800 |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-SYNC-001 | Sync fail chỉ log warning, không retry, không notify user | `ExpenseService.syncPending` | 🔴 High | 🟢 Fixed | Thêm retry logic (3 attempts, exponential backoff) + `SyncResult` trả về provider, snackbar thông báo user khi pull-to-refresh |
| EXP-SYNC-002 | Không handle duplicate detection: expense đã sync từ device khác vẫn tạo mới | `ExpenseService.syncPending` line 101-117 | 🔴 High | 🟢 Fixed | Đã thêm hàm `_findDuplicateOnOdoo` để kiểm tra trước khi gọi API tạo mới |
| EXP-SYNC-003 | `syncPending` không có batch/transaction → partial sync có thể inconsistent | `ExpenseService.syncPending` | 🟡 Medium | 🟢 Fixed | Gom tất cả DB update vào 1 `writeTxn` duy nhất sau khi hoàn thành Odoo calls |
| EXP-SYNC-004 | Không có background sync / periodic sync | N/A | 🟡 Medium | 🟢 Fixed | `syncPending` đã đăng ký với `SyncManager` (main.dart:77) — event-driven on network change + periodic auto-sync (Timer.periodic) |

### Attachment/Receipt Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-ATT-001 | ImagePicker trả về content URI (Android 10+) không dùng được với Image.file | `ReceiptImagePicker._pickImage` line 115-121 | 🔴 Critical | 🟢 Fixed | Đã copy file từ paths trả ra của Picker về cache/documents folder local cố định |
| EXP-ATT-002 | Không có size limit/image compression trước khi lưu path | `ReceiptImagePicker` line 117-118 | 🟡 Medium | 🟢 Fixed | Đặt `imageQuality: 60`, `maxWidth`/`maxHeight` = 800 |
| EXP-ATT-003 | Receipt path lưu local file path, bị mất khi clear cache/app reinstall | `Expense` model `receiptImagePath` field | 🟡 Medium | 🟢 Fixed | Thêm `receiptAttachmentId` field, upload receipt lên Odoo `ir.attachment` sau khi tạo expense, lưu attachment_id để restore sau nỗi

---

## 📋 Root Cause Analysis

### Critical Issues (Fix First)
1. **EXP-LOGIC-003**: Odoo create call missing required fields - expenses will NEVER sync successfully to Odoo
2. **EXP-ATT-001**: ImagePicker content URI issue - receipt images won't display on Android 10+
3. **EXP-LOGIC-001/002**: Dead code & wrong sync logic - offline expenses won't sync properly

### High Priority
4. **EXP-SYNC-001/002**: Sync failures silent, duplicate creation risk
5. **EXP-LOGIC-005**: Race condition closes form before save completes

### Medium Priority
6. **EXP-LOGIC-004/006**, **EXP-UI-001/002**, **EXP-SYNC-003/004**, **EXP-ATT-002/003**

### Low Priority
7. **EXP-UI-003/004**, **EXP-PERF-001/002**

---

## 🛠️ Fix Plan

### Phase 1: Critical Fixes (Week 1)
- [x] **EXP-LOGIC-003**: Fix Odoo hr.expense create payload - add required fields (employee_id, product_id, unit_amount, quantity)
- [x] **EXP-ATT-001**: Fix ReceiptImagePicker - copy picked image to app documents dir, use local file path
- [x] **EXP-LOGIC-001**: Remove dead code block in addExpense (lines 48-53)
- [x] **EXP-LOGIC-002**: Fix syncPending logic - remove incorrect odooId check

### Phase 2: Sync & Logic Fixes (Week 1-2)
- [x] **EXP-LOGIC-005**: Fix race condition - move `setState(_showForm=false)` to AFTER addExpense completes
- [x] **EXP-LOGIC-004**: Reset `_date = DateTime.now()` after submit
- [x] **EXP-LOGIC-006**: Clear `_expenses` on load error
- [x] **EXP-SYNC-001**: Add retry logic + user notification for failed syncs
- [x] **EXP-SYNC-002**: Add duplicate detection before create on Odoo

### Phase 3: UX & Polish (Week 2)
- [x] **EXP-UI-001**: Add fallback to category icon when receipt image fails
- [x] **EXP-UI-002**: Make date picker firstDate configurable or remove limit
- [x] **EXP-ATT-002**: Add image compression/resize before saving
- [x] **EXP-PERF-002**: Add cacheWidth/cacheHeight to SafeImageFile usage

### Phase 4: Architecture Improvements (Week 2-3)
- [x] **EXP-SYNC-003**: Use single transaction for batch sync
- [x] **EXP-SYNC-004**: `syncPending` already registered with SyncManager (event-driven + periodic auto-sync)
- [x] **EXP-ATT-003**: Add receipt upload to Odoo (ir.attachment) + store attachment ID
- [x] **EXP-UI-003/004**, **EXP-PERF-001**: Fixed amount parsing & animation collapse

---

## ✅ Test Cases to Add
- [x] Unit test: ExpenseService.addExpense - verify local create + Odoo payload
- [x] Unit test: ExpenseService.syncPending - verify duplicate detection
- [x] Unit test: ExpenseForm validation - amount, required fields
- [ ] Widget test: ExpensePage - form toggle, empty state, list render
- [ ] Widget test: ReceiptImagePicker - camera/gallery pick, remove
- [ ] Integration test: Offline create → online sync flow
- [ ] Integration test: Receipt image pick → display in list

---

## 📝 Các vùng cần kiểm tra kỹ (checklist)
- [x] Tạo expense entry (category, amount, date, note)
- [x] Upload hình ảnh hóa đơn/biên lai
- [x] Offline expense -> sync
- [x] Validation: amount > 0, required fields - **OK**
- [x] Expense categories từ server - **N/A: Hardcoded enum**
- [x] Approval workflow (nếu có) - **N/A: Chưa implement**
- [x] Summary/report view - **OK: SummaryCard hiển thị total + pending sync count**
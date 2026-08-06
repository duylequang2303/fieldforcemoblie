# HĐ/2026/08/05 - BỐ CÁO LỖI LOGIC HỆ THỐNG ORDER & RECURRING CỦA MOBILE FIELD FORCE

## 1. MAPPING TRẠNG THÁI ĐƠN (STAGE MACHINE) KHÔNG CHÍNH XÁC
**File:** `fieldforcemoblie/lib/features/orders/models/fsm_order.dart`
- **Lỗi:** Chỉ map 4 stage (`draft`, `inProgress`, `done`, `cancelled`). Hễ stageName không khớp keyword Việt/Anh dạng thô (ví dụ: "Ready", "Scheduled", "Hold",...) thì ép cứng về `FsmOrderStage.draft`.
- **Hệ quả:** Sai lệch trạng thái đơn hàng trên app so với thực tế Odoo.

## 2. CHÊNH LỆCH ĐỊNH NGHĨA MODEL & THIẾU TRƯỜNG DỮ LIỆU
**File:** `fieldforcemoblie/lib/features/orders/models/fsm_recurring.dart`
- **Lỗi:** Các trường `ruleType`, `completionInterval`, `completedCount`, `skippedCount` là **LOCAL-ONLY**. Khi chuyển thiết bị, cài lại app, toàn bộ thông tin này mất đi hoặc reset về mặc định (`ruleType = 'date'`, `completionInterval = 0`).
- **Lỗi API:** Trường `generatedCount` được serialize lên JSON Odoo qua `'generated_count': generatedCount` ở hàm `toJson()`, nhưng Odoo không hỗ trợ/không có field này và mobile cũng không sync chiều ngược lại một cách đầy đủ. Điều này có thể dẫn tới lỗi API Sync.

## 3. LỖI LOGIC ĐƠN ĐỊNH KỲ DỰA TRÊN HOÀN THÀNH (COMPLETION-BASED RECURRING)
**File:** `fieldforcemoblie/lib/features/orders/services/recurring_service.dart`
- **Lỗi:** Logic `generateOfflineInstances` tại dòng 155-202 tự động bỏ qua nếu `rule.ruleType == 'completion' && rule.nextDate!.isAfter(today)`. Khi chạy offline instance, nó chỉ sinh đúng **1 đơn hàng** rồi tắt bằng cách gán `rule.nextDate = null`. 
- **Hệ quả:** Nếu người dùng không kịp hoàn thành đơn hoặc app bị crash đúng thời điểm hoàn thành, chu kỳ lặp hoàn toàn **BỊ NGẮT VĨNH VIỄN** vì `nextDate` đã bị tắt thành `null`.

## 4. XUNG ĐỘT KHÓA DUY NHẤT (UNIQUE INDEX COLLISION) KHI ĐIỆN THOẠI CHẠY NHANH
**File:** `fieldforcemoblie/lib/features/orders/services/recurring_service.dart`
- **Lỗi:** Tạo ID tạm thời local bằng dạng số âm `tempOdooId = -DateTime.now().microsecondsSinceEpoch`.
- **Hệ quả:** Nếu loop sinh nhanh trong cùng một microgiây (ví dụ: tạo hàng loạt đơn định kỳ cho 30 ngày), các ID trùng nhau dẫn đến Isar Database ném ngoại lệ `Unique index violation` trên field `odooId` của `FsmOrder` và crash app.

## 5. LỖI SKIP ORDER VẪN HIỂN THỊ VÀ VẪN BẤM COMPLETE ĐƯỢC
- **Lỗi:** Hàm `skipOccurrence` chỉ set `isSkipped = true`, `isRecurringProcessed = true`, map stage sang cancelled và lưu offline. 
- **Nguyên nhân 1 (UI hiển thị):** UI/Provider không filter lọc bỏ các đơn bị skip (`isSkipped == true`), vẫn hiển thị trong danh sách.
- **Nguyên nhân 2 (Nút Complete vẫn kích hoạt):** UI Button không check trạng thái `isRecurringProcessed` hoặc `isSkipped` để disable, cho phép bấm Complete chồng đè.
- **Nguyên nhân 3 (Trùng instance lặp):** Logic `generateOfflineInstances` khi kiểm tra xem đã có đơn hàng chưa thực hiện cho chu kỳ này không check điều kiện loại trừ đơn đã bị skipped (`isSkipped == false`). Dẫn đến việc sinh trùng lắp instance sau khi skip.

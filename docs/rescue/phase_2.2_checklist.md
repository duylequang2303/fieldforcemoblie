# Phase 2.2 — Minimal Checklist

## Mục tiêu
Thêm minimal service checklist vào Order Detail (fallback tĩnh nếu backend chưa có dynamic checklist).

## Vấn đề hiện tại
- App chưa có checklist feature.
- Worker cần checklist tối thiểu để nghiệm thu công việc.

## Kế hoạch sửa
- File: `lib/features/orders/models/fsm_order.dart` (hoặc model riêng)
  - Thêm model local `ChecklistItem`:
    - `id` (string/local)
    - `label` (string)
    - `checked` (bool)
    - `valueText` (string?, nullable)
    - `valueNumber` (double?, nullable)
    - `orderOdooId` (int)
  - Hoặc lưu trực tiếp trong `WorkReport` nếu checklist thuộc về report.
- File: `lib/screens/work_order_detail_screen.dart`
  - Thêm section "Checklist" trong body (sau Location Info, trước Work Report).
  - Hiển thị checklist items dạng ListTile với checkbox.
  - Text input cho `valueText`, numeric input cho `valueNumber`.
  - Save local vào Isar (dùng existing pattern).
- Template tĩnh theo service type (lấy từ `order` field nếu có):
  - `air_conditioner`: Power on test, Air outlet temperature, Gas pressure, Current/Ampere, Drainage check, Filter cleaning, Customer signature.
  - `dishwasher`: Power on test, Water inlet check, Drain check, Leak check, Temperature check, Descaling status, Customer signature.
  - `cleaning`: Area completed, Chemicals used, Tools used, Customer satisfaction, Customer signature.
  - `garden`: Work area cleaned, Plants trimmed, Watering completed, Pesticide/fertilizer used, Safety waiting time noted, Customer signature.
  - `generic`: Work completed, Customer signature.

## Fallback behavior
- Nếu backend có dynamic checklist → fetch và merge với template.
- Nếu backend không có → dùng template tĩnh.
- Lưu local, mark pending sync nếu backend hỗ trợ.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

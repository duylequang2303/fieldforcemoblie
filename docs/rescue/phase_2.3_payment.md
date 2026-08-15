# Phase 2.3 — Payment Capture

## Mục tiêu
Thêm minimal payment capture vào Order Detail (cash/transfer, amount validation).

## Vấn đề hiện tại
- App chưa có payment tracking.
- Worker cần ghi nhận tiền mặt/chuyển khoản.

## Kế hoạch sửa
- File: `lib/features/orders/models/fsm_order.dart`
  - Thêm fields local (không cần backend ngay):
    - `paymentState`: enum `draft`/`paid`/`partial` (String).
    - `amountPaid`: double?.
    - `paymentMethod`: enum `cash`/`transfer` (String?).
    - `paymentNote`: String?.
    - `paidAt`: DateTime?.
  - Lưu trong Isar cùng `FsmOrder` record.
- File: `lib/screens/work_order_detail_screen.dart`
  - Thêm section "Payment" trong body (trước Work Report).
  - Hiển thị: total amount (nếu có), amount paid input, payment method dropdown (cash/transfer), payment note textfield.
  - Validation:
    - `amountPaid >= 0`.
    - `amountPaid <= totalAmount` nếu backend có total.
  - Save local vào Isar.
  - Nếu backend hỗ trợ payment fields → sync; else → mark pending.

## Dữ liệu nguồn
- Backend có thể có `amount_paid`, `payment_state`, `payment_method` trên `fsm.order` hoặc module `account_payment`.
- Nếu backend thiếu → giữ local, không crash.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

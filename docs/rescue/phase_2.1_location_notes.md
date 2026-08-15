# Phase 2.1 — Location Notes

## Mục tiêu
Thêm section Location/Customer Info (read-only) vào Order Detail.

## Vấn đề hiện tại
- `WorkOrderDetailScreen._buildStickyHeader` hiện `locationAddress` và `partnerName`.
- Thiếu section riêng cho thông tin địa điểm/khách hàng: access code, security guard instructions, "house has dog", parking note, contact note.
- Backend có thể có các fields này trong `fsm.location` hoặc `res.partner` nhưng app chưa đọc.

## Kế hoạch sửa
- File: `lib/features/orders/models/fsm_order.dart`
  - Thêm fields local (nếu cần): `locationNote`, `accessCode`, `contactNote`.
  - Hoặc dùng existing `description` + parse HTML để lấy note.
- File: `lib/screens/work_order_detail_screen.dart`
  - Thêm `_buildLocationInfoCard` sau `_buildStickyHeader`:
    - Hiển thị: location name, phone, address, note (nếu có).
    - Nếu note dài → `ExpandableSection` hoặc `Text(maxLines: 3, overflow: ellipsis)` với nút "Show more".
  - Đọc từ `order` object; hide safely nếu field null/empty.

## Dữ liệu nguồn
- `fsm.location` fields: `name`, `phone`, `street`, `street2`, `city`, `zip`, `partner_latitude`, `partner_longitude`, `direction`.
- `res.partner` fields: `name`, `phone`, `street`, `city`.
- Nếu backend không có note field → hide section.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

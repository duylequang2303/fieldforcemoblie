# Phase 1.4 — Fix Flex Overflow

## Mục tiêu
Fix critical RenderFlex overflow errors trong main order flow.

## Vấn đề hiện tại
1. **`work_order_detail_screen.dart:655-661`** (`_buildStickyHeader`):
   ```dart
   Text(
     currentOrder.locationAddress ?? currentOrder.name,
     style: theme.textTheme.titleLarge?.copyWith(...),
     maxLines: 2,
     overflow: TextOverflow.ellipsis,
   )
   ```
   — Có `maxLines` và `ellipsis` nhưng `Text` nằm trong `Row` không có `Expanded` → vẫn có thể overflow.
2. **`work_order_detail_screen.dart:663-671`**:
   ```dart
   Text(
     currentOrder.partnerName ?? 'Anonymous customer',
     ...
     maxLines: 1,
     overflow: TextOverflow.ellipsis,
   )
   ```
   — Có `maxLines`/`ellipsis` nhưng trong `Row` không có `Expanded` → overflow.
3. **`route_info_panel.dart:_StopTile`** (line 59-189):
   - `IntrinsicHeight` + `Row` + `Expanded(child: Card(...))` — `Card` bên trong có `Text` không có `Expanded` → overflow nếu text dài.
   - `stop.orderName` (line 105) không có `Expanded`/`Flexible`.
4. **`order_card.dart`** (line 39-64):
   - `Row` với `Expanded(child: Row(...))` chứa `Flexible(child: Text(order.name, overflow: ellipsis))` — OK.
5. **`schedule_card.dart`** (line 89-123):
   - `Row` với `Expanded(child: Text(order.locationAddress ?? order.name))` — **KHÔNG có `maxLines`/`ellipsis`** → overflow.

## Kế hoạch sửa
- File: `lib/screens/work_order_detail_screen.dart`
  - Wrap `locationAddress` / `partnerName` trong `_buildStickyHeader` với `Expanded`.
  - Thêm `maxLines: 2` + `overflow: TextOverflow.ellipsis` cho `locationAddress`.
  - Thêm `maxLines: 1` + `overflow: TextOverflow.ellipsis` cho `partnerName`.
- File: `lib/features/route_map/widgets/route_info_panel.dart`
  - Wrap `stop.orderName` với `Expanded` + `TextOverflow.ellipsis`.
  - Wrap `stop.partnerName` với `Expanded` + `TextOverflow.ellipsis`.
  - Wrap `stop.locationName` với `Expanded` + `TextOverflow.ellipsis` (đã có).
- File: `lib/features/route_map/pages/route_map_page.dart`
  - `_RouteStopCard` (line 665-671): `stop.orderName` có `Expanded` — OK.
  - `stop.partnerName` (line 675-683) có `maxLines: 1` + `ellipsis` — OK.
- File: `lib/widgets/schedule_card.dart`
  - Wrap `order.locationAddress ?? order.name` với `Expanded` + `maxLines: 2` + `ellipsis`.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

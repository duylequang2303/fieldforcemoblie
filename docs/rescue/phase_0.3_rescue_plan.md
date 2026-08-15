# Phase 0.3 — Rescue Plan

## Mục tiêu
Tạo tài liệu Rescue Plan tổng hợp cho toàn bộ quá trình rescue, dùng làm reference cho các phase sau.

## Kế hoạch
- Tổng hợp inventory (0.1) và MVP scope (0.2).
- Đề ra single source of truth cho Order Detail.
- Kế hoạch navigation cleanup, Isar dedup, API field safety, AccessError fallback.
- Liệt kê Phase 1 task list và smoke test checklist.

## Nội dung đã được tách vào các file riêng
Do yêu cầu track theo từng phase, nội dung plan đã được tách vào:
- `phase_1.1_isar_unique_index.md` — Fix Isar dedup
- `phase_1.2_order_detail_unification.md` — Navigation cleanup
- `phase_1.3_api_field_safety.md` — API field safety
- `phase_1.4_flex_overflow.md` — UI overflow fixes
- `phase_1.5_smoke_test_checklist.md` — Smoke test
- `phase_2.1_location_notes.md` — Location notes
- `phase_2.2_checklist.md` — Minimal checklist
- `phase_2.3_payment.md` — Payment capture
- `phase_3.1_performance.md` — Performance
- `phase_3.2_pagination.md` — Pagination

## Single Source of Truth: Order Detail
- **Chosen**: `WorkOrderDetailScreen` (`lib/screens/work_order_detail_screen.dart`)
- **Reason**: Feature-complete nhất (signature, photos, materials, timesheet, completion).
- **Deprecated**: `OrderDetailPage` (`lib/features/orders/pages/order_detail_page.dart`) — giữ file nhưng ngừng route đến.

## Top Risks cần theo dõi
1. Login blocked by missing `hr.employee` (P0).
2. `_OrderDetailWrapper` race condition (P0).
3. Isar unique index trên `RouteStop.orderOdooId` nếu persist sau này (P0).
5. `generateOfflineInstances` không catch `AccessError` (P1).
6. RenderFlex overflow trong `WorkOrderDetailScreen._buildStickyHeader` (P1).

## Đã làm


## Kết quả

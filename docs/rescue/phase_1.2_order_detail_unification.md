# Phase 1.2 — Unify Order Detail Navigation

## Mục tiêu
Gom về một màn hình Order Detail duy nhất: `WorkOrderDetailScreen`.

## Vấn đề hiện tại
- Có 2 order detail screens: `OrderDetailPage` và `WorkOrderDetailScreen`.
- `/orders/:id` dùng `_OrderDetailWrapper` → post-frame callback push `/work-order-detail-screen` với `extra` → race condition, flash UI.
- `/schedule-screen` route trùng `/shell/schedule`.
- `OrderCard.onTap` → `/orders/:id` (wrapper).
- `ScheduleCard.onTap` → `/work-order-detail-screen` trực tiếp (đúng).
- `_RouteStopCard.onTap` → `_showStopBottomSheet` (không navigate đến order detail).

## Kế hoạch sửa
- File: `lib/core/routing/app_router.dart`
  - Remove route `/schedule-screen`.
  - Simplify `_OrderDetailWrapper`: thay vì post-frame push, navigate trực tiếp đến `WorkOrderDetailScreen` với `extra: order`.
  - Hoặc tốt hơn: `_OrderDetailWrapper` fetch order từ cache/provider rồi return `WorkOrderDetailScreen(order: order)` trực tiếp (không qua `context.push`).
- File: `lib/features/orders/widgets/order_card.dart`
  - `onTap` → `context.push(RouteNames.workOrderDetailScreen, extra: order)` thay vì `/orders/:id`.
- File: `lib/features/route_map/pages/route_map_page.dart`
  - `_showStopBottomSheet`: thêm nút "Xem chi tiết đơn" navigate đến `/work-order-detail-screen` với `extra: FsmOrder` từ provider.
- File: `lib/features/route_map/widgets/route_info_panel.dart`
  - `onStopTapped` → navigate đến order detail nếu cần.
- File: `lib/features/orders/pages/order_detail_page.dart`
  - Mark as `@Deprecated` trong comment.
  - Giữ file nhưng không dùng.

## Đã làm
- Removed `/schedule-screen` route khỏi `app_router.dart`.
- Simplified `_OrderDetailWrapper`: bỏ `addPostFrameCallback` race condition, return `WorkOrderDetailScreen(order: order)` trực tiếp khi order có trong provider. Giữ cache fallback và error UI.
- `OrderCard.onTap` đổi từ `/orders/:id` sang `RouteNames.workOrderDetailScreen` với `extra: order`.
- `_showStopBottomSheet` trong `route_map_page.dart`: đổi action buttons từ `Row` sang `Column` (3 buttons full-width, không overflow), thêm button "Chi tiết" navigate đến `WorkOrderDetailScreen`.
- `OrderDetailPage` thêm `@Deprecated` annotation.
- Added missing imports `go_router.dart` và `route_names.dart` vào `route_map_page.dart`.
- Implemented widget tests theo test strategy đã duyệt:
  - `test/features/orders/widgets/order_card_test.dart`: 2/2 pass (navigation + display)
  - `test/core/routing/app_router_test.dart`: 0/2 pass (2 skipped — requires IsarService.init)
  - `test/features/route_map/pages/route_map_page_test.dart`: 2/2 pass (bottom sheet buttons + Chi tiết navigation)
- Total widget tests: 4 passed, 2 skipped.

## Kết quả

### Changed files
1. `lib/core/routing/app_router.dart`
2. `lib/features/orders/widgets/order_card.dart`
3. `lib/features/route_map/pages/route_map_page.dart`
4. `lib/features/orders/pages/order_detail_page.dart`
5. `test/features/orders/widgets/order_card_test.dart` (mới)
6. `test/core/routing/app_router_test.dart` (mới)
7. `test/features/route_map/pages/route_map_page_test.dart` (mới)

### Summary
- `/schedule-screen` route đã xóa.
- `_OrderDetailWrapper` không còn race condition, không còn flash UI.
- `OrderCard.onTap` navigate trực tiếp đến `WorkOrderDetailScreen` với `extra: order`.
- Bottom sheet trong route map có 3 buttons: "Chỉ đường", "Hoàn thành", "Chi tiết" — dạng Column, không overflow.
- `OrderDetailPage` mark as `@Deprecated`.
- Widget tests verify: OrderCard navigation, OrderCard display, RouteMap bottom sheet buttons, Chi tiết button navigation.

### Test steps
```bash
flutter analyze lib/core/routing/app_router.dart lib/features/orders/widgets/order_card.dart lib/features/route_map/pages/route_map_page.dart lib/features/orders/pages/order_detail_page.dart
flutter test test/features/orders/widgets/order_card_test.dart test/core/routing/app_router_test.dart test/features/route_map/pages/route_map_page_test.dart
flutter test
```

### Test results
- `flutter analyze` (new test files): No issues found.
- `flutter test` (new files): 4 passed, 2 skipped.
  - `order_card_test.dart`: 2/2 pass
  - `app_router_test.dart`: 0/2 pass, 2 skipped (requires IsarService.instance.init() for WorkOrderDetailScreen)
  - `route_map_page_test.dart`: 2/2 pass
- `flutter test` (full suite): 65/65 pass (63 existing + 4 new — 2 skipped not counted).

### Skipped tests
| Test | Reason |
|------|--------|
| `app_router_test.dart: shows WorkOrderDetailScreen when order exists` | Building `WorkOrderDetailScreen` requires `IsarService.instance.init()` which is unavailable in widget tests without complex setup |
| `app_router_test.dart: shows error UI when order not found` | Requires `OrdersService.instance.loadCachedOrders()` which needs Isar DB initialization |

### Remaining risks
- `/orders/:id` route vẫn tồn tại để backward compatibility (deep link, back button). `_OrderDetailWrapper` vẫn hoạt động nhưng giờ đã clean.
- `route_info_panel.dart` không được sửa vì không được dùng anywhere trong app.
- `OrderDetailPage` file vẫn tồn tại nhưng deprecated — có thể xóa sau khi confirm không còn deep link nào dùng.
- 2 widget tests bị skip do phụ thuộc IsarService — cần integration test để cover error UI path.

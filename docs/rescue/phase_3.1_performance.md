# Phase 3.1 — Performance + Sync Stability

## Mục tiêu
Reduce main-thread blocking during sync and route building.

## Vấn đề hiện tại
- `OrdersService.fetchMyOrders` (`orders_service.dart:197-405`):
  - Gọi nhiều `search_read` / `read` tuần tự (orders, locations, routes).
  - Parse JSON → `FsmOrder.fromJson` cho hàng trăm records trên main thread.
  - `_resolveConflictsAndSave` chạy trong `writeTxn` — có thể block.
- `RecurringService.generateOfflineInstances` (`recurring_service.dart:152-299`):
  - Vòng lặp while với nhiều `findFirst` / `writeTxn` — có thể block.
- `SyncManager._runHandlers` (`sync_manager.dart:162-178`):
  - Chạy tuần tự `await namedHandler.handler()` — nếu 1 handler chạy lâu → block.

## Kế hoạch sửa
- File: `lib/features/orders/services/orders_service.dart`
  - `fetchMyOrders`: di chuyển JSON parsing sang `compute()` isolate nếu số records > 50.
  - Giữ fallback nếu `compute` fail.
- File: `lib/core/database/sync_manager.dart`
  - `_runHandlers`: giữ tuần tự nhưng thêm timeout cho từng handler (30s).
  - Nếu handler timeout → log error, tiếp tục handler tiếp theo.
- File: `lib/features/route_map/providers/route_provider.dart`
  - `buildRoute`: sort + `RouteStop.fromOrder` là nhẹ → không cần isolate.
  - `_calculateDistances`: nếu stops > 100 → cân nhắc `compute`.

## Không thay đổi
- Isar schema.
- Business logic.
- Sync handler registration.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

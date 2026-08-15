# Phase 3.2 — Pagination / Safe Loading

## Mục tiêu
Add safe pagination or limit loading cho order list.

## Vấn đề hiện tại
- `OrdersService.fetchMyOrders` fetch tất cả orders (`search_read` không có `limit`) → có thể nặng nếu backend có hàng nghìn đơn.
- `OrdersListPage` hiện tất cả orders trong một `ListView.builder` → không có phân trang.
- `TimesheetProvider` đã có pagination (`_pageSize = 100`, `loadMoreEntries`).
- `PropertiesService` đã có pagination (`defaultPageSize = 50`).

## Kế hoạch sửa
- File: `lib/features/orders/services/orders_service.dart`
  - Thêm `pageSize = 50` constant.
  - `_callSearchRead` thêm `limit: _pageSize` và `offset` parameter.
  - `fetchMyOrders` fetch page đầu tiên; `loadMoreOrders` fetch page tiếp theo.
  - Nếu API không hỗ trợ pagination (Odoo `search_read` hỗ trợ `limit`/`offset`) → dùng local caching + warning log.
- File: `lib/features/orders/pages/orders_list_page.dart`
  - Thêm `ScrollController` + `_loadMore` khi scroll gần bottom.
  - Hiện `CircularProgressIndicator` ở bottom khi loading more.
  - Pull-to-refresh vẫn làm mới page đầu tiên.
- File: `lib/features/orders/providers/orders_provider.dart`
  - Thêm `loadMoreOrders()` method.
  - Track `hasMore`, `currentOffset`.

## Constraints
- Không break offline mode.
- Không duplicate records.
- Không crash khi network fail.

## Đã làm
_Chưa implement — chờ duyệt plan._

## Kết quả
_Sẽ cập nhật sau khi implement._

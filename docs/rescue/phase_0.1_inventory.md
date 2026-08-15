# Phase 0.1 — Rescue Inventory

## 1. Navigation Map

### Tất cả routes đã đăng ký (`lib/core/routing/app_router.dart`)

| Route | Screen | Loại | Trạng thái |
|-------|--------|------|-----------|
| `/` | SplashPage | Public | Active |
| `/login` | LoginPage | Public | Active |
| `/shell/schedule` | ScheduleScreen | Shell branch 0 | Active (primary home) |
| `/shell/properties` | SchedulePropertiesListPage | Shell branch 1 | Active (placeholder) |
| `/shell/settings` | SettingsPage | Shell branch 2 | Active (placeholder) |
| `/orders` | OrdersListPage | Protected | Active |
| `/orders/:id` | `_OrderDetailWrapper` → push `/work-order-detail-screen` với `extra: FsmOrder` | Protected | Active (wrapper indirection) |
| `/route-map` | RouteMapPage | Protected | Active |
| `/scanner/:orderId` | ScannerPage | Protected | Active |
| `/stock-moves/:orderId` | StockMovesPage | Protected | Active |
| `/work-order/:orderId` | WorkOrderPage | Protected | Active (acceptance/signature stepper) |
| `/timesheet/:orderId` | TimesheetPage | Protected | Active |
| `/expense/:orderId` | ExpensePage | Protected | Active |
| `/schedule-screen` | ScheduleScreen | **Duplicate** | Active (trùng `/shell/schedule`) |
| `/work-order-detail-screen` | WorkOrderDetailScreen | Protected | Active (primary order detail) |
| `/schedule-properties/:id` | SchedulePropertyDetailPage | Protected | Active (chỉ navigate từ Properties list) |

### Duplicate / suspicious routes
- `/schedule-screen` trùng `/shell/schedule` — cùng `ScheduleScreen`, 2 route entries.
- `/orders/:id` không trực tiếp render order detail mà dùng `_OrderDetailWrapper`:
  - Đầu tiên đọc `OrdersProvider.orders` tìm order theo `odooId`.
  - Nếu không có, gọi `OrdersService.instance.loadCachedOrders()` và tìm lại.
  - Nếu vẫn không có → hiện error.
  - Nếu có → dùng `WidgetsBinding.instance.addPostFrameCallback` để `context.push(RouteNames.workOrderDetailScreen, extra: order)`.
  - **Vấn đề**: post-frame callback có thể race với navigation stack; nếu user tap nhanh có thể push 2 lần.
- `_OrderDetailWrapper` hiện `Scaffold(body: Center(CircularProgressIndicator()))` trong khi chờ — flash UI.

### Inbound navigation sources
- `OrderCard.onTap` → `context.push(RouteNames.orderDetail.replaceFirst(':id', '${order.odooId}'))` → dùng wrapper.
- `ScheduleCard.onTap` → `context.push(RouteNames.workOrderDetailScreen, extra: order)` → trực tiếp.
- `_RouteStopCard.onTap` → `_showStopBottomSheet` → không navigate trực tiếp đến order detail, chỉ có nút "Chi tiết" mở bottom sheet.
- `SchedulePropertiesListPage` → `context.push('/schedule-properties/${p.odooId}', extra: p)`.

## 2. Order Detail Screens

### `lib/features/orders/pages/order_detail_page.dart` — OrderDetailPage
- **Mục đích**: Màn hình chi tiết đơn mới, thiết kế card-based.
- **Widget**: `StatefulWidget`, đọc `OrdersProvider` để tìm order theo `widget.orderId`.
- **Nội dung**:
  - `SliverAppBar` với tên đơn + `OrderStatusChip` + `RecurringBadge`.
  - `_buildInfoCard`: partner name, phone, location, technician, description.
  - `_buildScheduleCard`: scheduled start/end, check-in thực tế.
  - `_buildActionsCard`: route map, stock, timesheet, expense, work order, skip.
  - Bottom actions: Check-in / Bắt đầu thực hiện / Hoàn thành.
- **Trạng thái**: Đang active, nhưng **không phải single source of truth**. Chỉ được navigate đến qua `/orders/:id` wrapper.
- **Vấn đề**:
  - Không có signature/photo/material capture trực tiếp.
  - `_confirmComplete` gọi `WorkOrderProvider.loadReport` để kiểm tra signature → phụ thuộc vào WorkOrder flow.

### `lib/screens/work_order_detail_screen.dart` — WorkOrderDetailScreen
- **Mục đích**: Màn hình nghiệm thu đầy đủ (signature, photos, materials, timesheet, completion).
- **Widget**: `StatefulWidget with WidgetsBindingObserver`, nhận `FsmOrder order` qua constructor.
- **Nội dung**:
  - Sticky header: địa chỉ, partner, due date, duration/price, action buttons (Mark complete, Timesheet, Skip).
  - Expandable sections: General Instructions, Work Required, Attachments (photos), Materials Used, Timesheet, Work Report, Signature.
  - Photo capture: `_pickPhoto` (camera/gallery/in-app camera), `_uploadPhoto` (real-time upload).
  - Signature: `SignatureController`, export PNG, save vào `WorkReport`.
  - Materials: `_openMaterialSheet` → `MaterialEntryForm` → `StockService.recordStockOut`.
  - Check-in/out: `_onCheckIn`, `_onCheckOut` → `OrdersService.checkIn/checkOut`.
  - Completion: `_onComplete` → kiểm tra signature → submit report → `OrdersService.completeOrder`.
- **Trạng thái**: **Single source of truth** cho order detail. Feature-complete nhất.
- **Vấn đề**:
  - `_buildStickyHeader` dùng `Text` cho `locationAddress` / `partnerName` không có `Expanded`/`Flexible` → có thể overflow.
  - `_repeatText` khởi tạo async trong `initState` → race nếu widget dispose sớm.
  - `_loadReportDraft` catch lỗi nhưng log only → user không biết nếu report load fail.

### `lib/features/work_order/pages/work_order_page.dart` — WorkOrderPage
- **Mục đích**: Stepper nghiệm thu 3 bước (Công việc → Chữ ký → Xác nhận).
- **Widget**: `StatefulWidget`, đọc `WorkOrderProvider`.
- **Nội dung**:
  - Step 0: work done text, problems, photos.
  - Step 1: customer signature widget.
  - Step 2: summary review + submit.
- **Trạng thái**: Active nhưng là **sub-flow**, không phải order detail chính. Navigate từ `OrderDetailPage._buildActionsCard` hoặc `WorkOrderDetailScreen` (không, WorkOrderDetailScreen không navigate đến đây).
- **Vấn đề**: `_validateStep` dùng `order?.requirePhoto` và `order?.requireSignature` — nếu `order` null thì không validate đúng.

## 3. Sync/Isar Write Points

### Models & Unique Indexes
| Model | Collection | Unique Index |
|-------|-----------|--------------|
| `FsmOrder` | `fsmOrders` | `odooId` (unique) |
| `FsmRecurring` | `fsmRecurrings` | `odooId` (unique) |
| `FsmFrequencySet` | `fsmFrequencySets` | `odooId` (unique) |
| `Product` | `products` | `odooId` (unique) |
| `ScheduleProperty` | `schedulePropertys` | `odooId` (unique) |
| `RouteStop` | `routeStops` | `orderOdooId` (unique) — **lưu ý: không thấy code persist RouteStop vào Isar** |

### Order writes
| File | Function | Method | Duplicate filtering |
|------|----------|--------|---------------------|
| `orders_service.dart` | `_resolveConflictsAndSave` | `putAllByOdooId` | Yes — deduplicate by `odooId` trong fetchedOrders, xử lý conflict local vs server |
| `orders_service.dart` | `updateStage` | `put` (single, trong `writeTxn`) | No cần thiết (single record) |
| `orders_service.dart` | `completeOrder` | `put` (single, trong `writeTxn`) | No cần thiết |
| `orders_service.dart` | `checkIn` | `put` (single, trong `writeTxn`) | No cần thiết |
| `orders_service.dart` | `checkOut` | `put` (single, trong `writeTxn`) | No cần thiết |
| `orders_service.dart` | `syncPending` | `put` (single, trong `writeTxn`) | No cần thiết |
| `recurring_service.dart` | `_generateLocalInstance` | `put` (single, trong `writeTxn`) | Dùng negative `odooId` để tránh unique index collision |
| `recurring_service.dart` | `fetchRecurringRules` | `put` / `putAllByOdooId` | Yes — merge existing by `odooId` |

### RouteStop writes
| File | Function | Method | Duplicate filtering |
|------|----------|--------|---------------------|
| `route_provider.dart` | `buildRoute` | **Không ghi Isar** — chỉ gán `_stops` in-memory | Deduplicate orders by `odooId` trong memory trước khi tạo `RouteStop` |

**Kết luận**: `RouteStop` hiện chỉ là in-memory model. Nếu sau này persist vào Isar, cần dedup vì `orderOdooId` có unique index.

### Other writes
| File | Function | Model | Method |
|------|----------|-------|--------|
| `stock_service.dart` | `recordStockOut` | `StockMove` | `put` (single) |
| `work_order_service.dart` | `getOrCreateReport` | `WorkReport` | `put` (single) |
| `work_order_service.dart` | `saveReport` | `WorkReport` | `put` (single) |
| `timesheet_service.dart` | `addEntry` | `TimesheetEntry` | `put` (single) |
| `timesheet_service.dart` | `syncPending` | `TimesheetEntry` | `put` (single) |
| `expense_service.dart` | `addExpense` | `Expense` | `put` (single) |
| `expense_service.dart` | `syncPendingWithResult` | `Expense` | `put` (single trong batch `writeTxn`) |
| `properties_service.dart` | `_fetchFromOdooAndCache` | `ScheduleProperty` | `clear` + `putAll` |

## 4. API/Odoo Field Mapping

### `fsm.order` mapping (`lib/features/orders/models/fsm_order.dart`)
- `fromJson` đọc trực tiếp từ JSON, không có try/catch cho missing key.
- **Suspicious fields**:
  - `json['require_photo']` (line 118) — backend có thể không có field này.
  - `json['fsm_recurring_id']` (line 102) — optional, nhưng được gửi trong `search_read` fields.
  - `json['person_id']` — fallback về 0 nếu thiếu.
  - `json['location_id']` — expected là List `[id, name]`.

### `fsm.recurring` mapping (`lib/features/orders/services/recurring_service.dart`)
- `fetchRecurringRules` gọi `search_read` trên `fsm.recurring` với fields cố định.
- **Đã có** try/catch cho `AccessError` (line 136-138): nếu user không có quyền đọc `fsm.recurring`, log warning và return.
- `generateOfflineInstances` không catch `AccessError` — có thể crash nếu recurring rules không accessible.

### `employee_id` mapping (`lib/core/api/odoo_session_manager.dart`)
- Line 84-109: sau khi authenticate, đọc `hr.employee` với domain `[['user_id', '=', session.userId]]`.
- **Nếu không tìm thấy → throw `OdooAuthException`** (line 106-109): "Tài khoản chưa được liên kết với Hồ sơ nhân sự (hr.employee)".
- **Hậu quả**: User không có `hr.employee` record sẽ **không thể login**.
- `employeeId` được dùng trong:
  - `timesheet_service.dart` line 82, 104, 189, 211: `employee_id` trong `account.analytic.line`.
  - `expense_service.dart` line 89, 129, 212, 396: `employee_id` trong `hr.expense`.
  - Nếu `employeeId == null` → expense service log warning và giữ offline (line 112-115).

### `fsm.person` mapping
- `orders_service.dart` line 208-271: tìm `person_id` qua `fsm.person.calendar.filter` → fallback `fsm.person` với `user_id` → fallback `person_ids` → fallback team calendar.
- Mỗi fallback đều catch `OdooBusinessException` cho `AccessError`/field not exist.

### `fsm.location` mapping
- `orders_service.dart` line 76-90: `_locationFields` định nghĩa fields đọc từ `fsm.location`.
- `ScheduleProperty.fromOdooJson` (`schedule_property.dart`): đọc `name`, `street`, `street2`, `city`, `zip`, `owner_id`, `partner_latitude`, `partner_longitude`, `phone`, `email`.

## 5. Likely Crash Sources (Top 10)

### P0 — Critical
1. **Login blocked by missing `hr.employee`** (`odoo_session_manager.dart:106-109`): throw nếu `employeeId` null → user không login được.
2. **Isar unique index violation** trên `RouteStop.orderOdooId`: hiện chưa persist, nhưng nếu sau này persist mà có duplicate → crash.
3. **API field not found**: `require_photo` (`fsm_order.dart:118`) — nếu backend không có field, `json['require_photo']` trả `null`, `== true` → `false`, không crash nhưng có thể logic sai. Nếu field không tồn tại trong `search_read` → Odoo trả `invalid field` → catch ở `_callSearchRead` line 178-193 đã retry với core fields only.
4. **AccessError on `fsm.recurring`**: `fetchRecurringRules` đã catch (line 136-138), nhưng `generateOfflineInstances` không catch → có thể crash trong `SyncManager` auto-sync.

### P1 — High
5. **RenderFlex overflow**:
   - `order_card.dart`: `order.name` trong `Row` có `Flexible` + `ellipsis` — OK.
   - `work_order_detail_screen.dart:655-661`: `locationAddress` / `partnerName` trong `_buildStickyHeader` không có `Expanded` → overflow nếu text dài.
   - `route_info_panel.dart`: `_StopTile` dùng `IntrinsicHeight` + `Row` — có thể overflow nếu text dài.
   - `schedule_card.dart:93-100`: `order.locationAddress ?? order.name` trong `Row` có `Expanded` — OK.
6. **Null dereference in `WorkOrderDetailScreen._onDirections`** (`work_order_detail_screen.dart:209-249`): kiểm tra `lat/lng` null trước → OK. Nhưng `_onCall` / `_onSms` kiểm tra `partnerPhone` null → OK.
7. **`_OrderDetailWrapper` race condition** (`app_router.dart:241-303`): `addPostFrameCallback` push route sau khi build. Nếu widget rebuild hoặc user navigate nhanh → có thể push linh tinh.
8. **`employeeId` null trong timesheet/expense**: `timesheet_service.dart` và `expense_service.dart` dùng `_odoo.currentSession?.employeeId`. Nếu null → expense giữ offline (OK), timesheet gửi `null` → Odoo có thể reject.

### P2 — Medium
9. **Session expired / re-auth loop**: `odoo_session_manager.dart:252-265` → `_tryReAuthenticate` luôn return false vì không lưu password → user phải login lại. Không crash nhưng UX xấu.
10. **Isar initialization failure**: `main.dart:117-121` catch lỗi init và tiếp tục → `IsarService.instance.db` có thể null → crash sau này nếu có code gọi DB trước khi init xong.

## 6. Minimal Phase 1 Plan

| Priority | File | Vấn đề | Fix đề xuất |
|----------|------|--------|------------|
| P0 | `lib/core/api/odoo_session_manager.dart` | Login blocked by missing `hr.employee` | Không throw nếu `employeeId` null; lưu session với `employeeId: null`; các service tự handle. |
| P0 | `lib/features/orders/models/fsm_order.dart` | `require_photo` không defensive | Dùng `json['require_photo'] == true` (đã OK) nhưng thêm comment; không crash nếu key thiếu. |
| P0 | `lib/features/route_map/providers/route_provider.dart` | RouteStop dedup (preparation) | Thêm comment + guard nếu sau này persist RouteStop. |
| P0 | `lib/core/routing/app_router.dart` | `/schedule-screen` duplicate + wrapper race | Remove `/schedule-screen`; simplify `_OrderDetailWrapper` hoặc navigate trực tiếp. |
| P1 | `lib/screens/work_order_detail_screen.dart` | Overflow trong sticky header | Wrap `locationAddress` / `partnerName` với `Expanded` + `TextOverflow.ellipsis`. |
| P1 | `lib/features/route_map/widgets/route_info_panel.dart` | Overflow trong `_StopTile` | Wrap text với `Expanded`; thêm `maxLines` + `ellipsis`. |
| P1 | `lib/features/orders/pages/order_detail_page.dart` | Overflow (nếu còn dùng) | Tương tự sticky header fix. |
| P2 | `lib/features/orders/services/orders_service.dart` | `_callSearchRead` defensive | Đã có retry với core fields only — giữ nguyên. |
| P2 | `lib/features/orders/services/recurring_service.dart` | `generateOfflineInstances` AccessError | Wrap trong try/catch nếu cần. |

## Đã làm


## Kết quả

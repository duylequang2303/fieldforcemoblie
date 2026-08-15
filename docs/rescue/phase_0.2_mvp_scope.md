# Phase 0.2 — Minimum Survival Scope

## Mục tiêu
Dựa trên inventory, định nghĩa phạm vi tối thiểu để app demo được, không crash.

## Must-Work Flows (bắt buộc phải chạy)
1. **Login** → nhập server/db/user/pass → authenticate → vào `/shell/schedule`.
2. **View orders** → load từ Isar cache (offline) hoặc Odoo (online) → hiện danh sách.
3. **Open order detail** → tap order → mở `WorkOrderDetailScreen` → thấy thông tin cơ bản.
4. **Check-in / Check-out** → đổi stage draft → in-progress → done.
5. **Photo/Signature capture** → chụp ảnh, ký tên, lưu local.

## Should-Work Flows (nên chạy được)
1. Route map / route stops list build không crash.
2. Offline cache rebuild an toàn khi app restart.
3. Pull-to-refresh làm mới orders.
4. Recurring badge hiển thị nhưng không crash nếu backend từ chối quyền.
5. Settings: test connection, sync now, auto-sync toggle.

## Disable-Temporarily Flows (ẩn nếu chưa ổn)
1. **Expense** — ẩn navigation `/expense/:orderId` cho đến khi backend `hr.expense` stable.
2. **Timesheet** — ẩn navigation `/timesheet/:orderId` cho đến khi `account.analytic.line` mapping stable.
3. **Stock/Scanner** — ẩn `/stock-moves/:orderId` và scanner nếu kho chưa config.
4. **Complex routing enforcement** — tắt strict GPS/sequential check-in validation trong `RouteProvider.checkInValidation` nếu GPS không reliable.
5. **Recurring management** — ẩn recurring create/edit; giữ read-only instance view.

## Screens/Routes to Keep
| Route | Screen | Lý do |
|-------|--------|--------|
| `/login` | LoginPage | Bắt buộc |
| `/shell/schedule` | ScheduleScreen | Home chính |
| `/shell/properties` | SchedulePropertiesListPage | Placeholder, giữ structure |
| `/shell/settings` | SettingsPage | Bắt buộc (connection, sync, logout) |
| `/orders` | OrdersListPage | Danh sách đơn |
| `/work-order-detail-screen` | WorkOrderDetailScreen | **Single order detail** |
| `/route-map` | RouteMapPage | Xem lộ trình (read-only list) |

## Screens/Routes to Redirect or Hide
| Route | Hành động | Lý do |
|-------|-----------|--------|
| `/schedule-screen` | **Xóa route** | Duplicate của `/shell/schedule` |
| `/orders/:id` | **Redirect trực tiếp** đến `/work-order-detail-screen` | Wrapper indirection gây race |
| `/work-order/:orderId` | Ẩn từ order detail actions | Stepper phụ, không phải order detail chính |
| `/stock-moves/:orderId` | Ẳn navigation entry | Stock module chưa stable |
| `/timesheet/:orderId` | Ẩn navigation entry | Timesheet module chưa stable |
| `/expense/:orderId` | Ẩn navigation entry | Expense module chưa stable |
| `/schedule-properties/:id` | Ẩn navigation entry | Properties tab chưa ready |

## Risk List
1. **Login failure** nếu user không có `hr.employee` record trên Odoo.
2. **White screen / crash** nếu `_OrderDetailWrapper` race condition.
3. **Isar crash** nếu sau này persist `RouteStop` mà không dedup.
4. **Odoo AccessError** trên `fsm.recurring` block order fetch nếu không catch đủ.
5. **RenderFlex overflow** trên màn nhỏ với tên/địa chỉ dài.
6. **Photo/signature upload** fail silently — user nghĩ đã lưu nhưng thực tế không.

## Đã làm


## Kết quả

# AGENTS.md – Quy tắc Code Dart/Flutter cho AI

## 1. Ngôn ngữ & Phong cách
- Tất cả **code** viết bằng **Dart**. Comment trong code viết **tiếng Anh**.
- Tất cả **tài liệu** (`.md`) và **comment giải thích nghiệp vụ** viết **tiếng Việt**.
- Dùng `prefer_single_quotes` cho tất cả string literal.

## 2. Cấu trúc Thư mục — Feature-First
- Mỗi tính năng nằm trong `lib/features/<feature_name>/` gồm: `models/`, `providers/`, `services/`, `pages/`, `widgets/`.
- Code dùng chung nhiều feature → đặt trong `lib/shared/`.
- Hạ tầng kỹ thuật (API, DB, Auth) → `lib/core/`.
- **Không bao giờ** import trực tiếp từ feature này vào feature khác. Giao tiếp qua `provider` hoặc `service` trong `core/`.

## 3. State Management — Provider
- Dùng `ChangeNotifier` + `Provider` / `Consumer`.
- Mỗi feature có 1 `XxxProvider extends ChangeNotifier`.
- `Provider` chỉ chứa state và logic điều phối. **Không** gọi Odoo API trực tiếp trong Provider — delegate sang `XxxService`.
- Không dùng `setState` trong các trang phức tạp (>2 state). Dùng `Consumer<XxxProvider>`.

## 4. Routing — go_router
- Toàn bộ route khai báo tập trung tại `lib/core/routing/app_router.dart`.
- Tên route dùng hằng số trong `lib/core/routing/route_names.dart`.
- Navigate bằng `context.go(RouteNames.xxx)` hoặc `context.push(RouteNames.xxx)`.
- **Không** dùng `Navigator.push()` trực tiếp.

## 5. Kết nối Odoo API
- Toàn bộ giao tiếp Odoo đi qua `OdooSessionManager` (singleton).
- Mỗi feature có `XxxService` riêng, chỉ gọi methods của `OdooSessionManager`.
- Wrap tất cả Odoo call bằng try/catch và throw `OdooApiException`.
- Không hardcode server URL / database name — đọc từ `flutter_secure_storage`.

## 6. Offline First
- Tất cả dữ liệu Odoo fetch về phải lưu vào **Isar DB** trước khi hiển thị.
- Khi offline: đọc từ Isar, hiển thị `OfflineBanner`.
- Khi online trở lại: `SyncManager` tự động push các thay đổi local lên Odoo.
- Model Isar đặt trong `features/<feature>/models/`, annotate `@collection`.

## 7. Naming Conventions
| Loại | Convention | Ví dụ |
|---|---|---|
| File | `snake_case.dart` | `orders_list_page.dart` |
| Class | `PascalCase` | `OrdersListPage` |
| Variable/Method | `camelCase` | `fetchOrders()` |
| Constant | `camelCase` | `routeOrders` |
| Isar Model | `PascalCase` + `@collection` | `FsmOrder` |

## 8. Error Handling
- Tất cả API call phải có error handling rõ ràng.
- Hiển thị lỗi qua `ErrorView` widget (trong `shared/widgets/`), không dùng `print()` hay `showSnackBar` inline.
- Dùng `logger.dart` (trong `core/utils/`) để log thay vì `print()`.

## 9. Những điều cấm
- ❌ Không dùng `dynamic` type — dùng kiểu cụ thể hoặc `Object?`.
- ❌ Không để code unreachable hoặc `TODO` lâu hơn 1 task.
- ❌ Không gọi Odoo API trực tiếp trong Widget hoặc Provider.
- ❌ Không import `dart:io` trong code business logic — chỉ trong service.

## 10. Odoo Backend Server
- **Server URL:** https://demo002.crmhub.vn/
- **Web Admin Credentials:** `admin` / `<),9853$6Ect`
- **SSH Target:** `ssh root@demo002.crmhub.vn`
- **Odoo Config File:** `/etc/odoo19/odoo.conf`
- **Restart Command:** `systemctl restart odoo19`
- **SSH Public Key:**
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB92PzdxE/sr9uywTUi6C0YhvcgzRYHJaPT55Owgi83o duylequang588@gmail.com
  ```
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
> ⚠️ **Bảo mật:** Toàn bộ thông tin nhạy cảm (URL, credentials, SSH key...) **KHÔNG được viết trực tiếp trong file này**. Chỉ đọc từ file `.env` (không đẩy lên git, đã có trong `.gitignore`). Nếu thiếu biến, yêu cầu User cung cấp hoặc kiểm tra `.env`.

- **Tất cả thông tin kết nối** đọc từ `.env`:
  - `ODOO_URL` → Server URL
  - `ODOO_ADMIN_USER` / `ODOO_ADMIN_PASSWORD` → Web Admin Credentials
  - `ODOO_SSH_TARGET` → SSH Target
  - `ODOO_SSH_PUBLIC_KEY` → SSH Public Key
  - `ODOO_CONFIG_FILE` → Odoo Config File
  - `ODOO_RESTART_CMD` → Restart Command
- Command mẫu (sau khi load `.env`):
  ```bash
  ssh "$ODOO_SSH_TARGET" "$ODOO_RESTART_CMD"
  ```

## 11. Quy tắc Cấu trúc dữ liệu Thợ & Thao tác Database
- ❌ **CẤM** tự ý chỉnh sửa, tạo mới hoặc ghi đè thông tin Kỹ thuật viên (`fsm.person`, `res_partner`, `res_users`) trên cơ sở dữ liệu Odoo trừ khi có yêu cầu bằng văn bản rõ ràng của User.
- 💡 **Sơ đồ ánh xạ tài khoản kiểm thử mặc định**:
  - **Tài khoản đăng nhập (App)**: `worker1@gmail.com` (User ID: `5`, Partner ID: `11` - tên "Kỹ thuật viên 1").
  - **Kỹ thuật viên phân công (Odoo)**: `James` (Person ID: `4`, Partner ID: `18`).
  - **Cơ chế lọc đơn hàng**: App di động của tài khoản `worker1@gmail.com` lọc đơn hàng thông qua người thực hiện dịch vụ là `James` (`person_id = 4`). Tất cả các đơn hàng kiểm thử cho thợ này bắt buộc phải gán `person_id = 4`.
- 📋 **Quy định tạo đơn hàng test chuẩn trên Odoo (phải đủ các trường bắt buộc để hiện lên Lịch trình)**:
  - `name`: Tên đơn hàng.
  - `person_id`: Gán cứng là `4` (James).
  - `location_id`: Gán mặc định là `18` (Vinhomes Landmark 81).
  - `stage_id`: Gán là `1` (New) hoặc `4` (In Progress).
  - `company_id`: Mặc định là `1`.
  - `team_id`: Mặc định là `1` (Bắt buộc NOT NULL).
  - `warehouse_id`: Mặc định là `1` (Bắt buộc NOT NULL).
  - `scheduled_date_start`: Thời gian bắt đầu (phải cùng ngày hiện tại để hiện lên lịch của app di động, ví dụ: `NOW()`).
  - `scheduled_date_end`: Thời gian kết thúc (ví dụ: `NOW() + INTERVAL '10 hours'`).
  - **Mẫu SQL insert chuẩn**:
    ```sql
    INSERT INTO fsm_order (
        name, person_id, location_id, stage_id, company_id, team_id, warehouse_id, 
        scheduled_date_start, scheduled_date_end, scheduled_duration, create_date, write_date, create_uid, write_uid
    ) VALUES (
        'Đơn FSM Test - ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'), 
        4, 18, 1, 1, 1, 1, 
        CURRENT_DATE + TIME '08:00:00', CURRENT_DATE + TIME '18:00:00', 10.0,
        NOW(), NOW(), 2, 2
    );
    ```
- ⚠️ **Hạn chế hỏi quyền tối đa**: Tránh chạy các lệnh shell thăm dò hoặc truy vấn rời rạc làm phiền User phê duyệt quyền nhiều lần. Nếu cần thông tin hoặc tạo dữ liệu test, hãy hỏi trực tiếp User hoặc gom các lệnh SQL/CLI cần thiết vào duy nhất một lần thực thi.

## 12. Quy tắc sử dụng MCP Subagents (a2a-platform)
- 💡 **Tự động hóa Agent (a2a)**: Để tối ưu hóa chất lượng code và tránh rủi ro, AI nên chủ động gọi các subagents của `a2a-platform` tùy theo ngữ cảnh của nhiệm vụ:
  - **Khi Code/Refactor**: Sử dụng `softwareengineeringexpert` để hỗ trợ dọn rác, tái cấu trúc hoặc phát triển tính năng mới.
  - **Khi Review/Kiểm lỗi**: Sử dụng `constructivecritic` để kiểm tra chéo các thay đổi, đặc biệt là các logic nghiệp vụ quan trọng.
  - **Khi Sandbox/Thử nghiệm**: Sử dụng `sandboxcodingagent` để thử nghiệm mã nguồn một cách cô lập.
- ⚡ **Thiết lập Nhớ Bối cảnh**: Kết hợp các Rule này cùng với việc huấn luyện trí nhớ dài hạn (qua các công cụ lưu trữ như `supermemory` hoặc Agent Memory) để AI ở các phiên chat khác tự động nhận diện và phối hợp các bộ tool MCP một cách hiệu quả.
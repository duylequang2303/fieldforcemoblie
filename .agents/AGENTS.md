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
- **Web Admin Credentials:** `admin` / `REDACTED_PASSWORD`
- **SSH Target:** `ssh root@demo002.crmhub.vn`
- **Odoo Config File:** `/etc/odoo19/odoo.conf`
- **Restart Command:** `systemctl restart odoo19`
- **SSH Public Key:**
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB92PzdxE/sr9uywTUi6C0YhvcgzRYHJaPT55Owgi83o duylequang588@gmail.com
  ```

## 11. Quy tắc Cấu trúc dữ liệu Thợ & Thao tác Database
- ❌ **CẤM** tự ý chỉnh sửa, tạo mới hoặc ghi đè thông tin Kỹ thuật viên (`fsm.person`, `res_partner`, `res_users`) trên cơ sở dữ liệu Odoo trừ khi có yêu cầu bằng văn bản rõ ràng của User.
- 💡 **Sơ đồ ánh xạ tài khoản kiểm thử mặc định**:
  - **Tài khoản đăng nhập (App)**: `worker1@gmail.com` (User ID: `5`, Partner ID: `11` - tên "Kỹ thuật viên 1").
  - **Kỹ thuật viên phân công (Odoo)**: `James` (Person ID: `4`, Partner ID: `18`).
  - **Cơ chế lọc đơn hàng**: App di động của tài khoản `worker1@gmail.com` lọc đơn hàng thông qua người thực hiện dịch vụ là `James` (`person_id = 4`). Tất cả các đơn hàng kiểm thử cho thợ này bắt buộc phải gán `person_id = 4`.
  - 📋 **Quy định tạo đơn hàng test chuẩn trên Odoo (phải đủ các trường bắt buộc để hiện lên Lịch trình)**:
    - **Các trường dữ liệu test bắt buộc**:
      - `name`: Tên đơn hàng (ví dụ: 'Đơn FSM Test').
      - `person_id`: James (ID: `4`) để ánh xạ với Kỹ thuật viên `worker1@gmail.com` trên App.
      - `location_id`: Oakview Residence (ID: `18`).
      - `stage_id`: New (ID: `1`) hoặc In Progress (ID: `4`).
      - `scheduled_date_start`: Ngày hiện hại lúc 08:00:00.
      - `scheduled_date_end`: Ngày hiện tại lúc 18:00:00.
      - `company_id`: Mặc định `1`.
      - `team_id`: Mặc định `1` (NOT NULL).
      - `warehouse_id`: Mặc định `1` (NOT NULL).
    - **Quy trình tạo đơn test trên môi trường Staging**:
      - Tạo trực tiếp qua giao diện Web Admin Odoo bằng cách truy cập `Field Service` -> `Work Orders` -> click `New` và điền đầy đủ các thông tin bắt buộc với giá trị tương ứng ở trên.
      - Hoặc chạy script/python-shell tạo đơn qua Odoo XML-RPC API sử dụng model `fsm.order` với phương thức `create` tiêu chuẩn:
        ```python
        # Sử dụng Odoo RPC client tạo record hợp lệ trên database demo002.crmhub.vn
        odoo.env['fsm.order'].create({
            'name': 'Đơn FSM Test - XMLRPC',
            'person_id': 4,
            'location_id': 18,
            'stage_id': 1,
            'scheduled_date_start': fields.Datetime.now().replace(hour=8, minute=0, second=0),
            'scheduled_date_end': fields.Datetime.now().replace(hour=18, minute=0, second=0),
        })
        ```
      - Nếu thực hiện thao tác trên server Staging thông qua SSH, bắt buộc phải bật xác thực Host Key (không dùng tùy chọn bỏ qua kiểm tra an toàn) và sử dụng Odoo Python Shell của Odoo thay vì thao tác SQL trực tiếp vào DB:
        ```bash
        ssh root@demo002.crmhub.vn "sudo -u odoo19 /opt/odoo19/venv/bin/python3 /opt/odoo19/odoo/odoo-bin shell -c /etc/odoo19/odoo.conf -d demo002.crmhub.vn --no-http" << 'EOF'
        self.env['fsm.order'].create({
            'name': 'Đơn FSM Test SSH',
            'person_id': 4,
            'location_id': 18,
            'stage_id': 1,
            'fsm_recurring_id': 1,  # ID của mẫu định kỳ (ví dụ: 1) để hiện lên trang Định Kỳ
            'scheduled_date_start': fields.Datetime.now().replace(hour=8, minute=0, second=0),
            'scheduled_date_end': fields.Datetime.now().replace(hour=18, minute=0, second=0),
            'team_id': 1,
            'warehouse_id': 1,
        })
        self.env.cr.commit()
        EOF
        ```
- ⚠️ **Hạn chế hỏi quyền tối đa**: Tránh chạy các lệnh shell thăm dò hoặc truy vấn rời rạc làm phiền User phê duyệt quyền nhiều lần. Nếu cần thông tin hoặc tạo dữ liệu test, hãy hỏi trực tiếp User hoặc gom các lệnh SQL/CLI cần thiết vào duy nhất một lần thực thi.
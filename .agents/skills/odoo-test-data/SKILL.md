---
name: odoo-test-data
description: Tạo đơn hàng FSM test chuẩn trên Odoo (SQL insert với các trường bắt buộc để hiện lên lịch app)
---

# Odoo Test Data Skill

Hướng dẫn tạo đơn hàng test chuẩn trên Odoo FSM backend để đơn hiển thị trên lịch trình (Schedule) của app di động.

## Sơ đồ ánh xạ tài khoản kiểm thử mặc định

- **Tài khoản đăng nhập (App)**: `worker1@gmail.com` (User ID: `5`, Partner ID: `11` — "Kỹ thuật viên 1").
- **Kỹ thuật viên phân công (Odoo)**: `James` (Person ID: `4`, Partner ID: `18`).
- **Cơ chế lọc đơn hàng**: App di động của `worker1@gmail.com` lọc đơn qua người thực hiện là `James` (`person_id = 4`). Mọi đơn test cho thợ này BẮT BUỘC gán `person_id = 4`.

## Trường bắt buộc để đơn hiện lên Lịch trình

| Trường | Giá trị | Ghi chú |
|--------|---------|---------|
| `name` | Tên đơn hàng | — |
| `person_id` | `4` (James) | Bắt buộc để app lọc được |
| `location_id` | `18` (Vinhomes Landmark 81) | Mặc định |
| `stage_id` | `1` (New) hoặc `4` (In Progress) | — |
| `company_id` | `1` | Mặc định |
| `team_id` | `1` | Bắt buộc NOT NULL |
| `warehouse_id` | `1` | Bắt buộc NOT NULL |
| `scheduled_date_start` | Cùng ngày hiện tại (ví dụ `CURRENT_DATE + TIME '08:00:00'`) | Bắt buộc để hiện lên lịch hôm nay |
| `scheduled_date_end` | Cùng ngày hiện tại (ví dụ `CURRENT_DATE + TIME '18:00:00'`) | — |
| `scheduled_duration` | `10.0` | Số giờ |

## Mẫu SQL insert chuẩn

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

## Cách thực thi trên Odoo server

Thông tin SSH đọc từ `.env` (không hardcode):

```bash
set -a && . ./.env && set +a
ssh "$ODOO_SSH_TARGET" "psql -d $ODOO_DB -c \"$SQL\""
```

## Quy tắc quan trọng

- **CẤM** tự ý chỉnh sửa, tạo mới hoặc ghi đè thông tin Kỹ thuật viên (`fsm.person`, `res_partner`, `res_users`) trừ khi có yêu cầu bằng văn bản rõ ràng của User.
- Gom các lệnh SQL/CLI cần thiết vào **duy nhất một lần thực thi** để tránh làm phiền User phê duyệt quyền nhiều lần.
- Nếu cần thông tin hoặc tạo dữ liệu test, hỏi trực tiếp User trước khi thực thi.

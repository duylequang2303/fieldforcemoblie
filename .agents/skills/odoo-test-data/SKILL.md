---
name: odoo-test-data
description: Tạo đơn hàng FSM test chuẩn trên Odoo (SQL insert với các trường bắt buộc để hiện lên lịch app)
---

# Odoo Test Data Skill

Hướng dẫn tạo đơn hàng test chuẩn trên Odoo FSM backend để đơn hiển thị trên lịch trình (Schedule) của app di động.

## Sơ đồ ánh xạ tài khoản kiểm thử mặc định

- **Tài khoản đăng nhập (App)**: `worker1@gmail.com`
- **Kỹ thuật viên phân công (Odoo)**:
  Tài khoản đăng nhập tương ứng với user trên Odoo sẽ được phân giải động qua XML ID hoặc API lookup fsm.person / fsm.person.calendar.filter liên kết với `user_id` để lấy `person_id` tương chuẩn, tránh hardcode ID cố định.
- **Cơ chế lọc đơn hàng**: App di động lọc đơn qua người thực hiện gán cho user. Mọi đơn test cho thợ gán động theo tài khoản đang dùng.

## Trường bắt buộc để đơn hiện lên Lịch trình

| Trường | Mô tả | Ghi chú |
|--------|---------|---------|
| `name` | Tên đơn hàng | — |
| `person_id` | ID của technician | Bắt buộc để app lọc được, được phân giải động |
| `location_id` | ID địa điểm | Địa điểm thực hiện |
| `stage_id` | ID trạng thái | Mới / Đang thực hiện |
| `company_id` | ID công ty | Mặc định |
| `team_id` | ID đội ngũ | Bắt buộc |
| `warehouse_id` | ID kho | Bắt buộc |
| `scheduled_date_start` | Ngày bắt đầu dự kiến | Định dạng ISO hoặc DateTime Odoo chuẩn |
| `scheduled_date_end` | Ngày kết thúc dự kiến | — |
| `scheduled_duration` | Thời gian kéo dài dự kiến | Số giờ |

## Quy trình tạo dữ liệu kiểm thử chuẩn qua Odoo RPC/MCP

Khuyến nghị sử dụng Odoo RPC/MCP thay vì SQL trực tiếp:

```bash
# Chuẩn bị payload tạo fsm.order bằng Node.js / Python hoặc script CLI gọi RPC
# Ví dụ gọi fsm.order create qua call_kw
```

Trong trường hợp bắt buộc phải sử dụng SQL insert, thực thi an toàn qua SSH pass psql stdin:

```bash
# Thiết lập strict mode và chuẩn bị SQL qua quoted heredoc để tránh shell interpolation
set -euo pipefail

# Xác thực các biến môi trường cấu hình bắt buộc trước
if [ -z "${ODOO_SSH_TARGET:-}" ] || [ -z "${ODOO_DB:-}" ]; then
  echo "Error: ODOO_SSH_TARGET and ODOO_DB environment variables must be defined."
  exit 1
fi

SQL_QUERY=$(cat <<'EOF'
INSERT INTO fsm_order (
    name, person_id, location_id, stage_id, company_id, team_id, warehouse_id,
    scheduled_date_start, scheduled_date_end, scheduled_duration, create_date, write_date
) VALUES (
    'Đơn FSM Test - ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'),
    (SELECT id FROM fsm_person WHERE user_id = (SELECT id FROM res_users WHERE login = 'worker1@gmail.com') LIMIT 1),
    (SELECT id FROM fsm_location LIMIT 1),
    (SELECT id FROM fsm_stage LIMIT 1),
    1, 1, 1,
    CURRENT_DATE + TIME '08:00:00', CURRENT_DATE + TIME '18:00:00', 10.0,
    NOW(), NOW()
);
EOF
)

# Truyền SQL qua stdin đến psql remote với ON_ERROR_STOP kích hoạt
ssh "$ODOO_SSH_TARGET" "psql -d $ODOO_DB -v ON_ERROR_STOP=1 -f -" <<EOF
$SQL_QUERY
EOF
```

## Quy tắc quan trọng

- **CẤM** tự ý chỉnh sửa, tạo mới hoặc ghi đè thông tin Kỹ thuật viên (`fsm.person`, `res_partner`, `res_users`) trừ khi có yêu cầu bằng văn bản rõ ràng của User.
- Gom các lệnh SQL/CLI cần thiết vào **duy nhất một lần thực thi** để tránh làm phiền User phê duyệt quyền nhiều lần.
- Nếu cần thông tin hoặc tạo dữ liệu test, hỏi trực tiếp User trước khi thực thi.

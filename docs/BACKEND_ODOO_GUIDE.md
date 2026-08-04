# Hướng dẫn Backend Odoo — Tự mò, truy vấn, sửa đổi

> Dành cho AI/developer cần làm việc với backend Odoo của dự án fieldforce_mobile.
> Bao gồm: SSH, cách đọc model/fields, truy vấn DB, debug lỗi API, tùy chỉnh module.

---

## 1. Thông tin kết nối SSH

```bash
# Server Odoo
Host: demo002.crmhub.vn
Port: 2224
User: ubuntu
# SSH key hoặc password đã được cấu hình trong ~/.ssh/config
# Ví dụ:
# Host demo002
#   HostName demo002.crmhub.vn
#   Port 2224
#   User ubuntu
#   IdentityFile ~/.ssh/id_ed25519
```

### SSH vào server
```bash
ssh demo002
# Hoặc
ssh ubuntu@demo002.crmhub.vn -p 2224
```

---

## 2. Cấu trúc Odoo trên server

### 2.1 Đường dẫn thường gặp
```bash
# Source code Odoo
cd /opt/odoo19/odoo

# Custom modules (nếu có)
cd /opt/odoo19/odoo/addons

# Hoặc custom path riêng
cd /home/ubuntu/odoo/custom/addons

# Service Odoo
sudo systemctl status odoo19
sudo journalctl -u odoo19 -f  # xem log real-time
```

### 2.2 Database
```bash
# Switch user sang postgres để truy cập DB
sudo -u postgres psql

# Liệt kê databases
\l

# Connect vào DB của fieldforce
\c fieldforce

# Liệt kê tables
\dt

# Liệt kê users/roles
\du
```

---

## 3. Đọc Model & Fields (Cách đầy đủ)

### 3.1 Xem danh sách model
```python
# Trong Odoo shell
env = request.env
models = env.registry.models
print(list(models.keys())[:20])  # 20 model đầu tiên
```

### 3.2 Xem fields của model
```python
# Cách 1: Dựng dictionary Python (đầy đủ nhất)
model = env['fsm.order']
fields_meta = model.fields_get()
for fname, meta in fields_meta.items():
    print(f"{fname}: {meta.get('type')} | {meta.get('string')}")

# Cách 2: Dùng ORM inspect
for field in model._fields.values():
    print(f"{field.name}: {field.type} | {field.string}")

# Cách 3: Dựa vào file Python (source code)
# Tìm file định nghĩa model
find /opt/odoo19/odoo -name "*.py" -exec grep -l "class FsmOrder" {} \;
# Hoặc tìm trong tất cả thư mục addons (mặc định và custom)
grep -r "class FsmOrder" /opt/odoo19/odoo/addons/ /home/ubuntu/odoo/custom/addons/
```

### 3.3 Kiểm tra xem model có custom field không
```python
# Kiểm tra _inherit vs _name
model = env['fsm.order']
print("_name:", model._name)
print("_inherit:", model._inherit)

# Nếu là _inherit, tìm module gọi extend
# File: <module>/models/fsm_order.py
# Ví dụ: fieldservice_recurring/models/fsm_order.py
```

### 3.4 Xem Many2one/Many2many fields
```python
field = model._fields.get('partner_id')
print("type:", field.type)           # many2one
print("relation:", field.relation)   # res.partner
print("string:", field.string)       # "Customer"
```

---

## 4. Truy vấn Database trực tiếp (SQL)

### 4.1 Xem schema của bảng
```sql
-- Liệt kê tables liên quan
\dt *fsm*;

-- Xem columns của fsm_order
\d fsm_order;

-- Xem indexes
\d+ fsm_order;
```

### 4.2 Query thông qua ORM (an toàn)
```python
# Search read
orders = env['fsm.order'].search_read(
    domain=[['person_id.user_id', '=', 5]],
    fields=['id', 'name', 'scheduled_date_start', 'stage_id', 'fsm_recurring_id'],
    limit=10
)
for o in orders:
    print(o['id'], o['name'], o.get('fsm_recurring_id'))

# Count
count = env['fsm.order'].search_count([['person_id.user_id', '=', 5]])
print("Total orders:", count)
```

### 4.3 Raw SQL (khi cần debug)
```python
# Chỉ dùng khi ORM không đủ
self.env.cr.execute("""
    SELECT id, name, scheduled_date_start, fsm_recurring_id
    FROM fsm_order
    WHERE person_id = %s
    ORDER BY scheduled_date_start ASC
""", (person_id,))
results = self.env.cr.fetchall()
```

---

## 5. Debug lỗi API từ Flutter App

### 5.1 Xem log Odoo khi app gọi API
```bash
# Real-time log
sudo journalctl -u odoo19 -f

# Lọc theo request ID (nếu có)
grep "fieldforce_mobile" /var/log/odoo/odoo.log

# Xem lỗi chi tiết
grep -A 20 "ValueError" /var/log/odoo/odoo.log
```

### 5.2 Test API trực tiếp bằng curl
```bash
# Login lấy session (Sử dụng placeholder bảo mật, hãy thay bằng tài khoản thực tế)
curl -X POST https://demo002.crmhub.vn/web/session/authenticate \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"call","params":{"db":"fieldforce","login":"your_username","password":"your_password"}}'

# Gọi search_read
curl -X POST https://demo002.crmhub.vn/web/dataset/call_kw \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION" \
  -d '{
    "jsonrpc":"2.0",
    "method":"call",
    "params":{
      "model":"fsm.order",
      "method":"search_read",
      "args":[[["person_id.user_id","=",5]]],
      "kwargs":{"fields":["id","name"],"limit":5}
    }
  }'
```

### 5.3 Xem domain/fields bị lỗi
Khi Flutter báo `Invalid field 'X' on model 'Y'`:
```python
# Kiểm tra field có tồn tại không
model = env['fsm.order']
print('service_type' in model._fields)  # True/False

# Nếu không có, tìm module custom định nghĩa trong tất cả addons
grep -r "service_type" /opt/odoo19/odoo/addons/ /home/ubuntu/odoo/custom/addons/
```

---

## 6. Tùy chỉnh Module Odoo

### 6.1 Cấu trúc module
```text
odoo-modules/
└── fieldforce_reports/
    ├── __init__.py
    ├── __manifest__.py
    ├── models/
    │   └── fsm_order.py          # Extend fsm.order
    ├── views/
    │   └── fsm_order_report_views.xml
    └── security/
        └── ir.model.access.csv
```

### 6.2 Extend model
```python
# odoo-modules/fieldforce_reports/models/fsm_order.py
from odoo import models, fields, api

class FsmOrder(models.Model):
    _inherit = 'fsm.order'

    # Thêm field mới
    x_custom_field = fields.Char(string="Custom Field")
```

### 6.3 Add computed field
```python
x_recurring_count = fields.Integer(
    string="Recurring Count",
    compute='_compute_recurring_count',
    store=True
)

@api.depends('fsm_recurring_id')
def _compute_recurring_count(self):
    for rec in self:
        rec.x_recurring_count = len(rec.fsm_recurring_id.fsm_order_ids)
```

### 6.4 Override method
```python
def write(self, vals):
    # Custom logic trước khi write
    done_stage = self.env.ref('fieldservice.stage_completed').id
    if vals.get('stage_id') == done_stage:
        vals['x_completed_at'] = fields.Datetime.now()
    return super().write(vals)
```

### 6.5 Restart Odoo sau khi sửa
```bash
sudo systemctl restart odoo19
# Hoặc nâng cấp module bằng lệnh CLI chính thức của Odoo (để load XML/CSV data và chạy các module hooks):
sudo -u odoo19 odoo19 -d fieldforce -u fieldforce_reports --stop-after-init
```

---

## 7. Kiểm tra Recurring Orders (Module fieldservice_recurring)

### 7.1 Tìm model
```python
# Model chính: fsm.recurring
recurring_model = env['fsm.recurring']
fields_meta = recurring_model.fields_get()
for fname, meta in fields_meta.items():
    print(f"{fname}: {meta.get('type')} | {meta.get('string')}")
```

### 7.2 Kiểm tra quan hệ
```python
# Một recurring tạo ra nhiều fsm.order
recurring = env['fsm.recurring'].browse(1)
print("Name:", recurring.name)
print("Max orders:", recurring.max_orders)
print("Order count:", recurring.fsm_order_count)
print("Orders:", recurring.fsm_order_ids.mapped('name'))

# Ngược lại: fsm.order có fsm_recurring_id
order = env['fsm.order'].browse(100)
print("Recurring:", order.fsm_recurring_id.name)
```

### 7.3 Tạo recurring order mới
```python
recurring_vals = {
    'name': 'WO/REC/2024/001',
    'person_id': person_id,           # fsm.person
    'location_id': location_id,       # fsm.location
    'start_date': '2024-01-01',
    'end_date': '2024-12-31',
    'max_orders': 12,                 # tổng số buổi
    'state': 'progress',
}
new_recurring = env['fsm.recurring'].create(recurring_vals)
print("Created:", new_recurring.id)
```

---

## 8. Fix lỗi thường gặp

### 8.1 "Invalid field 'X' on model 'Y'"
- Nguyên nhân: Flutter request field không tồn tại trên backend.
- Cách fix:
  1. SSH vào server, chạy Python shell:
     ```python
     env['fsm.order']._fields.keys()  # xem field thật
     ```
  2. So sánh với `_fields` list trong `orders_service.dart`
  3. Bỏ field không tồn tại khỏi `_fields`

### 8.2 "AccessError"
- Kiểm tra quyền: `ir.model.access.csv`
- Hoặc dùng `sudo()`:
  ```python
  orders = env['fsm.order'].sudo().search_read(...)
  ```

### 8.3 "MissingError: Record does not exist"
- Record bị xóa hoặc không có quyền đọc
- Debug:
  ```python
  rec = env['fsm.order'].browse(record_id)
  print(rec.exists())  # True/False
  ```

### 8.4 "ValidationError"
- Kiểm tra constraints trong model:
  ```python
  model = env['fsm.order']
  for constraint in model._constraints:
      print(constraint)
  ```

---

## 9. Workflow đề xuất khi mò backend

1. **SSH vào server**
   ```bash
   ssh demo002
   ```

2. **Mở Odoo shell**
   ```bash
   sudo -u postgres psql -d fieldforce -c "
   SELECT id, name, model, state
   FROM ir_model
   WHERE model LIKE '%recurring%' OR model = 'fsm.order';
   "
   ```

3. **Hoặc dùng Odoo shell Python**
   *Lưu ý: Để kiểm tra dữ liệu read-only, chạy shell trực tiếp dưới tài khoản dịch vụ odoo19 mà không cần dừng dịch vụ đang chạy. Chỉ dừng dịch vụ odoo19 khi thực sự cần thiết và phải nằm trong một maintenance window có tài liệu được phê duyệt.*
   ```bash
   sudo -u odoo19 odoo19 shell -d fieldforce --no-http
   # Trong shell:
   >>> env['fsm.recurring'].fields_get().keys()
   ```

4. **Đọc source code module**
   ```bash
   find /opt/odoo19/odoo -path "*/fieldservice_recurring/*" -name "*.py"
   cat /opt/odoo19/odoo/addons/fieldservice_recurring/models/fsm_order.py
   ```

5. **Test từ Flutter**
   ```bash
   flutter run
   # Xem logcat:
   adb logcat -s flutter
   ```

6. **Nếu cần sửa backend**
   - Tạo custom module trong `odoo-modules/`
   - Restart Odoo
   - Upgrade module

---

## 10. Checklist khi thêm feature mới

- [ ] Xác định model + fields qua SSH (`fields_get()`)
- [ ] Test `search_read` trực tiếp bằng Python shell
- [ ] Thêm field vào `_fields` trong `orders_service.dart` (chỉ field tồn tại)
- [ ] Parse JSON với `_strOrNull`/`_intOrNull` để chống false/null
- [ ] Viết unit test cho logic thuần
- [ ] Build + deploy lên thiết bị thật
- [ ] Xem log Odoo nếu app báo lỗi API

---

## 11. Lệnh nhanh (Cheat Sheet)

```bash
# SSH
ssh demo002

# Xem log Odoo
sudo journalctl -u odoo19 -f

# Vào PostgreSQL
sudo -u postgres psql -d fieldforce

# Xem models
sudo -u postgres psql -d fieldforce -c "SELECT model, name FROM ir_model WHERE model LIKE 'fsm.%' ORDER BY model;"

# Xem fields của model
sudo -u postgres psql -d fieldforce -c "SELECT fieldname, field_description, ttype FROM ir_model_fields WHERE model = 'fsm.recurring' ORDER BY name;"

# Restart Odoo
sudo systemctl restart odoo19

# Flutter test
flutter test test/recurring_service_test.dart

# Flutter analyze
flutter analyze

# Deploy
flutter run -d "SM M127F"
```

---

## 12. Lưu ý quan trọng

1. **Backend Odoo 19** chạy tại `/opt/odoo19/odoo/`
2. **Custom module** hiện tại: `odoo-modules/fieldforce_reports/`
3. **Model recurring**: `fsm.recurring` (module `fieldservice_recurring`)
4. **Model order**: `fsm.order` (có field `fsm_recurring_id` do module recurring extend)
5. **Không có field `service_type`** trên `fsm.order` — xác nhận bằng `fields_get()` trước khi thêm vào Flutter
6. **Cơ chế trừ buổi**: Backend tự động qua `fsm_order_count` + `max_orders`, app chỉ cần push `stage_id = Done`

---

*Last updated: 2026-04-08 — Tạo cho feature recurring orders + notifications*
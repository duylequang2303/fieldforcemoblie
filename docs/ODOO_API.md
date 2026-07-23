# ODOO_API.md – Mapping Odoo Model ↔ API ↔ Flutter Feature

## Cách gọi Odoo RPC (odoo_rpc package)

```dart
// Đọc records
final result = await client.callKw(
  model: 'fsm.order',
  method: 'search_read',
  args: [domain],
  kwargs: {'fields': ['id', 'name', 'stage_id', 'location_id'], 'limit': 80},
);

// Tạo record
final id = await client.callKw(
  model: 'hr.expense',
  method: 'create',
  args: [{'name': 'Xăng xe', 'total_amount': 150000}],
  kwargs: {},
);

// Cập nhật record
await client.callKw(
  model: 'fsm.order',
  method: 'write',
  args: [[orderId], {'stage_id': newStageId}],
  kwargs: {},
);
```

---

## 1. Feature: `orders/` — fsm.order

| Odoo Model | `fsm.order` |
|---|---|
| **Lấy danh sách đơn** | `search_read`, domain: `[['person_id.user_id', '=', uid]]` |
| **Fields cần** | `id, name, stage_id, location_id, partner_id, scheduled_date_start, description` |
| **Cập nhật stage** | `write([id], {'stage_id': stage_id})` |
| **Isar Model** | `FsmOrder` |

### Stage IDs thường gặp (cần verify với hệ thống thực tế)
| Stage | Tên | Hành động |
|---|---|---|
| 1 | New | Đơn mới |
| 2 | In Progress | Đang thực hiện |
| 3 | Done | Hoàn thành |

---

## 2. Feature: `stock/` — stock.picking + stock.move

| Odoo Model | `stock.picking` |
|---|---|
| **Lấy picking theo đơn FSM** | `search_read`, domain: `[['fsm_order_id', '=', order_id]]` |
| **Fields cần** | `id, name, state, move_ids, origin` |
| **Validate picking** | `button_validate()` |

| Odoo Model | `stock.move.line` |
|---|---|
| **Cập nhật qty done** | `write([id], {'qty_done': qty})` |
| **Tìm theo barcode** | `product.product` → `search_read([['barcode','=', code]])` |

---

## 3. Feature: `timesheet/` — account.analytic.line

| Odoo Model | `account.analytic.line` |
|---|---|
| **Tạo timesheet** | `create({'name': desc, 'unit_amount': hours, 'project_id': proj, 'task_id': task})` |
| **Fields cần** | `id, name, date, unit_amount, employee_id` |
| **Liên kết FSM** | `fsm_order_id` (nếu module fieldservice_timesheet cài) |

---

## 4. Feature: `expense/` — hr.expense

| Odoo Model | `hr.expense` |
|---|---|
| **Tạo chi phí** | `create({'name': desc, 'total_amount': amount, 'currency_id': vnd_id, 'employee_id': emp_id})` |
| **Upload ảnh hóa đơn** | `ir.attachment` → `create({'res_model':'hr.expense', 'res_id': exp_id, 'datas': base64_img})` |
| **Fields cần** | `id, name, date, total_amount, state` |

---

## 5. Feature: `work_order/` — Upload ảnh & Chữ ký

| Tác vụ | Odoo Model | Method |
|---|---|---|
| Upload ảnh nghiệm thu | `ir.attachment` | `create({'res_model':'fsm.order', 'res_id': id, 'datas': base64})` |
| Lưu chữ ký khách hàng | `fsm.order` | `write([id], {'customer_signature': base64_png})` |

---

## 6. Feature: `route_map/` — GPS Tracking

- **Không có model Odoo riêng** — GPS tọa độ ghi nhận local bằng `geolocator`.
- Khi Worker "Check in" tại địa điểm → cập nhật `fsm.order`: `write([id], {'date_start': now})`.
- Hiển thị địa chỉ `fsm.location`: field `partner_latitude`, `partner_longitude`.

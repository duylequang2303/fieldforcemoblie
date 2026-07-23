# PROJECT_CONTEXT.md – Bối cảnh Dự án Fieldforce Mobile

> Tài liệu này đồng bộ từ Odoo Backend tại `/home/odoodev/Duck/odoo/fieldforce/context.md`.

---

## 1. Thông tin Dự án
| Thành phần | Thông tin |
|---|---|
| **Backend** | Odoo v19.0 (OCA – Odoo Community Association) |
| **Backend Repo** | `/home/odoodev/Duck/odoo/fieldforce` |
| **Mobile App Repo** | `/home/odoodev/Duck/fieldforce_mobile` (dự án này) |
| **Tech Stack Mobile** | Flutter (Dart), Provider, go_router, Isar DB, Google Maps |
| **Kết nối** | Odoo JSON-RPC qua thư viện `odoo_rpc` |

---

## 2. Module Odoo Backend ↔ Feature Mobile

| Module Odoo | Model Odoo | Feature Flutter |
|---|---|---|
| `fieldservice` | `fsm.order`, `fsm.location`, `fsm.person` | `features/orders/` |
| `fsm_route_map` | *(GPS tracking)* | `features/route_map/` |
| `fieldservice_stock` | `stock.picking`, `stock.move` | `features/stock/` |
| `fieldservice_timesheet` | `account.analytic.line` | `features/timesheet/` |
| `fieldservice_expense` | `hr.expense` | `features/expense/` |
| *(fsm_order_sign)* | *(attachment, binary)* | `features/work_order/` |

---

## 3. Luồng Dữ liệu Tổng quan

```
Worker mở app
    │
    ├── Online?
    │     ├── CÓ → Fetch Odoo API → Lưu Isar DB → Hiển thị UI
    │     └── KHÔNG → Đọc Isar DB → Hiển thị UI + OfflineBanner
    │
Worker thực hiện công việc
    │
    ├── Thay đổi dữ liệu → Lưu Isar DB (local first)
    │
    └── Online trở lại → SyncManager tự động push lên Odoo
```

---

## 4. Tài khoản & Kết nối Test
- **Odoo Server URL:** Được nhập tại màn hình Login (lưu `flutter_secure_storage`).
- **Database:** Được nhập tại màn hình Login.
- **Xác thực:** Username + Password Odoo, sau khi login lưu session token.

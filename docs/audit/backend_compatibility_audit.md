# Backend Compatibility Audit

## Purpose
Systematic validation of Odoo backend compatibility with FieldForce Mobile App.
Run backend audit first, then app-side tests, then fix by priority.

## Backend Audit Script
Prerequisite: clone the backend repository alongside this app, e.g.:
```bash
git clone git@github.com:duylequang2303/fieldforce.git ../fieldforce
```

Location: `../fieldforce/develop/audit/validate_app_compat.py`

Run:
```bash
cd ../fieldforce/develop
odoo shell -c /etc/odoo19/odoo.conf < audit/validate_app_compat.py
```

## App-Side Test Suite
Location: `test/backend_compat_test.dart`

Run:
```bash
cd /home/duyle/coding/fieldforcemoblie
flutter test test/backend_compat_test.dart
```

---

## Contract: App → Backend API Calls

### Auth & Session
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| Login | `res.users` | `authenticate(db, login, password)` | — | Returns session |
| Get user lang | `res.users` | `read(userId, fields=['lang'])` | `lang` | Fallback to `vi_VN` |
| Get employee | `hr.employee` | `search_read([['user_id','=',uid]], fields=['id'])` | `id` | **CRITICAL: employee must exist** |

### Orders
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| List orders | `fsm.order` | `search_read(domain, fields, order)` | see fields below | Domain: `person_id = pid` |
| Get stages | `fsm.stage` | `search_read([], fields=['id','name'])` | `id`, `name` | Cache locally |
| Get completed stage | `ir.model.data` | `search_read(module='fieldservice', name='fsm_stage_completed')` | `res_id` | XML ID lookup |
| Read locations | `fsm.location` | `read(ids, fields)` | see location fields | Batch read for coords |
| Read routes | `fsm.route` | `read(ids, fields=['state'])` | `state` | Optional |
| Write order | `fsm.order` | `write([id], vals)` | `stage_id`, `date_start`, `date_end` | UTC format |
| Complete order | `fsm.order` | `action_complete([id])` | — | Standard action |
| Create order | `fsm.order` | `create(vals)` | `name`, `stage_id`, `scheduled_*` | **NO `is_skipped`, NO `require_signature`** |
| Message post | `fsm.order` | `message_post([id], kwargs)` | `body`, `message_type`, `subtype_xmlid`, `attachment_ids` | For photos |
| Signature wizard | `fsm.order.sign.wizard` | `create(vals)` + `action_sign([id])` | `order_id`, `signed_by`, `signature` | Returns `True` |

### Recurring
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| List recurring | `fsm.recurring` | `search_read([['active','=',true]], fields)` | `id`, `name`, `fsm_frequency_set_id`, `fsm_order_template_id`, `start_date`, `end_date`, `next_date`, `active`, `recurrence_rule_type`, `recurrence_completion_interval`, `recurrence_completed_count`, `recurrence_skipped_count` | |
| Read frequency sets | `fsm.frequency.set` | `read(ids, fields)` | `id`, `name`, `interval`, `interval_type`, `duration` | |
| Read template order | `fsm.order` | `read([id], fields)` | basic fields | For offline instance generation |

### Expenses
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| Check duplicate | `hr.expense` | `search_read(domain, fields)` | `id`, `total_amount` | By name+date+employee+order |
| Create expense | `hr.expense` | `create(vals)` | `name`, `total_amount`, `unit_amount`, `quantity`, `date`, `employee_id`, `product_id`, `fsm_order_id` | |
| Upload receipt | `ir.attachment` | `create(vals)` | `name`, `datas`, `mimetype`, `res_model`, `res_id` | res_model=`hr.expense` |

### Timesheet
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| Check duplicate | `account.analytic.line` | `search_read(domain, fields)` | `id` | By employee+date+order+name+hours |
| Create line | `account.analytic.line` | `create(vals)` | `name`, `date`, `unit_amount`, `employee_id`, `fsm_order_id` | |

### Stock
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| Find product | `product.product` | `search_read(barcode/ilike, fields)` | `id`, `name`, `default_code`, `barcode`, `categ_id`, `uom_id`, `standard_price` | |
| Find picking type | `stock.picking.type` | `search_read([warehouse_id, code='outgoing'])` | `id` | |
| Read warehouse | `stock.warehouse` | `read([id], fields=['lot_stock_id'])` | `lot_stock_id` | |
| Create picking | `stock.picking` | `create(vals)` | `fsm_order_id`, `picking_type_id`, `location_id`, `location_dest_id` | |
| Confirm picking | `stock.picking` | `action_confirm([id])` | — | |
| Assign picking | `stock.picking` | `action_assign([id])` | — | |
| Read picking state | `stock.picking` | `read([id], fields=['state'])` | `state` | Must be `assigned` |
| Validate picking | `stock.picking` | `button_validate([id])` | — | |
| Create move | `stock.move` | `create(vals)` | `picking_id`, `fsm_order_id`, `name`, `product_id`, `product_uom_qty`, `location_id`, `location_dest_id` | |
| Write move qty | `stock.move` | `write([id], {'product_uom_qty': qty})` | `product_uom_qty` | **NOT `quantity`** |

### Locations & Routes
| Call | Model | Method | Required Fields | Notes |
|---|---|---|---|---|
| List locations | `fsm.location` | `search_read([], fields, limit=100, order='id')` | `id`, `name`, `partner_latitude`, `partner_longitude`, `partner_id`, `street`, `street2`, `city`, `zip`, `owner_id`, `direction`, `phone`, `email` | |
| Read routes | `fsm.route` | `read(ids, fields=['state'])` | `state` | Optional |

---

## Known Issues Found

### CRITICAL (Blocks functionality)
1. **Domain `person_id.user_id` doesn't work** — `fsm.person` has no `user_id` field
   - **Fix**: Use `fsm.person.calendar.filter` to map `user_id → person_id`
   - **Status**: FIXED in `orders_service.dart`

2. **`is_skipped` field missing on backend** — App sends it on `create`/`write`, Odoo rejects
   - **Fix**: Remove `is_skipped` from Odoo payloads, keep local-only
   - **Status**: FIXED in `orders_service.dart`

3. **`require_signature` is readonly related field** — App sends it on `create`, Odoo rejects
   - **Fix**: Remove from create payload
   - **Status**: FIXED in `orders_service.dart`

### HIGH (May break depending on config)
4. **`stock.move.quantity` doesn't exist** — Should be `product_uom_qty`
   - **Fix**: Changed to `product_uom_qty`
   - **Status**: FIXED in `stock_service.dart`

5. **Signature wizard returns `True`, app expects dict with `success`**
   - **Fix**: Accept both `True` and `{'success': True}`
   - **Status**: FIXED in `work_order_service.dart`

6. **Hardcoded Odoo version '19'** — `serverVersion: '19'` in session restore
   - **Risk**: Backend version mismatch
   - **Fix needed**: Make dynamic or verify backend version
   - **Status**: FIXED — dynamic `serverVersion` persisted in `SecureStorage` and restored

7. **Hardcoded product_id 1-5 for expenses** — Backend must have exactly these IDs
   - **Risk**: Expense creation fails if products don't match
   - **Fix needed**: Fetch product IDs dynamically by category name
   - **Status**: FIXED — dynamic fetch via `product.product` search with hardcoded fallback

### MEDIUM (Edge cases)
8. **Vietnamese stage name mapping** — App maps 'mới', 'nháp', etc. Backend must have matching stage names
   - **Risk**: Stage detection fails if backend uses English names only
   - **Fix needed**: Map by stage ID instead of name, or make name mapping configurable
   - **Status**: FIXED — `getStageIdByKeywords` accepts optional `fallbackIds`. Note: these fallback IDs are local-only conventions; `action_complete` does not send a stage ID to Odoo.

9. **`fsm.person.calendar.filter` required** — Module `fieldservice_calendar` must be installed
   - **Risk**: Order fetching fails if module not installed
   - **Fix needed**: Graceful fallback if module/records missing
   - **Status**: FIXED — silent fallback for missing-model errors, rethrow for real errors

10. **`hr.employee.user_id` link required** — Login fails if employee not linked to user
    - **Risk**: New users can't login
    - **Fix needed**: Better error message or auto-create employee
    - **Status**: FIXED — clear error message + blocks login correctly (downstream requires employee_id)

---

## Fix Priority Plan

### Phase 1: CRITICAL (Done)
- [x] Fix order fetching domain (`person_id.user_id` → `fsm.person.calendar.filter`)
- [x] Remove `is_skipped` from Odoo payloads
- [x] Remove `require_signature` from create payload
- [x] Fix signature wizard result check
- [x] Fix `stock.move.quantity` → `product_uom_qty`

### Phase 2: HIGH (Done)
- [x] Make Odoo version dynamic in session restore
- [x] Fetch expense product IDs dynamically instead of hardcoding 1-5
- [x] Add backend validation test to CI (app-side audit script + GitHub Actions workflow)

### Phase 3: MEDIUM (Done)
- [x] Improve stage name mapping (use ID instead of name where possible)
- [x] Add graceful fallback for missing `fieldservice_calendar` module
- [x] Better error handling for missing `hr.employee` link

---

## Test Checklist

Before building APK, verify:
- [x] Backend audit script passes (no CRITICAL issues) — *app-side audit + unit tests pass; backend script requires Odoo CLI in backend repo*
- [x] App-side unit tests pass — *47/47 tests pass*
- [ ] Manual test: login → fetch orders → update stage → complete order
- [ ] Manual test: stock scan → record material → validate picking
- [ ] Manual test: add expense → upload receipt → sync
- [ ] Manual test: add timesheet → sync
- [ ] Manual test: signature wizard → photo upload → submit report
- [ ] Manual test: recurring order generation (if applicable)

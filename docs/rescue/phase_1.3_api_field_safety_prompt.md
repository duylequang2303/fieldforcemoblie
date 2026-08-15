# Prompt Phase 1.3 — Sửa API field sai: require_photo, employee_id, fsm.recurring

You are a senior Flutter/Odoo integration engineer working in RESCUE MODE.

Task:
Make API mapping defensive and compatible with the actual Odoo backend.

Known suspicious fields:
- require_photo
- employee_id
- fsm.recurring

Requirements:

1. Per Odoo model DTO/mapper:
 - Do not send fields that may not exist on the Odoo model.
 - Do not read fields with hard failure if missing.
 - Use optional mapping with fallback.

2. For require_photo:
 - Check whether the backend model has require_photo.
 - If not, do not send it.
 - If there is an equivalent field such as require_picture, require_signature, require_image, map from that field.
 - If unknown, default to false or hide the UI flag.

3. For employee_id:
 - Check how fsm.person or current worker is represented.
 - Do not assume fsm.person.employee_id exists.
 - Prefer stable identifiers in this order if available:
 A. User_id
 B. Partner_id
 C. Person_id
 D. Id
 - If employee_id is missing, fallback safely.

4. For fsm.recurring:
 - The mobile app must not crash if the user has no access to fsm.recurring.
 - Wrap recurring fetch in try/catch.
 - On AccessError, return null/empty and hide recurring UI.
 - Do not block order list or order detail because recurring failed.

5. Add a safe API field allowlist:
 - Define known safe read fields.
 - Define known safe write fields.
 - Ignore unknown fields instead of crashing.

For now, assume we cannot quickly change Odoo access rights.
Make the mobile app resilient without requiring backend changes.
Disable or hide recurring-related UI on AccessError.

Acceptance criteria:
- App can load orders even if recurring fails.
- App can open order detail even if require_photo is absent.
- App can identify current worker without depending on employee_id if absent.
- No unhandled exception from JSON mapping.

Output:
- changed files
- fields removed/mapped/fallbacked
- how to test

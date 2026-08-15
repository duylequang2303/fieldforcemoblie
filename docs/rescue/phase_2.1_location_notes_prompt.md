# Prompt Phase 2.1 — Hiển thị thông tin địa điểm / ghi chú khách hàng

You are a senior Flutter/Odoo engineer working in RESCUE MODE.

Task:
Add a read-only Location/Customer Info section to the chosen Order Detail screen.

Business need:
Field workers need to see notes like:
- access code
- security guard instructions
- "house has dog"
- parking note
- contact note

Requirements:
1. Use existing fsm.location / res.partner / fsm.order related fields if available.
2. Do not create new backend fields unless explicitly requested.
3. If a field does not exist, hide it safely.
4. Display at least:
 - location/customer name
 - phone
 - address
 - note
5. Make the note section expandable if long.
6. No overflow.

Acceptance criteria:
- Order detail shows location notes when backend returns them.
- If backend lacks fields, app does not crash.
- UI remains readable.

Output:
- changed files
- fields used
- fallback behavior

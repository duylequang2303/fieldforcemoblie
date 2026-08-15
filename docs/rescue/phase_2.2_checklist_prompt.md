# Prompt Phase 2.2 — Checklist nghiệm thu tối thiểu

Nếu chưa kịp làm dynamic checklist từ Odoo, làm fallback tĩnh trước

You are a senior Flutter engineer working in RESCUE MODE.

Task:
Implement a minimal service checklist on Order Detail.

Constraints:
- Do not depend on unstable backend changes.
- Do not break existing offline sync.
- Use local state first.
- If backend field exists, sync; if not, store locally and mark pending sync.

Requirements:
1. Create a simple checklist model:
 - id
 - label
 - checked
 - valueText
 - valueNumber
 - orderOdooId
2. Provide fallback static checklist templates by service type:
 - air_conditioner
 - dishwasher
 - cleaning
 - garden
3. If order has service type/category, load matching template.
 If unknown, load generic checklist.
4. Checklist must support:
 - boolean check
 - text input
 - numeric input
5. Save checklist locally using existing local storage/Isar pattern if safe.
6. Do not add new package.

Air conditioner fallback checklist:
- Power on test
- Air outlet temperature
- Gas pressure
- Current/Ampere
- Drainage check
- Filter cleaning
- Customer signature

Dishwasher fallback checklist:
- Power on test
- Water inlet check
- Drain check
- Leak check
- Temperature check
- Descaling status
- Customer signature

Cleaning fallback checklist:
- Area completed
- Chemicals used
- Tools used
- Customer satisfaction
- Customer signature

Garden fallback checklist:
- Work area cleaned
- Plants trimmed
- Watering completed
- Pesticide/fertilizer used
- Safety waiting time noted
- Customer signature

Acceptance criteria:
- Checklist appears in order detail.
- User can check/input values.
- App does not crash if service type is unknown.
- Data can be read locally after reopening screen.

# Prompt Phase 2.3 — Thu tiền / chốt tiền mặt tối thiểu

You are a senior Flutter engineer working in RESCUE MODE.

Task:
Add minimal payment capture to Order Detail.

Business need:
Field workers may collect cash or transfer. Accounting needs to know amount collected.

Requirements:
1. Add payment fields to local order model only if safe:
 - payment_state: draft/paid/partial
 - amount_paid
 - payment_method: cash/transfer
 - payment_note
 - paid_at
2. Show a payment section in Order Detail.
3. Validate:
 - amount_paid >= 0
 - amount_paid <= total_amount if total_amount exists
4. If backend supports payment fields, sync them.
 If backend does not support them yet, store locally and mark pending sync.
5. Do not integrate full accounting/invoice yet.
6. Do not add QR/payment gateway yet.

Acceptance criteria:
- Worker can enter amount paid.
- Worker can choose cash or transfer.
- App validates invalid values.
- Data persists locally.
- No crash if backend fields are missing.

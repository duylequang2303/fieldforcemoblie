# Prompt Phase 3.2 — Pagination / load an toàn

You are a senior Flutter/Odoo engineer working in RESCUE MODE.

Task:
Add safe pagination or limit loading for order list if loading all records.

Requirements:
1. Use existing API list method.
2. Add page size constant, default 50.
3. Add pull-to-refresh.
4. Add load more only if API supports offset/limit.
5. If API does not support pagination, add local caching and warning log.
6. Do not break offline mode.

Acceptance criteria:
- First load is faster.
- No duplicate records.
- No crash when network fails.

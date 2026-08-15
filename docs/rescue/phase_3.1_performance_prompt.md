# Prompt Phase 3.1 — Performance + Sync ổn định

You are a senior Flutter performance engineer working in RESCUE MODE.

Task:
Reduce main-thread blocking during sync and route building.

Requirements:
1. Identify heavy functions in:
 - sync manager
 - route builder
 - offline storage
 - JSON parsing
 - Isar batch writes
2. Move CPU-heavy parsing or route calculation to compute()/isolate if safe.
3. Do not change business logic.
4. Do not change Isar schema.
5. Ensure cancellation/timeout does not crash UI.
6. Keep fallback if compute is unavailable.

Acceptance criteria:
- UI remains responsive during sync.
- No regression in route building.
- No new race condition.

# Prompt Phase 1.1 — Fix Isar Unique Index orderOdooId

You are a senior Flutter engineer working in RESCUE MODE.

Task:
Fix Isar Unique Index violation for RouteStop.orderOdooId.

Constraints:
- Do not change Isar schema unless necessary.
- Do not delete user data unless data is a rebuildable cache.
- If RouteStop is a local cache for route building, it may be cleared before rebuilding.
- Must deduplicate before writing.
- Must not crash if orderOdooId is null or duplicated.

Implementation requirements:
1. Find all code paths that insert RouteStop into Isar.
2. Before writing, filter duplicates by orderOdooId.
3. If orderOdooId is nullable, either:
 - skip invalid entries, or
 - generate a stable local key only if safe.
4. If the route list is rebuilt from API/cache, clear old RouteStop records inside the same write transaction before inserting new ones.
5. Add defensive logging instead of crashing.

Preferred pattern:
- Use a Set<int> or Set<String> to deduplicate.
- Use putAll with a cleaned list.
- Wrap in try/catch and return a safe fallback.

After changes:
- Provide list of changed files.
- Explain how to reproduce the previous crash and how it is now avoided.
- Provide manual test steps.
- Apply the Isar dedupe fix directly to the relevant file only.
- Do not touch unrelated files.

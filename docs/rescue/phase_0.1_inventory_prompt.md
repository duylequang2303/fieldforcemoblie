# Prompt Phase 0.1 — Kiểm kê repo Flutter

You are a senior Flutter rescue engineer. Work in RESCUE MODE.

Do NOT modify any code yet.
Do NOT refactor.
Do NOT add packages.

Task:
Read the Flutter repository and produce a rescue inventory.

Focus areas:
1. Lib/main.dart
2. App router / navigation files
3. Order detail screens
4. Route/trip/map screens
5. Sync manager / offline storage / Isar files
6. API client / Odoo service / DTO / mapper files
7. Providers/controllers related to orders, route stops, sync status, settings

Output format:

## 1. Navigation map
List all routes and their screens.
Mark duplicate or suspicious routes, especially anything related to:
- order detail
- work order detail
- route detail
- route stop

## 2. Order detail screens
List all files that look like order detail screens.
For each, state:
- file path
- likely purpose
- whether it seems deprecated, duplicate, or active
- which screen should be the single source of truth

## 3. Sync/Isar write points
List all places where RouteStop or Order is written into Isar.
Include:
- file path
- function name
- whether it uses put/putAll
- whether duplicate filtering exists

## 4. API/Odoo field mapping
List files that map fsm.order, fsm.person, fsm.recurring, fsm.location, stock, timesheet, expense.
Identify suspicious fields:
- require_photo
- employee_id
- fsm.recurring
- orderOdooId
- person_id
- partner_id

## 5. Likely crash sources
Based on code only, list top 10 likely crash sources.
Priority:
- Isar unique index violation
- RenderFlex overflow
- null check operator used on null
- API field not found
- AccessError on fsm.recurring
- duplicate navigation routes

## 6. Minimal Phase 1 plan
Propose a minimal fix plan with exact file paths.
Do not implement yet.

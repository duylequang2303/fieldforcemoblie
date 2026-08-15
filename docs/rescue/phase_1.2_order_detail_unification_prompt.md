# Prompt Phase 1.2 — Gom về một màn Order Detail duy nhất

You are a senior Flutter engineer working in RESCUE MODE.

Task:
Unify Order Detail navigation.

Problem:
The app likely has duplicate screens such as:
- OrderDetailPage
- WorkOrderDetailScreen
- ServiceOrderDetailScreen
- RouteStopDetailScreen

Requirements:
1. Identify the most complete active order detail screen.
 Prefer WorkOrderDetailScreen if it has newer fields/actions.
2. Make the router use that screen as the single order detail destination.
3. Replace navigation calls to deprecated screens with the chosen screen.
4. Do not delete old screen files unless they are unused and removal is safe.
5. If deletion is risky, mark them @Deprecated and redirect.
6. Ensure arguments/parameters are compatible.
7. Do not change business logic inside the chosen screen unless required to compile.

Acceptance criteria:
- From order list, tapping an order opens only the chosen screen.
- From route stops, tapping a stop opens the same chosen screen if appropriate.
- No dead routes.
- No duplicate detail screen in active navigation.

Output:
- chosen screen path
- deprecated screen paths
- router changes
- navigation call changes
- manual test steps

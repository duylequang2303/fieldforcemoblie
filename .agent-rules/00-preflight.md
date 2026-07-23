# Preflight Checks - Environment Readiness Verification

## Purpose
Ensure both development servers are reachable and properly rendering before test execution begins. The 5-minute execution timer does NOT start until preflight PASSES.

## Preconditions
- Odoo backend server must be running and accessible
- Flutter Web server must be running at http://localhost:8080

## Preflight Procedure

### Step 1: Verify Server Reachability
1. Check Odoo backend server reachability:
   - Send HTTP GET request to Odoo server URL
   - Verify HTTP 200 response is received
   - IF response is NOT 200, report "Environment error: Odoo backend unreachable" and STOP

2. Check Flutter Web server reachability:
   - Send HTTP GET request to http://localhost:8080
   - Verify HTTP 200 response is received
   - IF response is NOT 200, report "Environment error: Flutter web server unreachable" and STOP

### Step 2: Verify Actual Content Rendering (CRITICAL)
**Reachability alone is NOT sufficient. The application must actually render visible content.**

1. For Odoo Backend:
   - Wait up to 15 seconds (15,000 ms) for at least ONE visible DOM/semantics text node to appear
   - Look for identifiable text such as: login form, company logo, menu items, page title
   - IF after 15s there are ZERO DOM nodes with visible text content, report "Environment error: Odoo backend did not render" and STOP

2. For Flutter Web App (http://localhost:8080):
   - Wait up to 15 seconds (15,000 ms) for at least ONE visible DOM/semantics text node to appear
   - Look for identifiable text such as: app title, button labels, navigation items
   - IF after 15s there are ZERO DOM nodes with visible text content, proceed to Step 3

### Step 3: Flutter Web Semantics Tree Check
If no DOM nodes are found after page load for Flutter Web:

1. **Attempt to enable Semantics/Accessibility tree**:
   - Flutter Web renders via CanvasKit by default with no real DOM nodes
   - Check if Semantics mode is enabled or can be enabled
   - Wait an additional 10 seconds for semantics nodes to appear

2. IF semantics nodes STILL do not appear after retries:
   - Report "Environment error: Flutter Web CanvasKit rendering without accessible DOM after 2 retries"
   - Do NOT proceed to test execution
   - Output clear environment-error report

3. IF semantics nodes appear successfully:
   - Proceed to test execution using accessibility tree interactions

### Step 4: Retry Logic
- Maximum 2 retry attempts for each server
- Each retry includes: full HTTP request + 15s wait for DOM rendering
- After 2 failed retries on ANY server, STOP immediately

## Timing Rules
- **Time spent in preflight is NOT counted against the 5-minute execution budget**
- The 5-minute timer starts ONLY after preflight PASSES completely
- Log all preflight attempts with timestamps

## Failure Reporting
If preflight fails after 2 retry attempts:
- Output clear error message: "Environment error: [specific error]"
- Do NOT generate fake test results
- Do NOT attempt to continue with test execution
- Exit immediately with non-zero exit code

## Success Criteria
Preflight PASSES when:
1. Both servers return HTTP 200
2. At least one visible DOM/semantics text node is present on each page
3. For Flutter Web, either real DOM or semantics tree is accessible
4. No retry attempts remaining (or all passed on first try)

## Output Format
On success, log:
```
[PASS] Preflight completed successfully
- Odoo backend: HTTP 200, DOM nodes detected
- Flutter web: HTTP 200, [DOM/Semantics] nodes detected
- Execution timer started at: [timestamp]
```

On failure, log:
```
[FAIL] Preflight failed after [N] attempts
- Error: [specific error message]
- Action: Stopping test execution
```

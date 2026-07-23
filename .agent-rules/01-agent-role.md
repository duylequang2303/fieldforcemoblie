# Agent Role and Execution Rules

## Primary Role
**Senior QA Automator + UX Expert** specializing in Field Service Management (FSM) applications.

The agent acts as an automated testing system that validates both:
1. Odoo Web backend functionality
2. Flutter Web application ("fieldforce_mobile")

## Hard Timer Constraint (CRITICAL)

### 5-Minute Execution Budget
- **Total execution time: exactly 5 minutes (300,000 milliseconds)**
- The timer starts ONLY after preflight passes (per 00-preflight.md)
- When the timer expires, IMMEDIATELY stop ALL actions
- Output the Report immediately (per 05-report-schema.md), even if a test case is mid-execution
- Do NOT complete the current test case if it would exceed the timer

### Timer Expiration Handling
```
IF timer_expired == TRUE THEN
    1. Capture screenshot of current state
    2. Log: "Timer expired at [timestamp], stopping mid-execution"
    3. Mark current test case as "TIMEOUT_INCOMPLETE"
    4. Generate report with all completed test cases
    5. Exit with appropriate status
END IF
```

## Scope and Safety Rules (CRITICAL)

### Environment Constraints
1. **ONLY operate against the environment and account specified in .agent-rules/02b-test-credentials.md**
2. NEVER guess or invent a database name, URL, or login credentials
3. NEVER assume credentials are available - verify they exist in .env file first

### External Services
- **DO NOT call real external services** even if UI buttons are present:
  - Real payment gateways
  - Real customer email/SMS sending
  - Real third-party APIs that would incur costs
- If a button triggers external services, simulate or skip the test

### Source Code Protection
- **NEVER modify application source code while in test mode**
- Do not write temporary files to source directories
- Do not leave debugging code in production files

### Shared Environment Handling
- Treat the target Odoo server as a **SHARED environment** unless explicitly told otherwise
- See 02c-exploration-mode.md for action limits on shared servers
- Do not perform destructive operations without explicit confirmation

## 4-Step Workflow

### Step 1: Read Schema/Code + Prior Session Handoff
```
IF .agent-state/last-run.json exists THEN
    - Read previous test results
    - Identify PASS/FAIL/SKIPPED status
    - Determine where to resume
ELSE
    - Start fresh test suite
END IF

Read Dart models in: lib/features/**/models/*.dart
Read Odoo field definitions from repo documentation
```

### Step 2: Generate or Resume Test Cases
```
IF resuming_from_previous_session == TRUE THEN
    - Continue from first SKIPPED or NOT_RUN test case
    - Re-verify at least one previous PASS (per 06-session-handoff.md)
ELSE
    - Generate new test cases based on:
        * FSM business process flow (Schedule → Travel → Check-in → Materials → Photo → Signature → Complete)
        * Discovered UI structure
        * Available features in the app
END IF
```

### Step 3: Execute via Playwright MCP with Evidence Capture
```
FOR EACH test_case IN test_suite DO
    1. Capture screenshot BEFORE action
    2. Execute test action (click, fill, navigate)
    3. Wait for response (max 5000ms per action)
    4. Capture screenshot AFTER action
    5. Extract DOM/semantics text evidence
    6. Verify expected outcome
    
    IF evidence_captured == TRUE THEN
        status = "PASS"
    ELSE
        status = "FAIL"
    END IF
    
    Save checkpoint to .agent-state/last-run.json
    
    IF timer_remaining < estimated_test_time THEN
        Stop and generate report
    END IF
END FOR
```

### Step 4: Report Per Fixed Schema
- Generate JSON report: .agent-state/report.json
- Generate human-readable report: .agent-state/report.md
- Follow schema defined in 05-report-schema.md

## Test Case Categories
The agent should create test cases covering these FSM operations:

1. **Authentication**: Login, logout, session handling
2. **Scheduling**: View schedule, create/edit appointments
3. **Navigation**: Route map, directions, travel time
4. **Check-in/Check-out**: Location verification, time logging
5. **Materials/Parts**: Log used materials, inventory check
6. **Documentation**: Photo capture, notes, attachments
7. **Signature**: Customer signature capture
8. **Completion**: Mark job complete, send confirmation

## Output Requirements
- Always include visual evidence (screenshots)
- Always include text evidence (DOM/semantics content)
- Log all actions with timestamps
- Report in fixed JSON schema format

## Model Identity
The agent must identify itself in each run:
- Record `executed_by_model` in each test case
- Use semantic version for model identification
- Include model name in all log outputs

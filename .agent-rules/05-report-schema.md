# Test Report Schema

## Purpose
Define the fixed JSON schema structure for all test execution reports. This ensures consistent, machine-parseable output regardless of test outcomes.

## Report Files

### Primary JSON Report
- **Location**: `.agent-state/report.json`
- **Format**: Valid JSON
- **Purpose**: Machine-readable results for CI/CD integration

### Human-Readable Report
- **Location**: `.agent-state/report.md`
- **Format**: Markdown
- **Purpose**: Quick review by humans

## JSON Schema

### Root Structure
```json
{
  "report_metadata": {
    "generated_at": "ISO8601 timestamp",
    "execution_duration_ms": 300000,
    "execution_budget_ms": 300000,
    "preflight_passed": true,
    "preflight_timestamp": "ISO8601 timestamp",
    "environment": {
      "odoo_url": "https://odoo.example.com",
      "odoo_db": "production",
      "flutter_web_url": "http://localhost:8080"
    },
    "executed_by_model": "model-name-version"
  },
  "test_results": [
    {
      "test_case_id": "string (unique identifier)",
      "partition": "string (category: auth|schedule|navigation|checkin|materials|documentation|signature|completion)",
      "title": "string (descriptive test title)",
      "status": "PASS|FAIL|SKIPPED|TIMEOUT_INCOMPLETE",
      "duration_ms": 12345,
      "error_severity": "NONE|LOW|MEDIUM|HIGH",
      "error_message": "string (if status is FAIL)",
      "evidence": {
        "screenshot_before": "path/to/screenshot_before.png",
        "screenshot_after": "path/to/screenshot_after.png",
        "dom_text": "literal text actually read from page",
        "fallback_mode": "none|vision"
      },
      "executed_by_model": "model-name-version",
      "verified_evidence": true,
      "notes": "string (optional additional context)"
    }
  ],
  "summary": {
    "total_test_cases": 10,
    "passed": 7,
    "failed": 2,
    "skipped": 1,
    "timeout_incomplete": 0,
    "pass_rate_percentage": 70.0
  }
}
```

### Required Fields Per Test Case

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `test_case_id` | String | Unique identifier (e.g., "AUTH-001", "SCHED-002") | YES |
| `partition` | String | Category: auth, schedule, navigation, checkin, materials, documentation, signature, completion | YES |
| `title` | String | Descriptive test case title | YES |
| `status` | String | One of: PASS, FAIL, SKIPPED, TIMEOUT_INCOMPLETE | YES |
| `duration_ms` | Integer | Execution time in milliseconds | YES |
| `error_severity` | String | NONE, LOW, MEDIUM, HIGH | YES |
| `evidence` | Object | Evidence object (see below) | YES |
| `executed_by_model` | String | Model identifier that ran this test | YES |
| `verified_evidence` | Boolean | true if evidence was actually captured | YES |

### Evidence Object Structure

```json
"evidence": {
  "screenshot_before": "path/to/screenshot.png",
  "screenshot_after": "path/to/screenshot.png", 
  "dom_text": "literal DOM text content confirming outcome",
  "fallback_mode": "none|vision"
}
```

### Evidence Requirements (CRITICAL)

**A test case may NOT be marked PASS without:**
1. Non-empty `evidence` object
2. At least one screenshot file path
3. Non-empty `dom_text` field with LITERAL text read from the page

**Example of valid evidence:**
```json
"evidence": {
  "screenshot_before": ".agent-state/screenshots/auth_login_before_1705312200000.png",
  "screenshot_after": ".agent-state/screenshots/auth_login_after_1705312205000.png",
  "dom_text": "Welcome back, John Smith",
  "fallback_mode": "none"
}
```

**Invalid PASS (must be converted to FAIL):**
- Evidence has empty `dom_text`
- Evidence has no screenshots
- Evidence shows blank/crashed app
- `verified_evidence` is false

### Invalid PASS Handling
```
IF test_case.status == "PASS" AND (
    evidence.dom_text IS EMPTY OR
    evidence.screenshot_before IS EMPTY OR
    verified_evidence == FALSE
) THEN
    test_case.status = "FAIL"
    test_case.error_severity = "NONE"
    test_case.notes = "insufficient evidence — treat as unverified"
END IF
```

## Markdown Report Format

### Template
```markdown
# Test Execution Report

**Generated:** 2024-01-15T10:30:00Z  
**Duration:** 300,000ms (5 minutes)  
**Model:** Claude-Agent-v1.0  
**Environment:** Odoo @ https://odoo.example.com | Flutter Web @ http://localhost:8080

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | 10 |
| Passed | 7 |
| Failed | 2 |
| Skipped | 1 |
| Pass Rate | 70.0% |

## Test Results

### Auth Tests

#### AUTH-001: Login with valid credentials
- **Status:** PASS
- **Duration:** 1,234ms
- **Evidence:** screenshot_001.png | "Welcome back, John Smith"

#### AUTH-002: Login with invalid password
- **Status:** FAIL
- **Duration:** 2,345ms
- **Severity:** LOW
- **Error:** "Wrong password"
- **Evidence:** screenshot_002.png | "Wrong password"

[Continue for all test cases...]
```

## Status Values

### PASS
- Test executed successfully
- Expected outcome achieved
- Evidence captured (screenshot + DOM text)
- `verified_evidence` = true

### FAIL
- Test executed but outcome did not match expected
- Error occurred during execution
- Evidence captured (for debugging)
- `error_severity` must be set

### SKIPPED
- Test not executed due to:
  - UI frozen (per 04-error-handling.md)
  - Missing prerequisites
  - Previous test failure prevents this test
- `notes` must explain skip reason

### TIMEOUT_INCOMPLETE
- Execution timer expired before test completed
- Partial results captured
- Indicates budget exhaustion

## Error Severity Values

### NONE
- No error (for PASS status)
- Or: Insufficient evidence treated as failure

### LOW
- Minor issue that doesn't affect functionality
- Cosmetic UI glitch
- Non-critical warning

### MEDIUM
- Test failed but core functionality works
- Non-critical path affected
- Workaround exists

### HIGH
- Core functionality broken
- App crash or freeze
- Potential data issue

## Evidence Verification

### What Counts as Evidence
1. **Screenshot**: Visual proof of UI state
2. **DOM Text**: Actual text from page (not interpreted)
   - Button labels clicked
   - Error messages displayed
   - Confirmation messages
   - Page titles

### What Does NOT Count
1. "Test passed" without screenshots
2. Assumed outcomes
3. Blank screenshots (app not rendering)
4. Error messages that don't match actual page

## Report Generation

### When to Generate
1. After all test cases complete
2. After timer expires (partial report)
3. After unrecoverable error
4. On user request

### Where to Save
- JSON: `.agent-state/report.json`
- Markdown: `.agent-state/report.md`
- Screenshots: `.agent-state/screenshots/`

### Filename Convention
```
report_{timestamp}.json
report_{timestamp}.md
screenshot_{test_case_id}_{before|after}_{timestamp}.png
```

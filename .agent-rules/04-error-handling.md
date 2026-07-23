# Error Handling and Recovery

## Purpose
Define the error handling procedures, recovery strategies, and fallback mechanisms for test automation failures.

## Frozen UI Detection

### Definition of Frozen UI
A screen/UI is considered "frozen" when:
- No state change occurs for more than 10 seconds (10,000ms)
- No loading indicator completes
- No error message appears
- User interaction has no effect

### Frozen UI Detection Algorithm
```
action_start_time = current_timestamp()
action_description = "describe current action"

WHILE time_elapsed < 10000ms DO
    IF state_changed == TRUE THEN
        // UI is responsive
        RETURN "RESPONSIVE"
    END IF
    
    Wait 500ms
    Check for state changes
END WHILE

// If we reach here, 10 seconds have passed without state change
IF state_changed == FALSE THEN
    RETURN "FROZEN"
END IF
```

## Frozen UI Recovery Procedure

### Step 1: Capture Evidence
```
IF ui_state == "FROZEN" THEN
    // Always capture screenshot first
    1. Take screenshot of frozen state
    2. Save to: .agent-state/screenshots/frozen_{timestamp}.png
    3. Log: "Frozen UI detected during [action_description]"
    4. Log: "Frozen for [elapsed_time]ms"
END IF
```

### Step 2: Attempt Recovery Actions
```
// Recovery attempt 1: Refresh page
IF frozen_attempt == 0 THEN
    Log: "Recovery attempt 1: Refreshing page"
    page.reload()
    Wait 3000ms
    
    IF state_changed == TRUE THEN
        Log: "Recovery successful - page responsive after refresh"
        RETURN "RECOVERED"
    END IF
END IF

// Recovery attempt 2: Release focus
IF frozen_attempt == 1 THEN
    Log: "Recovery attempt 2: Releasing focus"
    Press: Tab key (to move focus)
    Press: Enter key (to confirm/release)
    Wait 2000ms
    
    IF state_changed == TRUE THEN
        Log: "Recovery successful - focus released"
        RETURN "RECOVERED"
    END IF
END IF
```

### Step 3: Mark Test Case as Skipped
```
// After 2 recovery attempts, give up
IF frozen_attempt >= 2 AND state_changed == FALSE THEN
    Log: "Recovery failed after 2 attempts"
    
    // Mark test case
    test_case.status = "SKIPPED"
    test_case.skip_reason = "UI Blocked - frozen after recovery attempts"
    test_case.frozen_duration_ms = total_elapsed_time
    
    // Move to next test case immediately
    Log: "Moving to next test case - not waiting out budget"
    
    // DO NOT retry this test case again in the same run
    RETURN "SKIPPED"
END IF
```

## Important: Not a Frozen UI

### Validation Errors Are NOT Frozen UI
The following are NOT frozen UI situations and should NOT trigger this fallback:

1. **Login Failure**
   - Error message: "Invalid database", "Wrong password"
   - This is a validation error, NOT frozen UI
   - Handle via: 02b-test-credentials.md procedures

2. **Form Validation Errors**
   - Error message: "Required field", "Invalid email format"
   - This is expected validation feedback
   - Continue with test case

3. **Confirmation Dialogs**
   - Popups asking for confirmation
   - This is normal UI behavior
   - Handle dialog appropriately

### Correct Response to Validation Errors
```
IF error_message_visible == TRUE THEN
    // This is NOT frozen UI
    IF error_type == "validation" THEN
        Log: "Validation error: " + error_message
        // Continue with test case - this is expected behavior
        // Fix input and retry
    ELSE IF error_type == "login" THEN
        Handle via: 02b-test-credentials.md
    ELSE
        Log: "Error: " + error_message
        Mark test case as FAIL
    END IF
END IF
```

## Checkpoint Persistence

### Save Checkpoint After EVERY Test Case
```
// NOT only at the end of session
// Save after EACH test case completion

checkpoint = {
    "timestamp": current_timestamp(),
    "last_test_case": test_case_id,
    "test_results": [
        // All test cases up to now
        {
            "test_case_id": "...",
            "status": "PASS|FAIL|SKIPPED",
            "duration_ms": 1234,
            "evidence": "..."
        }
    ],
    "execution_time_remaining": time_remaining_ms,
    "executed_by_model": "model_name"
}

Save to: .agent-state/last-run.json
```

### Why Checkpoint Every Time?
- Protects against abrupt quota cutoff
- Allows resume from exact point
- No loss of progress if interrupted
- Enables accurate session handoff

## Timeout Budget Management

### Timer Expiration During Test
```
IF execution_timer_expired == TRUE THEN
    // Stop immediately, even mid-test
    1. Capture final screenshot
    2. Mark current test as "TIMEOUT_INCOMPLETE"
    3. Generate partial report
    4. Log: "Budget exhausted at [timestamp]"
    5. Exit with appropriate status
END IF
```

### Budget Warning
```
IF time_remaining < 30000ms (30 seconds) THEN
    Log: "WARNING: Less than 30 seconds remaining"
    // Prioritize completing current test case
    // Or gracefully stop if too late
END IF
```

## Error Severity Classification

### Classification Criteria
```
error_severity = "NONE" IF no error
error_severity = "LOW" IF:
    - Minor UI glitch
    - Non-blocking visual issue
    - Cosmetic only

error_severity = "MEDIUM" IF:
    - Test case failed but app functional
    - Workaround exists
    - Non-critical path affected

error_severity = "HIGH" IF:
    - Core functionality broken
    - App crash
    - Data corruption possible
    - Security issue
```

### Error Response by Severity
```
IF error_severity == "HIGH" THEN
    // Stop execution, report immediately
    Generate report
    Exit with failure status
    
ELSE IF error_severity == "MEDIUM" THEN
    // Log error, continue to next test case
    Mark current test as FAIL
    Continue execution
    
ELSE IF error_severity == "LOW" THEN
    // Log warning, test passes
    Mark current test as PASS
    Continue execution
END IF
```

## Network Error Handling

### Connection Lost
```
IF network_error_detected == TRUE THEN
    Log: "Network error detected"
    
    // Wait briefly - might be temporary
    Wait 3000ms
    
    IF network_restored == TRUE THEN
        Log: "Network restored"
        Retry last action
    ELSE
        // Offline mode - skip dependent tests
        Mark test as SKIPPED
        Log: "Skipping - network unavailable"
    END IF
END IF
```

## Cleanup on Error

### Always Run Cleanup
```
FINALLY block (always executes):
    1. Close all open browser pages
    2. Release Playwright resources
    3. Save final checkpoint
    4. Generate report if not generated
    
    // Even if test fails:
    // - Screenshots are saved
    // - Progress is saved
    // - Report is generated
END
```

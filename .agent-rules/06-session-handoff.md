# Session Handoff Protocol

## Purpose
Ensure that when a new AI model takes over from a previous session (due to quota exhaustion or other interruptions), the new model can resume correctly without repeating prior mistakes or invalidating previous results.

## When Handoff Occurs
- Previous session quota exhausted
- Session timeout after inactivity
- User switches to different AI model
- External interruption (network loss, system restart)

## Mandatory First Steps for New Session

### Step 1: Read Prior Session State
```
IF exists(".agent-state/last-run.json") THEN
    // Read previous session results
    last_run = read_json(".agent-state/last-run.json")
    
    Log: "Found prior session from " + last_run.timestamp
    Log: "Previous model: " + last_run.executed_by_model
    
    // Extract test case statuses
    passed_cases = last_run.test_results.filter(status == "PASS")
    failed_cases = last_run.test_results.filter(status == "FAIL")
    skipped_cases = last_run.test_results.filter(status == "SKIPPED")
    incomplete_cases = last_run.test_results.filter(status == "NOT_RUN")
    
    Log: "Previous results: " + passed_cases.length + " PASS, " + failed_cases.length + " FAIL, " + skipped_cases.length + " SKIPPED"
ELSE
    // No prior session
    Log: "No prior session found - starting fresh"
    last_run = NULL
END IF
```

### Step 2: Re-Verify Previously Passed Tests (CRITICAL)
**DO NOT trust a prior PASS at face value. Re-verify randomly.**

```
IF last_run != NULL AND passed_cases.length > 0 THEN
    Log: "Re-verifying previously PASSED tests..."
    
    // Randomly select at least ONE previously PASSED test case
    test_to_verify = random_select(passed_cases)
    
    Log: "Re-verifying test case: " + test_to_verify.test_case_id
    
    // Execute the test case fresh
    result = execute_test(test_to_verify)
    
    IF result.status == "PASS" AND result.verified_evidence == TRUE THEN
        Log: "Re-verification PASSED - previous result was valid"
        // Continue with confidence
    ELSE
        // Previous PASS was actually invalid
        Log: "Re-verification FAILED - previous PASS was invalid/unverified"
        
        // Treat ENTIRE previous report as UNRELIABLE
        Log: "WARNING: Discarding entire previous session report"
        
        // Delete the unreliable checkpoint
        delete_file(".agent-state/last-run.json")
        
        // Re-run the FULL test suite from scratch
        Log: "Starting fresh test suite execution"
        
        // Clear any partial results
        Reset test suite to initial state
    END IF
END IF
```

### Step 3: Continue from Interrupted Point
If re-verification succeeds:

```
IF re_verification_success == TRUE THEN
    // Find where to continue
    next_test_case = NULL
    
    // Priority order:
    // 1. First test case marked SKIPPED
    // 2. First test case marked NOT_RUN
    // 3. First test case after last completed
    
    skipped_tests = last_run.test_results.filter(status == "SKIPPED")
    IF skipped_tests.length > 0 THEN
        next_test_case = skipped_tests[0]
        Log: "Resuming from skipped test: " + next_test_case.test_case_id
    ELSE
        not_run_tests = last_run.test_results.filter(status == "NOT_RUN")
        IF not_run_tests.length > 0 THEN
            next_test_case = not_run_tests[0]
            Log: "Resuming from not run test: " + next_test_case.test_case_id
        ELSE
            // All tests were run, start fresh
            Log: "Previous session completed all tests - starting fresh"
        END IF
    END IF
END IF
```

## Checkpoint Requirements

### Write Checkpoint After EVERY Test Case
```
// NOT only at session end
// Write after each test case to survive quota cutoff

checkpoint = {
    "timestamp": current_iso_timestamp(),
    "executed_by_model": current_model_name,
    "last_completed_test": test_case_id,
    "test_results": [
        // All test results up to this point
        {
            "test_case_id": "...",
            "status": "PASS|FAIL|SKIPPED|NOT_RUN",
            "duration_ms": 1234,
            "evidence": {
                "screenshot_path": "...",
                "dom_text": "..."
            },
            "executed_by_model": "...",
            "verified_evidence": true/false
        }
    ],
    "execution_time_remaining_ms": time_remaining,
    "session_id": unique_session_identifier
}

write_json(".agent-state/last-run.json", checkpoint)
```

### Checkpoint Data Requirements
Each test case in checkpoint MUST include:
- `test_case_id`: Unique identifier
- `status`: PASS, FAIL, SKIPPED, or NOT_RUN
- `duration_ms`: Execution time
- `evidence`: Screenshot path + DOM text
- `executed_by_model`: Which model ran it
- `verified_evidence`: true if evidence was actually proven

## Unreliable Results Indicators

### Treat as Unreliable If:
1. `verified_evidence` field is false or missing
2. Evidence has empty `dom_text`
3. Evidence has no screenshots
4. Previous session crashed (app blank/white)
5. Any re-verification fails
6. Report has no evidence at all

### Handling Unreliable Results
```
IF previous_report_is_unreliable == TRUE THEN
    // Discard the checkpoint
    delete_file(".agent-state/last-run.json")
    
    // Start fresh
    Log: "Previous session results unreliable - re-running full suite"
    
    // Reset all test cases to NOT_RUN
    FOR each test_case IN test_suite DO
        test_case.status = "NOT_RUN"
        test_case.verified_evidence = FALSE
    END FOR
    
    // Execute from beginning
END IF
```

## Never Claim Without Proof

### Prohibited Statements
A new agent must NEVER say:
- "Continuing based on previous report"
- "Skipping test as already passed"
- "Trusting prior results"

### Required Actions
Instead, always:
1. Re-verify at least one previous PASS
2. Check `verified_evidence` flag
3. If flag is false or missing, treat as NOT_RUN

```
// INVALID (never do this):
Log: "Test AUTH-001 was PASS in previous session - marking as complete"

// VALID (do this instead):
IF test_case.verified_evidence == TRUE THEN
    // Re-verify randomly
    result = execute_test(test_case)
    IF result.status == PASS THEN
        Log: "Test AUTH-001 re-verified PASS"
    END IF
ELSE
    // No verified evidence - must re-run
    Log: "Test AUTH-001 has no verified evidence - re-running"
    execute_test(test_case)
END IF
```

## Session ID Tracking

### Track Session Identity
```
session = {
    "session_id": generate_uuid(),
    "started_at": current_timestamp(),
    "resumed_from": previous_session_id_if_any,
    "executed_by_model": current_model_name,
    "model_version": semantic_version
}

write_json(".agent-state/session.json", session)
```

### Detect Session Changes
```
current_session = read_json(".agent-state/session.json")
previous_session_id = current_session.resumed_from

IF previous_session_id != NULL THEN
    Log: "This is a resumed session from: " + previous_session_id
    // Follow handoff protocol
ELSE
    Log: "This is a new session"
    // Start fresh
END IF
```

## Resume Point Determination

### Find Resume Point Algorithm
```
FUNCTION find_resume_point(last_run):
    // Priority 1: Find first SKIPPED test
    FOR each test_case IN last_run.test_results:
        IF test_case.status == "SKIPPED" THEN
            RETURN test_case
        END IF
    END FOR
    
    // Priority 2: Find first NOT_RUN test
    FOR each test_case IN last_run.test_results:
        IF test_case.status == "NOT_RUN" THEN
            RETURN test_case
        END IF
    END FOR
    
    // Priority 3: Resume after last completed
    RETURN last_completed_test + 1
    
    // If all complete: return NULL (start fresh)
END FUNCTION
```

## Final Validation

### Before Continuing
Ensure:
1. At least one previous PASS was re-verified
2. All test cases with `verified_evidence = false` are marked NOT_RUN
3. Session state is consistent
4. Checkpoint is saved

```
IF session_ready == TRUE THEN
    Log: "Session handoff complete - ready to continue"
    START executing from resume point
ELSE
    Log: "Session not ready - starting fresh"
    START fresh test suite
END IF
```

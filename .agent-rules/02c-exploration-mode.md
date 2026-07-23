# Exploration Mode - UI Discovery and Testing

## Purpose
Define the rules for exploring the application UI without a fixed script, while maintaining safety on shared/demo Odoo servers.

## When Exploration Mode Applies
- After successful login
- When no pre-written test cases exist for discovered UI
- When continuing from previous session without complete UI map

## Safety Principles

### Principle 1: Read-First, Write-Later
```
IF action_type == "READ" THEN
    Allow: open detail views, view tabs, expand sections
    Allow: scroll through lists, inspect fields
ELSE IF action_type == "WRITE" THEN
    Require: verification that data is safe test/demo data
END IF
```

### Principle 2: Single Record Modification
```
// Rule: Of all available records, select AT MOST ONE for full state-changing flow
IF clicking_state_changing_button == TRUE THEN
    // Button labels: Complete, Delete, Cancel, Approve, Confirm, Submit, Send
    
    IF records_modified_count >= 1 THEN
        Log: "Skipping state change on additional records - limit reached"
        Log: "Only viewing remaining records"
    ELSE
        Allow: perform state change
        Increment: records_modified_count
    END IF
END IF
```

### Principle 3: State-Changing Button Pre-Capture
```
// Before clicking any dangerous button, ALWAYS capture evidence
IF button_label contains_any ["Complete", "Delete", "Cancel", "Approve", "Confirm", "Submit", "Send"] THEN
    1. Capture screenshot BEFORE click
    2. Log action: "Preparing to click [button_label] on [record_identifier]"
    3. Record current state
    4. THEN perform click
    5. Capture screenshot AFTER click
    6. Log result
END IF
```

### Principle 4: Real vs Demo Data Detection
```
// If data looks like production/real data:
IF customer_name looks_real == TRUE AND
   address looks_real == TRUE AND
   data NOT contains "TEST" AND
   data NOT contains "DEMO" AND
   data NOT contains "SAMPLE" THEN
    
    Log: "WARNING: Potential real production data detected"
    Log: "Data: " + [sanitized_data_summary]
    
    // STOP and ask user
    Report: "Real production data detected - halting interaction"
    Report: "Please confirm if this is safe test/demo data before continuing"
    
    // Wait for user confirmation OR stop
    IF user_confirmed_safe == FALSE THEN
        STOP execution
    END IF
END IF
```

### Principle 5: UI Map Persistence
```
// Log discovered UI structure for future runs
IF discovered_new_ui_element == TRUE THEN
    Add to: .agent-state/discovered-ui-map.json
    - Element path/selector
    - Element label/text
    - Element type (button, input, link, etc.)
    - Parent navigation path
END IF
```

## Exploration Workflow

### Step 1: Initial Navigation
```
1. Start at main dashboard/home
2. Capture screenshot
3. Extract all visible navigation elements
4. Log: main menu items, section headers

5. FOR EACH main_menu_item DO
    - Click to expand
    - Capture screenshot
    - Extract sub-menu items
    - Log navigation path
END FOR
```

### Step 2: Record Discovery
```
FOR EACH list_view DO
    - Count available records
    - Extract first few record previews
    - Identify: record ID, name, status, date
    
    IF list_count > 0 THEN
        Select: first record for exploration
        Click: open detail view
        Extract: all fields, buttons, actions
        Log: complete record structure
    END IF
END FOR
```

### Step 3: Action Discovery
```
FOR EACH button_or_action DO
    - Identify button label
    - Identify button purpose (view, edit, create, delete, complete)
    - Note: button state (enabled/disabled)
    - Note: conditional visibility rules
    
    IF action is state_changing AND safe_to_test == TRUE THEN
        Mark: available for testing (limit to 1 per category)
    ELSE
        Mark: view_only for this session
    END IF
END FOR
```

### Step 4: Generate Test Cases from Discovery
```
// After exploration, generate test cases based on discovered UI
test_cases = []

FOR EACH discovered_flow DO
    test_case = {
        "title": "Test: " + flow_description,
        "partition": categorize(flow_type),
        "actions": flow_steps,
        "expected_outcome": expected_result,
        "evidence_requirements": what_to_capture
    }
    Add to: test_cases
END FOR
```

## UI Map Structure

### File: .agent-state/discovered-ui-map.json
```json
{
  "last_updated": "2024-01-15T10:30:00Z",
  "navigation_tree": {
    "main_menu": ["Field Service", "Calendar", "Customers", "Reporting"],
    "field_service_submenu": ["My Tasks", "All Orders", "Materials", "Timesheet"]
  },
  "discovered_pages": [
    {
      "path": "/web#action=field_service.my_tasks",
      "title": "My Tasks",
      "elements": [
        {"type": "button", "label": "Start", "selector": ".o_button_start"},
        {"type": "button", "label": "Complete", "selector": ".o_button_complete"}
      ]
    }
  ],
  "test_data_identifiers": {
    "demo_records": ["TEST_", "DEMO_", "Sample"],
    "production_indicators": []
  }
}
```

## Restrictions During Exploration

### Prohibited Actions
1. **DO NOT** perform bulk operations (mass delete, mass update)
2. **DO NOT** access database management features
3. **DO NOT** modify system configuration
4. **DO NOT** send real emails/SMS to customers
5. **DO NOT** create more than 1 new record for testing
6. **DO NOT** export sensitive data

### Allowed Actions (with limits)
1. View records and details
2. Click navigation links
3. Expand/collapse sections
4. Filter and search
5. Modify AT MOST ONE record (with pre-capture)
6. Create ONE demo record if needed

## Output
- Exploration results stored in: `.agent-state/discovered-ui-map.json`
- New test cases added to test suite
- All discoveries logged with timestamps
- Screenshots saved for each new page visited

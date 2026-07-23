# Tools and MCP Integration

## Purpose
Define the tools, interaction patterns, and MCP (Model Context Protocol) configurations for test automation.

## Primary Tool: Playwright MCP

### Interaction Method
- **PREFERRED**: Use Accessibility Tree / DOM text content for interactions
- **AVOID**: Raw pixel coordinates for click/tap actions
- **RATIONALE**: Accessibility tree is more stable and matches how users perceive UI

### Playwright MCP Capabilities
```
Available actions via Playwright MCP:
1. page.goto(url) - Navigate to URL
2. page.click(selector) - Click element by selector
3. page.fill(selector, text) - Fill input field
4. page.locator(selector) - Find element
5. page.screenshot() - Capture screenshot
6. page.content() - Get full HTML content
7. page.evaluate() - Execute JavaScript
8. page.waitForSelector(selector) - Wait for element
9. page.waitForTimeout(ms) - Wait for duration

Accessibility tree operations:
- Get accessibility tree snapshot
- Query by role, name, label
- Interact with semantic elements
```

## Flutter Web Specific Handling

### CanvasKit Rendering Challenge
Flutter Web uses CanvasKit by default, which:
- Renders via HTML5 Canvas
- Has NO real DOM nodes for UI elements
- Requires Semantics/Accessibility tree for automation

### Semantics Tree Verification and Enabling
```
IF app_type == "flutter_web" THEN
    // Step 1: Check if DOM nodes exist
    dom_nodes = page.locator("*").count()
    
    IF dom_nodes < 10 THEN
        // Likely CanvasKit without semantics
        Log: "Low DOM node count detected - checking for semantics"
        
        // Step 2: Check for semantics overlay/container
        has_semantics = page.locator("flt-semantics").count() > 0
        
        IF has_semantics == FALSE THEN
            // Step 3: Attempt to enable semantics
            // This may require URL parameter or app setting
            Log: "Attempting to enable semantics tree"
            
            // Try common Flutter Web semantics enable methods:
            // Method 1: URL parameter
            IF url does_not_contain "fl=semantics" THEN
                Navigate to: current_url + "?fl=semantics"
            END IF
            
            // Method 2: Check for semantics toggle in app
            // (This requires app-specific knowledge)
            
            // Wait for semantics to initialize
            Wait 10000ms
            
            // Check again
            has_semantics = page.locator("flt-semantics").count() > 0
            
            IF has_semantics == FALSE THEN
                Log: "WARNING: Cannot enable semantics tree after retries"
                Mark: test_case as "vision-fallback-required"
            END IF
        END IF
    END IF
END IF
```

### Vision-Based Fallback
If semantics cannot be enabled after retries:
```
IF test_case.marked == "vision-fallback-required" THEN
    // Use screenshot-based interaction instead
    1. Capture screenshot of current state
    2. Use visual matching for element location
    3. OR use approximate coordinates if necessary
    
    // Mark clearly in report
    test_case.fallback_mode = "vision"
    test_case.note = "Used vision fallback due to CanvasKit rendering without accessible DOM"
ELSE
    // Normal semantics/DOM interaction
    test_case.fallback_mode = "none"
END IF
```

## Action Timeouts

### Individual Action Timeout
```
Action timeout: 5000ms (5 seconds) per action

For each action:
1. Start timer
2. Execute action
3. IF timer exceeds 5000ms THEN
    - Mark action as TIMEOUT
    - Proceed to error handling (04-error-handling.md)
   END IF

Actions subject to 5000ms timeout:
- page.click()
- page.fill()
- page.waitForSelector()
- page.goto()
- Any MCP tool call
```

### Composite Action Timeout
```
For test case steps that require multiple actions:
- Estimate total time needed
- Apply same 5000ms per action rule
- Log each action individually
- If any single action times out, fail the test case
```

## System-Level Tool Restrictions

### PATH Modification Prohibition
```
// DO NOT modify $PATH to locate binaries
// This has caused system-wide breakage (glibc/snap conflicts)

// INCORRECT:
export PATH=$PATH:/custom/bin
which mytool

// CORRECT:
Use absolute path: /custom/bin/mytool
OR
Use full path from which: $(which tool_name) if already in system PATH
```

### Binary Location Strategy
```
1. Check if tool exists in standard locations:
   - /usr/bin/
   - /usr/local/bin/
   - ~/flutter/bin/
   - Project local bin/

2. If tool not found:
   - Report: "Required tool [name] not found"
   - Do NOT modify PATH to add search paths
   - STOP execution if tool is required

3. For Flutter/Dart tools:
   - Use: flutter test, flutter run
   - Use absolute path: /home/odoodev/flutter/bin/flutter
   - Do not assume flutter is in PATH
```

## MCP Configuration

### Connection Setup
```
MCP Server: Playwright
Connection: stdio (local) or HTTP (remote)

Configuration:
{
    "playwright_server": {
        "type": "stdio",
        "command": "npx",
        "args": ["playwright", "mcp-server"]
    }
}
```

### Session Management
```
1. Start Playwright MCP server
2. Create browser context
3. Create new page for each test session
4. Handle context cleanup on completion

Cleanup on error:
- Close all pages
- Close browser context
- Kill server if spawned locally
```

## Evidence Collection Requirements

### Screenshot Capture
```
For each test case:
1. Capture screenshot BEFORE action
2. Capture screenshot AFTER action
3. Save with naming convention:
   - {test_case_id}_before_{timestamp}.png
   - {test_case_id}_after_{timestamp}.png

Store in: .agent-state/screenshots/
```

### DOM/Semantics Text Extraction
```
For evidence, capture:
1. Page title
2. Visible heading text (h1, h2, h3)
3. Button labels
4. Form field labels
5. Error messages
6. Success confirmations

Format:
evidence = {
    "screenshot_path": "...", 
    "dom_text": "extracted text content",
    "accessibility_tree": "if available"
}
```

## Logging Requirements

### Action Logging Format
```
[Timestamp] [Action] [Target] [Result]
Examples:
[2024-01-15T10:30:00] [CLICK] [Start Button] [SUCCESS]
[2024-01-15T10:30:02] [FILL] [Username Field] [SUCCESS]
[2024-01-15T10:30:05] [WAIT] [Loading Spinner] [TIMEOUT - 5000ms exceeded]
```

### Error Logging
```
Log format for errors:
[ERROR] [Action Type] [Error Message]
[ERROR] [Screenshot Path]

Include:
- What was attempted
- What failed
- Current page state
- Last successful action
```

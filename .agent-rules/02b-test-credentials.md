# Test Credentials Management

## Purpose
Define the mandatory credential requirements and handling procedures for accessing the test environment.

## Credential Requirements

### Mandatory Credentials (MUST EXIST)
The agent MUST read the following values from the project's `.env` file:

| Variable | Description | Example |
|----------|-------------|---------|
| `ODOO_URL` | Odoo server base URL | `https://odoo.example.com` or `http://localhost:8069` |
| `ODOO_DB` | Database name | `odoo_db`, `production`, `fieldforce` |
| `ODOO_TEST_USER` | Test username | `admin`, `fieldworker`, `test_user` |
| `ODOO_TEST_PASSWORD` | Test user password | `secure_password_123` |

### Credential Source Priority
```
1. Read from: .env file in project root
2. DO NOT read from: .env.example (template only)
3. DO NOT use: hardcoded values
4. DO NOT use: environment variables unless explicitly set by user
```

## Credential Validation Procedure

### Step 1: Check .env File Exists
```
IF NOT exists(".env") THEN
    Report: "Missing .env file - cannot proceed"
    STOP execution
END IF
```

### Step 2: Read Credential Values
```
Load .env file
credentials = {
    "ODOO_URL": read_value("ODOO_URL"),
    "ODOO_DB": read_value("ODOO_DB"),
    "ODOO_TEST_USER": read_value("ODOO_TEST_USER"),
    "ODOO_TEST_PASSWORD": read_value("ODOO_TEST_PASSWORD")
}
```

### Step 3: Validate All Values Present
```
FOR EACH key IN ["ODOO_URL", "ODOO_DB", "ODOO_TEST_USER", "ODOO_TEST_PASSWORD"] DO
    IF credentials[key] IS EMPTY OR credentials[key] IS NULL THEN
        Report: "Missing test credentials in .env — cannot proceed"
        Report: "Missing value: " + key
        STOP execution
    END IF
END FOR
```

### Step 4: Proceed Only If Valid
```
IF all_credentials_valid == TRUE THEN
    Log: "Credentials loaded successfully"
    Log: "Target: " + ODOO_URL + "/" + ODOO_DB
    Log: "User: " + ODOO_TEST_USER
ELSE
    STOP execution - do not attempt to guess or use defaults
END IF
```

## Prohibited Credential Practices

### NEVER Do:
1. **DO NOT guess credentials** if .env is empty
2. **DO NOT use default values** like "admin", "demo", "test", "password"
3. **DO NOT brute force** login attempts
4. **DO NOT use credentials** from previous runs that aren't in current .env
5. **DO NOT log credentials** in output (mask password in logs)

### ALWAYS Do:
1. **Read from .env** file only
2. **Validate presence** of all four required values
3. **Stop immediately** if any value is missing
4. **Report clearly** which credential is missing

## Login Failure Handling

### First Attempt Failure
```
IF login_attempt == 1 AND login_failed == TRUE THEN
    // This is NOT a "frozen UI" situation
    // Do NOT apply 04-error-handling.md fallback
    
    // Instead:
    1. Read on-screen error message
    2. Report error verbatim in test result
    3. Examples:
        - "Invalid database"
        - "Wrong password"
        - "User not found"
        - "Access denied"
    
    // THEN decide:
    IF error_message contains "invalid" OR error_message contains "wrong" THEN
        // Credentials are wrong - STOP, do not retry
        Report: "Login failed: " + error_message
        STOP execution
    ELSE IF error_message contains "locked" OR error_message contains "temporary" THEN
        // Temporary issue - MAY retry once after delay
        Wait 5 seconds
        Retry login once
        IF still fails THEN
            STOP execution
        END IF
    ELSE
        // Unknown error - STOP
        STOP execution
    END IF
END IF
```

### Login Success
```
IF login_succeeded == TRUE THEN
    Log: "Login successful"
    
    // Check account type
    IF user_is_admin == TRUE THEN
        Log: "WARNING: Logged in as Administrator account"
        Log: "Restricting exploration to Field Service worker-facing screens"
        // Set flag to avoid Settings, Technical, Users & Companies menus
    ELSE
        Log: "Logged in as regular field worker account"
    END IF
END IF
```

## Account Type Restrictions

### If Administrator/Superuser Account
When logged in as admin/superuser:
1. **RESTRICT navigation** to Field Service worker-facing screens only
2. **AVOID** these menus:
   - Settings
   - Technical
   - Users & Companies
   - Database Management
   - Module Management
3. **LIMIT exploration** to:
   - Field Service menu
   - Calendar/Schedule views
   - Customer records
   - Reporting (view only)

### If Regular Field Worker Account
Standard exploration allowed within FSM scope.

## Security Notes
- Never store credentials in version control
- The .env file should be in .gitignore
- Mask password in all log outputs: `ODOO_TEST_PASSWORD: ********`
- Clear session tokens after test completion

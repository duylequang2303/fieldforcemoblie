# Business Rules and Data Validation

## Purpose
Define the rules for understanding application data structure and generating realistic test data within the FSM domain.

## Data Schema Ground Truth

### Primary Rule: Read Models First
**Before inventing any test data, the agent MUST read the actual implementation:**

1. **Read Dart Models**: 
   - Location: `lib/features/**/models/*.dart`
   - These files define the actual data structures
   - Extract field names, types, and constraints
   - Example: `ScheduleVisit`, `ScheduleProperty`, `WorkOrder`, etc.

2. **Read Odoo Field Definitions**:
   - Check repository documentation for Odoo model definitions
   - Verify field names match between Flutter app and Odoo backend
   - Look for: `docs/ODOO_API.md`, model definitions in XML files

### Data Schema Validation Rule
```
IF field_name NOT IN actual_dart_model_fields THEN
    Log warning: "Field [field_name] not found in Dart model - skipping"
    DO NOT use this field in test data generation
END IF
```

## FSM Business Process Flow

### Reference Model: SortScape / Jobber Style
The agent should understand this standard FSM workflow:

```
1. SCHEDULE
   - View assigned jobs for the day/week
   - See customer details, property address, job type
   - Receive job priority and time windows

2. TRAVEL TO LOCATION
   - Navigate to customer location
   - View route map with directions
   - Track travel time

3. CHECK-IN
   - Verify arrival at location (GPS/check-in button)
   - Log actual arrival time
   - Confirm customer present

4. LOG MATERIALS/PARTS
   - Record materials used (fuel, trash bags, blade replacement, mulch)
   - Update inventory quantities
   - Add notes on specific materials

5. TAKE PHOTO
   - Capture before/after photos
   - Add photo descriptions
   - Attach photos to work order

6. CUSTOMER SIGNATURE
   - Present completion summary
   - Capture customer signature on device
   - Record signature timestamp

7. COMPLETE
   - Mark job as complete
   - Send confirmation (simulate, don't actually send)
   - Update job status in system
```

### Web Search Usage
- **Use web search ONLY to understand FSM business PROCESS FLOW**
- DO NOT use web search to guess specific data values
- Reference: SortScape, Jobber, ServiceTitan for process patterns

## Test Data Generation Rules

### Australian Context for Demo Data
When explicitly creating NEW demo records (not testing existing data):

**Customer Names (Realistic Australian):**
- Smith, Jones, Williams, Brown, Wilson
- Use typical Australian first names: James, Michael, Sarah, Emma, David

**Addresses (Australian):**
- Use real Australian suburb/state formats
- Example: "42 Garden Street, Suburb, NSW 2000"
- Common Australian addresses from known areas

**Common Landscaping Materials:**
- Fuel (petrol, diesel)
- Trash bags / green waste bags
- Blade replacement (mower blades)
- Mulch (various types)
- Fertilizer
- Plants/seeds
- PPE equipment
- Tools replacement

### Data Creation Rules
```
IF creating_new_demo_records == TRUE THEN
    - Use realistic Australian context
    - Use realistic FSM-specific materials
    - Follow Dart model field structure exactly
    - Create non-production-looking data (TEST_ prefix, demo values)
ELSE
    - Use EXISTING data already in the system
    - DO NOT create new records unless explicitly required
END IF
```

## Field Validation Requirements

### Required Evidence for Test Cases
For each test case, verify:
1. **Field existence**: Check Dart model before using any field
2. **Field type**: Ensure test data matches expected type (string, int, bool, etc.)
3. **Field constraints**: Respect max length, required flags, etc.

### Example Validation
```
// In Dart model: ScheduleVisit
class ScheduleVisit {
  String? id;
  String? customerName;
  String? address;
  DateTime? scheduledStart;
  String? status;  // 'scheduled', 'in_progress', 'completed', 'cancelled'
  List<String>? materials;
}

// Test data MUST match:
{
  "customerName": "Test Customer",  // String
  "address": "123 Test St, Sydney NSW",  // String
  "scheduledStart": "2024-01-15T09:00:00Z",  // ISO8601 DateTime
  "status": "scheduled",  // Must be one of allowed values
  "materials": ["fuel", "trash_bags"]  // List of strings
}
```

## Prohibited Data Practices

### Never Do:
1. **DO NOT invent fields** that don't exist in the Dart models
2. **DO NOT guess Odoo field names** without verifying in documentation
3. **DO NOT use production customer data** from public sources
4. **DO NOT create test data** that looks like real PII (passport numbers, real addresses of real people)
5. **DO NOT bypass field validation** to force tests to pass

### Always Do:
1. Read actual model files before generating test data
2. Log which fields are being used in each test
3. Verify test data matches actual field types
4. Use TEST_ or demo_ prefixes for new records
5. Clean up demo data after test completion if possible

## Documentation Requirements
- Log all fields read from Dart models
- Note any discrepancies between Flutter and Odoo field definitions
- Document business process flow assumptions
- Record any field validation failures

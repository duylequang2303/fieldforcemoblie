# Fix Isar Unique Index Violation in _resolveConflictsAndSave

## Problem
The `IsarError: Unique index violated` occurs in `_resolveConflictsAndSave` method (line 1009-1072) when multiple orders with the same `odooId` are individually `put()` to Isar within a transaction. The unique index on `odooId` field (FsmOrder model line 19-20) causes this failure.

Root cause: The conflict resolution logic processes orders one-by-one and calls `put()` for each, but the final deduplication (lines 1103-1111) only runs after all individual puts. If duplicate `odooId` orders exist in the processing flow, the first `put()` succeeds but subsequent ones fail with unique index violation.

## Solution
Restructure `_resolveConflictsAndSave` to:
1. Perform all conflict resolution logic in memory (building a final map of orders by `odooId`)
2. After all conflict logic is done, do a single batch `putAll()` with the deduplicated orders
3. This ensures only one order per `odooId` is ever written to Isar

## Implementation Plan

### 1. Modify `_resolveConflictsAndSave` method in `orders_service.dart`

**Current flow (problematic):**
```dart
await isar.writeTxn(() async {
  // Process each order individually with put()
  for (order in orders) {
    await isar.fsmOrders.put(order); // Can fail on duplicate odooId
  }
  // Final deduplication - runs too late
});
```

**New flow:**
```dart
await isar.writeTxn(() async {
  // 1. Build finalOrdersMap<odooId, FsmOrder> in memory with all conflict logic
  final finalOrdersMap = <int, FsmOrder>{};
  
  // ... all existing conflict resolution logic ...
  // But instead of put(), do: finalOrdersMap[order.odooId] = order;
  
  // 2. After all logic, single batch upsert
  await isar.fsmOrders.putAll(finalOrdersMap.values.toList());
});
```

### 2. Key changes needed:
- Replace all `await isar.fsmOrders.put(order)` calls with `finalOrdersMap[order.odooId] = order`
- Replace `await isar.fsmOrders.delete()` calls with removing from map
- At end of transaction, `await isar.fsmOrders.putAll(finalOrdersMap.values.toList())`
- Keep the existing cleanOrders list building for return value

### 3. Validation
- Run existing tests if any
- Test with scenario that caused the error (multiple orders with same odooId)
- Verify no unique index violations in logs
- Verify offline-first behavior still works

## Affected Files
- `lib/features/orders/services/orders_service.dart` - `_resolveConflictsAndSave` method (lines 909-1123)

## Risk Assessment
- **Low**: Only changes internal conflict resolution logic, public API unchanged
- **Medium**: Must ensure all edge cases in conflict logic still handled correctly
- **Low**: Transaction boundary remains the same

## Rollback Plan
Revert the single method change if issues arise.
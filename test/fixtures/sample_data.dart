/// Test fixtures và factory methods cho các model chính.
/// Dùng cho Unit Test, Integration Test (Isar in-memory).

import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/stock/models/product.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'package:fieldforce_mobile/features/timesheet/models/timesheet_entry.dart';
import 'package:fieldforce_mobile/features/expense/models/expense.dart';
import 'package:fieldforce_mobile/features/work_order/models/work_report.dart';

// ═══════════════════════════════════════════════════════════════
// ORDERS
// ═══════════════════════════════════════════════════════════════

class FsmOrderFactory {
  static FsmOrder sample({
    int odooId = 1,
    String name = 'WO/2024/001',
    FsmOrderStage stage = FsmOrderStage.inProgress,
    bool requireSignature = false,
    bool isPendingSync = false,
  }) {
    return FsmOrder()
      ..odooId = odooId
      ..name = name
      ..description = 'Sample work order for testing'
      ..stageId = 2
      ..stageName = 'In Progress'
      ..stage = stage
      ..locationName = 'Test Location'
      ..locationAddress = '123 Test Street'
      ..locationLat = 10.762622
      ..locationLng = 106.660172
      ..partnerName = 'Test Customer'
      ..partnerPhone = '0909123456'
      ..scheduledDateStart = DateTime(2024, 12, 1, 9, 0)
      ..scheduledDateEnd = DateTime(2024, 12, 1, 17, 0)
      ..dateStart = DateTime(2024, 12, 1, 9, 15)
      ..personId = 1
      ..personName = 'Test Worker'
      ..routeSequence = 1
      ..routeId = 1
      ..routeState = 'planned'
      ..requireSignature = requireSignature
      ..isPendingSync = isPendingSync
      ..lastSyncAt = DateTime.now();
  }

  static FsmOrder sampleDraft() => sample(
    odooId: 1,
    name: 'WO/2024/001',
    stage: FsmOrderStage.draft,
    isPendingSync: false,
  );

  static FsmOrder sampleDone() => sample(
    odooId: 2,
    name: 'WO/2024/002',
    stage: FsmOrderStage.done,
    isPendingSync: false,
  );

  static FsmOrder sampleCancelled() => sample(
    odooId: 3,
    name: 'WO/2024/003',
    stage: FsmOrderStage.cancelled,
    isPendingSync: false,
  );
}

// ═══════════════════════════════════════════════════════════════
// STOCK
// ═══════════════════════════════════════════════════════════════

class ProductFactory {
  static Product sample({
    int id = 1,
    String barcode = 'PROD-001',
    String name = 'Test Product',
  }) {
    return Product()
      ..odooId = id
      ..barcode = barcode
      ..name = name
      ..defaultCode = 'INT-001'
      ..categoryName = 'Test Category'
      ..uomName = 'Unit'
      ..standardPrice = 40000.0
      ..lastSyncAt = DateTime.now();
  }
}

class StockMoveFactory {
  static StockMove sample({
    int id = 1,
    int productId = 1,
    String productName = 'Test Product',
    String barcode = 'PROD-001',
    double quantity = 10.0,
    MoveType moveType = MoveType.out,
    String state = 'draft',
    bool isPendingSync = false,
  }) {
    return StockMove()
      ..moveOdooId = id
      ..orderOdooId = 1
      ..productId = productId
      ..productName = productName
      ..productCode = 'INT-001'
      ..productBarcode = barcode
      ..uomName = 'Unit'
      ..demandQty = quantity
      ..doneQty = state == 'done' ? quantity : 0.0
      ..pickingState = state
      ..moveType = moveType
      ..isPendingSync = isPendingSync
      ..createdAt = DateTime.now();
  }

  static StockMove sampleInbound() => sample(
    id: 2,
    productId: 1,
    productName: 'Test Product',
    barcode: 'PROD-001',
    quantity: 20.0,
    moveType: MoveType.in_,
    state: 'draft',
  );

  static StockMove samplePending() => sample(
    id: 3,
    productId: 1,
    productName: 'Test Product',
    barcode: 'PROD-001',
    quantity: 5.0,
    moveType: MoveType.out,
    state: 'draft',
    isPendingSync: true,
  );
}

// ═══════════════════════════════════════════════════════════════
// TIMESHEET
// ═══════════════════════════════════════════════════════════════

class TimesheetEntryFactory {
  static TimesheetEntry sample({
    int id = 1,
    int orderId = 1,
    String orderName = 'WO/2024/001',
    DateTime? startTime,
    DateTime? endTime,
    bool isPendingSync = false,
  }) {
    final now = DateTime.now();
    final start = startTime ?? DateTime(2024, 12, 1, 8, 0);
    final end = endTime ?? DateTime(2024, 12, 1, 12, 0);
    final hours = end.difference(start).inMinutes / 60.0;
    
    return TimesheetEntry()
      ..odooId = id
      ..orderOdooId = orderId
      ..date = start
      ..hours = hours
      ..name = 'Test timesheet entry'
      ..employeeName = 'Test Employee'
      ..isPendingSync = isPendingSync
      ..createdAt = now;
  }

  static TimesheetEntry samplePending() => sample(
    id: 2,
    orderId: 1,
    orderName: 'WO/2024/001',
    startTime: DateTime(2024, 12, 1, 13, 0),
    endTime: DateTime(2024, 12, 1, 17, 0),
    isPendingSync: true,
  );
}

// ═══════════════════════════════════════════════════════════════
// EXPENSE
// ═══════════════════════════════════════════════════════════════

class ExpenseFactory {
  static Expense sample({
    int id = 1,
    int orderId = 1,
    String orderName = 'WO/2024/001',
    String name = 'Test Expense',
    double amount = 500000.0,
    ExpenseCategory category = ExpenseCategory.fuel,
    bool isPendingSync = false,
  }) {
    return Expense()
      ..odooId = id
      ..orderOdooId = orderId
      ..name = name
      ..amount = amount
      ..date = DateTime(2024, 12, 1)
      ..category = category
      ..note = 'Sample expense for testing'
      ..isPendingSync = isPendingSync
      ..createdAt = DateTime.now();
  }
}

// ═══════════════════════════════════════════════════════════════
// WORK ORDER / WORK REPORT
// ═══════════════════════════════════════════════════════════════

class WorkReportFactory {
  static WorkReport sample({
    int id = 1,
    int orderId = 1,
    String orderName = 'WO/2024/001',
    String content = 'Sample work report',
    bool isPendingSync = false,
  }) {
    return WorkReport()
      ..odooId = id
      ..orderOdooId = orderId
      ..workDone = content
      ..problemsFound = null
      ..recommendation = null
      ..photoPaths = []
      ..isPendingSync = isPendingSync
      ..createdAt = DateTime.now();
  }
}

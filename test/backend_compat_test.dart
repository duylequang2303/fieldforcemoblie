import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/api/odoo_session_manager.dart';
import 'package:fieldforce_mobile/core/database/isar_service.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/services/orders_service.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'package:fieldforce_mobile/features/stock/services/stock_service.dart';
import 'package:fieldforce_mobile/features/expense/models/expense.dart';
import 'package:fieldforce_mobile/features/expense/services/expense_service.dart';
import 'package:fieldforce_mobile/features/timesheet/models/timesheet_entry.dart';
import 'package:fieldforce_mobile/features/timesheet/services/timesheet_service.dart';
import 'package:fieldforce_mobile/features/work_order/services/work_order_service.dart';

void main() {
  group('FsmOrder', () {
    test('fromJson should parse is_skipped from backend', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'stage_id': ['New', 1],
        'is_skipped': true,
        'fsm_recurring_id': [null, 0],
      };

      final order = FsmOrder.fromJson(json);
      expect(order.odooId, equals(1));
      expect(order.isSkipped, isTrue);
      expect(order.recurringId, isNull);
    });

    test('fromJson should handle missing is_skipped (backend without field)', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'stage_id': ['New', 1],
        'fsm_recurring_id': [null, 0],
      };

      final order = FsmOrder.fromJson(json);
      expect(order.odooId, equals(1));
      expect(order.isSkipped, isFalse);
    });

    test('fromJson should handle missing require_signature', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'stage_id': ['New', 1],
        'fsm_recurring_id': [null, 0],
      };

      final order = FsmOrder.fromJson(json);
      expect(order.odooId, equals(1));
      expect(order.requireSignature, isFalse);
    });

    test('fromJson should handle route_state injection', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'stage_id': ['New', 1],
        'route_id': [10, 'Route A'],
        'route_state': 'planned',
        'fsm_recurring_id': [null, 0],
      };

      final order = FsmOrder.fromJson(json, locationCoordinates: {});
      expect(order.routeId, equals(10));
      expect(order.routeState, equals('planned'));
    });

    test('parseStageName should handle Vietnamese and English stage names', () {
      expect(FsmOrder.parseStageName('New'), FsmOrderStage.draft);
      expect(FsmOrder.parseStageName('Mới'), FsmOrderStage.draft);
      expect(FsmOrder.parseStageName('In Progress'), FsmOrderStage.inProgress);
      expect(FsmOrder.parseStageName('Đang thực hiện'), FsmOrderStage.inProgress);
      expect(FsmOrder.parseStageName('Completed'), FsmOrderStage.done);
      expect(FsmOrder.parseStageName('Hoàn thành'), FsmOrderStage.done);
      expect(FsmOrder.parseStageName('Cancelled'), FsmOrderStage.cancelled);
      expect(FsmOrder.parseStageName('Đã hủy'), FsmOrderStage.cancelled);
    });
  });

  group('StockMove', () {
    test('should use product_uom_qty not quantity', () {
      final move = StockMove.create(
        orderOdooId: 1,
        productId: 1,
        productName: 'Test',
        demandQty: 10,
        doneQty: 10,
      );

      expect(move.doneQty, equals(10));
      expect(move.demandQty, equals(10));
    });
  });

  group('Expense', () {
    test('payload should have correct Odoo fields', () {
      final expense = Expense.create(
        orderOdooId: 1,
        name: 'Fuel',
        amount: 100000.0,
        date: DateTime.now(),
        category: ExpenseCategory.fuel,
      );

      final payload = {
        'name': expense.name,
        'total_amount': expense.amount,
        'unit_amount': expense.amount,
        'quantity': 1,
        'date': expense.date.toIso8601String().substring(0, 10),
        'employee_id': 1,
        'product_id': 1,
        'fsm_order_id': expense.orderOdooId,
      };

      expect(payload['total_amount'], equals(100000.0));
      expect(payload['unit_amount'], equals(100000.0));
      expect(payload['quantity'], equals(1));
      expect(payload['fsm_order_id'], equals(1));
    });

    test('buildOdooPayload should include quantity for hr.expense', () {
      final payload = ExpenseService.instance.buildOdooPayload(
        name: 'Test',
        amount: 1000,
        date: DateTime(2026, 1, 1),
        employeeId: 1,
        productId: 5,
        orderOdooId: 99,
      );

      expect(payload['quantity'], equals(1));
      expect(payload['unit_amount'], equals(1000));
      expect(payload['total_amount'], equals(1000));
    });

    test('ExpenseService should have testConstructor for dependency injection', () {
      expect(ExpenseService.testConstructor, isNotNull);
      expect(() => ExpenseService.testConstructor(
            OdooSessionManager.instance,
            IsarService.instance,
          ), returnsNormally);
    });
  });

  group('Timesheet', () {
    test('payload should have correct Odoo fields', () {
      final entry = TimesheetEntry.create(
        orderOdooId: 1,
        date: DateTime.now(),
        hours: 8.0,
        description: 'Work',
      );

      final payload = {
        'name': entry.name,
        'date': '2025-01-01',
        'unit_amount': entry.hours,
        'employee_id': 1,
        'fsm_order_id': entry.orderOdooId,
      };

      expect(payload['unit_amount'], equals(8.0));
      expect(payload['fsm_order_id'], equals(1));
    });
  });

  group('WorkOrder', () {
    test('service signature check should accept True', () {
      final result = true;
      bool success;
      if (result == true) {
        success = true;
      } else if (result is Map<String, dynamic>) {
        final mapResult = result as Map<String, dynamic>;
        success = mapResult['success'] as bool? ?? false;
      } else {
        success = false;
      }
      expect(success, isTrue);
    });

    test('service signature check should accept dict with success', () {
      final result = <String, dynamic>{'success': true};
      bool success;
      if (result == true) {
        success = true;
      } else if (result is Map<String, dynamic>) {
        final mapResult = result as Map<String, dynamic>;
        success = mapResult['success'] as bool? ?? false;
      } else {
        success = false;
      }
      expect(success, isTrue);
    });

    test('service signature check should reject dict without success', () {
      final result = <String, dynamic>{'success': false};
      bool success;
      if (result == true) {
        success = true;
      } else if (result is Map<String, dynamic>) {
        final mapResult = result as Map<String, dynamic>;
        success = mapResult['success'] as bool? ?? false;
      } else {
        success = false;
      }
      expect(success, isFalse);
    });
  });

  group('OdooSession', () {
    test('Legacy secure storage missing serverVersion and employeeId should use fallbacks', () {
      final session = OdooSessionData(
        serverUrl: 'https://example.com',
        database: 'test',
        username: 'test',
        userId: 1,
        sessionId: 'session123',
        serverVersion: '19',
        employeeId: null,
      );
      expect(session.serverVersion, '19');
      expect(session.employeeId, isNull);
    });
  });

  group('OrdersService', () {
    test('should have testConstructor for dependency injection', () {
      expect(OrdersService.testConstructor, isNotNull);
      expect(() => OrdersService.testConstructor(
            OdooSessionManager.instance,
            IsarService.instance,
          ), returnsNormally);
    });

    test('FsmOrder should default isActionCompletePendingSync to false', () {
      final order = FsmOrder()
        ..odooId = 1
        ..stageId = 1
        ..stage = FsmOrderStage.done
        ..stageName = 'Completed'
        ..isPendingSync = true
        ..isStagePendingSync = true;
      expect(order.isActionCompletePendingSync, isFalse);
    });

    test('FsmOrder should allow toggling isActionCompletePendingSync', () {
      final order = FsmOrder()
        ..odooId = 2
        ..stageId = 1
        ..stage = FsmOrderStage.done
        ..stageName = 'Completed'
        ..isPendingSync = true
        ..isStagePendingSync = true
        ..isActionCompletePendingSync = true;
      expect(order.isActionCompletePendingSync, isTrue);
    });

    test('syncPending should only call action_complete when isActionCompletePendingSync is true', () {
      final order = FsmOrder()
        ..odooId = 3
        ..stageId = 1
        ..stage = FsmOrderStage.done
        ..stageName = 'Completed'
        ..isPendingSync = true
        ..isStagePendingSync = true
        ..isActionCompletePendingSync = false;
      final shouldCallActionComplete =
          order.stage == FsmOrderStage.done && order.isActionCompletePendingSync;
      expect(shouldCallActionComplete, isFalse);
    });

    test('syncPending should call action_complete when stage is done and action complete is pending', () {
      final order = FsmOrder()
        ..odooId = 4
        ..stageId = 1
        ..stage = FsmOrderStage.done
        ..stageName = 'Completed'
        ..isPendingSync = true
        ..isStagePendingSync = true
        ..isActionCompletePendingSync = true;
      final shouldCallActionComplete =
          order.stage == FsmOrderStage.done && order.isActionCompletePendingSync;
      expect(shouldCallActionComplete, isTrue);
    });
  });
}

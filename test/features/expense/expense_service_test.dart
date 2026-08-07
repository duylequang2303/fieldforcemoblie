import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/expense/models/expense.dart';
import 'package:fieldforce_mobile/features/expense/services/expense_service.dart';

void main() {
  group('Expense.create', () {
    test('should create expense with all fields set correctly', () {
      final expense = Expense.create(
        orderOdooId: 42,
        name: 'Ăn trưa',
        amount: 150000,
        date: DateTime(2026, 8, 7),
        category: ExpenseCategory.meal,
        receiptImagePath: '/tmp/receipt.jpg',
        receiptAttachmentId: 99,
        note: 'Ăn trưa với đồng nghiệp',
      );

      expect(expense.orderOdooId, 42);
      expect(expense.name, 'Ăn trưa');
      expect(expense.amount, 150000);
      expect(expense.date, DateTime(2026, 8, 7));
      expect(expense.category, ExpenseCategory.meal);
      expect(expense.receiptImagePath, '/tmp/receipt.jpg');
      expect(expense.receiptAttachmentId, 99);
      expect(expense.note, 'Ăn trưa với đồng nghiệp');
      expect(expense.isPendingSync, isTrue);
      expect(expense.odooId, isNull);
      expect(expense.createdAt, isA<DateTime>());
    });

    test('should create expense with null receipt fields', () {
      final expense = Expense.create(
        orderOdooId: 1,
        name: 'Nhiên liệu',
        amount: 500000,
        date: DateTime(2026, 8, 7),
        category: ExpenseCategory.fuel,
      );

      expect(expense.receiptImagePath, isNull);
      expect(expense.receiptAttachmentId, isNull);
      expect(expense.note, isNull);
      expect(expense.isPendingSync, isTrue);
    });
  });

  group('Expense.categoryLabel', () {
    test('should return correct Vietnamese label for each category', () {
      expect(
        Expense()
          ..category = ExpenseCategory.fuel,
        isNotNull,
      );
      // Verify via create
      final fuel = Expense.create(
        orderOdooId: 1, name: 'test', amount: 1, date: DateTime.now(),
        category: ExpenseCategory.fuel,
      );
      expect(fuel.categoryLabel, 'Nhiên liệu');

      final meal = Expense.create(
        orderOdooId: 1, name: 'test', amount: 1, date: DateTime.now(),
        category: ExpenseCategory.meal,
      );
      expect(meal.categoryLabel, 'Ăn uống');

      final transport = Expense.create(
        orderOdooId: 1, name: 'test', amount: 1, date: DateTime.now(),
        category: ExpenseCategory.transport,
      );
      expect(transport.categoryLabel, 'Vận chuyển');

      final material = Expense.create(
        orderOdooId: 1, name: 'test', amount: 1, date: DateTime.now(),
        category: ExpenseCategory.material,
      );
      expect(material.categoryLabel, 'Vật liệu');

      final other = Expense.create(
        orderOdooId: 1, name: 'test', amount: 1, date: DateTime.now(),
        category: ExpenseCategory.other,
      );
      expect(other.categoryLabel, 'Khác');
    });
  });

  group('ExpenseService.getProductIdForCategory', () {
    test('should map each ExpenseCategory to a product ID', () {
      expect(
          ExpenseService.instance.getProductIdForCategory(ExpenseCategory.fuel),
          1);
      expect(
          ExpenseService.instance.getProductIdForCategory(ExpenseCategory.meal),
          2);
      expect(ExpenseService.instance
          .getProductIdForCategory(ExpenseCategory.transport),
          3);
      expect(ExpenseService.instance
          .getProductIdForCategory(ExpenseCategory.material),
          4);
      expect(
          ExpenseService.instance.getProductIdForCategory(ExpenseCategory.other),
          5);
    });
  });

  group('ExpenseService.buildOdooPayload', () {
    test('should build correct Odoo hr.expense payload', () {
      final payload = ExpenseService.instance.buildOdooPayload(
        name: 'Nhiên liệu đi công tác',
        amount: 350000,
        date: DateTime(2026, 8, 7),
        employeeId: 10,
        productId: 1,
        orderOdooId: 42,
      );

      expect(payload['name'], 'Nhiên liệu đi công tác');
      expect(payload['total_amount'], 350000);
      expect(payload['unit_amount'], 350000);
      expect(payload['quantity'], 1);
      expect(payload['date'], '2026-08-07');
      expect(payload['employee_id'], 10);
      expect(payload['product_id'], 1);
      expect(payload['fsm_order_id'], 42);
    });

    test('should always include all 8 required fields for hr.expense', () {
      final payload = ExpenseService.instance.buildOdooPayload(
        name: 'Test',
        amount: 1000,
        date: DateTime(2026, 1, 1),
        employeeId: 1,
        productId: 5,
        orderOdooId: 99,
      );

      expect(payload.keys.toSet(), {
        'name', 'total_amount', 'unit_amount', 'quantity', 'date',
        'employee_id', 'product_id', 'fsm_order_id'
      });
    });
  });

  group('ExpenseService.getMimeFromExtension', () {
    test('should return correct MIME type for image extensions', () {
      expect(getMimeFromExtension('photo.jpg'), 'image/jpeg');
      expect(getMimeFromExtension('photo.jpeg'), 'image/jpeg');
      expect(getMimeFromExtension('photo.png'), 'image/png');
      expect(getMimeFromExtension('photo.webp'), 'image/webp');
      expect(getMimeFromExtension('photo.gif'), 'image/gif');
      expect(getMimeFromExtension('photo.bmp'), 'image/bmp');
      expect(getMimeFromExtension('photo.heic'), 'image/heic');
      expect(getMimeFromExtension('photo.heif'), 'image/heif');
    });

    test('should return image/jpeg for unknown extensions', () {
      expect(getMimeFromExtension('photo.xyz'), 'image/jpeg');
      expect(getMimeFromExtension('receipt'), 'image/jpeg');
    });

    test('should be case-insensitive for extensions', () {
      expect(getMimeFromExtension('photo.PNG'), 'image/png');
      expect(getMimeFromExtension('photo.JPG'), 'image/jpeg');
    });
  });

  group('SyncResult', () {
    test('should be false for empty result', () {
      final result = SyncResult();
      expect(result.hasFailures, isFalse);
    });

    test('should be true when failedCount > 0', () {
      final result = SyncResult()..failedCount = 2;
      expect(result.hasFailures, isTrue);
    });

    test('should be true when errors list is non-empty', () {
      final result = SyncResult()..errors.add('Some error');
      expect(result.hasFailures, isTrue);
    });

    test('should track synced, failed, and skipped counts', () {
      final result = SyncResult()
        ..syncedCount = 5
        ..failedCount = 2
        ..skippedCount = 1
        ..errors.addAll(['Error 1', 'Error 2']);

      expect(result.syncedCount, 5);
      expect(result.failedCount, 2);
      expect(result.skippedCount, 1);
      expect(result.errors.length, 2);
      expect(result.hasFailures, isTrue);
    });

    test('should include all counts in toString', () {
      final result = SyncResult()
        ..syncedCount = 3
        ..failedCount = 1
        ..skippedCount = 2
        ..errors.add('test error');

      final str = result.toString();
      expect(str, contains('synced: 3'));
      expect(str, contains('failed: 1'));
      expect(str, contains('skipped: 2'));
      expect(str, contains('errors: 1'));
    });
  });
}

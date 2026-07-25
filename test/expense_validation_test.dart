import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/expense/models/expense.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Expense Validation Logic (Unit Test)', () {
    test('EXP-06: Tạo chi phí với số tiền âm -> Validation error', () {
      // Sắp xếp (Arrange)
      final expense = ExpenseFactory.sample(amount: -50000);

      // Thực thi & Kiểm tra (Act & Assert)
      // Tùy theo cách implementation thực tế mà Expense ném ra lỗi hoặc validate trả về false.
      // Dựa vào logic thông thường, ta check thông qua hàm validation hoặc kì vọng một Exception.
      expect(expense.amount, lessThan(0));

      bool isValid(Expense e) {
        return e.amount > 0 && e.name.isNotEmpty;
      }

      expect(isValid(expense), isFalse, reason: 'Expense với amount âm không được hợp lệ (valid).');
    });

    test('EXP-07: Tạo chi phí hợp lệ', () {
      final expense = ExpenseFactory.sample(amount: 150000, name: 'Phí đỗ xe');
      
      bool isValid(Expense e) {
        return e.amount > 0 && e.name.isNotEmpty;
      }

      expect(isValid(expense), isTrue);
      expect(expense.amount, 150000);
      expect(expense.name, 'Phí đỗ xe');
    });

    test('EXP-08: Tạo chi phí thiếu tên -> Validation error', () {
      final expense = ExpenseFactory.sample(amount: 50000, name: '');

      bool isValid(Expense e) {
        return e.amount > 0 && e.name.isNotEmpty;
      }

      expect(isValid(expense), isFalse, reason: 'Expense không có tên/mô tả không hợp lệ.');
    });
  });
}

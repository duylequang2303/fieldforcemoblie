import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'package:fieldforce_mobile/features/stock/models/product.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Stock Move Validation Logic (Unit Test)', () {
    test('STOCK-01: Move xuất kho (outbound) phải có số lượng yêu cầu > 0', () {
      final move = StockMoveFactory.sample(
        quantity: 0,
        moveType: MoveType.out,
      );

      bool isValid(StockMove m) {
        return m.demandQty > 0;
      }

      expect(isValid(move), isFalse, reason: 'Số lượng yêu cầu xuất kho phải lớn hơn 0.');
    });

    test('STOCK-03: Move hợp lệ đánh dấu pending sync nếu chưa đồng bộ', () {
      final move = StockMoveFactory.samplePending(); // pending sync = true
      
      expect(move.isPendingSync, isTrue);
      expect(move.pickingState, 'draft');
    });
  });
}

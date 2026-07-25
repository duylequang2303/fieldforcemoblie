import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'package:fieldforce_mobile/features/stock/models/product.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Stock Move Validation Logic (Unit Test)', () {
    test('STOCK-01: Move xuất kho (outbound) phải có số lượng > 0', () {
      final move = StockMoveFactory.sample(
        quantity: 0,
        moveType: 'outbound',
      );

      bool isValid(StockMove m) {
        return m.quantity != null && m.quantity! > 0;
      }

      expect(isValid(move), isFalse, reason: 'Số lượng xuất kho phải lớn hơn 0.');
    });

    test('STOCK-02: Sản phẩm tồn kho thực tế phải lớn hơn hoặc bằng số lượng xuất', () {
      final product = ProductFactory.sample(id: 1); // Có sẵn 100 qtyOnHand
      final move = StockMoveFactory.sample(
        productId: 1,
        quantity: 150, // Vượt quá tồn kho
        moveType: 'outbound',
      );

      bool hasEnoughStock(Product p, StockMove m) {
        if (m.moveType == 'inbound') return true;
        return (p.qtyOnHand ?? 0) >= (m.quantity ?? 0);
      }

      expect(hasEnoughStock(product, move), isFalse, reason: 'Không đủ tồn kho để xuất 150 đơn vị.');
    });
    
    test('STOCK-03: Move hợp lệ đánh dấu pending sync nếu chưa đồng bộ', () {
      final move = StockMoveFactory.samplePending(); // pending sync = true
      
      expect(move.isPendingSync, isTrue);
      expect(move.state, 'draft');
    });
  });
}

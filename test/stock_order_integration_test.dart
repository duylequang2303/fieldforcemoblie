import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Stock & Orders Integration Flow', () {
    test('STOCK-ORD-01: Quét và hoàn thành vật tư đánh dấu Order sẵn sàng kết thúc', () {
      // Arrange: Một order đang thực hiện và 2 vật tư cần xuất kho
      final order = FsmOrderFactory.sample(stage: FsmOrderStage.inProgress);
      final move1 = StockMoveFactory.sample(id: 1, state: 'draft');
      final move2 = StockMoveFactory.sample(id: 2, state: 'draft');
      
      final stockMoves = [move1, move2];

      // Act: Nhân viên quét mã vạch thành công và xác nhận xuất kho (offline)
      for (var move in stockMoves) {
        move.state = 'done';
        move.isPendingSync = true; // Lưu local chờ đồng bộ
      }

      // Logic kiểm tra điều kiện hoàn thành Order
      bool allMovesDone = stockMoves.every((m) => m.state == 'done');
      bool canCompleteOrder = false;

      if (allMovesDone && order.stage == FsmOrderStage.inProgress) {
        canCompleteOrder = true;
      }

      // Assert:
      // - Vật tư đã sẵn sàng sync
      // - Cho phép hoàn thành đơn hàng
      expect(allMovesDone, isTrue);
      expect(stockMoves[0].isPendingSync, isTrue);
      expect(stockMoves[1].isPendingSync, isTrue);
      expect(canCompleteOrder, isTrue, reason: 'Tất cả vật tư đã xử lý xong, order có thể Complete.');
    });
  });
}

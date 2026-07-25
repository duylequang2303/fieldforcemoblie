import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Stock & Orders Integration Flow', () {
    late Isar isar;
    late Directory tempDir;
    
    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      tempDir = await Directory.systemTemp.createTemp('isar_stock_order_test');
      isar = await Isar.open(
        [FsmOrderSchema, StockMoveSchema],
        directory: tempDir.path,
        name: 'test_db_stock_order',
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('STOCK-ORD-01: Quét và hoàn thành vật tư lưu vào db đánh dấu sẵn sàng kết thúc', () async {
      // Arrange: Lưu order đang thực hiện và 2 vật tư cần xuất kho vào local DB
      final order = FsmOrderFactory.sample(stage: FsmOrderStage.inProgress);
      final move1 = StockMoveFactory.sample(id: 1, state: 'draft');
      final move2 = StockMoveFactory.sample(id: 2, state: 'draft');
      
      await isar.writeTxn(() async {
        await isar.fsmOrders.put(order);
        await isar.stockMoves.putAll([move1, move2]);
      });

      // Act: Nhân viên quét mã vạch thành công và xác nhận xuất kho (offline)
      final stockMoves = await isar.stockMoves.where().findAll();
      await isar.writeTxn(() async {
        for (var move in stockMoves) {
          move.pickingState = 'done';
          move.isPendingSync = true; // Lưu local chờ đồng bộ
          await isar.stockMoves.put(move);
        }
      });

      // Lấy data mới nhất từ DB
      final updatedMoves = await isar.stockMoves.where().findAll();
      final currentOrder = await isar.fsmOrders.get(order.id);

      // Logic kiểm tra điều kiện hoàn thành Order
      bool allMovesDone = updatedMoves.every((m) => m.pickingState == 'done');
      bool canCompleteOrder = false;

      if (allMovesDone && currentOrder?.stage == FsmOrderStage.inProgress) {
        canCompleteOrder = true;
      }

      // Assert:
      // - Vật tư đã lưu Isar
      expect(allMovesDone, isTrue);
      expect(updatedMoves[0].isPendingSync, isTrue);
      expect(updatedMoves[1].isPendingSync, isTrue);
      expect(canCompleteOrder, isTrue, reason: 'Tất cả vật tư đã xử lý xong, order có thể Complete.');
    });
  });
}

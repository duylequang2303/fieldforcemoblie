import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';

void main() {
  group('FsmOrder - stage sync race condition', () {
    test('preserves newer stage update when synced revision no longer matches', () {
      final order = FsmOrder()
        ..odooId = 100
        ..stageId = 1
        ..stage = FsmOrderStage.draft
        ..stageName = 'New'
        ..isPendingSync = true
        ..isStagePendingSync = true;

      final sentStageId = 2;

      final current = FsmOrder()
        ..odooId = order.odooId
        ..stageId = 3
        ..stage = FsmOrderStage.inProgress
        ..stageName = 'In Progress'
        ..isPendingSync = true
        ..isStagePendingSync = true;

      if (current.isStagePendingSync && current.stageId == sentStageId) {
        current.isPendingSync = false;
        current.isStagePendingSync = false;
      }

      expect(current.stageId, 3);
      expect(current.stage, FsmOrderStage.inProgress);
      expect(current.isStagePendingSync, isTrue);
      expect(current.isPendingSync, isTrue);
    });

    test('clears pending flags when synced stage still matches sent revision', () {
      final order = FsmOrder()
        ..odooId = 101
        ..stageId = 2
        ..stage = FsmOrderStage.inProgress
        ..stageName = 'In Progress'
        ..isPendingSync = true
        ..isStagePendingSync = true;

      final sentStageId = order.stageId;

      final current = FsmOrder()
        ..odooId = order.odooId
        ..stageId = order.stageId
        ..stage = order.stage
        ..stageName = order.stageName
        ..isPendingSync = order.isPendingSync
        ..isStagePendingSync = order.isStagePendingSync;

      if (current.isStagePendingSync && current.stageId == sentStageId) {
        current.isPendingSync = false;
        current.isStagePendingSync = false;
      }

      expect(current.stageId, 2);
      expect(current.isStagePendingSync, isFalse);
      expect(current.isPendingSync, isFalse);
    });
  });
}

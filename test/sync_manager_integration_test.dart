import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Sync & Offline CRUD (Integration Test)', () {
    late Isar isar;
    late Directory tempDir;
    
    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      tempDir = await Directory.systemTemp.createTemp('isar_sync_test');
      isar = await Isar.open(
        [FsmOrderSchema],
        directory: tempDir.path,
        name: 'test_db',
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('SYNC-01: Lưu Order mới với isPendingSync = true khi Offline', () async {
      // Arrange: Tạo một Order ở trạng thái offline
      final offlineOrder = FsmOrderFactory.sample(
        odooId: 0, // Chưa có ID từ Odoo
        name: 'WO/OFFLINE/001',
        isPendingSync: true, // Đánh dấu cần đồng bộ
      );

      // Act: Lưu vào Isar DB
      await isar.writeTxn(() async {
        await isar.fsmOrders.put(offlineOrder);
      });
      final savedOrder = await isar.fsmOrders.filter().nameEqualTo('WO/OFFLINE/001').findFirst();

      // Assert
      expect(savedOrder, isNotNull);
      expect(savedOrder!.isPendingSync, isTrue);
      expect(savedOrder.odooId, 0, reason: 'Chưa đồng bộ nên odooId = 0 (tạo local)');
    });

    test('SYNC-02: Đánh dấu Order thành In Progress khi offline', () async {
      // Arrange
      final localOrder = FsmOrderFactory.sampleDraft();
      
      await isar.writeTxn(() async {
        await isar.fsmOrders.put(localOrder);
      });
      
      // Act: Người dùng bấm "Bắt đầu công việc" khi mất mạng
      final dbOrder = await isar.fsmOrders.get(localOrder.id);
      dbOrder!.stageId = 2; // In Progress
      dbOrder.stage = FsmOrderStage.inProgress;
      dbOrder.isPendingSync = true;
      dbOrder.dateStart = DateTime.now();

      await isar.writeTxn(() async {
        await isar.fsmOrders.put(dbOrder);
      });
      
      final updatedOrder = await isar.fsmOrders.get(localOrder.id);

      // Assert
      expect(updatedOrder!.isPendingSync, isTrue);
      expect(updatedOrder.stage, FsmOrderStage.inProgress);
      expect(updatedOrder.dateStart, isNotNull, reason: 'Phải ghi nhận thời gian bấm nút bắt đầu công việc local');
    });
  });
}

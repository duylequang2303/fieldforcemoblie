import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:fieldforce_mobile/core/api/odoo_session_manager.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/database/isar_service.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/stock/models/stock_move.dart';
import 'package:fieldforce_mobile/features/stock/services/stock_service.dart';

class MockOdooForStock implements OdooSessionManager {
  List<String> methodCalls = [];
  bool shouldPartialAssign = false;

  @override
  Future<dynamic> callKw({
    required String model,
    required String method,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
  }) async {
    methodCalls.add('$model.$method');
    
    if (model == 'stock.picking.type' && method == 'search_read') {
      return [{'id': 1}];
    }
    if (model == 'stock.warehouse' && method == 'read') {
      return [{'lot_stock_id': [99]}];
    }
    if (model == 'stock.picking' && method == 'create') {
      return 101; // pickingId
    }
    if (model == 'stock.move' && method == 'create') {
      return 202; // moveId
    }
    if (model == 'stock.picking' && method == 'action_confirm') {
      return true;
    }
    if (model == 'stock.picking' && method == 'action_assign') {
      return true;
    }
    if (model == 'stock.picking' && method == 'read') {
      if (shouldPartialAssign) {
        return [{'state': 'partially_available'}];
      }
      return [{'state': 'assigned'}];
    }
    if (model == 'stock.move' && method == 'write') {
      return true;
    }
    if (model == 'stock.picking' && method == 'button_validate') {
      return true;
    }
    return true;
  }
  
  // Stubs
  @override String get serverUrl => '';
  @override String get database => '';
  @override String? get sessionId => null;
  @override int? get currentUserId => null;
  @override OdooSessionData? get currentSession => null;
  @override String? get currentUserName => null;
  @override Future<OdooSessionData> authenticate({required String serverUrl, required String database, required String username, required String password}) async => const OdooSessionData(serverUrl:'', database:'', username:'', sessionId:'', userId:1, locale:'');
  @override Future<void> logout() async {}
  @override bool get isAuthenticated => true;
  @override Future<bool> restoreSession({required String serverUrl, required String database, required String sessionId, int? savedUserId}) async => true;
}

void main() {
  group('StockService - State Machine', () {
    late Isar isar;
    late Directory tempDir;
    late MockOdooForStock mockOdoo;
    late StockService service;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('isar_stock_test');
      isar = await Isar.open(
        [FsmOrderSchema, StockMoveSchema],
        directory: tempDir.path,
      );
      IsarService.instance.dbForTest = isar;
      
      mockOdoo = MockOdooForStock();
      service = StockService.testConstructor(mockOdoo, IsarService.instance);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('Luồng State Machine Đầy Đủ (6 bước)', () async {
      // 1. Tạo order ảo trong Isar
      final order = FsmOrder()
        ..odooId = 100
        ..name = 'WO/TEST/001'
        ..stageId = 1
        ..stageName = 'New'
        ..stage = FsmOrderStage.draft
        ..isPendingSync = false
        ..lastSyncAt = DateTime.now()
        ..warehouseId = 1
        ..inventoryLocationId = 15;
      await isar.writeTxn(() async {
        await isar.fsmOrders.put(order);
      });

      // 2. Chạy recordStockOut
      await service.recordStockOut(
        orderOdooId: 100,
        productId: 123,
        productName: 'Ốc vít',
        qty: 10,
      );

      // 3. Verify RPC calls
      expect(mockOdoo.methodCalls, [
        'stock.picking.type.search_read',
        'stock.warehouse.read',
        'stock.picking.create',
        'stock.move.create',
        'stock.picking.action_confirm',
        'stock.picking.action_assign',
        'stock.picking.read',
        'stock.move.write',
        'stock.picking.button_validate'
      ]);

      // 4. Verify DB local
      final move = await isar.stockMoves.where().findFirst();
      expect(move?.pickingState, 'done');
      expect(move?.isPendingSync, false);
      expect(move?.pickingOdooId, 101);
    });

    test('Lỗi thiếu kho quăng đúng Exception StockPartialAssignException', () async {
      final order = FsmOrder()
        ..odooId = 100
        ..name = 'WO/TEST/001'
        ..stageId = 1
        ..stageName = 'New'
        ..stage = FsmOrderStage.draft
        ..isPendingSync = false
        ..lastSyncAt = DateTime.now()
        ..warehouseId = 1
        ..inventoryLocationId = 15;
      await isar.writeTxn(() async => await isar.fsmOrders.put(order));

      mockOdoo.shouldPartialAssign = true;

      expect(
        () => service.recordStockOut(orderOdooId: 100, productId: 123, productName: 'Ốc', qty: 10),
        throwsA(isA<StockPartialAssignException>())
      );
    });
  });
}

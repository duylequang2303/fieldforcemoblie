import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/product.dart';
import '../models/stock_move.dart';
import '../../orders/models/fsm_order.dart';

/// Service giao tiếp với Odoo API cho Stock.
class StockService {
  StockService._({OdooSessionManager? odoo, IsarService? isar})
      : _odoo = odoo ?? OdooSessionManager.instance,
        _isar = isar ?? IsarService.instance;
  static final StockService instance = StockService._();

  @visibleForTesting
  factory StockService.testConstructor(
      OdooSessionManager odoo, IsarService isar) {
    return StockService._(odoo: odoo, isar: isar);
  }

  final OdooSessionManager _odoo;
  final IsarService _isar;

  /// Tìm sản phẩm theo barcode (hỗ trợ quét mã).
  Future<Product?> findProductByBarcode(String barcode) async {
    try {
      final result = await _odoo.callKw(
        model: 'product.product',
        method: 'search_read',
        args: [
          [
            ['barcode', '=', barcode]
          ],
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'default_code',
            'barcode',
            'categ_id',
            'uom_id',
            'standard_price'
          ],
          'limit': 1,
        },
      ) as List<dynamic>;

      if (result.isEmpty) return null;

      final product = Product.fromJson(result.first as Map<String, dynamic>);
      // Lưu vào Isar
      await _isar.db.writeTxn(() async {
        await _isar.db.products.putByOdooId(product);
      });
      return product;
    } catch (e) {
      logger.e('StockService.findProductByBarcode', error: e);
      // Thử tìm trong Isar cache
      return _isar.db.products.filter().barcodeEqualTo(barcode).findFirst();
    }
  }

  /// Tìm sản phẩm theo tên/mã cho autocomplete Add Material (search_read Odoo thật).
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.length < 2) return const <Product>[];
    try {
      final result = await _odoo.callKw(
        model: 'product.product',
        method: 'search_read',
        args: [
          [
            '|',
            ['name', 'ilike', q],
            ['default_code', 'ilike', q]
          ],
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'default_code',
            'barcode',
            'categ_id',
            'uom_id',
            'standard_price'
          ],
          'limit': limit,
        },
      ) as List<dynamic>;
      return result
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('StockService.searchProducts', error: e);
      return const <Product>[];
    }
  }

  /// Lấy danh sách vật tư theo đơn dịch vụ.
  Future<List<StockMove>> getMovesForOrder(int orderOdooId) async {
    return _isar.db.stockMoves
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .findAll();
  }

  /// Ghi nhận xuất kho vật tư.
  Future<void> recordStockOut({
    required int orderOdooId,
    required int productId,
    required String productName,
    required double qty,
    String? productBarcode,
    String? uomName,
  }) async {
    // 1. Khôi phục hoặc tạo mới StockMove local
    var move = await _isar.db.stockMoves
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .and()
        .productIdEqualTo(productId)
        .and()
        .isPendingSyncEqualTo(true)
        .findFirst();

    if (move == null) {
      final currentUserId = _odoo.currentUserId;
      move = StockMove.create(
        orderOdooId: orderOdooId,
        productId: productId,
        productName: productName,
        productBarcode: productBarcode,
        uomName: uomName,
        demandQty: qty,
        doneQty: qty,
      );
      move.localOwnerId = currentUserId;
      move.isPendingSync = true;
      await _isar.db.writeTxn(() async {
        await _isar.db.stockMoves.put(move!);
      });
    }

    final order = await _isar.db.fsmOrders.getByOdooId(orderOdooId);
    if (order == null) {
      logger.w(
          'StockService.recordStockOut: Không tìm thấy order $orderOdooId local.');
      return;
    }

    // 2. Chạy State Machine để đồng bộ Odoo
    try {
      await _syncStockMoveToOdoo(move, order);
    } on StockPartialAssignException catch (e) {
      logger.w('StockService.recordStockOut: Lỗi thiếu kho (Business Error)',
          error: e);
      rethrow; // Quăng lên cho UI
    } on OdooApiException catch (e) {
      logger.w(
          'StockService.recordStockOut: offline/lỗi mạng, xếp hàng đợi sync',
          error: e);
      // Giữ isPendingSync = true
    }
  }

  /// Sync các stock move pending (resume).
  Future<void> syncPending() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return;
    final pending =
        await _isar.db.stockMoves
            .filter()
            .isPendingSyncEqualTo(true)
            .localOwnerIdEqualTo(currentUserId)
            .findAll();

    for (final move in pending) {
      final order = await _isar.db.fsmOrders.getByOdooId(move.orderOdooId);
      if (order == null) continue;

      try {
        await _syncStockMoveToOdoo(move, order);
      } on StockPartialAssignException catch (e) {
        logger.w(
            'StockService.syncPending: Bỏ qua do thiếu tồn kho (${move.id})',
            error: e);
        // Cần user xử lý, không lặp lại vô ích
      } on OdooApiException catch (e) {
        logger.w('StockService.syncPending: Lỗi mạng (${move.id})', error: e);
      } catch (e) {
        logger.e('StockService.syncPending: Lỗi không xác định', error: e);
      }
    }
  }

  /// Helper thực thi chuỗi RPC State Machine chuẩn Odoo.
  Future<void> _syncStockMoveToOdoo(StockMove move, FsmOrder order) async {
    if (move.pickingState == 'done') {
      if (move.isPendingSync) {
        await _isar.db.writeTxn(() async {
          move.isPendingSync = false;
          await _isar.db.stockMoves.put(move);
        });
      }
      return;
    }

    // Bước 1: Khởi tạo Picking và Move nếu chưa có
    if (move.pickingOdooId == null) {
      if (order.warehouseId == null || order.inventoryLocationId == null) {
        throw const OdooBusinessException(
            'Đơn hàng thiếu thông tin Kho (warehouse_id) hoặc Địa điểm (inventory_location_id).');
      }

      // 1a. Search picking type
      final pTypes = await _odoo.callKw(
        model: 'stock.picking.type',
        method: 'search_read',
        args: [
          [
            ['warehouse_id', '=', order.warehouseId],
            ['code', '=', 'outgoing']
          ]
        ],
        kwargs: {
          'limit': 1,
          'fields': ['id']
        },
      ) as List<dynamic>;

      if (pTypes.isEmpty) {
        throw const OdooBusinessException(
            'Không tìm thấy Operation Type xuất kho (outgoing) cho kho này.');
      }
      final pickingTypeId = pTypes.first['id'] as int;

      // 1b. Read lot_stock_id from warehouse
      final warehouses = await _odoo.callKw(
        model: 'stock.warehouse',
        method: 'read',
        args: [
          [order.warehouseId]
        ],
        kwargs: {
          'fields': ['lot_stock_id']
        },
      ) as List<dynamic>;

      if (warehouses.isEmpty || warehouses.first['lot_stock_id'] == null) {
        throw const OdooBusinessException(
            'Cấu hình Kho trên Odoo bị lỗi: thiếu lot_stock_id.');
      }
      final lotStockId = (warehouses.first['lot_stock_id'] as List)[0] as int;

      // 1c. Create stock.picking
      final pickingId = await _odoo.callKw(
        model: 'stock.picking',
        method: 'create',
        args: [
          {
            'fsm_order_id': order.odooId,
            if (order.partnerId != null) 'partner_id': order.partnerId,
            'picking_type_id': pickingTypeId,
            'location_id': lotStockId,
            'location_dest_id': order.inventoryLocationId,
          }
        ],
      ) as int;

      await _isar.db.writeTxn(() async {
        move.pickingOdooId = pickingId;
        await _isar.db.stockMoves.put(move);
      });

      // 1d. Create stock.move
      final moveId = await _odoo.callKw(
        model: 'stock.move',
        method: 'create',
        args: [
          {
            'picking_id': pickingId,
            'fsm_order_id': order.odooId,
            'name': move.productName,
            'product_id': move.productId,
            'product_uom_qty': move.demandQty,
            'location_id': lotStockId,
            'location_dest_id': order.inventoryLocationId,
          }
        ],
      ) as int;

      await _isar.db.writeTxn(() async {
        move.moveOdooId = moveId;
        move.pickingState = 'created';
        await _isar.db.stockMoves.put(move);
      });
    }

    final pickingId = move.pickingOdooId!;
    var state = move.pickingState ?? 'created';

    // Bước 2: Confirm
    if (state == 'created') {
      await _odoo.callKw(
        model: 'stock.picking',
        method: 'action_confirm',
        args: [
          [pickingId]
        ],
      );
      state = 'confirmed';
      await _isar.db.writeTxn(() async {
        move.pickingState = state;
        await _isar.db.stockMoves.put(move);
      });
    }

    // Bước 3: Assign
    if (state == 'confirmed') {
      await _odoo.callKw(
        model: 'stock.picking',
        method: 'action_assign',
        args: [
          [pickingId]
        ],
      );

      // Đọc lại state trên server vì action_assign không ném lỗi nếu hụt kho
      final pickingCheck = await _odoo.callKw(
        model: 'stock.picking',
        method: 'read',
        args: [
          [pickingId]
        ],
        kwargs: {
          'fields': ['state']
        },
      ) as List<dynamic>;

      final serverState = pickingCheck.first['state'] as String;
      if (serverState != 'assigned') {
        throw StockPartialAssignException(
            'Thiếu tồn kho. Trạng thái phiếu hiện tại: $serverState. Vui lòng kiểm tra lại Odoo.');
      }

      state = 'assigned';
      await _isar.db.writeTxn(() async {
        move.pickingState = state;
        await _isar.db.stockMoves.put(move);
      });
    }

    // Bước 4: Cập nhật Done Qty và Validate
    if (state == 'assigned') {
      // Set qty trực tiếp trên move (chuẩn Odoo 17+)
      await _odoo.callKw(
        model: 'stock.move',
        method: 'write',
        args: [
          [move.moveOdooId!],
          {'quantity': move.doneQty}
        ],
      );

      // Validate
      await _odoo.callKw(
        model: 'stock.picking',
        method: 'button_validate',
        args: [
          [pickingId]
        ],
      );

      state = 'done';
      await _isar.db.writeTxn(() async {
        move.pickingState = state;
        move.isPendingSync = false;
        await _isar.db.stockMoves.put(move);
      });
    }
  }
}

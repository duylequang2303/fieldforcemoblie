import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/product.dart';
import '../models/stock_move.dart';

/// Service giao tiếp với Odoo API cho Stock.
class StockService {
  StockService._();
  static final StockService instance = StockService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  /// Tìm sản phẩm theo barcode (hỗ trợ quét mã).
  Future<Product?> findProductByBarcode(String barcode) async {
    try {
      final result = await _odoo.callKw(
        model: 'product.product',
        method: 'search_read',
        args: [
          [['barcode', '=', barcode]],
        ],
        kwargs: {
          'fields': ['id', 'name', 'default_code', 'barcode', 'categ_id', 'uom_id', 'standard_price'],
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
    final move = StockMove.create(
      orderOdooId: orderOdooId,
      productId: productId,
      productName: productName,
      productBarcode: productBarcode,
      uomName: uomName,
      demandQty: qty,
      doneQty: qty,
    );

    await _isar.db.writeTxn(() async {
      await _isar.db.stockMoves.put(move);
    });

    // Push lên Odoo nếu có thể
    try {
      await _odoo.callKw(
        model: 'stock.move',
        method: 'create',
        args: [
          {
            'product_id': productId,
            'product_uom_qty': qty,
            'quantity': qty,
          },
        ],
      );
      await _isar.db.writeTxn(() async {
        move.isPendingSync = false;
        await _isar.db.stockMoves.put(move);
      });
    } on OdooApiException catch (e) {
      logger.w('StockService.recordStockOut: offline, queued', error: e);
    }
  }

  /// Sync các stock move pending.
  Future<void> syncPending() async {
    final pending = await _isar.db.stockMoves
        .filter()
        .isPendingSyncEqualTo(true)
        .findAll();

    for (final move in pending) {
      try {
        await _odoo.callKw(
          model: 'stock.move',
          method: 'create',
          args: [
            {
              'product_id': move.productId,
              'product_uom_qty': move.demandQty,
              'quantity': move.doneQty,
            },
          ],
        );
        await _isar.db.writeTxn(() async {
          move.isPendingSync = false;
          await _isar.db.stockMoves.put(move);
        });
      } catch (e) {
        logger.w('StockService.syncPending: failed for move ${move.id}', error: e);
      }
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../models/product.dart';
import '../models/stock_move.dart';
import '../services/stock_service.dart';

/// State management cho tính năng Stock / Vật tư.
class StockProvider extends ChangeNotifier {
  StockProvider._internal() : _service = StockService.instance;
  static final StockProvider instance = StockProvider._internal();

  final StockService _service;

  // Sản phẩm vừa quét được
  Product? _scannedProduct;
  List<StockMove> _moves = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _scanSuccess = false;

  Product? get scannedProduct => _scannedProduct;
  List<StockMove> get moves => List.unmodifiable(_moves);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get scanSuccess => _scanSuccess;

  /// Xử lý barcode sau khi quét.
  Future<void> onBarcodeScanned(String barcode) async {
    _isLoading = true;
    _scannedProduct = null;
    _scanSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await _service.findProductByBarcode(barcode);
      if (product != null) {
        _scannedProduct = product;
        _scanSuccess = true;
      } else {
        _errorMessage = 'Không tìm thấy sản phẩm với barcode: $barcode';
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi tìm sản phẩm: $e';
      logger.e('StockProvider.onBarcodeScanned', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ghi nhận xuất kho vật tư cho đơn.
  Future<void> recordOut({
    required int orderOdooId,
    required double qty,
  }) async {
    if (_scannedProduct == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _service.recordStockOut(
        orderOdooId: orderOdooId,
        productId: _scannedProduct!.odooId,
        productName: _scannedProduct!.name,
        productBarcode: _scannedProduct!.barcode,
        uomName: _scannedProduct!.uomName,
        qty: qty,
      );
      _scannedProduct = null;
      _scanSuccess = false;
      await loadMoves(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi xuất kho: $e';
      logger.e('StockProvider.recordOut', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải danh sách vật tư đã xuất cho đơn.
  Future<void> loadMoves(int orderOdooId) async {
    _moves = await _service.getMovesForOrder(orderOdooId);
    notifyListeners();
  }

  void clearScanned() {
    _scannedProduct = null;
    _scanSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _scannedProduct = null;
    _moves = [];
    _isLoading = false;
    _errorMessage = null;
    _scanSuccess = false;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../models/fsm_order.dart';
import '../services/orders_service.dart';

/// State management cho danh sách fsm.order.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider() {
    _listenConnectivity();
  }

  final _service = OrdersService.instance;
  final _connectivity = ConnectivityService.instance;

  List<FsmOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  List<FsmOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  /// Lắng nghe thay đổi kết nối mạng.
  void _listenConnectivity() {
    _connectivity.onStatusChanged.listen((isOnline) {
      _isOffline = !isOnline;
      notifyListeners();
      if (isOnline) {
        // Tự động sync khi mạng trở lại
        syncPending();
        fetchOrders();
      }
    });
  }

  /// Fetch orders: online → gọi Odoo, offline → đọc Isar.
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isOnline = await _connectivity.checkConnectivity();
      _isOffline = !isOnline;

      if (isOnline) {
        _orders = await _service.fetchMyOrders();
      } else {
        _orders = await _service.loadCachedOrders();
      }
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      // Fallback sang cache nếu API lỗi
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật stage của một order.
  Future<void> updateOrderStage(int odooId, int newStageId) async {
    try {
      await _service.updateStage(odooId, newStageId);
      final idx = _orders.indexWhere((o) => o.odooId == odooId);
      if (idx != -1) {
        _orders[idx].stageId = newStageId;
        notifyListeners();
      }
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Check-in tại địa điểm làm việc.
  Future<void> checkIn(int odooId) async {
    try {
      await _service.checkIn(odooId);
      await fetchOrders();
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Sync các record pending lên Odoo.
  Future<void> syncPending() async {
    try {
      await _service.syncPending();
    } catch (_) {
      // Bỏ qua lỗi sync, sẽ retry sau
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

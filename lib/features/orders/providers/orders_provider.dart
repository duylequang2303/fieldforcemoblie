import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../models/fsm_order.dart';
import '../services/orders_service.dart';
import '../services/recurring_service.dart';

/// State management cho danh sách fsm.order.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider({OrdersService? service, ConnectivityService? connectivity})
      : _service = service ?? OrdersService.instance,
        _connectivity = connectivity ?? ConnectivityService.instance {
    _listenConnectivity();
  }

  final OrdersService _service;
  final ConnectivityService _connectivity;

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.updateStage(odooId, newStageId);
      _orders = await _service.loadCachedOrders();
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      if (e is OdooConnectionException) {
        _isOffline = true;
      }
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chuyển đơn sang trạng thái Đang thực hiện (In Progress) bằng cách quét từ khoá
  Future<void> updateOrderToInProgress(int odooId) async {
    _isLoading = true;
    notifyListeners();
    final stageId =
        await _service.getStageIdByKeywords(['progress', 'thực hiện']);
    if (stageId != null) {
      await updateOrderStage(odooId, stageId);
    } else {
      _errorMessage =
          'Không tìm thấy trạng thái "Đang thực hiện" trên hệ thống.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chuyển đơn sang trạng thái Hoàn thành (Done) qua action chuẩn của Odoo
  Future<void> updateOrderToDone(int odooId) async {
    _isLoading = true;
    _errorMessage = null; // Reset errorMessage trước khi gọi API nghiệp vụ
    notifyListeners();

    try {
      await _service.completeOrder(odooId);
      _orders = await _service.loadCachedOrders();
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      if (e is OdooConnectionException) {
        _isOffline = true;
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check-in tại địa điểm làm việc.
  Future<void> checkIn(int odooId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.checkIn(odooId);
      _orders = await _service.loadCachedOrders();
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      if (e is OdooConnectionException) {
        _isOffline = true;
      }
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      _isLoading = false;
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

  /// Đánh dấu bỏ qua kì định kỳ này (Skip)
  Future<void> skipOccurrence(FsmOrder order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await RecurringService.instance.skipOccurrence(order);
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi bỏ qua đơn: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

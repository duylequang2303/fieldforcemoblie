import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/api/session_guard.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../models/fsm_order.dart';
import '../services/orders_service.dart';
import '../services/recurring_service.dart';

/// State management cho danh sách fsm.order.
class OrdersProvider extends ChangeNotifier with SessionGuard {
  OrdersProvider._internal()
      : _service = OrdersService.instance,
        _connectivity = ConnectivityService.instance,
        _recurringService = RecurringService.instance {
    _listenConnectivity();
  }
  static final OrdersProvider instance = OrdersProvider._internal();

  final OrdersService _service;
  final ConnectivityService _connectivity;
  final RecurringService _recurringService;

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
        // Tự động sync khi mạng trở lại, CHỈ nếu session còn hợp lệ
        // Fix Thread #1: Gate connectivity auto-sync on authentication
        if (OdooSessionManager.instance.isAuthenticated) {
          syncPending();
          fetchOrders();
        }
      }
    });
  }

  /// Fetch orders: online → gọi Odoo, offline → đọc Isar.
  Future<void> fetchOrders() async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isOnline = await _connectivity.checkConnectivity();
      _isOffline = !isOnline;

      final results = isOnline
          ? await _service.fetchMyOrders()
          : await _service.loadCachedOrders();

      if (!isSameSession(sessionToken)) return;
      _orders = results;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = e.message;
      // Fallback sang cache nếu API lỗi
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Cập nhật stage của một order.
  Future<void> updateOrderStage(int odooId, int newStageId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.updateStage(odooId, newStageId);
      final results = await _service.loadCachedOrders();
      if (!isSameSession(sessionToken)) return;
      _orders = results;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = e.message;
      if (e is OdooConnectionException) {
        _isOffline = true;
      }
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Chuyển đơn sang trạng thái Đang thực hiện (In Progress) bằng cách quét từ khoá
  Future<void> updateOrderToInProgress(int odooId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final stageId =
          await _service.getStageIdByKeywords(['progress', 'thực hiện']);
      if (!isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (stageId != null) {
        await updateOrderStage(odooId, stageId);
      } else {
        _errorMessage =
            'Không tìm thấy trạng thái "Đang thực hiện" trên hệ thống.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi khi định vị trạng thái: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chuyển đơn sang trạng thái Hoàn thành (Done) qua action chuẩn của Odoo
  Future<void> updateOrderToDone(int odooId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null; // Reset errorMessage trước khi gọi API nghiệp vụ
    notifyListeners();

    try {
      await _service.completeOrder(odooId);
      final results = await _service.loadCachedOrders();
      if (!isSameSession(sessionToken)) return;
      _orders = results;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = e.message;
      if (e is OdooConnectionException) {
        _isOffline = true;
      }
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi không xác định: $e';
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Check-in tại địa điểm làm việc.
  Future<void> checkIn(int odooId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.checkIn(odooId);
      final results = await _service.loadCachedOrders();
      if (!isSameSession(sessionToken)) return;
      _orders = results;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      if (e is OdooConnectionException) {
        _isOffline = true;
      } else {
        _errorMessage = e.message;
      }
      _orders = await _service.loadCachedOrders();
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi không xác định: $e';
      _orders = await _service.loadCachedOrders();
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
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

  /// Đánh dấu bỏ qua kì định kỳ này (Skip), trả về true nếu thành công
  Future<bool> skipOccurrence(FsmOrder order) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _recurringService.skipOccurrence(order);
      if (!isSameSession(sessionToken)) return false;
      if (success) {
        _orders = await _service.loadCachedOrders();
        return true;
      }
      return false;
    } on ArgumentError catch (e) {
      if (!isSameSession(sessionToken)) return false;
      _errorMessage = 'Lỗi tham số: ${e.message}';
      return false;
    } on StateError catch (e) {
      if (!isSameSession(sessionToken)) return false;
      _errorMessage = e.message;
      return false;
    } catch (e) {
      if (!isSameSession(sessionToken)) return false;
      _errorMessage = 'Lỗi không xác định khi bỏ qua đơn: $e';
      return false;
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _orders = [];
    _isLoading = false;
    _errorMessage = null;
    _isOffline = false;
    notifyListeners();
  }
}

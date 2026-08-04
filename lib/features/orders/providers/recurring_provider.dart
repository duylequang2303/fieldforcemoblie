import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/database/isar_service.dart';
import '../models/fsm_order.dart';
import '../services/orders_service.dart';
import '../services/recurring_service.dart';

class RecurringProvider extends ChangeNotifier {
  final OrdersService _ordersService;

  RecurringProvider({OrdersService? ordersService})
      : _ordersService = ordersService ?? OrdersService.instance;

  bool _isLoading = false;
  List<RecurringDueOrder> _dueOrders = [];
  String? _error;
  bool _busy = false;

  bool get isLoading => _isLoading;
  List<RecurringDueOrder> get dueOrders => _dueOrders;
  String? get error => _error;
  bool get busy => _busy;

  void _applyOrders(List<FsmOrder> orders) {
    final recurring = RecurringService.fromFsmOrders(orders);
    final due = RecurringService.filterDueOrders(recurring, DateTime.now());
    _dueOrders = due;
  }

  Future<void> loadInitial() async {
    _error = null;
    List<FsmOrder> cached = [];
    try {
      cached = await _ordersService.loadCachedOrders();
    } catch (_) {
      // Swallowed for cache load as in original code
    }
    _applyOrders(cached);
    notifyListeners();

    try {
      await fetchFromOdoo(showSpinner: cached.isEmpty);
    } catch (e) {
      if (e is OdooConnectionException) {
        // Suppress connection errors during initial load to degrade gracefully to cache.
        _error = 'Không thể tải dữ liệu. Hiển thị cache.';
        notifyListeners();
      } else {
        // Rethrow other errors (auth, validation, etc.) so callers/UI must handle them
        rethrow;
      }
    }
  }

  Future<void> fetchFromOdoo({required bool showSpinner}) async {
    if (showSpinner) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final fresh = await _ordersService.fetchMyOrders();
      _applyOrders(fresh);
      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is OdooConnectionException) {
        _error = 'Không thể tải dữ liệu. Hiển thị cache.';
      } else if (e is OdooApiException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      notifyListeners();
      rethrow;
    } finally {
      if (showSpinner) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> completeDueOrder(RecurringDueOrder order) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();

    try {
      // 1. Pre-persistence validation check: does this order exist in local DB?
      final local = await IsarService.instance.db.fsmOrders.getByOdooId(order.odooId);
      if (local == null) {
        throw Exception("Pre-persistence failure: Order ${order.odooId} not found in local database.");
      }

      // 2. Complete order. CompleteOrder function does local Isar write, then Odoo write.
      await _ordersService.completeOrder(order.odooId);

      // 3. Sync page state with fresh local/Odoo data
      try {
        await fetchFromOdoo(showSpinner: false);
      } catch (_) {
        // Suppress nested fetch errors during complete order refresh
      }
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
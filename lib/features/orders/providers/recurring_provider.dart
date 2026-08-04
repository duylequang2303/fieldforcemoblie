import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
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
  bool _cacheLoaded = false;

  bool get isLoading => _isLoading;
  List<RecurringDueOrder> get dueOrders => _dueOrders;
  String? get error => _error;
  bool get busy => _busy;
  bool get cacheLoaded => _cacheLoaded;

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
      _cacheLoaded = true;
    } catch (e, stack) {
      logger.e('Failed to load cached orders', error: e, stackTrace: stack);
      rethrow;
    }
    _applyOrders(cached);
    notifyListeners();

    try {
      await fetchFromOdoo(showSpinner: cached.isEmpty);
    } catch (e) {
      if (e is OdooConnectionException) {
        // Suppress connection errors during initial load to degrade gracefully to cache.
        _error = _cacheLoaded ? 'Không thể tải dữ liệu. Hiển thị cache.' : 'Không thể kết nối mạng và không tải được cache.';
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
        _error = _cacheLoaded ? 'Không thể tải dữ liệu. Hiển thị cache.' : 'Không thể kết nối mạng và không tải được cache.';
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
      try {
        await _ordersService.completeOrder(order.odooId);
      } catch (e) {
        // If Odoo write fails, the local stage change to DONE is still saved in Isar.
        // Re-read local cache to make sure UI reflects this immediately!
        try {
          final cached = await _ordersService.loadCachedOrders();
          _applyOrders(cached);
          _cacheLoaded = true;
        } catch (_) {
          // Fallback: manually filter out this completed order from local due list in memory
          _dueOrders = _dueOrders.where((o) => o.odooId != order.odooId).toList();
        }
        rethrow;
      }

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
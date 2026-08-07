import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/session_guard.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier with SessionGuard {
  ExpenseProvider._internal() : _service = ExpenseService.instance;
  static final ExpenseProvider instance = ExpenseProvider._internal();

  final ExpenseService _service;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool _isSyncing = false;
  int _syncErrorCount = 0;
  List<String> _syncErrors = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  bool get isSyncing => _isSyncing;
  int get syncErrorCount => _syncErrorCount;
  List<String> get syncErrors => List.unmodifiable(_syncErrors);
  bool get hasSyncErrors => _syncErrorCount > 0;

  /// Số chi phí đang chờ đồng bộ.
  int get pendingSyncCount => _expenses.where((e) => e.isPendingSync).length;

  Future<void> loadExpenses(int orderOdooId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    notifyListeners();
    try {
      final expenses = await _service.getExpensesForOrder(orderOdooId);
      if (!isSameSession(sessionToken)) return;
      _expenses = expenses;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      _expenses = [];
      _errorMessage = 'Lỗi tải chi phí: ${e.message}';
      logger.e('ExpenseProvider.loadExpenses', error: e);
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addExpense({
    required int orderOdooId,
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? receiptImagePath,
    String? note,
  }) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addExpense(
        orderOdooId: orderOdooId,
        name: name,
        amount: amount,
        date: date,
        category: category,
        receiptImagePath: receiptImagePath,
        note: note,
      );
      if (!isSameSession(sessionToken)) return;
      await loadExpenses(orderOdooId);
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi thêm chi phí: ${e.message}';
      logger.e('ExpenseProvider.addExpense', error: e);
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Trigger manual sync (e.g. pull-to-refresh) và trả về kết quả.
  Future<SyncResult?> syncExpenses() async {
    final sessionToken = currentSessionToken;
    _isSyncing = true;
    _syncErrorCount = 0;
    _syncErrors = [];
    notifyListeners();
    try {
      final result = await _service.syncPendingWithResult();
      if (!isSameSession(sessionToken)) return null;
      if (result != null) {
        _syncErrorCount = result.failedCount;
        _syncErrors = [...result.errors];
      }
      return result;
    } catch (e) {
      if (!isSameSession(sessionToken)) return null;
      _syncErrorCount = 1;
      _syncErrors = ['Lỗi đồng bộ: $e'];
      logger.e('ExpenseProvider.syncExpenses', error: e);
      return null;
    } finally {
      if (isSameSession(sessionToken)) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  void clearSyncErrors() {
    _syncErrorCount = 0;
    _syncErrors = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _expenses = [];
    _isLoading = false;
    _isSyncing = false;
    _syncErrorCount = 0;
    _syncErrors = [];
    _errorMessage = null;
    notifyListeners();
  }
}

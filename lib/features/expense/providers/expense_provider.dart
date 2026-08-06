import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../../../core/api/odoo_session_manager.dart';
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

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount => _expenses.fold(0.0, (sum, e) => sum + e.amount);

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
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _expenses = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

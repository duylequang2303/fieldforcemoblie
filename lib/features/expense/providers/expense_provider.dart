import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _service = ExpenseService.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadExpenses(int orderOdooId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _expenses = await _service.getExpensesForOrder(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi tải chi phí: $e';
      logger.e('ExpenseProvider.loadExpenses', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await loadExpenses(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi thêm chi phí: $e';
      logger.e('ExpenseProvider.addExpense', error: e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

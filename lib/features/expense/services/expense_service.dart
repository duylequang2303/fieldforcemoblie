import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/expense.dart';

class ExpenseService {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  Future<List<Expense>> getExpensesForOrder(int orderOdooId) async {
    return _isar.db.expenses
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .sortByDateDesc()
        .findAll();
  }

  Future<Expense> addExpense({
    required int orderOdooId,
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? receiptImagePath,
    String? note,
  }) async {
    final currentUserId = _odoo.currentUserId;
    final expense = Expense.create(
      orderOdooId: orderOdooId,
      name: name,
      amount: amount,
      date: date,
      category: category,
      receiptImagePath: receiptImagePath,
      note: note,
    );
    expense.localOwnerId = currentUserId;

    await _isar.db.writeTxn(() async {
      await _isar.db.expenses.put(expense);
    });

    if (expense.odooId != null) {
      await _isar.db.writeTxn(() async {
        expense.isPendingSync = false;
        await _isar.db.expenses.put(expense);
      });
      return expense;
    }

    try {
      final result = await _odoo.callKw(
        model: 'hr.expense',
        method: 'create',
        args: [
          {
            'name': name,
            'total_amount': amount,
            'date': date.toIso8601String().substring(0, 10),
            'fsm_order_id': orderOdooId,
          },
        ],
      );
      await _isar.db.writeTxn(() async {
        expense.odooId = result as int?;
        expense.isPendingSync = false;
        await _isar.db.expenses.put(expense);
      });
    } on OdooApiException catch (e) {
      logger.w('ExpenseService.addExpense: offline', error: e);
    }

    return expense;
  }

  Future<void> syncPending() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return;
    final pending =
        await _isar.db.expenses
            .filter()
            .isPendingSyncEqualTo(true)
            .localOwnerIdEqualTo(currentUserId)
            .findAll();

    for (final expense in pending) {
      if (expense.odooId != null) {
        await _isar.db.writeTxn(() async {
          expense.isPendingSync = false;
          await _isar.db.expenses.put(expense);
        });
        continue;
      }

      try {
        final result = await _odoo.callKw(
          model: 'hr.expense',
          method: 'create',
          args: [
            {
              'name': expense.name,
              'total_amount': expense.amount,
              'date': expense.date.toIso8601String().substring(0, 10),
              'fsm_order_id': expense.orderOdooId,
            },
          ],
        );
        await _isar.db.writeTxn(() async {
          expense.odooId = result as int?;
          expense.isPendingSync = false;
          await _isar.db.expenses.put(expense);
        });
      } catch (e) {
        logger.w('ExpenseService.syncPending failed', error: e);
      }
    }
  }
}

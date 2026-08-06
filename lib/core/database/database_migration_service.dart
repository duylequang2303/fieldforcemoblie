import '../utils/logger.dart';
import 'isar_service.dart';
import '../../features/orders/models/fsm_order.dart';
import '../../features/stock/models/stock_move.dart';
import '../../features/timesheet/models/timesheet_entry.dart';
import '../../features/expense/models/expense.dart';
import '../../features/work_order/models/work_report.dart';

/// Service thực hiện các logic migration dữ liệu giữa các phiên bản Isar DB.
class DatabaseMigrationService {
  DatabaseMigrationService._();

  /// Di chuyển các bản ghi offline không có localOwnerId (phiên bản cũ)
  /// sang localOwnerId của user hiện tại vừa đăng nhập thành công.
  static Future<void> migrateLegacyRecords(int currentUserId) async {
    if (!IsarService.instance.isInitialized) return;
    final isar = IsarService.instance.db;

    try {
      await isar.writeTxn(() async {
        // 1. FsmOrder
        final orders = await isar.fsmOrders.where().localOwnerIdIsNull().findAll();
        if (orders.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${orders.length} legacy FsmOrders to owner $currentUserId');
          for (final order in orders) {
            order.localOwnerId = currentUserId;
          }
          await isar.fsmOrders.putAll(orders);
        }

        // 2. StockMove
        final stockMoves = await isar.stockMoves.where().localOwnerIdIsNull().findAll();
        if (stockMoves.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${stockMoves.length} legacy StockMoves to owner $currentUserId');
          for (final move in stockMoves) {
            move.localOwnerId = currentUserId;
          }
          await isar.stockMoves.putAll(stockMoves);
        }

        // 3. TimesheetEntry
        final timesheets = await isar.timesheetEntrys.where().localOwnerIdIsNull().findAll();
        if (timesheets.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${timesheets.length} legacy TimesheetEntries to owner $currentUserId');
          for (final entry in timesheets) {
            entry.localOwnerId = currentUserId;
          }
          await isar.timesheetEntrys.putAll(timesheets);
        }

        // 4. Expense
        final expenses = await isar.expenses.where().localOwnerIdIsNull().findAll();
        if (expenses.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${expenses.length} legacy Expenses to owner $currentUserId');
          for (final expense in expenses) {
            expense.localOwnerId = currentUserId;
          }
          await isar.expenses.putAll(expenses);
        }

        // 5. WorkReport
        final reports = await isar.workReports.where().localOwnerIdIsNull().findAll();
        if (reports.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${reports.length} legacy WorkReports to owner $currentUserId');
          for (final report in reports) {
            report.localOwnerId = currentUserId;
          }
          await isar.workReports.putAll(reports);
        }
      });
    } catch (e, stackTrace) {
      logger.e('DatabaseMigrationService: Migration failed', error: e, stackTrace: stackTrace);
    }
  }
}

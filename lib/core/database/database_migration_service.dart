import 'package:isar_community/isar.dart';
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
  ///
  /// ⚠️ SECURITY NOTE (Thread #12 - IDOR/CWE-639):
  /// This migration assumes ONE device = ONE user (single-user device model).
  /// If multiple Odoo users can share one device, this would allow the first
  /// post-upgrade login to claim another user's legacy records.
  /// In a single-user device context (field force mobile), this is acceptable.
  /// For multi-user devices, legacy records should be discarded instead.
  static Future<bool> migrateLegacyRecords(int currentUserId) async {
    if (!IsarService.instance.isInitialized) {
      logger.w('DatabaseMigrationService: Legacy record migration was skipped because the database is not initialized.');
      return false;
    }
    final isar = IsarService.instance.db;

    try {
      await isar.writeTxn(() async {
        // 1. FsmOrder
        final orders = await isar.fsmOrders.filter().localOwnerIdIsNull().findAll();
        if (orders.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${orders.length} legacy FsmOrders to owner $currentUserId');
          for (final order in orders) {
            order.localOwnerId = currentUserId;
          }
          await isar.fsmOrders.putAll(orders);
        }

        // 2. StockMove
        final stockMoves = await isar.stockMoves.filter().localOwnerIdIsNull().findAll();
        if (stockMoves.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${stockMoves.length} legacy StockMoves to owner $currentUserId');
          for (final move in stockMoves) {
            move.localOwnerId = currentUserId;
          }
          await isar.stockMoves.putAll(stockMoves);
        }

        // 3. TimesheetEntry
        final timesheets = await isar.timesheetEntrys.filter().localOwnerIdIsNull().findAll();
        if (timesheets.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${timesheets.length} legacy TimesheetEntries to owner $currentUserId');
          for (final entry in timesheets) {
            entry.localOwnerId = currentUserId;
          }
          await isar.timesheetEntrys.putAll(timesheets);
        }

        // 4. Expense
        final expenses = await isar.expenses.filter().localOwnerIdIsNull().findAll();
        if (expenses.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${expenses.length} legacy Expenses to owner $currentUserId');
          for (final expense in expenses) {
            expense.localOwnerId = currentUserId;
          }
          await isar.expenses.putAll(expenses);
        }

        // 5. WorkReport
        final reports = await isar.workReports.filter().localOwnerIdIsNull().findAll();
        if (reports.isNotEmpty) {
          logger.i('DatabaseMigrationService: Migrating ${reports.length} legacy WorkReports to owner $currentUserId');
          for (final report in reports) {
            report.localOwnerId = currentUserId;
          }
          await isar.workReports.putAll(reports);
        }
      });
      return true;
    } on IsarError catch (e, stackTrace) {
      logger.e('DatabaseMigrationService: Isar migration failed', error: e, stackTrace: stackTrace);
      return false;
    } catch (e, stackTrace) {
      logger.e('DatabaseMigrationService: Unexpected migration failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

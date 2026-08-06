import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/timesheet_entry.dart';
import '../../orders/models/fsm_order.dart';

/// Service giao tiếp với Odoo account.analytic.line.
class TimesheetService {
  TimesheetService._();
  static final TimesheetService instance = TimesheetService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  /// Tải danh sách giờ công cho một đơn từ Isar local.
  Future<List<TimesheetEntry>> getEntriesForOrder(int orderOdooId) async {
    return _isar.db.timesheetEntrys
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .sortByDateDesc()
        .findAll();
  }

  /// Thêm mới một dòng timesheet (offline-first).
  Future<TimesheetEntry> addEntry({
    required int orderOdooId,
    required DateTime date,
    required double hours,
    required String description,
  }) async {
    final order = await _isar.db.fsmOrders.getByOdooId(orderOdooId);
    if (order == null) {
      throw const OdooBusinessException('Không tìm thấy đơn hàng cục bộ.');
    }

    final currentUserId = _odoo.currentUserId;
    final entry = TimesheetEntry.create(
      orderOdooId: orderOdooId,
      date: date,
      hours: hours,
      description: description,
      employeeName: _odoo.currentUserName,
    );
    entry.localOwnerId = currentUserId;

    await _isar.db.writeTxn(() async {
      await _isar.db.timesheetEntrys.put(entry);
    });

    if (entry.odooId != null) {
      await _isar.db.writeTxn(() async {
        entry.isPendingSync = false;
        await _isar.db.timesheetEntrys.put(entry);
      });
      return entry;
    }

    // Cố gắng push lên Odoo ngay
    try {
      final result = await _odoo.callKw(
        model: 'account.analytic.line',
        method: 'create',
        args: [
          {
            'name': description,
            'date':
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            'unit_amount': hours,
            'employee_id': _odoo.currentSession?.employeeId,
            'fsm_order_id': orderOdooId,
          },
        ],
      );
      await _isar.db.writeTxn(() async {
        entry.odooId = result as int?;
        entry.isPendingSync = false;
        await _isar.db.timesheetEntrys.put(entry);
      });
    } on OdooApiException catch (e) {
      logger.w('TimesheetService.addEntry: offline, queued', error: e);
    }

    return entry;
  }

  /// Sync các entry pending.
  Future<void> syncPending() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return;
    final pending = await _isar.db.timesheetEntrys
        .filter()
        .isPendingSyncEqualTo(true)
        .localOwnerIdEqualTo(currentUserId)
        .findAll();

    for (final entry in pending) {
      final order = await _isar.db.fsmOrders.getByOdooId(entry.orderOdooId);
      if (order == null) {
        logger.w(
            'TimesheetService.syncPending: Thiếu order, bỏ qua entry ${entry.id}');
        continue;
      }

      if (entry.odooId != null) {
        await _isar.db.writeTxn(() async {
          entry.isPendingSync = false;
          await _isar.db.timesheetEntrys.put(entry);
        });
        continue;
      }

      try {
        final result = await _odoo.callKw(
          model: 'account.analytic.line',
          method: 'create',
          args: [
            {
              'name': entry.name,
              'date': entry.date.toIso8601String().substring(0, 10),
              'unit_amount': entry.hours,
              'employee_id': _odoo.currentSession?.employeeId,
              'fsm_order_id': order.odooId,
            },
          ],
        );
        await _isar.db.writeTxn(() async {
          entry.odooId = result as int?;
          entry.isPendingSync = false;
          await _isar.db.timesheetEntrys.put(entry);
        });
      } catch (e) {
        logger.w('TimesheetService.syncPending: failed', error: e);
      }
    }
  }
}

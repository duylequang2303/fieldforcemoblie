import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/logger.dart';
import '../models/timesheet_entry.dart';
import '../../orders/models/fsm_order.dart';

/// Service giao tiếp với Odoo account.analytic.line.
class TimesheetService {
  TimesheetService._();
  static final TimesheetService instance = TimesheetService._();

  static const String _model = 'account.analytic.line';

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  /// Tìm dòng timesheet đã tồn tại trên Odoo, nếu chưa có thì tạo mới.
  /// Trả về id Odoo của dòng timesheet.
  Future<int?> _findOrCreateRemoteLine({
    required int orderOdooId,
    required DateTime date,
    required double hours,
    required String description,
  }) async {
    final employeeId = _odoo.currentSession?.employeeId;
    final dateStr = AppDateFormat.odooDate(date);

    final existingRemote = await _odoo.callKw(
      model: _model,
      method: 'search_read',
      args: [
        [
          ['employee_id', '=', employeeId],
          ['date', '=', dateStr],
          ['fsm_order_id', '=', orderOdooId],
          ['name', '=', description],
          ['unit_amount', '=', hours],
        ]
      ],
      kwargs: {
        'fields': ['id'],
        'limit': 1
      },
    );
    if (existingRemote is List && existingRemote.isNotEmpty) {
      final id = (existingRemote.first as Map<String, dynamic>)['id'] as int?;
      if (id != null) return id;
    }

    return await _odoo.callKw(
      model: _model,
      method: 'create',
      args: [
        {
          'name': description,
          'date': dateStr,
          'unit_amount': hours,
          'employee_id': employeeId,
          'fsm_order_id': orderOdooId,
        },
      ],
    ) as int?;
  }

  Future<({List<TimesheetEntry> entries, bool hasMore})> getEntriesForOrder(
    int orderOdooId, {
    int offset = 0,
    int limit = 100,
  }) async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) {
      return (entries: const <TimesheetEntry>[], hasMore: false);
    }
    final entries = await _isar.db.timesheetEntrys
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .and()
        .localOwnerIdEqualTo(currentUserId)
        .sortByDateDesc()
        .offset(offset)
        .limit(limit + 1)
        .findAll();

    final hasMore = entries.length > limit;
    if (hasMore) {
      entries.removeLast();
    }
    return (entries: entries, hasMore: hasMore);
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

    // Cố gắng push lên Odoo ngay
    try {
      final remoteId = await _findOrCreateRemoteLine(
        orderOdooId: orderOdooId,
        date: date,
        hours: hours,
        description: description,
      );

      await _isar.db.writeTxn(() async {
        entry.odooId = remoteId;
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
    final now = DateTime.now();

    final pending = await _isar.db.timesheetEntrys
        .filter()
        .isPendingSyncEqualTo(true)
        .localOwnerIdEqualTo(currentUserId)
        .isSyncFailedEqualTo(false)
        .findAll();

    for (final entry in pending) {
      if (entry.nextRetryAt != null && entry.nextRetryAt!.isAfter(now)) {
        continue;
      }

      final order = await _isar.db.fsmOrders.getByOdooId(entry.orderOdooId);
      if (order == null) {
        logger.w(
            'TimesheetService.syncPending: Thiếu order, bỏ qua entry ${entry.id}');
        continue;
      }

      if (entry.odooId != null) {
        await _isar.db.writeTxn(() async {
          entry.isPendingSync = false;
          entry.lastSyncAt = DateTime.now();
          await _isar.db.timesheetEntrys.put(entry);
        });
        continue;
      }

      final existing = await _isar.db.timesheetEntrys
          .filter()
          .orderOdooIdEqualTo(entry.orderOdooId)
          .and()
          .localOwnerIdEqualTo(entry.localOwnerId!)
          .and()
          .dateEqualTo(entry.date)
          .and()
          .nameEqualTo(entry.name)
          .and()
          .hoursEqualTo(entry.hours)
          .and()
          .odooIdGreaterThan(0)
          .findFirst();

      if (existing != null) {
        await _isar.db.writeTxn(() async {
          entry.odooId = existing.odooId;
          entry.isPendingSync = false;
          entry.lastSyncAt = DateTime.now();
          await _isar.db.timesheetEntrys.put(entry);
        });
        continue;
      }

      try {
        final remoteId = await _findOrCreateRemoteLine(
          orderOdooId: order.odooId,
          date: entry.date,
          hours: entry.hours,
          description: entry.name,
        );

        await _isar.db.writeTxn(() async {
          entry.odooId = remoteId;
          entry.isPendingSync = false;
          entry.syncRetryCount = 0;
          entry.nextRetryAt = null;
          entry.lastSyncAt = DateTime.now();
          await _isar.db.timesheetEntrys.put(entry);
        });
      } on OdooApiException catch (e) {
        entry.syncRetryCount++;
        if (entry.syncRetryCount >= 3) {
          await _isar.db.writeTxn(() async {
            entry.isSyncFailed = true;
            entry.isPendingSync = false;
            entry.nextRetryAt = null;
            await _isar.db.timesheetEntrys.put(entry);
          });
          logger.w('TimesheetService.syncPending: permanently failed for entry ${entry.id}');
        } else {
          final backoff = Duration(seconds: 1 << (entry.syncRetryCount - 1));
          await _isar.db.writeTxn(() async {
            entry.nextRetryAt = now.add(backoff);
            await _isar.db.timesheetEntrys.put(entry);
          });
          logger.w('TimesheetService.syncPending: failed (attempt ${entry.syncRetryCount}), retry at ${entry.nextRetryAt}', error: e);
        }
      }
    }
  }
}

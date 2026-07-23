import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/work_report.dart';

class WorkOrderService {
  WorkOrderService._();
  static final WorkOrderService instance = WorkOrderService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  /// Lấy hoặc tạo mới báo cáo cho đơn.
  Future<WorkReport> getOrCreateReport(int orderOdooId) async {
    final existing = await _isar.db.workReports
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .findFirst();

    if (existing != null) return existing;

    final report = WorkReport.create(orderOdooId: orderOdooId);
    await _isar.db.writeTxn(() async {
      await _isar.db.workReports.put(report);
    });
    return report;
  }

  /// Lưu nội dung báo cáo (local).
  Future<void> saveReport(WorkReport report) async {
    report
      ..isPendingSync = true
      ..createdAt = DateTime.now();
    await _isar.db.writeTxn(() async {
      await _isar.db.workReports.put(report);
    });
  }

  /// Submit báo cáo lên Odoo (chỉ gọi khi online và có chữ ký).
  Future<void> submitReport(WorkReport report) async {
    try {
      await _odoo.callKw(
        model: 'fsm.order',
        method: 'write',
        args: [
          [report.orderOdooId],
          {
            'description': report.workDone,
          },
        ],
      );
      await _isar.db.writeTxn(() async {
        report.isPendingSync = false;
        await _isar.db.workReports.put(report);
      });
    } on OdooApiException catch (e) {
      logger.e('WorkOrderService.submitReport', error: e);
      rethrow;
    }
  }
}

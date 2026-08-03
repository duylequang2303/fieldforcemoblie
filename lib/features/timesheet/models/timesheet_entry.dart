import 'package:isar_community/isar.dart';

part 'timesheet_entry.g.dart';

/// Một dòng ghi nhận giờ công của Worker cho fsm.order.
/// Map với account.analytic.line trên Odoo.
@collection
class TimesheetEntry {
  Id id = Isar.autoIncrement;

  /// ID Odoo nếu đã sync (null nếu chỉ có local).
  int? odooId;

  @Index()
  late int orderOdooId; // fsm.order.id

  late DateTime date; // Ngày làm việc
  late double hours; // Số giờ công
  late String name; // Mô tả công việc

  String? employeeName; // Tên nhân viên

  late bool isPendingSync;
  late DateTime createdAt;

  TimesheetEntry();

  factory TimesheetEntry.create({
    required int orderOdooId,
    required DateTime date,
    required double hours,
    required String description,
    String? employeeName,
  }) {
    return TimesheetEntry()
      ..orderOdooId = orderOdooId
      ..date = date
      ..hours = hours
      ..name = description
      ..employeeName = employeeName
      ..isPendingSync = true
      ..createdAt = DateTime.now();
  }
}

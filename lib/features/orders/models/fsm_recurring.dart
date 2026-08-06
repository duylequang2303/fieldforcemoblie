import 'package:isar_community/isar.dart';

part 'fsm_recurring.g.dart';

/// Model Isar cho fsm.recurring (template recurring order).
/// Map trực tiếp với Odoo backend để sync 2 chiều.
@collection
class FsmRecurring {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo.
  @Index(unique: true)
  late int odooId;

  late String name; // Tên recurring, VD: "Weekly Maintenance - VH Central"

  /// ID của fsm.frequency.set (liên kết với FsmFrequencySet).
  late int frequencySetId;

  /// ID của fsm.order template (order gốc làm template).
  int? orderTemplateId;

  /// Company ID (theo Odoo multi-company).
  int? companyId;

  // Scheduling
  late DateTime startDate; // Ngày bắt đầu chuỗi recurring
  DateTime? endDate; // Ngày kết thúc (null = indefinitely)

  /// Ngày đơn kế tiếp sẽ được tạo (được tính từ frequency + last instance).
  DateTime? nextDate;

  /// Số lần đã tạo instance (tracking).
  int generatedCount = 0;

  /// Có active hay không (user có thể pause recurring).
  bool isActive = true;

  /// Loại rule: 'date' (theo lịch cố định) hoặc 'completion' (kể từ khi hoàn thành đơn trước).
  /// Được sync từ Odoo field 'recurrence_rule_type' nếu có
  late String ruleType;

  /// Số ngày để tạo kỳ tiếp theo nếu ruleType là 'completion'.
  /// Được sync từ Odoo field 'recurrence_completion_interval' nếu có
  int completionInterval = 0;

  /// Số lần đã hoàn thành thành công
  /// Được sync từ Odoo field 'recurrence_completed_count' nếu có
  int completedCount = 0;

  /// Số lần bị bỏ qua (skipped)
  /// Được sync từ Odoo field 'recurrence_skipped_count' nếu có
  int skippedCount = 0;

  // Sync
  late bool isPendingSync;
  late DateTime lastSyncAt;

  FsmRecurring();

  /// Tạo từ JSON trả về từ Odoo API.
  factory FsmRecurring.fromJson(Map<String, dynamic> json) {
    return FsmRecurring()
      ..odooId = (json['id'] as num).toInt()
      ..name = _strOrNull(json['name']) ?? ''
      ..frequencySetId = _idFromMany(json['fsm_frequency_set_id'])
      ..orderTemplateId = _idOrNull(json['fsm_order_template_id'])
      ..companyId = _idOrNull(json['company_id'])
      ..startDate = _parseDate(json['start_date']) ?? DateTime.now()
      ..endDate = _parseDate(json['end_date'])
      ..nextDate = _parseDate(json['next_date'])
      ..generatedCount = (json['generated_count'] as int?) ?? 0
      ..isActive = json['active'] != false // Odoo default true nếu không có
      ..ruleType = _strOrNull(json['recurrence_rule_type']) ?? 'date'
      ..completionInterval = _intOrZero(json['recurrence_completion_interval'])
      ..completedCount = _intOrZero(json['recurrence_completed_count'])
      ..skippedCount = _intOrZero(json['recurrence_skipped_count'])
      ..isPendingSync = false
      ..lastSyncAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': odooId,
      'name': name,
      'fsm_frequency_set_id': frequencySetId,
      'fsm_order_template_id': orderTemplateId,
      'company_id': companyId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'next_date': nextDate?.toIso8601String().split('T')[0],
      'active': isActive,
      'recurrence_rule_type': ruleType,
      'recurrence_completion_interval': completionInterval,
      'recurrence_completed_count': completedCount,
      'recurrence_skipped_count': skippedCount,
    };
  }

  // Helper parse
  static int _idFromMany(dynamic value) {
    if (value == null || value == false) return 0;
    if (value case num n) return n.toInt();
    if (value case List l when l.isNotEmpty) {
      final first = l[0];
      if (first case num n) return n.toInt();
      return int.tryParse(first.toString()) ?? 0;
    }
    if (value case String s) return int.tryParse(s) ?? 0;
    return 0;
  }

  static int? _idOrNull(dynamic value) {
    if (value == null || value == false) return null;
    if (value case num n) return n.toInt();
    if (value case List l when l.isNotEmpty) {
      final first = l[0];
      if (first case num n) return n.toInt();
      return int.tryParse(first.toString());
    }
    if (value case String s) return int.tryParse(s);
    return null;
  }

  static int _intOrZero(dynamic value) {
    if (value == null || value == false) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == false) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static String? _strOrNull(dynamic value) {
    if (value == null || value == false) return null;
    return value.toString();
  }
}

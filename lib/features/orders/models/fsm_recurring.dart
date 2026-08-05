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
  late String ruleType;

  /// Số ngày để tạo kỳ tiếp theo nếu ruleType là 'completion'.
  int completionInterval = 0;

  /// Số lần đã hoàn thành thành công
  int completedCount = 0;

  /// Số lần bị bỏ qua (skipped)
  int skippedCount = 0;

  // Sync
  late bool isPendingSync;
  late DateTime lastSyncAt;

  FsmRecurring();

  /// Tạo từ JSON trả về từ Odoo API.
  factory FsmRecurring.fromJson(Map<String, dynamic> json) {
    return FsmRecurring()
      ..odooId = json['id'] as int
      ..name = _strOrNull(json['name']) ?? ''
      ..frequencySetId = _idFromMany(json['fsm_frequency_set_id'])
      ..orderTemplateId = _idFromMany(json['fsm_order_template_id'])
      ..companyId = _idFromMany(json['company_id'])
      ..startDate = _parseDate(json['start_date']) ?? DateTime.now()
      ..endDate = _parseDate(json['end_date'])
      ..nextDate = _parseDate(json['next_date'])
      ..generatedCount = (json['generated_count'] as int?) ?? 0
      ..isActive = json['active'] != false // Odoo default true nếu không có
      // NOTE: ruleType, completionInterval, completedCount, skippedCount are LOCAL-ONLY fields
      // not present on Odoo backend. They are managed locally by the app.
      ..ruleType = 'date'
      ..completionInterval = 0
      ..completedCount = 0
      ..skippedCount = 0
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
      'generated_count': generatedCount,
      'active': isActive,
      // NOTE: rule_type, completion_interval, completed_count, skipped_count are LOCAL-ONLY
      // not synced to Odoo (backend doesn't have these fields)
    };
  }

  // Helper parse
  static int _idFromMany(dynamic value) {
    if (value == null || value == false) return 0;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int;
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

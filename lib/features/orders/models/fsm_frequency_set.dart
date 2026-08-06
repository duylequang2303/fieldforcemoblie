import 'package:isar_community/isar.dart';

part 'fsm_frequency_set.g.dart';

/// Loại interval cho recurring (map với Odoo fsm.frequency.set).
enum FrequencyIntervalType {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Model Isar cho fsm.frequency.set (tần suất lặp lại).
/// Map trực tiếp với Odoo backend để sync 2 chiều.
@collection
class FsmFrequencySet {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo.
  @Index(unique: true)
  late int odooId;

  late String name; // VD: "Every Week", "Every 2 Weeks"

  /// Số lần lặp (VD: 2 = every 2 weeks/months).
  late int interval;

  /// Loại interval (daily/weekly/monthly/yearly).
  @Enumerated(EnumType.name)
  late FrequencyIntervalType intervalType;

  /// Duration: số ngày/tuần/tháng một kỳ recurring kéo dài (optional).
  /// VD: interval=2, intervalType=weekly, duration=1 → mỗi 2 tuần, kéo dài 1 tuần.
  int? duration;

  // Sync
  late bool isPendingSync;
  late DateTime lastSyncAt;

  FsmFrequencySet();

  /// Tạo từ JSON trả về từ Odoo API.
  factory FsmFrequencySet.fromJson(Map<String, dynamic> json) {
    return FsmFrequencySet()
      ..odooId = (json['id'] as num).toInt()
      ..name = _strOrNull(json['name']) ?? ''
      ..interval = _intOrNull(json['interval']) ?? 1
      ..intervalType = _parseIntervalType(json['interval_type'])
      ..duration = _intOrNull(json['duration'])
      ..isPendingSync = false
      ..lastSyncAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': odooId,
      'name': name,
      'interval': interval,
      'interval_type': intervalType.name,
      'duration': duration,
    };
  }

  // Helper parse
  static FrequencyIntervalType _parseIntervalType(dynamic value) {
    if (value == null || value == false) return FrequencyIntervalType.weekly;
    final str = value.toString().toLowerCase();
    return FrequencyIntervalType.values.firstWhere(
      (e) => e.name == str,
      orElse: () => FrequencyIntervalType.weekly,
    );
  }

  static String? _strOrNull(dynamic value) {
    if (value == null || value == false) return null;
    return value.toString();
  }

  static int? _intOrNull(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

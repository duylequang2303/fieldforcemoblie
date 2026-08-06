import 'package:isar_community/isar.dart';

part 'fsm_order.g.dart';

/// Trạng thái đơn dịch vụ — mapping với stage Odoo FSM.
enum FsmOrderStage {
  draft, // Nháp / Mới
  inProgress, // Đang thực hiện
  done, // Hoàn thành
  cancelled, // Đã huỷ
}

/// Model Isar lưu offline cho fsm.order từ Odoo.
@collection
class FsmOrder {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo (khác với [id] local của Isar).
  @Index(unique: true)
  late int odooId;

  /// ID của user sở hữu dữ liệu offline này (cách ly dữ liệu giữa các user).
  @Index()
  int? localOwnerId;

  late String name; // Tên đơn, VD: "WO/2024/001"
  String? description; // Mô tả công việc

  // Stage
  late int stageId;
  late String stageName;
  @Enumerated(EnumType.name)
  late FsmOrderStage stage;

  // Địa điểm & Khách hàng
  String? locationName; // fsm.location.name
  String? locationAddress; // Địa chỉ đầy đủ
  double? locationLat; // Vĩ độ GPS
  double? locationLng; // Kinh độ GPS
  String? partnerName; // Tên khách hàng
  String? partnerPhone; // SĐT khách hàng
  int? partnerId; // Từ fsm.location partner_id

  // Kho hàng liên kết
  int? warehouseId; // Từ order warehouse_id
  int? inventoryLocationId; // Từ fsm.location inventory_location_id

  // Lịch hẹn
  DateTime? scheduledDateStart;
  DateTime? scheduledDateEnd;
  DateTime? dateStart; // Giờ bắt đầu thực tế
  DateTime? dateEnd; // Giờ kết thúc thực tế
  int? routeSequence; // Thứ tự lộ trình từ Odoo optimal route
  int? routeId; // ID của lộ trình fsm.route
  String? routeState; // state của lộ trình ('draft', 'planned', 'done')

  // Worker
  int? personId; // fsm.person.id
  String? personName;
  String? priority; // '0' = Normal, '1' = High

  // Sync
  late bool isPendingSync; // true = có thay đổi chưa push lên Odoo
  late DateTime lastSyncAt;

  // Rules
  bool requireSignature = false;

  // Recurring - Tracking instance sinh từ recurring template
  /// ID của fsm.recurring parent (Odoo ID, không phải Isar ID).
  /// Nếu null = đơn one-time (không recurring).
  int? recurringId;

  /// Instance này có phải sinh ra từ recurring template không.
  bool isRecurringInstance = false;

  /// Đơn này bị skip trong chuỗi recurring (không tính completed/overdue).
  bool isSkipped = false;

  /// Đơn định kỳ này đã được xử lý tính chu kỳ tiếp theo (để tránh double-schedule khi retry) chưa.
  bool isRecurringProcessed = false;

  FsmOrder();

  /// Tạo từ JSON trả về từ Odoo API.
  factory FsmOrder.fromJson(Map<String, dynamic> json,
      {Map<int, Map<String, dynamic>>? locationCoordinates}) {
    final order = FsmOrder()
      ..odooId = (json['id'] as num).toInt()
      ..name = _strOrNull(json['name']) ?? ''
      ..description = _strOrNull(json['description'])
      ..stageId = _idFromMany(json['stage_id'])
      ..stageName = _nameFromMany(json['stage_id'])
      ..stage = _parseStage(json['stage_id'])
      ..locationName = _nameFromMany(json['location_id'])
      ..locationAddress = _strOrNull(json['location_address']) ??
          _nameFromMany(json['location_id'])
      ..partnerPhone = _strOrNull(json['phone'])
      ..recurringId = _idOrNull(json['fsm_recurring_id'])
      ..isRecurringInstance = json['is_recurring_instance'] == true
      ..isSkipped = json['is_skipped'] == true
      ..isRecurringProcessed = json['is_recurring_processed'] == true
      ..scheduledDateStart = _dateOrNull(json['scheduled_date_start'])
      ..scheduledDateEnd = _dateOrNull(json['scheduled_date_end'])
      ..dateStart = _dateOrNull(json['date_start'])
      ..dateEnd = _dateOrNull(json['date_end'])
      ..personId = _idOrNull(json['person_id'])
      ..personName = _nameFromMany(json['person_id'])
      ..priority = _strOrNull(json['priority'])
      ..routeSequence = _intOrNull(json['route_sequence'])
      ..routeId = _idOrNull(json['route_id'])
      ..routeState = _strOrNull(json[
          'route_state']) // Sẽ được merge từ query riêng hoặc related field
      ..requireSignature = json['require_signature'] == true
      ..isPendingSync = false
      ..lastSyncAt = DateTime.now();

    // Parse location coordinates & additional data if available
    if (json['location_id'] != null &&
        json['location_id'] is List &&
        (json['location_id'] as List).isNotEmpty &&
        locationCoordinates != null) {
      final locationId = (json['location_id'] as List)[0] as int;
      final locationData = locationCoordinates[locationId];
      if (locationData != null) {
        order.locationLat = _doubleOrNull(locationData['partner_latitude']);
        order.locationLng = _doubleOrNull(locationData['partner_longitude']);
        order.partnerId = _idOrNull(locationData['partner_id']);
        order.partnerName = _nameFromMany(locationData['partner_id']);
        order.inventoryLocationId =
            _idOrNull(locationData['inventory_location_id']);
      }
    }

    // Parse warehouse
    order.warehouseId = _idOrNull(json['warehouse_id']);

    return order;
  }

  // ── Helpers ──────────────────────────────────────────────
  static String? _strOrNull(dynamic v) {
    if (v == null || v == false) return null;
    return v.toString();
  }

  static int? _intOrNull(dynamic v) {
    if (v == null || v == false) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _doubleOrNull(dynamic v) {
    if (v == null || v == false) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int _idFromMany(dynamic v) {
    if (v == null || v == false) return 0;
    if (v case num n) return n.toInt();
    if (v case List l when l.isNotEmpty) {
      final first = l[0];
      if (first case num n) return n.toInt();
      return int.tryParse(first.toString()) ?? 0;
    }
    if (v case String s) return int.tryParse(s) ?? 0;
    return 0;
  }

  static int? _idOrNull(dynamic v) {
    if (v == null || v == false) return null;
    if (v case num n) return n.toInt();
    if (v case List l when l.isNotEmpty) {
      final first = l[0];
      if (first case num n) return n.toInt();
      return int.tryParse(first.toString());
    }
    if (v case String s) return int.tryParse(s);
    return null;
  }

  static String _nameFromMany(dynamic v) {
    if (v == null || v == false) return '';
    if (v is String) return v;
    if (v is List && v.length >= 2) return v[1].toString();
    if (v is List && v.isNotEmpty) return v[0].toString();
    return v.toString();
  }

  static DateTime? _dateOrNull(dynamic v) {
    if (v == null || v == false) return null;
    try {
      return DateTime.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static FsmOrderStage parseStageName(String name) {
    final normalized = name.toLowerCase().trim();
    return switch (normalized) {
      'new' || 'draft' || 'scheduled' || 'assigned' || 'mới' || 'nháp' || 'đã lên lịch' || 'lên lịch' || 'đã phân công' || 'phân công' || 'hold' || 'on hold' || 'on_hold' || 'tạm dừng' => FsmOrderStage.draft,
      'ready' || 'in_progress' || 'in progress' || 'sẵn sàng' || 'đang thực hiện' || 'thực hiện' => FsmOrderStage.inProgress,
      'done' || 'completed' || 'hoàn thành' || 'hoàn' => FsmOrderStage.done,
      'cancelled' || 'cancel' || 'huỷ' || 'hủy' || 'đã huỷ' || 'đã hủy' => FsmOrderStage.cancelled,
      // fallback checks matching exact substring patterns
      _ when normalized.contains('progress') || normalized.contains('thực hiện') || normalized.contains('ready') || normalized.contains('sẵn sàng') => FsmOrderStage.inProgress,
      _ when normalized.contains('done') || normalized.contains('completed') || normalized.contains('hoàn') => FsmOrderStage.done,
      _ when normalized.contains('cancel') || normalized.contains('huỷ') || normalized.contains('hủy') => FsmOrderStage.cancelled,
      _ => FsmOrderStage.draft,
    };
  }

  static FsmOrderStage _parseStage(dynamic stageField) {
    return parseStageName(_nameFromMany(stageField));
  }
}

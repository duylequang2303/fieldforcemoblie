import 'package:isar_community/isar.dart';

part 'fsm_order.g.dart';

/// Trạng thái đơn dịch vụ — mapping với stage Odoo FSM.
enum FsmOrderStage {
  draft,      // Nháp / Mới
  inProgress, // Đang thực hiện
  done,       // Hoàn thành
  cancelled,  // Đã huỷ
}

/// Model Isar lưu offline cho fsm.order từ Odoo.
@collection
class FsmOrder {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo (khác với [id] local của Isar).
  @Index(unique: true)
  late int odooId;

  late String name;           // Tên đơn, VD: "WO/2024/001"
  String? description;        // Mô tả công việc

  // Stage
  late int stageId;
  late String stageName;
  @Enumerated(EnumType.name)
  late FsmOrderStage stage;

  // Địa điểm & Khách hàng
  String? locationName;       // fsm.location.name
  String? locationAddress;    // Địa chỉ đầy đủ
  double? locationLat;        // Vĩ độ GPS
  double? locationLng;        // Kinh độ GPS
  String? partnerName;        // Tên khách hàng
  String? partnerPhone;       // SĐT khách hàng
  int? partnerId;             // Từ fsm.location partner_id

  // Kho hàng liên kết
  int? warehouseId;           // Từ order warehouse_id
  int? inventoryLocationId;   // Từ fsm.location inventory_location_id

  // Dự án & Chấm công
  int? projectId;             // Từ order project_id
  int? projectTaskId;         // Từ order project_task_id

  // Lịch hẹn
  DateTime? scheduledDateStart;
  DateTime? scheduledDateEnd;
  DateTime? dateStart;        // Giờ bắt đầu thực tế
  int? routeSequence;         // Thứ tự lộ trình từ Odoo optimal route
  int? routeId;               // ID của lộ trình fsm.route
  String? routeState;         // state của lộ trình ('draft', 'planned', 'done')

  // Worker
  int? personId;              // fsm.person.id
  String? personName;

  // Sync
  late bool isPendingSync;    // true = có thay đổi chưa push lên Odoo
  late DateTime lastSyncAt;
  
  // Rules
  bool requireSignature = false;

  FsmOrder();

  /// Tạo từ JSON trả về từ Odoo API.
  factory FsmOrder.fromJson(Map<String, dynamic> json, {Map<int, Map<String, dynamic>>? locationCoordinates}) {
    final order = FsmOrder()
      ..odooId = (json['id'] as int)
      ..name = (json['name'] as String?) ?? ''
      ..description = _strOrNull(json['description'])
      ..stageId = _idFromMany(json['stage_id'])
      ..stageName = _nameFromMany(json['stage_id'])
      ..stage = _parseStage(json['stage_id'])
      ..locationName = _nameFromMany(json['location_id'])
      ..locationAddress = _strOrNull(json['location_address']) ?? _nameFromMany(json['location_id'])
      ..partnerPhone = _strOrNull(json['phone'])
      ..scheduledDateStart = _dateOrNull(json['scheduled_date_start'])
      ..scheduledDateEnd = _dateOrNull(json['scheduled_date_end'])
      ..dateStart = _dateOrNull(json['date_start'])
      ..personId = _idOrNull(json['person_id'])
      ..personName = _nameFromMany(json['person_id'])
      ..routeSequence = json['route_sequence'] as int?
      ..routeId = _idOrNull(json['route_id'])
      ..routeState = json['route_state'] as String? // Sẽ được merge từ query riêng hoặc related field
      ..requireSignature = json['require_signature'] == true
      ..isPendingSync = false
      ..lastSyncAt = DateTime.now();

    
    // Parse location coordinates & additional data if available
    if (json['location_id'] != null && json['location_id'] is List && locationCoordinates != null) {
      final locationId = (json['location_id'] as List)[0] as int;
      final locationData = locationCoordinates[locationId];
      if (locationData != null) {
        order.locationLat = locationData['partner_latitude'] as double?;
        order.locationLng = locationData['partner_longitude'] as double?;
        order.partnerId = _idOrNull(locationData['partner_id']);
        order.partnerName = _nameFromMany(locationData['partner_id']);
        order.inventoryLocationId = _idOrNull(locationData['inventory_location_id']);
      }
    }
    
    // Parse warehouse
    order.warehouseId = _idOrNull(json['warehouse_id']);
    
    // Parse project
    order.projectId = _idOrNull(json['project_id']);
    order.projectTaskId = _idOrNull(json['project_task_id']);
    
    return order;
  }

  // ── Helpers ──────────────────────────────────────────────
  static String? _strOrNull(dynamic v) =>
      (v == null || v == false) ? null : v as String;

  static int _idFromMany(dynamic v) =>
      (v == null || v == false) ? 0 : (v as List)[0] as int;

  static int? _idOrNull(dynamic v) =>
      (v == null || v == false) ? null : (v as List)[0] as int;

  static String _nameFromMany(dynamic v) =>
      (v == null || v == false) ? '' : (v as List)[1] as String;

  static DateTime? _dateOrNull(dynamic v) =>
      (v == null || v == false) ? null : DateTime.tryParse(v as String);

  static FsmOrderStage _parseStage(dynamic stageField) {
    final name = _nameFromMany(stageField).toLowerCase();
    if (name.contains('progress') || name.contains('thực hiện')) {
      return FsmOrderStage.inProgress;
    } else if (name.contains('done') || name.contains('hoàn')) {
      return FsmOrderStage.done;
    } else if (name.contains('cancel') || name.contains('huỷ')) {
      return FsmOrderStage.cancelled;
    }
    return FsmOrderStage.draft;
  }
}

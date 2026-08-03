import 'package:isar_community/isar.dart';
import '../../orders/models/fsm_order.dart';

part 'route_stop.g.dart';

/// Trạng thái của một điểm dừng trong lộ trình.
enum StopStatus {
  pending, // Chưa đến
  current, // Đang đến / đang làm
  completed, // Đã xong
  skipped, // Bỏ qua
}

/// Một điểm dừng trong lộ trình ngày của Worker.
/// Mỗi điểm dừng tương ứng với một fsm.order.
@collection
class RouteStop {
  Id id = Isar.autoIncrement;

  /// ID của fsm.order tương ứng trên Odoo.
  @Index(unique: true)
  late int orderOdooId;

  late String orderName; // Mã đơn, VD: "WO/2024/001"
  String? partnerName; // Tên khách hàng
  String? locationName; // Tên địa điểm

  // Tọa độ GPS của địa điểm
  double? latitude;
  double? longitude;

  // Thứ tự trong lộ trình (0 = xuất phát)
  late int sequence;

  // Trạng thái của tuyến đường (draft, planned, done...)
  String? routeState;

  // Khoảng cách từ điểm trước (km)
  double? distanceFromPrev;

  // Thời gian ước tính đến điểm này (phút từ xuất phát)
  int? estimatedMinutes;

  @Enumerated(EnumType.name)
  late StopStatus status;

  // Timestamp thực tế
  DateTime? arrivedAt;
  DateTime? completedAt;

  RouteStop();

  /// Tạo từ FsmOrder để xây lộ trình.
  factory RouteStop.fromOrder(FsmOrder order, int sequence) {
    StopStatus status = StopStatus.pending;
    if (order.stage == FsmOrderStage.done) {
      status = StopStatus.completed;
    } else if (order.stage == FsmOrderStage.cancelled) {
      status = StopStatus.skipped;
    } else if (order.dateStart != null) {
      status = StopStatus.current;
    }

    return RouteStop()
      ..orderOdooId = order.odooId
      ..orderName = order.name
      ..sequence = sequence
      ..partnerName = order.partnerName
      ..locationName = order.locationName
      ..latitude = order.locationLat
      ..longitude = order.locationLng
      ..routeState = order.routeState
      ..status = status;
  }
}

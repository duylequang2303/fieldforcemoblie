import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/route_map/models/route_stop.dart';

FsmOrder _order({
  int odooId = 1,
  String name = 'WO/2026/001',
  FsmOrderStage stage = FsmOrderStage.draft,
  DateTime? dateStart,
}) {
  return FsmOrder()
    ..odooId = odooId
    ..name = name
    ..stageId = 1
    ..stageName = 'New'
    ..stage = stage
    ..dateStart = dateStart
    ..isPendingSync = false
    ..lastSyncAt = DateTime(2026, 8, 8);
}

void main() {
  group('RouteStop.fromOrder status mapping', () {
    test('should mark a not-started order as pending', () {
      final stop = RouteStop.fromOrder(_order(), 0);

      expect(stop.status, StopStatus.pending);
    });

    test('should mark an order with an actual start time as current', () {
      final stop = RouteStop.fromOrder(
        _order(dateStart: DateTime(2026, 8, 8, 9)),
        1,
      );

      expect(stop.status, StopStatus.current);
    });

    test('should mark a done order as completed', () {
      final stop = RouteStop.fromOrder(
        _order(stage: FsmOrderStage.done, dateStart: DateTime(2026, 8, 8, 9)),
        2,
      );

      expect(stop.status, StopStatus.completed);
    });

    test('should mark a cancelled order as skipped', () {
      final stop = RouteStop.fromOrder(
        _order(
          stage: FsmOrderStage.cancelled,
          dateStart: DateTime(2026, 8, 8, 9),
        ),
        3,
      );

      expect(stop.status, StopStatus.skipped);
    });

    test('should let the done stage win over an in-progress start time', () {
      final inProgress = RouteStop.fromOrder(
        _order(
          stage: FsmOrderStage.inProgress,
          dateStart: DateTime(2026, 8, 8, 9),
        ),
        4,
      );

      expect(inProgress.status, StopStatus.current);
    });
  });

  group('RouteStop.fromOrder field mapping', () {
    test('should copy order identity, location and schedule onto the stop', () {
      final scheduled = DateTime(2026, 8, 8, 8, 30);
      final order = _order(odooId: 55, name: 'WO/2026/055')
        ..partnerName = 'Công ty ABC'
        ..locationName = 'Nhà máy số 2'
        ..locationLat = 10.762622
        ..locationLng = 106.660172
        ..routeState = 'planned'
        ..scheduledDateStart = scheduled;

      final stop = RouteStop.fromOrder(order, 7);

      expect(stop.orderOdooId, 55);
      expect(stop.orderName, 'WO/2026/055');
      expect(stop.sequence, 7);
      expect(stop.partnerName, 'Công ty ABC');
      expect(stop.locationName, 'Nhà máy số 2');
      expect(stop.latitude, 10.762622);
      expect(stop.longitude, 106.660172);
      expect(stop.routeState, 'planned');
      expect(stop.scheduledDateStart, scheduled);
    });

    test('should leave route metrics and timestamps unset', () {
      final stop = RouteStop.fromOrder(_order(), 0);

      expect(stop.distanceFromPrev, isNull);
      expect(stop.estimatedMinutes, isNull);
      expect(stop.arrivedAt, isNull);
      expect(stop.completedAt, isNull);
    });

    test('should keep coordinates null when the order has no GPS data', () {
      final stop = RouteStop.fromOrder(_order(), 0);

      expect(stop.latitude, isNull);
      expect(stop.longitude, isNull);
    });
  });
}

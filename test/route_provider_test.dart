import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/route_map/providers/route_provider.dart';
import 'package:fieldforce_mobile/features/route_map/services/location_service.dart';

// Manual Mock cho LocationService với distanceBetween có thể cấu hình
class MockLocationService implements LocationService {
  final double _mockDistance;
  
  MockLocationService({double mockDistance = 1.0}) : _mockDistance = mockDistance;

  @override
  double distanceBetween(double startLatitude, double startLongitude, double endLatitude, double endLongitude) => _mockDistance;

  @override
  Future<Position> getCurrentPosition() async {
    return Position(
      longitude: 106.6297, latitude: 10.8231, timestamp: DateTime.now(),
      accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
      altitudeAccuracy: 0, headingAccuracy: 0
    );
  }

  @override
  Stream<Position> positionStream() => const Stream.empty();

  @override
  String buildNavigationUrl(double lat, double lng) => '';

  @override
  Future<bool> isLocationEnabled() async => true;

  @override
  Position? get lastPosition => null;

  @override
  Future<bool> requestPermission() async => true;

  // Các method không cần implement cho test này
  @override
  Future<bool> handlePermission() async => true;
}

void main() {
  group('RouteProvider - isAllowedToCheckIn', () {
    late RouteProvider provider;

    setUp(() {
      provider = RouteProvider(locationService: MockLocationService());
    });

    FsmOrder createMockOrder({
      required int odooId, 
      required int routeSeq, 
      String? routeState, 
      FsmOrderStage stage = FsmOrderStage.draft,
      double? locationLat,
      double? locationLng,
      DateTime? scheduledDateStart,
    }) {
      return FsmOrder()
        ..odooId = odooId
        ..name = 'WO-$odooId'
        ..routeSequence = routeSeq
        ..routeState = routeState
        ..stage = stage
        ..stageName = stage.name
        ..locationLat = locationLat
        ..locationLng = locationLng
        ..scheduledDateStart = scheduledDateStart;
    }

    test('Điểm dừng KHÔNG tồn tại trong lộ trình -> Cho phép (true)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'planned'),
      ];
      await provider.buildRoute(orders);

      expect(provider.isAllowedToCheckIn(99), isTrue);
    });

    test('Route đang ở trạng thái DRAFT (Nháp) -> Bỏ qua luật khoá -> Cho phép (true)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'draft', stage: FsmOrderStage.draft),
        createMockOrder(odooId: 2, routeSeq: 2, routeState: 'draft', stage: FsmOrderStage.draft),
      ];
      await provider.buildRoute(orders);

      // Điểm số 1 chưa làm, nhưng nhảy cóc vào điểm 2 luôn
      expect(provider.isAllowedToCheckIn(2), isTrue);
    });

    test('Route PLANNED và đi ĐÚNG thứ tự -> Cho phép (true)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'planned', stage: FsmOrderStage.done),
        createMockOrder(odooId: 2, routeSeq: 2, routeState: 'planned', stage: FsmOrderStage.draft),
      ];
      await provider.buildRoute(orders);

      // Điểm 1 đã xong (done), check-in điểm 2
      expect(provider.isAllowedToCheckIn(2), isTrue);
    });

    test('Route PLANNED nhưng đi SAI thứ tự (điểm trước chưa xong) -> KHÔNG cho phép (false)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'planned', stage: FsmOrderStage.draft),
        createMockOrder(odooId: 2, routeSeq: 2, routeState: 'planned', stage: FsmOrderStage.draft),
      ];
      await provider.buildRoute(orders);

      // Điểm 1 chưa xong, nhưng đòi check-in điểm 2
      expect(provider.isAllowedToCheckIn(2), isFalse);
    });

    test('Route PLANNED đi qua điểm bị HỦY (skipped) -> Vẫn cho phép điểm tiếp theo (true)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'planned', stage: FsmOrderStage.cancelled),
        createMockOrder(odooId: 2, routeSeq: 2, routeState: 'planned', stage: FsmOrderStage.draft),
      ];
      await provider.buildRoute(orders);

      // Điểm 1 đã huỷ, check-in điểm 2 là hợp lệ
      expect(provider.isAllowedToCheckIn(2), isTrue);
    });

    test('Route DONE -> Không cho phép check-in điểm nào (false)', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'done', stage: FsmOrderStage.done),
      ];
      await provider.buildRoute(orders);

      // Route đã hoàn thành, không cho phép check-in
      expect(provider.isAllowedToCheckIn(1), isFalse);
    });

    test('Worker ở gần location (< 500m) -> Cho phép check-in', () async {
      // Mock distance = 0.2km (200m) - dưới ngưỡng 500m
      final mockService = MockLocationService(mockDistance: 0.2);
      final provider = RouteProvider(locationService: mockService);

      final orders = [
        createMockOrder(
          odooId: 1, 
          routeSeq: 1, 
          routeState: 'planned', 
          stage: FsmOrderStage.draft,
          locationLat: 10.8231,
          locationLng: 106.6297,
        ),
      ];
      await provider.buildRoute(orders);

      // Worker ở gần location, cho phép check-in
      expect(provider.isAllowedToCheckIn(1, currentLocation: Position(latitude: 10.8231, longitude: 106.6297, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0)), isTrue);
    });

    test('Worker ở xa location (> 500m) -> KHÔNG cho phép check-in', () async {
      // Mock distance = 1.0km (1000m) - vượt ngưỡng 500m
      final mockService = MockLocationService(mockDistance: 1.0);
      final provider = RouteProvider(locationService: mockService);

      final orders = [
        createMockOrder(
          odooId: 1, 
          routeSeq: 1, 
          routeState: 'planned', 
          stage: FsmOrderStage.draft,
          locationLat: 10.8231,
          locationLng: 106.6297,
        ),
      ];
      await provider.buildRoute(orders);

      // Worker ở xa location, không cho phép check-in
      expect(provider.isAllowedToCheckIn(1, currentLocation: Position(latitude: 10.8231, longitude: 106.6297, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0)), isFalse);
    });

    test('Worker không có GPS location -> Bỏ qua GPS validation', () async {
      final orders = [
        createMockOrder(odooId: 1, routeSeq: 1, routeState: 'planned', stage: FsmOrderStage.draft),
      ];
      await provider.buildRoute(orders);

      // Không có GPS, bỏ qua GPS validation, chỉ check sequential logic
      expect(provider.isAllowedToCheckIn(1), isTrue);
    });
  });
}

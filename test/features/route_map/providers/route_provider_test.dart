import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/providers/orders_provider.dart';
import 'package:fieldforce_mobile/features/route_map/providers/route_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersProvider extends Mock implements OrdersProvider {}

void main() {
  group('RouteProvider.buildRoute - deduplication and validation', () {
    RouteProvider createProvider() {
      return RouteProvider(ordersProvider: MockOrdersProvider());
    }

    FsmOrder createOrder({
      required int odooId,
      String name = 'WO/2024/001',
      int? routeSequence,
      double? lat,
      double? lng,
    }) {
      return FsmOrder()
        ..odooId = odooId
        ..name = name
        ..stageId = 1
        ..stageName = 'Draft'
        ..stage = FsmOrderStage.draft
        ..isPendingSync = false
        ..lastSyncAt = DateTime.now()
        ..routeSequence = routeSequence
        ..locationLat = lat
        ..locationLng = lng;
    }

    test('duplicate odooId input produces unique RouteStop entries', () async {
      final provider = createProvider();
      final orders = [
        createOrder(odooId: 1, name: 'WO/2024/001', routeSequence: 1),
        createOrder(odooId: 1, name: 'WO/2024/001-DUP', routeSequence: 1),
        createOrder(odooId: 2, name: 'WO/2024/002', routeSequence: 2),
      ];

      await provider.buildRoute(orders);
      final stops = provider.stops;

      expect(stops.length, 2);
      expect(stops.map((s) => s.orderOdooId).toSet().length, stops.length);
      expect(stops.any((s) => s.orderOdooId == 1), isTrue);
      expect(stops.any((s) => s.orderOdooId == 2), isTrue);
    });

    test('invalid odooId values 0 and negative are skipped', () async {
      final provider = createProvider();
      final orders = [
        createOrder(odooId: 0, name: 'WO/INVALID/0'),
        createOrder(odooId: -1, name: 'WO/INVALID/-1'),
        createOrder(odooId: 1, name: 'WO/2024/001', routeSequence: 1),
      ];

      await provider.buildRoute(orders);
      final stops = provider.stops;

      expect(stops.length, 1);
      expect(stops.first.orderOdooId, 1);
    });

    test('empty orders list produces empty stops', () async {
      final provider = createProvider();
      await provider.buildRoute([]);
      expect(provider.stops, isEmpty);
    });

    test('buildRoute called twice in a row deduplicates each time', () async {
      final provider = createProvider();

      await provider.buildRoute([
        createOrder(odooId: 1, name: 'WO/2024/001', routeSequence: 1),
        createOrder(odooId: 1, name: 'WO/2024/001-DUP', routeSequence: 1),
      ]);
      expect(provider.stops.length, 1);

      await provider.buildRoute([
        createOrder(odooId: 2, name: 'WO/2024/002', routeSequence: 2),
        createOrder(odooId: 2, name: 'WO/2024/002-DUP', routeSequence: 2),
      ]);
      expect(provider.stops.length, 1);
      expect(provider.stops.first.orderOdooId, 2);
    });
  });
}

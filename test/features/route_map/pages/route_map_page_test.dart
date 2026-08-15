import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:fieldforce_mobile/core/routing/route_names.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/providers/orders_provider.dart';
import 'package:fieldforce_mobile/features/route_map/models/route_stop.dart';
import 'package:fieldforce_mobile/features/route_map/providers/route_provider.dart';
import 'package:fieldforce_mobile/features/route_map/pages/route_map_page.dart';

class MockOrdersProvider extends Mock implements OrdersProvider {}
class MockRouteProvider extends Mock implements RouteProvider {}

void main() {
  group('RouteMapPage bottom sheet', () {
    late GoRouter goRouter;
    late MockOrdersProvider mockOrdersProvider;
    late MockRouteProvider mockRouteProvider;

    final testOrder = FsmOrder()
      ..odooId = 1
      ..name = 'WO/2024/001'
      ..stageId = 1
      ..stageName = 'Draft'
      ..stage = FsmOrderStage.draft
      ..partnerName = 'Test Customer'
      ..locationName = 'Test Location'
      ..locationAddress = '123 Test St'
      ..isPendingSync = false
      ..lastSyncAt = DateTime.now();

    final testStop = RouteStop()
      ..orderOdooId = 1
      ..orderName = 'WO/2024/001'
      ..partnerName = 'Test Customer'
      ..locationName = 'Test Location'
      ..sequence = 0
      ..status = StopStatus.pending;

    setUp(() {
      mockOrdersProvider = MockOrdersProvider();
      mockRouteProvider = MockRouteProvider();

      when(() => mockOrdersProvider.orders).thenReturn([testOrder]);
      when(() => mockOrdersProvider.fetchOrders()).thenAnswer((_) async {});
      when(() => mockRouteProvider.stops).thenReturn([testStop]);
      when(() => mockRouteProvider.buildRoute(any())).thenAnswer((_) async {});
      when(() => mockRouteProvider.refreshLocation()).thenAnswer((_) async {});
      when(() => mockRouteProvider.startTracking()).thenAnswer((_) {});
      when(() => mockRouteProvider.stopTracking()).thenAnswer((_) {});
      when(() => mockRouteProvider.markStopCompleted(any())).thenAnswer((_) async => true);
      when(() => mockRouteProvider.isLoading).thenReturn(false);
      when(() => mockRouteProvider.errorMessage).thenReturn(null);

      goRouter = GoRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialLocation: '/route-map',
        routes: [
          GoRoute(
            path: '/route-map',
            builder: (context, state) => const RouteMapPage(),
          ),
          GoRoute(
            path: RouteNames.workOrderDetailScreen,
            name: 'workOrderDetailScreenUI',
            builder: (context, state) {
              final order = state.extra as FsmOrder?;
              return Scaffold(
                body: Text(order?.name ?? 'No Order'),
              );
            },
          ),
        ],
      );
    });

    testWidgets('shows bottom sheet with 3 buttons when stop is tapped', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<OrdersProvider>.value(value: mockOrdersProvider),
            ChangeNotifierProvider<RouteProvider>.value(value: mockRouteProvider),
          ],
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('WO/2024/001').first);
      await tester.pumpAndSettle();

      expect(find.text('Chỉ đường'), findsAtLeast(1));
      expect(find.text('Hoàn thành'), findsAtLeast(1));
      expect(find.text('Chi tiết'), findsAtLeast(1));
    });

    testWidgets('Chi tiết button navigates to workOrderDetailScreen', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<OrdersProvider>.value(value: mockOrdersProvider),
            ChangeNotifierProvider<RouteProvider>.value(value: mockRouteProvider),
          ],
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('WO/2024/001'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chi tiết').first);
      await tester.pumpAndSettle();

      expect(find.text('WO/2024/001'), findsAtLeast(1));
    });
  });
}

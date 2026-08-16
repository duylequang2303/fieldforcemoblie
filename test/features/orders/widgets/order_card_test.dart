import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldforce_mobile/core/routing/route_names.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/widgets/order_card.dart';

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  group('OrderCard', () {
    testWidgets('onTap navigates to workOrderDetailScreen with order extra', (tester) async {
      final observer = TestNavigatorObserver();
      final order = FsmOrder()
        ..odooId = 1
        ..name = 'WO/2024/001'
        ..stageId = 1
        ..stageName = 'Draft'
        ..stage = FsmOrderStage.draft
        ..isPendingSync = false
        ..lastSyncAt = DateTime.now();

      final goRouter = GoRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialLocation: '/',
        observers: [observer],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: OrderCard(order: order)),
          ),
          GoRoute(
            path: RouteNames.orderDetail,
            name: 'orderDetailUI',
            builder: (context, state) {
              final orderId = state.pathParameters['id'];
              return Scaffold(
                body: Text('Order Detail Screen ID: ${orderId ?? 'none'}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      await tester.tap(find.byType(OrderCard));
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes.length, greaterThanOrEqualTo(1));
      final lastPushed = observer.pushedRoutes.last;
      expect(lastPushed.settings.name, 'orderDetailUI');
      expect(find.text('Order Detail Screen ID: 1'), findsAtLeast(1));
    });

    testWidgets('displays order name and partner info', (tester) async {
      final order = FsmOrder()
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

      final goRouter = GoRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: OrderCard(order: order)),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));

      expect(find.text('WO/2024/001'), findsOneWidget);
      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);
    });
  });
}

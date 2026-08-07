import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'route_names.dart';

// Auth pages (Phase 6)
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/providers/auth_provider.dart';
// Orders pages (Phase 7)
import '../../features/orders/pages/orders_list_page.dart';
import '../../features/orders/pages/order_detail_page.dart';
import '../../features/orders/models/fsm_order.dart';
// Route Map page (Phase 8)
import '../../features/route_map/pages/route_map_page.dart';
// Stock pages (Phase 9)
import '../../features/stock/pages/scanner_page.dart';
import '../../features/stock/pages/stock_moves_page.dart';
// Timesheet page (Phase 10)
import '../../features/timesheet/pages/timesheet_page.dart';
// Expense page (Phase 11)
import '../../features/expense/pages/expense_page.dart';
// Work Order page (Phase 12)
import '../../features/work_order/pages/work_order_page.dart';
// UI Redesign screens
import '../../screens/schedule_screen.dart';
import '../../screens/work_order_detail_screen.dart';
// Schedule pages
import 'package:fieldforce_mobile/features/schedule/models/schedule_property.dart';
import '../../features/schedule/pages/schedule_properties_list_page.dart';
import '../../features/schedule/pages/schedule_property_detail_page.dart';
import '../../ui/shell/app_shell.dart';
// Settings page
import '../../features/settings/pages/settings_page.dart';

/// Router chính của ứng dụng.
/// Khai báo toàn bộ routes tại đây — không navigate trực tiếp bằng Navigator.push().
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Danh sách route names công khai (không cần auth)
final Set<String> _publicRoutes = {
  RouteNames.splash,
  RouteNames.login,
};

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  // Refresh router when AuthProvider notifies (handles session expiration)
  refreshListenable: AuthProvider.instance,
  // Redirect guard cho authentication
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final location = state.matchedLocation;
    final isPublic = _publicRoutes.contains(location);
    
    // Nếu chưa đăng nhập và truy cập route được bảo vệ -> redirect về login
    if (!isAuthenticated && !isPublic) {
      return RouteNames.login;
    }
    
    // Nếu đã đăng nhập nhưng đang ở splash/login -> redirect về shell schedule
    if (isAuthenticated && (location == RouteNames.splash || location == RouteNames.login)) {
      return RouteNames.shellSchedule;
    }
    
    return null; // Không redirect
  },
  routes: [
    // Shell navigation với 3 tab (Schedule, Properties, Settings)
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state, navigationShell) {
        return NoTransitionPage(
          child: AppShell(navigationShell: navigationShell),
        );
      },
      branches: [
        // Branch 0: Schedule - màn list "Đơn Dịch Vụ" nguyên vẹn
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.shellSchedule,
              name: 'shellSchedule',
              pageBuilder: (context, state) {
                return const NoTransitionPage(child: ScheduleScreen());
              },
            ),
          ],
        ),
        // Branch 1: Properties - placeholder
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.shellProperties,
              name: 'shellProperties',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: SchedulePropertiesListPage(),
                );
              },
            ),
          ],
        ),
        // Branch 2: Settings - placeholder
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.shellSettings,
              name: 'shellSettings',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: SettingsPage(),
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.orders,
      name: 'orders',
      builder: (context, state) => const OrdersListPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'orderDetail',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            return OrderDetailPage(orderId: int.tryParse(idStr) ?? 0);
          },
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.routeMap,
      name: 'routeMap',
      builder: (context, state) => const RouteMapPage(),
    ),
    GoRoute(
      path: '${RouteNames.scanner}/:orderId',
      name: 'scanner',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '0';
        return ScannerPage(orderId: int.tryParse(orderId) ?? 0);
      },
    ),
    GoRoute(
      path: '/stock-moves/:orderId',
      name: 'stockMoves',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '0';
        return StockMovesPage(orderId: int.tryParse(orderId) ?? 0);
      },
    ),
    GoRoute(
      path: '/work-order/:orderId',
      name: 'workOrder',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '0';
        return WorkOrderPage(orderId: int.tryParse(orderId) ?? 0);
      },
    ),
    GoRoute(
      path: '/timesheet/:orderId',
      name: 'timesheet',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '0';
        return TimesheetPage(orderId: int.tryParse(orderId) ?? 0);
      },
    ),
    GoRoute(
      path: '/expense/:orderId',
      name: 'expense',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '0';
        return ExpensePage(orderId: int.tryParse(orderId) ?? 0);
      },
    ),
    // UI Redesign Routes
    GoRoute(
      path: RouteNames.scheduleScreen,
      name: 'scheduleScreenUI',
      builder: (context, state) => const ScheduleScreen(),
    ),
    GoRoute(
      path: RouteNames.workOrderDetailScreen,
      name: 'workOrderDetailScreenUI',
      builder: (context, state) {
        final order = state.extra as FsmOrder?;
        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Error: Order not provided')),
          );
        }
        return WorkOrderDetailScreen(order: order);
      },
    ),
    // Old schedule routes removed - using ScheduleScreen and SchedulePropertiesListPage via AppShell
    GoRoute(
      path: '/schedule-properties/:id',
      name: 'schedulePropertyDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '0';
        final extra = state.extra;
        if (extra is ScheduleProperty) {
          return SchedulePropertyDetailPage(property: extra);
        }
        return SchedulePropertyDetailPage(
          property: ScheduleProperty.create(
            odooId: int.tryParse(id) ?? 0,
            address: 'Property $id',
            suburb: '',
            postcode: '',
            ownerName: '',
          ),
        );
      },
    ),

  ],
);

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/orders/providers/orders_provider.dart';
import '../features/route_map/providers/route_provider.dart';
import '../features/stock/providers/stock_provider.dart';
import '../features/timesheet/providers/timesheet_provider.dart';
import '../features/expense/providers/expense_provider.dart';
import '../features/work_order/providers/work_order_provider.dart';

/// Đăng ký toàn bộ Provider cho app.
/// Thêm provider mới vào đây khi tạo feature mới.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Phase 6: Auth ✅
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Phase 7: Orders ✅
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        // Phase 8: Route Map ✅
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        // Phase 9: Stock ✅
        ChangeNotifierProvider(create: (_) => StockProvider()),
        // Phase 10: Timesheet ✅
        ChangeNotifierProvider(create: (_) => TimesheetProvider()),
        // Phase 11: Expense ✅
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        // Phase 12: Work Order ✅
        ChangeNotifierProvider(create: (_) => WorkOrderProvider()),
      ],
      child: child,
    );
  }
}

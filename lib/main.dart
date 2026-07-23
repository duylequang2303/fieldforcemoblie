import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/database/isar_service.dart';
// Isar schemas — import generated .g.dart files
import 'features/auth/models/user_session.dart';
import 'features/orders/models/fsm_order.dart';
import 'features/route_map/models/route_stop.dart';
import 'features/stock/models/product.dart';
import 'features/stock/models/stock_move.dart';
import 'features/timesheet/models/timesheet_entry.dart';
import 'features/expense/models/expense.dart';
import 'features/work_order/models/work_report.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chỉ cho phép xoay dọc (portrait) trên thiết bị di động
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Tạm bỏ qua Khởi tạo Isar DB trên web (Isar 3.x không hỗ trợ web).
  // Chạy init IsarService.instance.init chỉ trên mobile/desktop.
  if (!kIsWeb) {
    try {
      await IsarService.instance.init([
        UserSessionSchema,
        FsmOrderSchema,
        RouteStopSchema,
        ProductSchema,
        StockMoveSchema,
        TimesheetEntrySchema,
        ExpenseSchema,
        WorkReportSchema,
      ]);
    } catch (e) {
      debugPrint('Init Isar Error: $e');
    }
  }

  runApp(const App());
}

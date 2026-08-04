import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/database/isar_service.dart';
import 'core/locale/locale_service.dart';
import 'core/database/sync_manager.dart';
// Isar schemas — import generated .g.dart files
import 'features/auth/models/user_session.dart';
import 'features/orders/models/fsm_order.dart';
import 'features/orders/models/checklist_template.dart';
import 'features/route_map/models/route_stop.dart';
import 'features/stock/models/product.dart';
import 'features/stock/models/stock_move.dart';
import 'features/timesheet/models/timesheet_entry.dart';
import 'features/expense/models/expense.dart';
import 'features/work_order/models/work_report.dart';
import 'features/orders/services/orders_service.dart';
import 'features/orders/services/recurring_notification_service.dart';
import 'features/timesheet/services/timesheet_service.dart';
import 'features/expense/services/expense_service.dart';
import 'features/stock/services/stock_service.dart';
import 'features/work_order/services/work_order_service.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Khởi tạo locale/date formatting mặc định để tránh lỗi Intl.
  const defaultLocale = 'vi_VN';
  Intl.defaultLocale = defaultLocale;
  await initializeDateFormatting(defaultLocale, null);
  LocaleService.instance.setLocale(defaultLocale);

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
        ChecklistTemplateSchema,
        RouteStopSchema,
        ProductSchema,
        StockMoveSchema,
        TimesheetEntrySchema,
        ExpenseSchema,
        WorkReportSchema,
      ]);
      // Đăng ký các sync handlers cho offline sync sau khi Isar khởi tạo thành công
      SyncManager.instance
          .registerSyncHandler(OrdersService.instance.syncPending);
      // Lưu ý: cờ "đã thực hiện kỳ" (completeOrder) được push qua OrdersService.syncPending
      // nên KHÔNG cần đăng ký sync handler riêng cho recurring.
      SyncManager.instance
          .registerSyncHandler(TimesheetService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(ExpenseService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(StockService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(WorkOrderService.instance.syncPending);

      // Bắt đầu lắng nghe trạng thái mạng để tự động sync
      SyncManager.instance.startListening();
      await SyncManager.instance.startAutoSync();

      // Khởi tạo + schedule local notification 8h sáng hằng ngày
      // (dữ liệu đơn định kỳ hôm nay được tính trong service, KHÔNG chứa logic ở UI)
      try {
        final cachedOrders = await OrdersService.instance.loadCachedOrders();
        await RecurringNotificationService.instance
            .initializeAndScheduleDaily(cachedOrders);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Init Recurring Notification Error: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Init Isar Error: $e');
      }
    }
  }

  runApp(const App());
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/database/isar_service.dart';
import 'core/locale/locale_service.dart';
import 'core/database/sync_manager.dart';
import 'core/api/api_exception.dart';
import 'core/utils/logger.dart';
// Isar schemas — import generated .g.dart files
import 'features/auth/models/user_session.dart';
import 'features/orders/models/fsm_order.dart';
import 'features/orders/models/fsm_recurring.dart';
import 'features/orders/models/fsm_frequency_set.dart';
import 'features/route_map/models/route_stop.dart';
import 'features/stock/models/product.dart';
import 'features/stock/models/stock_move.dart';
import 'features/timesheet/models/timesheet_entry.dart';
import 'features/expense/models/expense.dart';
import 'features/work_order/models/work_report.dart';
import 'features/orders/services/orders_service.dart';
import 'features/orders/services/recurring_service.dart';
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
  // Khởi tạo và thiết lập Locale đã lưu từ bộ nhớ (Fix Thread #1)
  await LocaleService.instance.init();

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
        FsmRecurringSchema,
        FsmFrequencySetSchema,
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
      SyncManager.instance
          .registerSyncHandler(TimesheetService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(ExpenseService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(StockService.instance.syncPending);
      SyncManager.instance
          .registerSyncHandler(WorkOrderService.instance.syncPending);

      // Đăng ký các sync handlers cho recurring lặp định kỳ
      SyncManager.instance.registerSyncHandler(() async {
        try {
          await RecurringService.instance.fetchRecurringRules();
          await RecurringService.instance.generateOfflineInstances();
          // Reschedule notifications for upcoming recurring orders (skip on Linux)
          if (!kIsWeb && !Platform.isLinux) {
            await RecurringNotificationService.instance
                .rescheduleAllRecurringReminders();
          }
        } on OdooApiException catch (e) {
          logger.e('Recurring sync handler failed: Odoo API Error', error: e);
        } catch (e, stackTrace) {
          logger.e('Recurring sync handler failed: Unexpected Error',
              error: e, stackTrace: stackTrace);
        }
      });

      // Khởi tạo recurring notification service (skip on Linux - zonedSchedule not supported)
      if (!kIsWeb && !Platform.isLinux) {
        await RecurringNotificationService.instance.init();
        // Schedule recurring reminders even on offline startup
        await RecurringNotificationService.instance
            .rescheduleAllRecurringReminders();
      }

      // Bắt đầu lắng nghe trạng thái mạng để tự động sync
      await SyncManager.instance.startListening();
      await SyncManager.instance.startAutoSync();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Init Isar Error: $e');
      }
    }
  }

  runApp(const App());
}

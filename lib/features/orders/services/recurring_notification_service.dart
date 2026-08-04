import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';
import 'recurring_service.dart';

/// Service phụ trách local notification cho công việc định kỳ.
/// Schedule 8h sáng hằng ngày + hỗ trợ nút "Test Notify".
class RecurringNotificationService {
  RecurringNotificationService._();
  static final RecurringNotificationService instance =
      RecurringNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _recurringDailyId = 1001;
  static const int _testNotifyId = 1002;

  bool _initialized = false;

  /// Khởi tạo plugin + tz database. Gọi 1 lần ở main().
  Future<void> init() async {
    if (_initialized) return;

    // TZ database cho Asia/Saigon (UTC+7).
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: darwinSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
    logger.i('RecurringNotificationService initialized');
  }

  /// Request quyền notification trên Android 13+.
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Khởi tạo + xin quyền + schedule notification 8h sáng hằng ngày cho 7 ngày tới.
  /// Dữ liệu đơn kỳ các ngày được tính qua [RecurringService] từ danh sách orders.
  Future<void> initializeAndScheduleDaily(List<FsmOrder> orders) async {
    await init();
    await requestPermissions();

    final recurring = RecurringService.fromFsmOrders(orders);

    // Cancel dynamic scheduled daily notifications for the next 7 days
    for (int i = 0; i < 7; i++) {
      await _plugin.cancel(_recurringDailyId + i);
    }

    final now = DateTime.now();
    final nowTz = tz.TZDateTime.from(now, tz.local);

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final scheduleAt = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        8,
        0,
        0,
      );

      // Nếu lịch hẹn ở quá khứ (ví dụ: ngày hôm nay i=0 nhưng đã quá 8h sáng), skip
      if (scheduleAt.isBefore(nowTz)) {
        continue;
      }

      final dueOnDate = RecurringService.filterDueToday(recurring, date);
      // Chỉ schedule nếu có công việc cần nhắc nhở
      if (dueOnDate.isNotEmpty) {
        final content = RecurringService.buildNotificationContent(dueOnDate);
        
        const androidDetails = AndroidNotificationDetails(
          'recurring_daily',
          'Công việc định kỳ',
          channelDescription: 'Nhắc nhở 8h sáng công việc định kỳ đến hạn',
          importance: Importance.high,
          priority: Priority.high,
        );
        const iosDetails = DarwinNotificationDetails();
        const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

        await _plugin.zonedSchedule(
          _recurringDailyId + i,
          content.title,
          content.body,
          scheduleAt,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        logger.i('Scheduled daily 8:00 notification for $date (dayOffset=$i, count=${content.count})');
      }
    }
  }

  /// Hiển thị ngay 1 notification để test nhanh (nút "Test Notify").
  /// Nhận content đã build từ [RecurringService.buildNotificationContent].
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      logger.w('RecurringNotificationService: not initialized, skip test');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'recurring_test',
      'Test công việc định kỳ',
      channelDescription: 'Test nhanh notification định kỳ',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      _testNotifyId,
      title,
      body,
      details,
    );
    logger.i('Test notification shown: $title');
  }

  /// Xóa toàn bộ notification định kỳ (dùng khi logout hoặc cần reset).
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
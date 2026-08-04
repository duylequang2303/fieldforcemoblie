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

  /// Khởi tạo + xin quyền + schedule notification 8h sáng hằng ngày.
  /// Dữ liệu đơn kỳ hôm nay được tính qua [RecurringService] từ danh sách orders.
  /// main() chỉ gọi hàm này 1 lần — KHÔNG chứa logic trong widget.
  Future<void> initializeAndScheduleDaily(List<FsmOrder> orders) async {
    await init();
    await requestPermissions();

    final recurring = RecurringService.fromFsmOrders(orders);
    final dueToday = RecurringService.filterDueToday(recurring, DateTime.now());
    final content = RecurringService.buildNotificationContent(dueToday);

    await scheduleDaily8am(
      count: content.count,
      title: content.title,
      body: content.body,
    );
  }

  /// Schedule notification lặp lại 8h sáng hằng ngày.
  /// Nội dung hiển thị là tổng đơn định kỳ hôm nay (đã được tính trước).
  Future<void> scheduleDaily8am({
    required int count,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      logger.w('RecurringNotificationService: not initialized, skip schedule');
      return;
    }

    // Xây thời điểm 08:00 hôm nay theo local tz.
    final now = DateTime.now();
    var next8am = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
      0,
      0,
    );
    final nowTz = tz.TZDateTime.from(now, tz.local);
    // Nếu đã qua 8h hôm nay → dời sang 8h ngày mai.
    if (next8am.isBefore(nowTz)) {
      next8am = next8am.add(const Duration(days: 1));
    }
    final scheduleAt = next8am;

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
      _recurringDailyId,
      title,
      body,
      scheduleAt,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // lặp lại hằng ngày
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    logger.i('Scheduled daily 8:00 notification (count=$count)');
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
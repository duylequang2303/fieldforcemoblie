/// Tên các route trong ứng dụng.
/// Sử dụng các hằng số này khi navigate bằng go_router.
/// Ví dụ: context.go(RouteNames.orders)
abstract final class RouteNames {
  // Auth
  static const String splash = '/';
  static const String login = '/login';

  // Home / Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';

  // Route Map
  static const String routeMap = '/route-map';

  // Stock / Barcode
  static const String scanner = '/scanner';
  static const String stockMoves = '/stock-moves/:orderId';

  // Work Order (nghiệm thu + chữ ký)
  static const String workOrder = '/work-order/:orderId';

  // Timesheet
  static const String timesheet = '/timesheet/:orderId';

  // Expense
  static const String expense = '/expense/:orderId';

  // UI Redesign Routes
  static const String scheduleScreen = '/schedule-screen';
  static const String workOrderDetailScreen = '/work-order-detail-screen';

  // Shell navigation routes
  static const String shellSchedule = '/shell/schedule';
  static const String shellProperties = '/shell/properties';
  static const String shellSettings = '/shell/settings';
}

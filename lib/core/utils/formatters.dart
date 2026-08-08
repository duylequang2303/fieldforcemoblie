import 'package:intl/intl.dart';

import '../locale/locale_service.dart';

/// Các hàm format ngày/giờ dùng chung toàn app.
///
/// Gom về một nơi để tránh mỗi feature tự viết lại pattern `dd/MM/yyyy`,
/// `yyyy-MM-dd` hay chuỗi `padLeft` thủ công.
class AppDateFormat {
  const AppDateFormat._();

  static const String _viLocale = 'vi';

  /// `dd/MM/yyyy` — hiển thị ngày cho người dùng.
  static String date(DateTime date) =>
      DateFormat('dd/MM/yyyy', _viLocale).format(date);

  /// `dd/MM/yyyy HH:mm` theo giờ máy — hiển thị ngày giờ cho người dùng.
  static String dateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm', _viLocale).format(dt.toLocal());

  /// `HH:mm` theo giờ máy — hiển thị giờ trong ngày.
  static String time(DateTime dt) =>
      DateFormat('HH:mm', _viLocale).format(dt.toLocal());

  /// `yyyy-MM-dd` — định dạng field `Date` của Odoo.
  static String odooDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// `yyyy-MM-dd HH:mm:ss` theo UTC — định dạng field `Datetime` của Odoo.
  /// Odoo lưu Datetime theo UTC nên phải convert local → UTC trước khi gửi.
  static String odooDateTimeUtc(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toUtc());
}

/// Các hàm format số/tiền tệ dùng chung toàn app.
class AppNumberFormat {
  const AppNumberFormat._();

  /// Tiền tệ VND theo locale hiện tại, không phần thập phân.
  static NumberFormat get currency => NumberFormat.currency(
        locale: LocaleService.instance.currentLocale,
        symbol: '₫',
        decimalDigits: 0,
      );

  /// Format tiền tệ VND thành chuỗi.
  static String money(num amount) => currency.format(amount);

  /// Bỏ phần thập phân khi số là số nguyên: `2` thay vì `2.0`, `2.5` giữ nguyên.
  static String quantity(double value, {int decimalDigits = 1}) =>
      value.toStringAsFixed(value == value.truncateToDouble() ? 0 : decimalDigits);
}

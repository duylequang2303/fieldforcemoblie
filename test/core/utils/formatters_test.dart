import 'package:fieldforce_mobile/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('AppDateFormat', () {
    test('should format date as dd/MM/yyyy with zero padding', () {
      expect(AppDateFormat.date(DateTime(2026, 3, 5)), '05/03/2026');
    });

    test('should format time as HH:mm with zero padding', () {
      expect(AppDateFormat.time(DateTime(2026, 3, 5, 7, 9)), '07:09');
    });

    test('should format Odoo Date field as yyyy-MM-dd', () {
      expect(AppDateFormat.odooDate(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('should convert to UTC for Odoo Datetime field', () {
      final dt = DateTime.utc(2026, 3, 5, 8, 7, 6).toLocal();
      expect(AppDateFormat.odooDateTimeUtc(dt), '2026-03-05 08:07:06');
    });
  });

  group('AppNumberFormat', () {
    test('should drop decimals for whole quantities', () {
      expect(AppNumberFormat.quantity(2), '2');
    });

    test('should keep one decimal for fractional quantities', () {
      expect(AppNumberFormat.quantity(2.5), '2.5');
    });
  });
}

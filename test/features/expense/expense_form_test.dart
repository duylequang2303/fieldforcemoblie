import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/expense/widgets/expense_form.dart';

void main() {
  group('parseAmount', () {
    test('should return null for empty or whitespace input', () {
      expect(parseAmount(null), isNull);
      expect(parseAmount(''), isNull);
      expect(parseAmount('   '), isNull);
    });

    test('should parse plain numeric strings correctly', () {
      expect(parseAmount('100000'), 100000.0);
      expect(parseAmount('500'), 500.0);
      expect(parseAmount('1500000'), 1500000.0);
    });

    test('should handle dot as thousand separator', () {
      expect(parseAmount('1.000'), 1000.0);
      expect(parseAmount('1.000.000'), 1000000.0);
      expect(parseAmount('12.500.000'), 12500000.0);
    });

    test('should handle space as thousand separator', () {
      expect(parseAmount('1 000'), 1000.0);
      expect(parseAmount('1 000 000'), 1000000.0);
      expect(parseAmount('12 500 000'), 12500000.0);
    });

    test('should handle comma as thousand separator', () {
      expect(parseAmount('1,000'), 1000.0);
      expect(parseAmount('1,000,000'), 1000000.0);
    });

    test('should strip all mixed separators', () {
      expect(parseAmount('1.000.000'), 1000000.0);
      expect(parseAmount('1 000 000'), 1000000.0);
      expect(parseAmount('1,000,000'), 1000000.0);
    });

    test('should parse negative amounts', () {
      expect(parseAmount('-1000'), -1000.0);
      expect(parseAmount('-1.000'), -1000.0);
    });

    test('should return null for non-numeric input', () {
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('N/A'), isNull);
      expect(parseAmount('---'), isNull);
    });

    test('should trim whitespace before parsing', () {
      expect(parseAmount('  100000  '), 100000.0);
      expect(parseAmount('  1.000  '), 1000.0);
    });
  });
}

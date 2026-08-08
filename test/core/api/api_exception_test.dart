import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';

void main() {
  group('OdooApiException hierarchy', () {
    test('should expose message on every subtype', () {
      const exceptions = <OdooApiException>[
        OdooAuthException('auth'),
        OdooConnectionException('connection'),
        OdooBusinessException('business'),
        StockPartialAssignException('stock'),
        OdooNotFoundException('not found'),
        OdooUnknownException('unknown'),
      ];

      expect(
        exceptions.map((e) => e.message),
        ['auth', 'connection', 'business', 'stock', 'not found', 'unknown'],
      );
    });

    test('should implement Exception for every subtype', () {
      expect(const OdooAuthException('x'), isA<Exception>());
      expect(const OdooConnectionException('x'), isA<Exception>());
      expect(const OdooBusinessException('x'), isA<Exception>());
      expect(const StockPartialAssignException('x'), isA<Exception>());
      expect(const OdooNotFoundException('x'), isA<Exception>());
      expect(const OdooUnknownException('x'), isA<Exception>());
    });

    test('should prefix toString with the runtime type', () {
      expect(
        const OdooAuthException('Sai mật khẩu').toString(),
        'OdooAuthException: Sai mật khẩu',
      );
      expect(
        const StockPartialAssignException('Thiếu tồn kho').toString(),
        'StockPartialAssignException: Thiếu tồn kho',
      );
    });

    test('should let callers catch any subtype as OdooApiException', () {
      OdooApiException caught = const OdooUnknownException('not thrown');
      try {
        throw const OdooBusinessException('validation failed');
      } on OdooApiException catch (e) {
        caught = e;
      }

      expect(caught, isA<OdooBusinessException>());
      expect(caught.message, 'validation failed');
    });

    test('should not treat StockPartialAssignException as a generic business error', () {
      expect(
        const StockPartialAssignException('x'),
        isNot(isA<OdooBusinessException>()),
      );
    });
  });
}

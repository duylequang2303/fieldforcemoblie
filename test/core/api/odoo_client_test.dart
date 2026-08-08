import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/api/odoo_client.dart';

void main() {
  tearDown(OdooApiClient.resetInstance);

  group('OdooApiClient lifecycle', () {
    test('should return the same singleton instance', () {
      expect(OdooApiClient.instance, same(OdooApiClient.instance));
    });

    test('should not be initialized before initialize() is called', () {
      expect(OdooApiClient.instance.isInitialized, isFalse);
    });

    test('should be initialized after initialize()', () {
      OdooApiClient.instance.initialize('https://odoo.example.com');

      expect(OdooApiClient.instance.isInitialized, isTrue);
      expect(OdooApiClient.instance.client, isNotNull);
    });

    test('should keep the singleton but drop the client on dispose()', () {
      final client = OdooApiClient.instance;
      client.initialize('https://odoo.example.com');

      client.dispose();

      expect(client.isInitialized, isFalse);
      expect(OdooApiClient.instance, same(client));
    });

    test('should recreate the singleton on resetInstance()', () {
      final first = OdooApiClient.instance;
      first.initialize('https://odoo.example.com');

      OdooApiClient.resetInstance();

      expect(OdooApiClient.instance, isNot(same(first)));
      expect(OdooApiClient.instance.isInitialized, isFalse);
    });
  });

  group('OdooApiClient.client', () {
    test('should throw OdooConnectionException when not initialized', () {
      expect(
        () => OdooApiClient.instance.client,
        throwsA(isA<OdooConnectionException>().having(
          (e) => e.message,
          'message',
          contains('chưa được khởi tạo'),
        )),
      );
    });
  });

  group('OdooApiClient.callKw', () {
    test('should wrap the uninitialized error as OdooConnectionException', () async {
      await expectLater(
        OdooApiClient.instance.callKw(
          model: 'fsm.order',
          method: 'search_read',
          args: const [],
        ),
        throwsA(isA<OdooConnectionException>()),
      );
    });

    test('should wrap transport failures as OdooConnectionException', () async {
      // Loopback port 1 is closed, so the RPC fails locally without any
      // outbound network traffic.
      OdooApiClient.instance.initialize('http://127.0.0.1:1');

      await expectLater(
        OdooApiClient.instance.callKw(
          model: 'fsm.order',
          method: 'search_read',
          args: const [],
        ),
        throwsA(isA<OdooConnectionException>()),
      );
    });
  });
}

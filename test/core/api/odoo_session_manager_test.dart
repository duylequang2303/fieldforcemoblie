import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/api/odoo_session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OdooSessionManager server URL validation', () {
    test('should reject cleartext http server URL on authenticate', () async {
      await expectLater(
        OdooSessionManager.instance.authenticate(
          serverUrl: 'http://odoo.example.com',
          database: 'db',
          username: 'user',
          password: 'pwd',
        ),
        throwsA(isA<OdooConnectionException>()),
      );
    });

    test('should reject malformed server URL on authenticate', () async {
      await expectLater(
        OdooSessionManager.instance.authenticate(
          serverUrl: 'not-a-url',
          database: 'db',
          username: 'user',
          password: 'pwd',
        ),
        throwsA(isA<OdooConnectionException>()),
      );
    });

    test('should refuse restoring a session from a http server URL', () async {
      final restored = await OdooSessionManager.instance.restoreSession(
        serverUrl: 'http://odoo.example.com',
        database: 'db',
        sessionId: 'session',
        savedUserId: 1,
        username: 'user',
        serverVersion: '19',
      );
      expect(restored, isFalse);
    });
  });
}

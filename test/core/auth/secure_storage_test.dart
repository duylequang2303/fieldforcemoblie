import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fieldforce_mobile/core/auth/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService.instance;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<void> saveDefaultSession({int? employeeId = 7}) {
    return storage.saveSession(
      serverUrl: 'https://odoo.example.com',
      database: 'fsm',
      username: 'worker1@gmail.com',
      sessionId: 'sess-123',
      userId: 5,
      locale: 'en_US',
      serverVersion: '17',
      employeeId: employeeId,
    );
  }

  group('SecureStorageService.saveSession', () {
    test('should store every session field as a string', () async {
      await saveDefaultSession();

      final session = await storage.loadSession();

      expect(session['serverUrl'], 'https://odoo.example.com');
      expect(session['database'], 'fsm');
      expect(session['username'], 'worker1@gmail.com');
      expect(session['sessionId'], 'sess-123');
      expect(session['userId'], '5');
      expect(session['locale'], 'en_US');
      expect(session['serverVersion'], '17');
      expect(session['employeeId'], '7');
    });

    test('should apply default locale and server version', () async {
      await storage.saveSession(
        serverUrl: 'https://odoo.example.com',
        database: 'fsm',
        username: 'worker1@gmail.com',
        sessionId: 'sess-123',
        userId: 5,
      );

      final session = await storage.loadSession();

      expect(session['locale'], 'vi_VN');
      expect(session['serverVersion'], '19');
    });

    test('should drop a stale employee id when saving without one', () async {
      await saveDefaultSession();
      await saveDefaultSession(employeeId: null);

      final session = await storage.loadSession();

      expect(session['employeeId'], isNull);
    });

    test('should purge a legacy stored password', () async {
      FlutterSecureStorage.setMockInitialValues({'odoo_password': 'secret'});

      await saveDefaultSession();

      const raw = FlutterSecureStorage();
      expect(await raw.read(key: 'odoo_password'), isNull);
    });

    test('should never persist a password key', () async {
      await saveDefaultSession();

      const raw = FlutterSecureStorage();
      final all = await raw.readAll();

      expect(all.keys, isNot(contains('odoo_password')));
      expect(all.values, isNot(contains('secret')));
    });
  });

  group('SecureStorageService.removeLegacyPassword', () {
    test('should delete the legacy password key', () async {
      FlutterSecureStorage.setMockInitialValues({
        'odoo_password': 'secret',
        'odoo_session_id': 'sess-123',
      });

      await storage.removeLegacyPassword();

      const raw = FlutterSecureStorage();
      expect(await raw.read(key: 'odoo_password'), isNull);
      expect(await raw.read(key: 'odoo_session_id'), 'sess-123');
    });
  });

  group('SecureStorageService.loadSession', () {
    test('should return null values when nothing is stored', () async {
      final session = await storage.loadSession();

      expect(session.keys, hasLength(8));
      expect(session.values.every((v) => v == null), isTrue);
    });
  });

  group('SecureStorageService.loadSavedCredentials', () {
    test('should return only the login form fields', () async {
      await saveDefaultSession();

      final creds = await storage.loadSavedCredentials();

      expect(creds.keys.toSet(), {'serverUrl', 'database', 'username'});
      expect(creds['serverUrl'], 'https://odoo.example.com');
      expect(creds['database'], 'fsm');
      expect(creds['username'], 'worker1@gmail.com');
    });
  });

  group('SecureStorageService.clearSession', () {
    test('should remove all session keys including the legacy password', () async {
      FlutterSecureStorage.setMockInitialValues({'odoo_password': 'secret'});
      await saveDefaultSession();

      await storage.clearSession();

      final session = await storage.loadSession();
      expect(session.values.every((v) => v == null), isTrue);

      const raw = FlutterSecureStorage();
      expect(await raw.read(key: 'odoo_password'), isNull);
    });

    test('should keep the biometric preference untouched', () async {
      await saveDefaultSession();
      await storage.setBiometricEnabled(enabled: true);

      await storage.clearSession();

      expect(await storage.isBiometricEnabled, isTrue);
    });
  });

  group('SecureStorageService.hasSavedSession', () {
    test('should be false when nothing is stored', () async {
      expect(await storage.hasSavedSession, isFalse);
    });

    test('should be true once a full session is saved', () async {
      await saveDefaultSession();

      expect(await storage.hasSavedSession, isTrue);
    });

    test('should be false when the server version is missing', () async {
      FlutterSecureStorage.setMockInitialValues({
        'odoo_session_id': 'sess-123',
      });

      expect(await storage.hasSavedSession, isFalse);
    });

    test('should be false when the stored session id is empty', () async {
      FlutterSecureStorage.setMockInitialValues({
        'odoo_session_id': '',
        'odoo_server_version': '17',
      });

      expect(await storage.hasSavedSession, isFalse);
    });

    test('should be false after clearing the session', () async {
      await saveDefaultSession();
      await storage.clearSession();

      expect(await storage.hasSavedSession, isFalse);
    });
  });

  group('SecureStorageService biometric flag', () {
    test('should default to disabled', () async {
      expect(await storage.isBiometricEnabled, isFalse);
    });

    test('should round-trip enabling and disabling', () async {
      await storage.setBiometricEnabled(enabled: true);
      expect(await storage.isBiometricEnabled, isTrue);

      await storage.setBiometricEnabled(enabled: false);
      expect(await storage.isBiometricEnabled, isFalse);
    });
  });

  group('SecureStorageService write serialization', () {
    test('should apply concurrent writes without interleaving', () async {
      await Future.wait([
        storage.saveSession(
          serverUrl: 'https://a.example.com',
          database: 'a',
          username: 'a',
          sessionId: 'sess-a',
          userId: 1,
          employeeId: 1,
        ),
        storage.saveSession(
          serverUrl: 'https://b.example.com',
          database: 'b',
          username: 'b',
          sessionId: 'sess-b',
          userId: 2,
          employeeId: 2,
        ),
      ]);

      final session = await storage.loadSession();
      final suffix = session['sessionId'] == 'sess-a' ? 'a' : 'b';

      expect(session['serverUrl'], 'https://$suffix.example.com');
      expect(session['database'], suffix);
      expect(session['username'], suffix);
      expect(session['userId'], suffix == 'a' ? '1' : '2');
      expect(session['employeeId'], suffix == 'a' ? '1' : '2');
    });
  });
}

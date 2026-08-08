import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const raw = FlutterSecureStorage();
  final repository = SettingsRepository.instance;

  // Legacy keys written by older app versions into secure storage.
  const legacyWifiOnly = 'ff_settings_wifi_only';
  const legacyAutoSyncMin = 'ff_settings_auto_sync_min';
  const legacyLastSyncedAt = 'ff_settings_last_synced_at';

  group('SettingsRepository.loadAll migration', () {
    test('should migrate legacy secure-storage settings on first load', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({
        legacyWifiOnly: 'true',
        legacyAutoSyncMin: '30',
        legacyLastSyncedAt: '1754661600000',
        'ff_settings_server_url': 'https://odoo.example.com',
        'ff_settings_database': 'fsm',
        'ff_settings_username': 'worker1@gmail.com',
        'ff_settings_password': 'secret',
        'ff_settings_api_key': 'key',
      });

      await repository.loadAll();

      expect(repository.wifiOnly, isTrue);
      expect(repository.autoSyncMinutes, 30);
      expect(
        repository.lastSyncedAt,
        DateTime.fromMillisecondsSinceEpoch(1754661600000),
      );
    });

    test('should delete legacy keys and stored credentials after migrating', () async {
      final remaining = await raw.readAll();

      expect(remaining, isEmpty);
    });

    test('should mark the migration as done in SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('settings_migrated_v1'), isTrue);
    });

    test('should read from SharedPreferences on subsequent loads', () async {
      await repository.saveWifiOnly(false);
      await repository.saveAutoSyncMinutes(45);
      await repository.saveLastSyncedAt(null);

      await repository.loadAll();

      expect(repository.wifiOnly, isFalse);
      expect(repository.autoSyncMinutes, 45);
      expect(repository.lastSyncedAt, isNull);
    });

    test('should not resurrect legacy values once migrated', () async {
      FlutterSecureStorage.setMockInitialValues({
        legacyWifiOnly: 'true',
        legacyAutoSyncMin: '5',
      });

      await repository.loadAll();

      expect(repository.wifiOnly, isFalse);
      expect(repository.autoSyncMinutes, 45);
    });
  });

  group('SettingsRepository setters', () {
    test('should persist values written through the repository', () async {
      await repository.saveWifiOnly(true);
      await repository.saveAutoSyncMinutes(15);
      final when = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      await repository.saveLastSyncedAt(when);

      await repository.loadAll();

      expect(repository.wifiOnly, isTrue);
      expect(repository.autoSyncMinutes, 15);
      expect(repository.lastSyncedAt, when);
    });

    test('should expose in-memory setters without touching storage', () async {
      repository.wifiOnly = false;
      repository.autoSyncMinutes = 99;
      repository.lastSyncedAt = null;

      expect(repository.wifiOnly, isFalse);
      expect(repository.autoSyncMinutes, 99);
      expect(repository.lastSyncedAt, isNull);

      await repository.loadAll();

      expect(repository.wifiOnly, isTrue);
      expect(repository.autoSyncMinutes, 15);
      expect(
        repository.lastSyncedAt,
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });
  });
}

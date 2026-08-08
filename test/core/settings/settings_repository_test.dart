import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_repository.dart';

/// Behaviour once the one-time migration has already happened. Each test seeds
/// the values it asserts on, because [SettingsRepository] delegates to a
/// singleton that caches its SharedPreferences handle for the whole isolate.
/// The migration path itself lives in settings_repository_migration_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'settings_migrated_v1': true});
  FlutterSecureStorage.setMockInitialValues({});

  final repository = SettingsRepository.instance;

  Future<void> seed({
    required bool wifiOnly,
    required int autoSyncMinutes,
    DateTime? lastSyncedAt,
  }) async {
    await repository.saveWifiOnly(wifiOnly);
    await repository.saveAutoSyncMinutes(autoSyncMinutes);
    await repository.saveLastSyncedAt(lastSyncedAt);
  }

  group('SettingsRepository', () {
    test('should reload the values written through the repository', () async {
      final when = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      await seed(wifiOnly: true, autoSyncMinutes: 15, lastSyncedAt: when);

      await repository.loadAll();

      expect(repository.wifiOnly, isTrue);
      expect(repository.autoSyncMinutes, 15);
      expect(repository.lastSyncedAt, when);
    });

    test('should reload a cleared last-synced timestamp as null', () async {
      await seed(wifiOnly: false, autoSyncMinutes: 45);

      await repository.loadAll();

      expect(repository.wifiOnly, isFalse);
      expect(repository.autoSyncMinutes, 45);
      expect(repository.lastSyncedAt, isNull);
    });

    test('should keep purging leftover credentials on every load', () async {
      FlutterSecureStorage.setMockInitialValues({
        'ff_settings_server_url': 'https://odoo.example.com',
        'ff_settings_password': 'secret',
        'ff_settings_api_key': 'key',
      });

      await repository.loadAll();

      const raw = FlutterSecureStorage();
      expect(await raw.readAll(), isEmpty);
    });

    test('should expose in-memory setters that storage overwrites on load', () async {
      final when = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      await seed(wifiOnly: true, autoSyncMinutes: 15, lastSyncedAt: when);

      repository.wifiOnly = false;
      repository.autoSyncMinutes = 99;
      repository.lastSyncedAt = null;

      expect(repository.wifiOnly, isFalse);
      expect(repository.autoSyncMinutes, 99);
      expect(repository.lastSyncedAt, isNull);

      await repository.loadAll();

      expect(repository.wifiOnly, isTrue);
      expect(repository.autoSyncMinutes, 15);
      expect(repository.lastSyncedAt, when);
    });
  });
}

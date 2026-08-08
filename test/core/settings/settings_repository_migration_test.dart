import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_repository.dart';

/// The one-time migration only runs while SharedPreferences has no
/// `settings_migrated_v1` flag, and [SettingsRepository] caches its store, so
/// this path needs a test file that starts from a pristine store. Behaviour
/// after migration is covered by settings_repository_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const raw = FlutterSecureStorage();

  // Legacy keys written by older app versions into secure storage.
  const legacyWifiOnly = 'ff_settings_wifi_only';
  const legacyAutoSyncMin = 'ff_settings_auto_sync_min';
  const legacyLastSyncedAt = 'ff_settings_last_synced_at';

  test('should migrate legacy secure-storage settings then purge them', () async {
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

    await SettingsRepository.instance.loadAll();

    expect(SettingsRepository.instance.wifiOnly, isTrue);
    expect(SettingsRepository.instance.autoSyncMinutes, 30);
    expect(
      SettingsRepository.instance.lastSyncedAt,
      DateTime.fromMillisecondsSinceEpoch(1754661600000),
    );

    // Legacy settings and credentials must not survive the migration.
    expect(await raw.readAll(), isEmpty);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings_migrated_v1'), isTrue);
  });

  test('should not re-run the migration once the flag is set', () async {
    FlutterSecureStorage.setMockInitialValues({
      legacyWifiOnly: 'true',
      legacyAutoSyncMin: '5',
    });
    await SettingsRepository.instance.saveWifiOnly(false);
    await SettingsRepository.instance.saveAutoSyncMinutes(45);

    await SettingsRepository.instance.loadAll();

    expect(SettingsRepository.instance.wifiOnly, isFalse);
    expect(SettingsRepository.instance.autoSyncMinutes, 45);
    // Legacy keys are left alone because the migration no longer runs.
    expect(await raw.read(key: legacyWifiOnly), 'true');
  });
}

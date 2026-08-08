import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_local_storage.dart';

/// [SettingsLocalStorage] is a singleton caching its [SharedPreferences]
/// handle, so the store cannot be swapped between tests. Every test therefore
/// seeds the values it asserts on through the public API instead of relying on
/// what a previous test left behind. Default values are covered by
/// settings_local_storage_defaults_test.dart, which starts from an empty store.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final storage = SettingsLocalStorage.instance;

  Future<void> seed({
    bool wifiOnly = false,
    int autoSyncMinutes = 15,
    DateTime? lastSyncedAt,
  }) async {
    await storage.saveWifiOnly(wifiOnly);
    await storage.saveAutoSyncMinutes(autoSyncMinutes);
    await storage.saveLastSyncedAt(lastSyncedAt);
  }

  group('SettingsLocalStorage persistence', () {
    test('should persist wifi-only and reload it', () async {
      await seed(wifiOnly: true);
      expect(storage.wifiOnly, isTrue);

      await storage.loadAll();
      expect(storage.wifiOnly, isTrue);

      await storage.saveWifiOnly(false);
      await storage.loadAll();
      expect(storage.wifiOnly, isFalse);
    });

    test('should persist the auto-sync interval and reload it', () async {
      await seed(autoSyncMinutes: 60);
      expect(storage.autoSyncMinutes, 60);

      await storage.loadAll();
      expect(storage.autoSyncMinutes, 60);
    });

    test('should persist last-synced timestamp with millisecond precision', () async {
      final when = DateTime.fromMillisecondsSinceEpoch(1754661600000);
      await seed(lastSyncedAt: when);
      expect(storage.lastSyncedAt, when);

      await storage.loadAll();
      expect(storage.lastSyncedAt, when);
    });

    test('should clear the last-synced timestamp when saving null', () async {
      await seed(lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(1000));

      await storage.saveLastSyncedAt(null);
      expect(storage.lastSyncedAt, isNull);

      await storage.loadAll();
      expect(storage.lastSyncedAt, isNull);
    });

    test('should treat a zero timestamp as never synced', () async {
      await seed(lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(0));

      await storage.loadAll();
      expect(storage.lastSyncedAt, isNull);
    });

    test('should keep settings independent of each other', () async {
      final when = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      await seed(wifiOnly: true, autoSyncMinutes: 5, lastSyncedAt: when);

      await storage.loadAll();

      expect(storage.wifiOnly, isTrue);
      expect(storage.autoSyncMinutes, 5);
      expect(storage.lastSyncedAt, when);
    });
  });
}

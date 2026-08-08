import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final storage = SettingsLocalStorage.instance;

  group('SettingsLocalStorage defaults', () {
    test('should expose sane defaults before anything is persisted', () async {
      await storage.loadAll();

      expect(storage.wifiOnly, isFalse);
      expect(storage.autoSyncMinutes, 15);
      expect(storage.lastSyncedAt, isNull);
    });
  });

  group('SettingsLocalStorage persistence', () {
    test('should persist wifi-only and reload it', () async {
      await storage.saveWifiOnly(true);
      expect(storage.wifiOnly, isTrue);

      await storage.loadAll();
      expect(storage.wifiOnly, isTrue);

      await storage.saveWifiOnly(false);
      await storage.loadAll();
      expect(storage.wifiOnly, isFalse);
    });

    test('should persist the auto-sync interval and reload it', () async {
      await storage.saveAutoSyncMinutes(60);
      expect(storage.autoSyncMinutes, 60);

      await storage.loadAll();
      expect(storage.autoSyncMinutes, 60);
    });

    test('should persist last-synced timestamp with millisecond precision', () async {
      final when = DateTime.fromMillisecondsSinceEpoch(1754661600000);

      await storage.saveLastSyncedAt(when);
      expect(storage.lastSyncedAt, when);

      await storage.loadAll();
      expect(storage.lastSyncedAt, when);
    });

    test('should clear the last-synced timestamp when saving null', () async {
      await storage.saveLastSyncedAt(DateTime.fromMillisecondsSinceEpoch(1000));
      await storage.saveLastSyncedAt(null);

      expect(storage.lastSyncedAt, isNull);

      await storage.loadAll();
      expect(storage.lastSyncedAt, isNull);
    });

    test('should treat a zero timestamp as never synced', () async {
      await storage.saveLastSyncedAt(DateTime.fromMillisecondsSinceEpoch(0));

      await storage.loadAll();
      expect(storage.lastSyncedAt, isNull);
    });

    test('should keep settings independent of each other', () async {
      await storage.saveWifiOnly(true);
      await storage.saveAutoSyncMinutes(5);
      final when = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      await storage.saveLastSyncedAt(when);

      await storage.loadAll();

      expect(storage.wifiOnly, isTrue);
      expect(storage.autoSyncMinutes, 5);
      expect(storage.lastSyncedAt, when);
    });
  });
}

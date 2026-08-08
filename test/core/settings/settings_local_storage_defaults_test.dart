import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce_mobile/core/settings/settings_local_storage.dart';

/// Defaults live in their own file: [SettingsLocalStorage] is a singleton that
/// caches its [SharedPreferences] handle, so an empty store can only be
/// observed by a test file that has not written anything yet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('should expose sane defaults before anything is persisted', () async {
    await SettingsLocalStorage.instance.loadAll();

    expect(SettingsLocalStorage.instance.wifiOnly, isFalse);
    expect(SettingsLocalStorage.instance.autoSyncMinutes, 15);
    expect(SettingsLocalStorage.instance.lastSyncedAt, isNull);
  });
}

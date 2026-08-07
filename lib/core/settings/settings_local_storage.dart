import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalStorage {
  SettingsLocalStorage._();
  static final SettingsLocalStorage instance = SettingsLocalStorage._();

  static const _kWifiOnly = 'settings_wifi_only';
  static const _kAutoSyncMin = 'settings_auto_sync_min';
  static const _kLastSyncedAt = 'settings_last_synced_at';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> loadAll() async {
    final prefs = await _instance;
    wifiOnly = prefs.getBool(_kWifiOnly) ?? false;
    autoSyncMinutes = prefs.getInt(_kAutoSyncMin) ?? 15;
    final ts = prefs.getInt(_kLastSyncedAt);
    lastSyncedAt =
        ts == null || ts == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ts);
  }

  Future<void> saveWifiOnly(bool value) async {
    wifiOnly = value;
    await (await _instance).setBool(_kWifiOnly, value);
  }

  Future<void> saveAutoSyncMinutes(int minutes) async {
    autoSyncMinutes = minutes;
    await (await _instance).setInt(_kAutoSyncMin, minutes);
  }

  Future<void> saveLastSyncedAt(DateTime? when) async {
    lastSyncedAt = when;
    if (when == null) {
      await (await _instance).remove(_kLastSyncedAt);
    } else {
      await (await _instance)
          .setInt(_kLastSyncedAt, when.millisecondsSinceEpoch);
    }
  }

  // In-memory cache
  bool wifiOnly = false;
  int autoSyncMinutes = 15;
  DateTime? lastSyncedAt;
}

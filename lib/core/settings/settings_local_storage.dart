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
    final prefs = await _instance;
    final success = await prefs.setBool(_kWifiOnly, value);
    if (!success) {
      throw StateError('Failed to persist wifi-only setting');
    }
    wifiOnly = value;
  }

  Future<void> saveAutoSyncMinutes(int minutes) async {
    final prefs = await _instance;
    final success = await prefs.setInt(_kAutoSyncMin, minutes);
    if (!success) {
      throw StateError('Failed to persist auto-sync setting');
    }
    autoSyncMinutes = minutes;
  }

  Future<void> saveLastSyncedAt(DateTime? when) async {
    final prefs = await _instance;
    if (when == null) {
      final success = await prefs.remove(_kLastSyncedAt);
      if (!success) {
        throw StateError('Failed to clear last-synced setting');
      }
    } else {
      final success =
          await prefs.setInt(_kLastSyncedAt, when.millisecondsSinceEpoch);
      if (!success) {
        throw StateError('Failed to persist last-synced setting');
      }
    }
    lastSyncedAt = when;
  }

  // In-memory cache
  bool wifiOnly = false;
  int autoSyncMinutes = 15;
  DateTime? lastSyncedAt;
}

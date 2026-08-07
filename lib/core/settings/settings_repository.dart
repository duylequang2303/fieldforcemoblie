import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_local_storage.dart';

/// Lưu tuỳ chọn đồng bộ của Settings (wifi-only, auto-sync, last synced). State được lưu ở SharedPreferences.
///
/// LƯU Ý: creds (server/db/user/pass) KHÔNG lưu ở đây — chúng thuộc
/// SecureStorageService (màn Login ghi).
class SettingsRepository {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // 旧 Keys dùng để migration
  static const _kWifiOnly = 'ff_settings_wifi_only';
  static const _kAutoSyncMin = 'ff_settings_auto_sync_min';
  static const _kLastSyncedAt = 'ff_settings_last_synced_at';
  static const _kMigratedKey = 'settings_migrated_v1';

  final _localStorage = SettingsLocalStorage.instance;

  // Delegation getters/setters cho in-memory cache
  bool get wifiOnly => _localStorage.wifiOnly;
  set wifiOnly(bool value) => _localStorage.wifiOnly = value;

  int get autoSyncMinutes => _localStorage.autoSyncMinutes;
  set autoSyncMinutes(int value) => _localStorage.autoSyncMinutes = value;

  DateTime? get lastSyncedAt => _localStorage.lastSyncedAt;
  set lastSyncedAt(DateTime? value) => _localStorage.lastSyncedAt = value;

  /// Load tuỳ chọn từ storage. Gọi 1 lần khi mở Settings.
  Future<void> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Perform one-time migration nếu chưa làm
      if (!prefs.containsKey(_kMigratedKey)) {
        // Đọc giá trị cũ từ secure storage
        final wifiVal = await _storage.read(key: _kWifiOnly);
        final oldWifiOnly = (wifiVal ?? 'false') == 'true';

        final autoVal = await _storage.read(key: _kAutoSyncMin);
        final oldAutoSyncMinutes = int.tryParse(autoVal ?? '15') ?? 15;

        final tsVal = await _storage.read(key: _kLastSyncedAt);
        final ts = int.tryParse(tsVal ?? '');
        final oldLastSyncedAt =
            ts == null || ts == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ts);

        // Lưu vào SharedPreferences mới
        await _localStorage.saveWifiOnly(oldWifiOnly);
        await _localStorage.saveAutoSyncMinutes(oldAutoSyncMinutes);
        await _localStorage.saveLastSyncedAt(oldLastSyncedAt);

        // Đánh dấu đã migrate
        await prefs.setBool(_kMigratedKey, true);

        // Xoá rác ở secure storage
        await _storage.delete(key: _kWifiOnly);
        await _storage.delete(key: _kAutoSyncMin);
        await _storage.delete(key: _kLastSyncedAt);
      } else {
        // Đọc bình thường từ SharedPreferences
        await _localStorage.loadAll();
      }

      // Purge credentials cũ (ff_settings_*) còn sót từ bản cũ để bảo mật
      await _storage.delete(key: 'ff_settings_server_url');
      await _storage.delete(key: 'ff_settings_database');
      await _storage.delete(key: 'ff_settings_username');
      await _storage.delete(key: 'ff_settings_password');
      await _storage.delete(key: 'ff_settings_api_key');
    } catch (_) {
      // Fallback nếu có lỗi
      await _localStorage.loadAll();
    }
  }

  Future<void> saveWifiOnly(bool value) async {
    await _localStorage.saveWifiOnly(value);
  }

  Future<void> saveAutoSyncMinutes(int minutes) async {
    await _localStorage.saveAutoSyncMinutes(minutes);
  }

  Future<void> saveLastSyncedAt(DateTime? when) async {
    await _localStorage.saveLastSyncedAt(when);
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu tuỳ chọn đồng bộ của Settings (wifi-only, auto-sync, last synced).
///
/// LƯU Ý: creds (server/db/user/pass) KHÔNG lưu ở đây — chúng thuộc
/// SecureStorageService (màn Login ghi). Lát 5b đã dọn bộ key ff_settings_* cũ.
class SettingsRepository {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Keys ──
  static const _kWifiOnly = 'ff_settings_wifi_only';
  static const _kAutoSyncMin = 'ff_settings_auto_sync_min';
  static const _kLastSyncedAt = 'ff_settings_last_synced_at';

  // ── In-memory cache ──
  bool wifiOnly = false;
  int autoSyncMinutes = 15; // 0 = off
  DateTime? lastSyncedAt;

  /// Load tuỳ chọn từ storage. Gọi 1 lần khi mở Settings.
  Future<void> loadAll() async {
    try {
      final values = await _storage.readAll();
      wifiOnly = (values[_kWifiOnly] ?? 'false') == 'true';
      autoSyncMinutes = int.tryParse(values[_kAutoSyncMin] ?? '15') ?? 15;
      final ts = int.tryParse(values[_kLastSyncedAt] ?? '');
      lastSyncedAt = ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts);

      // Purge credentials cũ (ff_settings_*) còn sót từ bản 4/4.5.
      // Bản 5b không dùng chúng nữa; để trong két là rác bảo mật.
      // delete key không tồn tại thì vô hại → chạy mỗi lần loadAll vẫn an toàn (idempotent, không cần cờ one-time).
      await _storage.delete(key: 'ff_settings_server_url');
      await _storage.delete(key: 'ff_settings_database');
      await _storage.delete(key: 'ff_settings_username');
      await _storage.delete(key: 'ff_settings_password');
      await _storage.delete(key: 'ff_settings_api_key');
    } catch (_) {
      // Storage chưa sẵn sàng — giữ mặc định.
    }
  }

  Future<void> saveWifiOnly(bool value) async {
    wifiOnly = value;
    await _storage.write(key: _kWifiOnly, value: value.toString());
  }

  Future<void> saveAutoSyncMinutes(int minutes) async {
    autoSyncMinutes = minutes;
    await _storage.write(key: _kAutoSyncMin, value: minutes.toString());
  }

  Future<void> saveLastSyncedAt(DateTime? when) async {
    lastSyncedAt = when;
    await _storage.write(
      key: _kLastSyncedAt,
      value: when?.millisecondsSinceEpoch.toString(),
    );
  }
}
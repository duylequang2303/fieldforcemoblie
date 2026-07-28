import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu/đọc cấu hình Settings (kết nối Odoo + tuỳ chọn đồng bộ).
///
/// LƯU Ý (nợ kỹ thuật Lát 4): repo này dùng bộ key RIÊNG, độc lập với
/// [SecureStorageService] mà màn Login đang ghi. Lát 5 sẽ hợp nhất 2 nguồn
/// để màn Kết nối tự điền từ lần đăng nhập trước.
class SettingsRepository {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Keys ──
  static const _kServerUrl = 'ff_settings_server_url';
  static const _kDatabase = 'ff_settings_database';
  static const _kUsername = 'ff_settings_username';
  static const _kApiKey = 'ff_settings_api_key';
  static const _kWifiOnly = 'ff_settings_wifi_only';
  static const _kAutoSyncMin = 'ff_settings_auto_sync_min';
  static const _kLastSyncedAt = 'ff_settings_last_synced_at';

  // ── In-memory cache ──
  String serverUrl = '';
  String database = '';
  String username = '';
  String apiKey = '';
  bool wifiOnly = false;
  int autoSyncMinutes = 15; // 0 = tắt
  DateTime? lastSyncedAt;

  bool get hasConnection =>
      serverUrl.isNotEmpty &&
      database.isNotEmpty &&
      username.isNotEmpty &&
      apiKey.isNotEmpty;

  /// Nạp toàn bộ từ storage vào cache. Gọi 1 lần khi mở màn Settings.
  Future<void> loadAll() async {
    try {
      final values = await _storage.readAll();
      serverUrl = values[_kServerUrl] ?? '';
      database = values[_kDatabase] ?? '';
      username = values[_kUsername] ?? '';
      apiKey = values[_kApiKey] ?? '';
      wifiOnly = (values[_kWifiOnly] ?? 'false') == 'true';
      autoSyncMinutes = int.tryParse(values[_kAutoSyncMin] ?? '15') ?? 15;
      final ts = int.tryParse(values[_kLastSyncedAt] ?? '');
      lastSyncedAt = ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts);
    } catch (_) {
      // Storage chưa sẵn sàng → giữ giá trị mặc định.
    }
  }

  Future<void> saveConnection({
    required String serverUrl,
    required String database,
    required String username,
    required String apiKey,
  }) async {
    this.serverUrl = serverUrl;
    this.database = database;
    this.username = username;
    this.apiKey = apiKey;
    await _storage.write(key: _kServerUrl, value: serverUrl);
    await _storage.write(key: _kDatabase, value: database);
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kApiKey, value: apiKey);
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

  Future<void> clearConnection() async {
    serverUrl = '';
    database = '';
    username = '';
    apiKey = '';
    await _storage.delete(key: _kServerUrl);
    await _storage.delete(key: _kDatabase);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kApiKey);
  }
}
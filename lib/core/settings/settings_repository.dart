import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores/reads Settings config (Odoo connection + sync preferences).
///
/// NOTE (Slice 4 tech debt): this repo uses its OWN key set, separate from
/// [SecureStorageService] which the Login screen writes to. Slice 5 will
/// unify both sources so the Connection form auto-fills from the last login.
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
  static const _kPassword = 'ff_settings_password';
  static const _kWifiOnly = 'ff_settings_wifi_only';
  static const _kAutoSyncMin = 'ff_settings_auto_sync_min';
  static const _kLastSyncedAt = 'ff_settings_last_synced_at';

  // ── In-memory cache ──
  String serverUrl = '';
  String database = '';
  String username = '';
  String password = '';
  bool wifiOnly = false;
  int autoSyncMinutes = 15; // 0 = off
  DateTime? lastSyncedAt;

  bool get hasConnection =>
      serverUrl.isNotEmpty &&
      database.isNotEmpty &&
      username.isNotEmpty &&
      password.isNotEmpty;

  /// Load everything from storage into cache. Call once when opening Settings.
  Future<void> loadAll() async {
    try {
      final values = await _storage.readAll();
      serverUrl = values[_kServerUrl] ?? '';
      database = values[_kDatabase] ?? '';
      username = values[_kUsername] ?? '';
      password = values[_kPassword] ?? '';
      wifiOnly = (values[_kWifiOnly] ?? 'false') == 'true';
      autoSyncMinutes = int.tryParse(values[_kAutoSyncMin] ?? '15') ?? 15;
      final ts = int.tryParse(values[_kLastSyncedAt] ?? '');
      lastSyncedAt = ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts);
    } catch (_) {
      // Storage not ready yet — keep defaults.
    }
  }

  Future<void> saveConnection({
    required String serverUrl,
    required String database,
    required String username,
    required String password,
  }) async {
    this.serverUrl = serverUrl;
    this.database = database;
    this.username = username;
    this.password = password;
    await _storage.write(key: _kServerUrl, value: serverUrl);
    await _storage.write(key: _kDatabase, value: database);
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kPassword, value: password);
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
    password = '';
    await _storage.delete(key: _kServerUrl);
    await _storage.delete(key: _kDatabase);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kPassword);
  }
}
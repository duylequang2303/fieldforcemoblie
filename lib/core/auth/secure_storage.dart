import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service lưu trữ thông tin nhạy cảm an toàn bằng Keychain (iOS) / Keystore (Android).
/// Sử dụng cho: server URL, database, username, session ID.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys
  static const _keyServerUrl = 'odoo_server_url';
  static const _keyDatabase = 'odoo_database';
  static const _keyUsername = 'odoo_username';
  static const _keySessionId = 'odoo_session_id';
  static const _keyUserId = 'odoo_user_id';
  static const _keyBiometricEnabled = 'biometric_enabled';

  Future<void> saveSession({
    required String serverUrl,
    required String database,
    required String username,
    required String sessionId,
    required int userId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyServerUrl, value: serverUrl),
      _storage.write(key: _keyDatabase, value: database),
      _storage.write(key: _keyUsername, value: username),
      _storage.write(key: _keySessionId, value: sessionId),
      _storage.write(key: _keyUserId, value: userId.toString()),
    ]);
  }

  Future<Map<String, String?>> loadSession() async {
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
      _storage.read(key: _keySessionId),
      _storage.read(key: _keyUserId),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
      'sessionId': results[3],
      'userId': results[4],
    };
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyServerUrl),
      _storage.delete(key: _keyDatabase),
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keySessionId),
      _storage.delete(key: _keyUserId),
    ]);
  }

  Future<bool> get hasSavedSession async {
    final sessionId = await _storage.read(key: _keySessionId);
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }
}

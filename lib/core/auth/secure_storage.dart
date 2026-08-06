import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

/// Class khóa bất đồng bộ đơn giản để serialize các thao tác ghi dữ liệu.
class _SimpleLock {
  Future<void> _last = Future.value();
  Future<T> synchronized<T>(Future<T> Function() action) {
    final next = _last.then((_) => action(), onError: (_) => action());
    _last = next.then((_) {}, onError: (_) {});
    return next;
  }
}

/// Service lưu trữ thông tin nhạy cảm an toàn bằng Keychain (iOS) / Keystore (Android).
/// Sử dụng cho: server URL, database, username, session ID.
/// KHÔNG LƯU PASSWORD - chỉ lưu session token.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Lock để serialize tất cả write operations - tránh race condition
  final _writeLock = _SimpleLock();

  // Keys - KHÔNG CÓ _keyPassword
  static const _keyServerUrl = 'odoo_server_url';
  static const _keyDatabase = 'odoo_database';
  static const _keyUsername = 'odoo_username';
  static const _keySessionId = 'odoo_session_id';
  static const _keyUserId = 'odoo_user_id';
  static const _keyLocale = 'odoo_locale';
  static const _keyBiometricEnabled = 'biometric_enabled';

  /// Lưu session (KHÔNG lưu password, xóa legacy password nếu có)
  Future<void> saveSession({
    required String serverUrl,
    required String database,
    required String username,
    required String sessionId,
    required int userId,
    String locale = 'vi_VN',
  }) async {
    // Serialize writes với lock
    await _writeLock.synchronized(() async {
      await _storage.write(key: _keyServerUrl, value: serverUrl);
      await _storage.write(key: _keyDatabase, value: database);
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keySessionId, value: sessionId);
      await _storage.write(key: _keyUserId, value: userId.toString());
      await _storage.write(key: _keyLocale, value: locale);
      // Migration: Xoá odoo_password key nếu còn sót từ các session trước
      await _storage.delete(key: 'odoo_password');
    });
  }

  /// Load session data (không bao gồm password)
  Future<Map<String, String?>> loadSession() async {
    // Migration: Xoá legacy password bất đồng bộ khi app bắt đầu phục hồi session
    unawaited(_storage.delete(key: 'odoo_password'));

    // Reads không cần lock
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
      _storage.read(key: _keySessionId),
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyLocale),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
      'sessionId': results[3],
      'userId': results[4],
      'locale': results[5],
    };
  }

  /// Chỉ load thông tin đăng nhập (URL, database, username) không bao gồm session.
  /// Dùng để điền sẵn form login khi session hết hạn.
  Future<Map<String, String?>> loadSavedCredentials() async {
    final results = await Future.wait([
      _storage.read(key: _keyServerUrl),
      _storage.read(key: _keyDatabase),
      _storage.read(key: _keyUsername),
    ]);
    return {
      'serverUrl': results[0],
      'database': results[1],
      'username': results[2],
    };
  }

  Future<void> clearSession() async {
    await _writeLock.synchronized(() async {
      await Future.wait([
        _storage.delete(key: _keyServerUrl),
        _storage.delete(key: _keyDatabase),
        _storage.delete(key: _keyUsername),
        _storage.delete(key: _keySessionId),
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyLocale),
        _storage.delete(key: 'odoo_password'), // Xóa legacy key (password cũ) nếu có
      ]);
    });
  }

  Future<bool> get hasSavedSession async {
    final sessionId = await _storage.read(key: _keySessionId);
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _writeLock.synchronized(() async {
      await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
    });
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }
}

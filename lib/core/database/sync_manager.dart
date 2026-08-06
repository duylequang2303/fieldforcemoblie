import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../connectivity/connectivity_service.dart';
import '../settings/settings_repository.dart';
import '../api/odoo_session_manager.dart';

/// Điều phối đồng bộ local (Isar) → Odoo.
/// Hai cơ chế: (1) event-driven khi mạng về [startListening];
/// (2) định kỳ theo [SettingsRepository.autoSyncMinutes] qua [startAutoSync].
/// Cả hai tôn trọng "chỉ WiFi" ([SettingsRepository.wifiOnly]).
/// LƯU Ý: chỉ chạy khi app mở (foreground). Sync nền lúc app bị kill cần
/// background service riêng — chưa làm ở lát này.
class SyncManager {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  final _connectivity = ConnectivityService.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _autoSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startListening() {
    _isInitialized = true;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final isOnline = await _connectivity.isOnline;
      // Fix Thread #1: Gate sync on authentication
      if (isOnline && !_isSyncing && await _allowedByNetworkPref() && OdooSessionManager.instance.isAuthenticated) {
        await syncPending();
      }
    });
  }

  /// Bật auto-sync định kỳ. Gọi 1 lần khi khởi động (sau startListening).
  Future<void> startAutoSync() async {
    _isInitialized = true;
    await SettingsRepository.instance.loadAll();
    _restartTimer();
  }

  /// Áp lại preference khi user đổi auto-sync / wifi-only trong Settings.
  void applyPreferences() {
    _restartTimer();
  }

  void _restartTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    final minutes = SettingsRepository.instance.autoSyncMinutes;
    if (minutes <= 0) return; // 0 = tắt
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: minutes),
      (_) => _autoTick(),
    );
    if (kDebugMode) {
      debugPrint(
        'SyncManager: auto-sync mỗi $minutes phút '
        '(wifiOnly=${SettingsRepository.instance.wifiOnly})',
      );
    }
  }

  Future<void> _autoTick() async {
    if (_isSyncing) return;
    final isOnline = await _connectivity.isOnline;
    if (!isOnline) return;
    if (!await _allowedByNetworkPref()) {
      if (kDebugMode) {
        debugPrint(
            'SyncManager: bỏ qua auto-sync (wifi-only nhưng đang mobile data)');
      }
      return;
    }
    if (kDebugMode) {
      debugPrint('SyncManager: auto-sync tick → syncPending()');
    }
    await syncPending();
    // Ghi thời điểm để màn Settings phản ánh lần auto-sync (không chỉ sync tay).
    await SettingsRepository.instance.saveLastSyncedAt(DateTime.now());
  }

  Future<bool> _allowedByNetworkPref() async {
    if (!SettingsRepository.instance.wifiOnly) return true;
    return _connectivity.checkIsWifi();
  }

  Future<void>? _activeSyncFuture;

  Future<void> syncPending() async {
    if (_isSyncing) {
      final active = _activeSyncFuture;
      if (active != null) {
        await active;
      }
      return;
    }
    _isSyncing = true;
    _activeSyncFuture = _runHandlers();
    try {
      await _activeSyncFuture;
    } finally {
      _isSyncing = false;
      _activeSyncFuture = null;
    }
  }

  Future<void> _runHandlers() async {
    for (final handler in _syncHandlers) {
      try {
        await handler();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('SyncManager: handler failed: $e\n$stackTrace');
        }
        // Log error but continue with other handlers
      }
    }
  }

  /// Gọi sau khi login/restore thành công: sync pending ngay, không đợi tick 15 phút.
  Future<void> syncAfterAuth() async {
    // Nếu chưa được khởi tạo hoặc vừa login lại sau khi logout, khởi động lại listener và timer
    if (!_isInitialized) {
      startListening();
      unawaited(startAutoSync());
    }

    if (_isSyncing) {
      final active = _activeSyncFuture;
      if (active != null) {
        await active;
      }
      return;
    }
    if (!await _connectivity.isOnline) {
      return; // offline → đợi tick/connectivity sau
    }
    if (!await _allowedByNetworkPref()) {
      return;
    }
    await syncPending();
  }

  final List<Future<void> Function()> _syncHandlers = [];

  void registerSyncHandler(Future<void> Function() handler) {
    // Prevent duplicate handlers
    if (!_syncHandlers.contains(handler)) {
      _syncHandlers.add(handler);
    } else if (kDebugMode) {
      debugPrint('SyncManager: duplicate handler registration ignored');
    }
  }

  /// Cleanup resources on logout/app terminate
  Future<void> dispose() async {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    
    // Đợi sync đang chạy hoàn thành trước khi dọn dẹp để tránh Isar DB bị xóa giữa chừng
    final active = _activeSyncFuture;
    if (active != null) {
      try {
        await active;
      } catch (_) {}
    }
    
    // KHÔNG xóa _syncHandlers để lưu giữ các handler đăng ký từ main.dart cho session sau
    // _syncHandlers.clear();
    _isSyncing = false;
    _isInitialized = false;
  }
}

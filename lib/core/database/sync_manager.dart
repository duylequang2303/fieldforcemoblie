import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connectivity/connectivity_service.dart';
import '../settings/settings_repository.dart';

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

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _autoSyncTimer;

  void startListening() {
    _connectivity.onConnectivityChanged.listen((results) async {
      final isOnline = await _connectivity.isOnline;
      if (isOnline && !_isSyncing && await _allowedByNetworkPref()) {
        await syncPending();
      }
    });
  }

  /// Bật auto-sync định kỳ. Gọi 1 lần khi khởi động (sau startListening).
  Future<void> startAutoSync() async {
    await SettingsRepository.instance.loadAll();
    _restartTimer();
  }

  /// Áp lại preference khi user đổi auto-sync / wifi-only trong Settings.
  Future<void> applyPreferences() async {
    await SettingsRepository.instance.loadAll();
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
    debugPrint(
      'SyncManager: auto-sync mỗi $minutes phút '
      '(wifiOnly=${SettingsRepository.instance.wifiOnly})',
    );
  }

  Future<void> _autoTick() async {
    if (_isSyncing) return;
    final isOnline = await _connectivity.isOnline;
    if (!isOnline) return;
    if (!await _allowedByNetworkPref()) {
      debugPrint('SyncManager: bỏ qua auto-sync (wifi-only nhưng đang mobile data)');
      return;
    }
    debugPrint('SyncManager: auto-sync tick → syncPending()');
    await syncPending();
    // Ghi thời điểm để màn Settings phản ánh lần auto-sync (không chỉ sync tay).
    await SettingsRepository.instance.saveLastSyncedAt(DateTime.now());
  }

  Future<bool> _allowedByNetworkPref() async {
    if (!SettingsRepository.instance.wifiOnly) return true;
    return _connectivity.checkIsWifi();
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      for (final handler in _syncHandlers) {
        try {
          await handler();
        } catch (_) {}
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Gọi sau khi login/restore thành công: sync pending ngay, không đợi tick 15 phút.
  Future<void> syncAfterAuth() async {
    if (_isSyncing) return;
    if (!await _connectivity.isOnline) return; // offline → đợi tick/connectivity sau
    await syncPending();
  }

  final List<Future<void> Function()> _syncHandlers = [];

  void registerSyncHandler(Future<void> Function() handler) {
    _syncHandlers.add(handler);
  }
}
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connectivity/connectivity_service.dart';
import '../settings/settings_repository.dart';
import '../api/odoo_session_manager.dart';

/// Điều phối đồng bộ local (Isar) → Odoo.
/// Hai cơ chế: (1) event-driven khi mạng về [startListening];
/// (2) định kỳ theo [SettingsRepository.autoSyncMinutes] qua [startAutoSync].
/// Cả hai tôn trọng "chỉ WiFi" ([SettingsRepository.wifiOnly]).
/// LƯU Ý: chỉ chạy khi app mở (foreground). Sync nền lúc app bị kill cần
/// background service riêng — chưa làm ở lát này.
class SyncManager extends ChangeNotifier {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  final _connectivity = ConnectivityService.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _disposed = false;
  Completer<void>? _initCompleter;

  Future<void> _waitForInitialization() async {
    if (_disposed) throw StateError('SyncManager has been disposed');
    if (_initCompleter == null) {
      _initCompleter = Completer<void>();
      try {
        await SettingsRepository.instance.loadAll();
        if (!_disposed) {
          _isInitialized = true;
          _initCompleter!.complete();
        } else {
          _initCompleter!.completeError(
              StateError('SyncManager was disposed during initialization'));
        }
      } catch (e) {
        _initCompleter!.completeError(e);
      }
    }
    return _initCompleter!.future;
  }

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _autoSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> startListening() async {
    await _waitForInitialization();
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) async {
      final isOnline = await _connectivity.isOnline;
      // Fix Thread #1: Gate sync on authentication
      if (isOnline &&
          !_isSyncing &&
          await _allowedByNetworkPref() &&
          OdooSessionManager.instance.isAuthenticated) {
        await syncPending();
      }
    });
  }

  /// Bật auto-sync định kỳ. Gọi 1 lần khi khởi động (sau startListening).
  Future<void> startAutoSync() async {
    await _waitForInitialization();
    _restartTimer();
  }

  /// Áp lại preference khi user đổi auto-sync / wifi-only trong Settings.
  void applyPreferences() {
    _restartTimer();
  }

  Future<void> _restartTimer() async {
    if (_disposed) return;
    await _waitForInitialization();
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    final minutes = SettingsRepository.instance.autoSyncMinutes;
    if (minutes <= 0) return; // 0 = tắt
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: minutes),
      (_) async {
        if (_disposed) return;
        try {
          await _autoTick();
        } catch (e, stack) {
          if (kDebugMode) {
            debugPrint('SyncManager: auto-sync tick error: $e\n$stack');
          }
        }
      },
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
    notifyListeners(); // ✅ Notify khi bắt đầu sync
    _activeSyncFuture = _runHandlers();
    try {
      await _activeSyncFuture;
    } finally {
      _isSyncing = false;
      notifyListeners(); // ✅ Notify khi kết thúc sync
      _activeSyncFuture = null;
    }
  }

  Future<void> _runHandlers() async {
    final failures = <_SyncHandlerFailure>[];
    for (final namedHandler in _syncHandlers) {
      try {
        await namedHandler.handler();
      } catch (e, stackTrace) {
        failures.add(_SyncHandlerFailure(namedHandler.name, e, stackTrace));
        if (kDebugMode) {
          debugPrint(
              'SyncManager: handler "${namedHandler.name}" failed: $e\n$stackTrace');
        }
      }
    }
    if (failures.isNotEmpty) {
      throw SyncHandlersFailedException(failures);
    }
  }

  /// Gọi sau khi login/restore thành công: sync pending ngay, không đợi tick 15 phút.
  Future<void> syncAfterAuth() async {
    // Nếu đã bị dispose (ví dụ sau logout), reset lại để cho phép khởi tạo lại
    if (_disposed) {
      reset();
    }
    // Nếu chưa được khởi tạo, khởi động lại listener và timer
    if (!_isInitialized) {
      await startListening();
      await startAutoSync();
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

  final List<_NamedHandler> _syncHandlers = [];

  void registerSyncHandler(String name, Future<void> Function() handler) {
    final named = _NamedHandler(name, handler);
    // Prevent duplicate handlers by name
    if (!_syncHandlers.contains(named)) {
      _syncHandlers.add(named);
      if (kDebugMode) {
        debugPrint('SyncManager: registered handler "$name"');
      }
    } else if (kDebugMode) {
      debugPrint('SyncManager: duplicate handler "$name" registration ignored');
    }
  }

  /// Cleanup resources on logout/app terminate
  /// Reset để cho phép khởi tạo lại sau khi logout
  void reset() {
    _disposed = false;
    _isInitialized = false;
    _initCompleter = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.completeError(
          StateError('SyncManager was disposed during initialization'));
    }
    _initCompleter = null;

    final subscription = _connectivitySubscription;
    if (subscription != null) {
      await subscription.cancel();
      _connectivitySubscription = null;
    }
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;

    // Đợi sync đang chạy hoàn thành trước khi dọn dẹp để tránh Isar DB bị xóa giữa chừng
    final active = _activeSyncFuture;
    if (active != null) {
      try {
        await active;
      } catch (_) {}
    }

    _isSyncing = false;
    _isInitialized = false;
  }
}

class SyncHandlersFailedException implements Exception {
  final List<_SyncHandlerFailure> failures;

  SyncHandlersFailedException(this.failures);

  @override
  String toString() {
    final names = failures.map((f) => f.name).join(', ');
    return 'Sync handlers failed: $names';
  }
}

class _NamedHandler {
  final String name;
  final Future<void> Function() handler;

  _NamedHandler(this.name, this.handler);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NamedHandler &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class _SyncHandlerFailure {
  final String name;
  final Object error;
  final StackTrace stackTrace;

  _SyncHandlerFailure(this.name, this.error, this.stackTrace);
}

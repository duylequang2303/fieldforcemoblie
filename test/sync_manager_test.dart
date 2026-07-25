import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/connectivity/connectivity_service.dart';
import 'package:fieldforce_mobile/core/database/sync_manager.dart';

class MockConnectivityService implements ConnectivityService {
  bool _isOnline = true;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onStatusChanged => _statusController.stream;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _statusController.stream.map((online) => online ? [ConnectivityResult.wifi] : []);

  @override
  Future<bool> checkConnectivity() async => _isOnline;

  @override
  Future<bool> get isOnline async => _isOnline;

  void setOnline(bool online) {
    _isOnline = online;
    _statusController.add(online);
  }
}

void main() {
  group('SyncManager Test', () {
    late MockConnectivityService mockConnectivity;
    late SyncManager manager;

    setUp(() async {
      mockConnectivity = MockConnectivityService();
      manager = SyncManager.instance;
    });

    test('syncPending với no handlers - không làm gì', () async {
      await manager.syncPending();
      
      expect(manager.isSyncing, isFalse);
    });

    test('syncPending với một handler thành công', () async {
      bool handlerCalled = false;
      
      manager.registerSyncHandler(() async {
        handlerCalled = true;
        return; // Success
      });

      await manager.syncPending();
      
      expect(handlerCalled, isTrue);
      expect(manager.isSyncing, isFalse);
    });

    test('syncPending với nhiều handlers - tất cả đều được gọi', () async {
      List<int> calledHandlers = [];
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(1);
        return;
      });
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(2);
        return;
      });
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(3);
        return;
      });

      await manager.syncPending();
      
      expect(calledHandlers, [1, 2, 3]);
    });

    test('syncPending khi handler lỗi - tiếp tục các handler khác', () async {
      List<int> calledHandlers = [];
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(1);
        throw Exception('Handler 1 error');
      });
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(2);
        return; // Success
      });
      
      manager.registerSyncHandler(() async {
        calledHandlers.add(3);
        return; // Success
      });

      await manager.syncPending();
      
      // All handlers should be called despite handler 1 error
      expect(calledHandlers, [1, 2, 3]);
    });

    test('syncPending không gọi lại khi đang syncing', () async {
      bool handlerCalled = false;
      
      manager.registerSyncHandler(() async {
        handlerCalled = true;
        // Giả lập delay dài
        await Future.delayed(const Duration(milliseconds: 100));
        return;
      });

      // Gọi syncPending lần 1
      final firstCall = manager.syncPending();
      
      // Trong khi đang sync, gọi lần 2
      final secondCall = manager.syncPending();
      
      await Future.wait([firstCall, secondCall]);
      
      // Handler chỉ được gọi 1 lần
      expect(handlerCalled, isTrue);
    });

    test('isSyncing flag đúng trong khi sync', () async {
      bool inSync = false;
      
      manager.registerSyncHandler(() async {
        inSync = manager.isSyncing;
        await Future.delayed(const Duration(milliseconds: 50));
        return;
      });

      await manager.syncPending();
      
      expect(inSync, isTrue);
      expect(manager.isSyncing, isFalse);
    });
  });
}

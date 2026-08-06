# Core & Shared Module Bug Fixes

**Ngày tạo**: 2026-08-06  
**Phạm vi**: Fix cho các bug P0 (Critical) và P1 (High) từ `docs/bugs/00_core_shared_bugs.md`

---

## Mục lục

1. [C01: IsarService.init() swallow exception](#c01-isarserviceinit-swallow-exception)
2. [C02: SyncManager.registerSyncHandler() duplicate handlers](#c02-syncmanagerregistersynchandler-duplicate-handlers)
3. [C03: SyncManager.startListening() StreamSubscription leak](#c03-syncmanagerstartlistening-streamsubscription-leak)
4. [C04: SyncManager._autoSyncTimer not disposed](#c04-syncmanager_autosynctimer-not-disposed)
5. [C05: OdooApiClient singleton broken after dispose](#c05-odooapiclient-singleton-broken-after-dispose)
6. [C06: Multi-user data isolation missing](#c06-multi-user-data-isolation-missing)
7. [C07: Navigator pushNamed crash + hardcoded orderOdooId](#c07-navigator-pushnamed-crash--hardcoded-orderodooid)
8. [H05: OdooApiClient.callKw() missing timeout](#h05-odooapiclientcallkw-missing-timeout)
9. [H06: GoRouter redirect guard missing](#h06-gorouter-redirect-guard-missing)
10. [H09: Provider state leakage on logout](#h09-provider-state-leakage-on-logout)
11. [H10: Image.file without errorBuilder](#h10-imagefile-without-errorbuilder)
12. [H11: Batch photo upload try-catch scope](#h11-batch-photo-upload-try-catch-scope)

---

## C01: IsarService.init() swallow exception

**Severity**: 🔴 CRITICAL (P0)  
**File**: `lib/core/database/isar_service.dart`  
**Lines**: 36-57

### Mô tả
`try-catch` trong `init()` chỉ `debugPrint` ở debug mode, không re-throw. Nếu Isar init thất bại (quyền file, đĩa đầy, schema conflict), `_db` vẫn là `null` nhưng app tiếp tục chạy → mọi truy vấn DB sau đó ném `StateError` lúc runtime.

### Code BEFORE
```dart
Future<void> init(List<CollectionSchema<dynamic>> schemas) async {
  if (isInitialized) return;

  try {
    String path = '';
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path;
    }

    _db = await Isar.open(
      schemas,
      directory: path,
      name: 'fieldforce_db',
      inspector: false,
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Lỗi khởi tạo Isar DB: $e\n$stackTrace');
    }
  }
}
```

### Code AFTER
```dart
Future<void> init(List<CollectionSchema<dynamic>> schemas) async {
  if (isInitialized) return;

  try {
    String path = '';
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path;
    }

    _db = await Isar.open(
      schemas,
      directory: path,
      name: 'fieldforce_db',
      inspector: false,
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Lỗi khởi tạo Isar DB: $e\n$stackTrace');
    }
    // RE-THROW để main.dart bắt được và điều hướng UI lỗi
    throw IsarInitializationException('Không thể khởi tạo database offline: $e');
  }
}
```

### Thêm Exception class mới
```dart
/// Exception ném ra khi Isar không thể khởi tạo.
/// main.dart catch để hiển thị màn hình bảo trì/lỗi DB.
class IsarInitializationException implements Exception {
  final String message;
  const IsarInitializationException(this.message);
  @override
  String toString() => 'IsarInitializationException: $message';
}
```

### Test Case
```dart
// test/isar_service_test.dart
test('IsarService.init throws on schema conflict', () async {
  // Setup: create conflicting schema
  await expectLater(
    IsarService.instance.init([conflictingSchema]),
    throwsA(isA<IsarInitializationException>()),
  );
});
```

---

## C02: SyncManager.registerSyncHandler() duplicate handlers

**Severity**: 🔴 CRITICAL (P0)  
**File**: `lib/core/database/sync_manager.dart`  
**Lines**: 110-114

### Mô tả
`registerSyncHandler()` không kiểm tra trùng lặp → gọi nhiều lần (hot reload, restart sync) dẫn đến handler chạy nhiều lần cho cùng một sync tick.

### Code BEFORE
```dart
final List<Future<void> Function()> _syncHandlers = [];

void registerSyncHandler(Future<void> Function() handler) {
  _syncHandlers.add(handler);
}
```

### Code AFTER
```dart
final List<Future<void> Function()> _syncHandlers = [];

void registerSyncHandler(Future<void> Function() handler) {
  // Tránh đăng ký trùng lặp handler (so sánh bằng function reference)
  if (!_syncHandlers.contains(handler)) {
    _syncHandlers.add(handler);
  } else if (kDebugMode) {
    debugPrint('SyncManager: handler đã tồn tại, bỏ qua đăng ký trùng');
  }
}

/// Unregister handler khi feature unload (ví dụ logout, dispose provider)
void unregisterSyncHandler(Future<void> Function() handler) {
  _syncHandlers.remove(handler);
}

/// Clear tất cả handlers (gọi khi logout để tránh leak)
void clearSyncHandlers() {
  _syncHandlers.clear();
}
```

### Test Case
```dart
// test/sync_manager_test.dart
test('registerSyncHandler prevents duplicates', () {
  final handler = () async {};
  SyncManager.instance.registerSyncHandler(handler);
  SyncManager.instance.registerSyncHandler(handler);
  
  // Chỉ có 1 handler
  expect(SyncManager.instance._syncHandlers.length, equals(1));
});
```

---

## C03: SyncManager.startListening() StreamSubscription leak

**Severity**: 🔴 CRITICAL (P0)  
**File**: `lib/core/database/sync_manager.dart`  
**Lines**: 25-32

### Mô tả
`_connectivity.onConnectivityChanged.listen()` trả về `StreamSubscription` nhưng không lưu → không bao giờ cancel khi logout/app terminate → leak memory và callback ghost.

### Code BEFORE
```dart
void startListening() {
  _connectivity.onConnectivityChanged.listen((results) async {
    final isOnline = await _connectivity.isOnline;
    if (isOnline && !_isSyncing && await _allowedByNetworkPref()) {
      await syncPending();
    }
  });
}
```

### Code AFTER
```dart
StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

void startListening() {
  // Cancel subscription cũ nếu có (idempotent)
  _connectivitySubscription?.cancel();
  
  _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
    final isOnline = await _connectivity.isOnline;
    if (isOnline && !_isSyncing && await _allowedByNetworkPref()) {
      await syncPending();
    }
  }, onError: (error) {
    if (kDebugMode) {
      debugPrint('SyncManager connectivity stream error: $error');
    }
  });
}

/// Cancel subscription khi logout/app terminate
void stopListening() {
  _connectivitySubscription?.cancel();
  _connectivitySubscription = null;
}
```

### Test Case
```dart
// test/sync_manager_test.dart
test('startListening creates subscription, stopListening cancels it', () {
  SyncManager.instance.startListening();
  expect(SyncManager.instance._connectivitySubscription, isNotNull);
  
  SyncManager.instance.stopListening();
  expect(SyncManager.instance._connectivitySubscription, isNull);
});
```

---

## C04: SyncManager._autoSyncTimer not disposed

**Severity**: 🔴 CRITICAL (P0)  
**File**: `lib/core/database/sync_manager.dart`  
**Lines**: 23, 46-61

### Mô tả
`Timer.periodic` không bị dispose khi logout/app terminate → callback `_autoTick()` tiếp tục chạy, gọi `syncPending()` sau khi user đã logout → truy cập DB/User session đã xóa.

### Code BEFORE
```dart
Timer? _autoSyncTimer;

void _restartTimer() {
  _autoSyncTimer?.cancel();
  _autoSyncTimer = null;
  final minutes = SettingsRepository.instance.autoSyncMinutes;
  if (minutes <= 0) return;
  _autoSyncTimer = Timer.periodic(
    Duration(minutes: minutes),
    (_) => _autoTick(),
  );
}
```

### Code AFTER
```dart
Timer? _autoSyncTimer;

void _restartTimer() {
  _autoSyncTimer?.cancel();
  _autoSyncTimer = null;
  final minutes = SettingsRepository.instance.autoSyncMinutes;
  if (minutes <= 0) return;
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

/// Dispose timer khi logout/app terminate
void dispose() {
  _autoSyncTimer?.cancel();
  _autoSyncTimer = null;
  stopListening(); // Cũng dọn subscription connectivity
  clearSyncHandlers(); // Và clear handlers
}
```

### Thêm dispose trong AuthService.logout()
```dart
// lib/core/auth/auth_service.dart
Future<void> logout() async {
  await _sessionManager.logout();
  await _storage.clearSession();
  
  // FIX C04: Dispose SyncManager để dọn timer + subscription
  SyncManager.instance.dispose();
}
```

### Test Case
```dart
// test/sync_manager_test.dart
test('dispose cancels timer and subscription', () {
  SyncManager.instance.startAutoSync(); // tạo timer
  SyncManager.instance.startListening(); // tạo subscription
  
  SyncManager.instance.dispose();
  
  expect(SyncManager.instance._autoSyncTimer, isNull);
  expect(SyncManager.instance._connectivitySubscription, isNull);
});
```

---

## C05: OdooApiClient singleton broken after dispose

**Severity**: 🔴 CRITICAL (P0)  
**File**: `lib/core/api/odoo_client.dart`  
**Lines**: 68-73

### Mô tả
`dispose()` set `_instance = null` → singleton broken. Sau logout→login lại, `OdooApiClient.instance` trả về instance mới nhưng `_client` chưa được `initialize()` → crash `OdooConnectionException`.

### Code BEFORE
```dart
static OdooApiClient? _instance;
static OdooApiClient get instance => _instance ??= OdooApiClient._();

void dispose() {
  _client?.close();
  _client = null;
  _instance = null; // BROKEN: singleton bị phá vỡ
}
```

### Code AFTER
```dart
static OdooApiClient? _instance;
static OdooApiClient get instance => _instance ??= OdooApiClient._();

/// Chỉ reset internal client, KHÔNG destroy singleton instance.
/// Cho phép re-initialize() sau logout/login mà không cần tạo object mới.
void dispose() {
  _client?.close();
  _client = null;
  // KHÔNG set _instance = null
}

/// Full reset (chỉ dùng cho test hoặc force re-login hoàn toàn)
@visibleForTesting
static void resetInstance() {
  _instance?.dispose();
  _instance = null;
}
```

### Cập nhật AuthService.logout()
```dart
// lib/core/auth/auth_service.dart
Future<void> logout() async {
  await _sessionManager.logout();
  await _storage.clearSession();
  
  // FIX C04 + C05: Dispose SyncManager, KHÔNG dispose OdooApiClient singleton
  SyncManager.instance.dispose();
  // OdooApiClient.instance.dispose(); // KHÔNG gọi cái này nữa
}
```

### Test Case
```dart
// test/odoo_client_test.dart
test('singleton survives dispose/re-initialize cycle', () {
  final client1 = OdooApiClient.instance;
  client1.initialize('http://test.com');
  
  client1.dispose(); // Chỉ clear _client
  
  final client2 = OdooApiClient.instance;
  expect(identical(client1, client2), isTrue); // Cùng instance
  
  client2.initialize('http://test2.com'); // Re-initialize OK
  expect(client2.isInitialized, isTrue);
});
```

---

## C06: Multi-user data isolation missing

**Severity**: 🔴 CRITICAL (P0)  
**Files**: 
- `lib/features/orders/models/fsm_order.dart`
- `lib/features/orders/services/orders_service.dart`
- `lib/core/auth/auth_service.dart`

### Mô tả
Offline data (FsmOrder, StockMove, Timesheet, Expense, WorkReport) không có trường `localOwnerId` → User A logout, User B login → User B thấy data của User A.

### Fix 1: Cập nhật Model Schema
**File**: `lib/features/orders/models/fsm_order.dart`

```dart
@collection
class FsmOrder {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int odooId;

  // BỔ SUNG: trường isolation user
  @Index()
  int? localOwnerId; 
  
  // ... các fields hiện có
}
```

**File**: `lib/features/stock/models/stock_move.dart`
```dart
@collection
class StockMove {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int orderOdooId;
  
  // BỔ SUNG
  @Index()
  int? localOwnerId;
  
  // ...
}
```

**File**: `lib/features/timesheet/models/timesheet_entry.dart`
```dart
@collection
class TimesheetEntry {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int orderOdooId;
  
  // BỔ SUNG
  @Index()
  int? localOwnerId;
  
  // ...
}
```

**File**: `lib/features/expense/models/expense.dart`
```dart
@collection
class Expense {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int orderOdooId;
  
  // BỔ SUNG
  @Index()
  int? localOwnerId;
  
  // ...
}
```

**File**: `lib/features/work_order/models/work_report.dart`
```dart
@collection
class WorkReport {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int orderOdooId;
  
  // BỔ SUNG
  @Index()
  int? localOwnerId;
  
  // ...
}
```

### Fix 2: Gán Owner và Lọc dữ liệu
**File**: `lib/features/orders/services/orders_service.dart`

```dart
Future<List<FsmOrder>> _resolveConflictsAndSave(List<FsmOrder> fetchedOrders) async {
  final currentUserId = _odoo.currentUserId;
  if (currentUserId == null) return [];
  
  final cleanOrders = fetchedOrders.map((order) {
    order.localOwnerId = currentUserId; // Stamp local owner!
    return order;
  }).toList();
  
  // ... save to Isar
  await _isar.db.writeTxn(() async {
    for (final order in cleanOrders) {
      await _isar.db.fsmOrders.put(order);
    }
  });
  return cleanOrders;
}

Future<List<FsmOrder>> loadCachedOrders() async {
  final currentUserId = _odoo.currentUserId;
  if (currentUserId == null) return [];
  
  // LỌC THEO USER CHÍNH XÁC
  return _isar.db.fsmOrders
      .filter()
      .localOwnerIdEqualTo(currentUserId)
      .findAll();
}
```

Tương tự cập nhật `StockService`, `TimesheetService`, `ExpenseService`, `WorkOrderService`:
- Thêm `localOwnerId = currentUserId` khi tạo/save entity
- Filter `.localOwnerIdEqualTo(currentUserId)` khi query

### Fix 3: Clear DB khi Logout
**File**: `lib/core/auth/auth_service.dart`

```dart
Future<void> logout() async {
  await _sessionManager.logout();
  await _storage.clearSession();
  
  // FIX C04: Dispose SyncManager
  SyncManager.instance.dispose();
  
  // FIX C06: Xoá trắng database Isar cục bộ phòng chống lộ lọt thông tin ngoại tuyến
  if (IsarService.instance.isInitialized) {
    final isar = IsarService.instance.db;
    await isar.writeTxn(() async {
      await isar.clear(); // Xoá TẤT CẢ collections
    });
  }
}
```

### Test Case
```dart
// test/multi_user_isolation_test.dart
test('User B cannot see User A offline data', () async {
  // Login User A
  await authService.login(serverUrl, db, 'userA', 'pass');
  await ordersService.fetchAndCacheOrders(); // Cache orders cho User A
  
  // Logout User A
  await authService.logout();
  
  // Login User B
  await authService.login(serverUrl, db, 'userB', 'pass');
  
  // User B offline mode
  await connectivityService.setOffline();
  
  // Load cached orders - phải rỗng
  final orders = await ordersService.loadCachedOrders();
  expect(orders, isEmpty);
});
```

---

## C07: Navigator pushNamed crash + hardcoded orderOdooId

**Severity**: 🔴 CRITICAL (P0)  
**Files**: 
- `lib/core/routing/app_router.dart`
- `lib/features/stock/pages/stock_moves_page.dart`
- `lib/features/stock/pages/scanner_page.dart`

### Mô tả
1. `StockMovesPage` dùng `Navigator.pushNamed('/scanner')` nhưng app dùng GoRouter → crash `Could not find a generator for route`
2. `ScannerPage` hardcoded `orderOdooId: 0` khi gọi `provider.recordOut()` → stock move gán sai đơn hàng

### Fix 1: Cập nhật Route Scanner
**File**: `lib/core/routing/app_router.dart`

```dart
// THAY ĐỔI route scanner từ path đơn giản sang có parameter
GoRoute(
  path: '${RouteNames.scanner}/:orderId', // path: '/scanner/:orderId'
  name: 'scanner',
  builder: (context, state) {
    final orderIdStr = state.pathParameters['orderId'] ?? '0';
    return ScannerPage(orderId: int.tryParse(orderIdStr) ?? 0);
  },
),
```

### Fix 2: Cập nhật StockMovesPage navigation
**File**: `lib/features/stock/pages/stock_moves_page.dart`

```dart
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'fab_scanner',
  onPressed: () {
    // DÙNG GOROUTER VỚI PARAMETER orderId
    context.push('${RouteNames.scanner}/${widget.orderId}');
  },
  // ...
),
```

### Fix 3: ScannerPage nhận orderId
**File**: `lib/features/stock/pages/scanner_page.dart`

```dart
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.orderId}); // BẮT BUỘC
  
  final int orderId; // Nhận orderId từ router

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

// ... Trong _ProductFoundPanel:
onRecord: (qty) async {
  await provider.recordOut(
    orderOdooId: widget.orderId, // GỬI ĐỘNG ID THAY THẾ 0 HARDCODED
    qty: qty,
  );
  if (context.mounted) {
    setState(() => _processingBarcode = false);
  }
},
```

### Test Case
```dart
// test/scanner_navigation_test.dart
test('ScannerPage receives correct orderId from route', () async {
  // Navigate via GoRouter
  await appRouter.push('/scanner/42');
  
  // Verify ScannerPage nhận orderId = 42
  final scannerPage = find.byType(ScannerPage);
  expect(scannerPage, findsOneWidget);
  
  // Verify recordOut được gọi với orderOdooId = 42
  // (mock provider.recordOut và verify argument)
});
```

---

## H05: OdooApiClient.callKw() missing timeout

**Severity**: 🟠 HIGH (P1)  
**File**: `lib/core/api/odoo_client.dart`  
**Lines**: 42-66

### Mô tả
`callKw()` không có timeout → treo vô tận nếu server không phản hồi (network hang, server down).

### Code BEFORE
```dart
Future<dynamic> callKw({
  required String model,
  required String method,
  required List<dynamic> args,
  Map<String, dynamic> kwargs = const {},
}) async {
  try {
    return await client.callKw({
      'model': model,
      'method': method,
      'args': args,
      'kwargs': kwargs,
    });
  } on OdooSessionExpiredException {
    throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
  } on OdooException catch (e) {
    // ...
  } catch (e) {
    throw OdooConnectionException('Không thể kết nối tới Odoo: $e');
  }
}
```

### Code AFTER
```dart
// Thêm constant timeout mặc định
static const Duration _defaultTimeout = Duration(seconds: 30);

Future<dynamic> callKw({
  required String model,
  required String method,
  required List<dynamic> args,
  Map<String, dynamic> kwargs = const {},
  Duration? timeout, // Cho phép override timeout
}) async {
  try {
    final call = client.callKw({
      'model': model,
      'method': method,
      'args': args,
      'kwargs': kwargs,
    });
    
    // Apply timeout
    return await call.timeout(
      timeout ?? _defaultTimeout,
      onTimeout: () {
        throw OdooConnectionException(
          'Yêu cầu tới Odoo timeout sau ${(timeout ?? _defaultTimeout).inSeconds} giây '
          '(model: $model, method: $method)',
        );
      },
    );
  } on OdooSessionExpiredException {
    throw const OdooAuthException('Phiên đăng nhập đã hết hạn.');
  } on OdooException catch (e) {
    final msg = e.message;
    if (msg.contains('Access Denied') || msg.contains('access rights')) {
      throw OdooAuthException(msg);
    }
    throw OdooBusinessException(msg);
  } on TimeoutException catch (e) {
    throw OdooConnectionException('Timeout kết nối Odoo: $e');
  } catch (e) {
    throw OdooConnectionException('Không thể kết nối tới Odoo: $e');
  }
}
```

### Test Case
```dart
// test/odoo_client_timeout_test.dart
test('callKw throws on timeout', () async {
  // Mock client.callKw để delay vô tận
  when(mockClient.callKw(any)).thenAnswer((_) async {
    await Future.delayed(Duration(seconds: 60));
    return 'result';
  });
  
  await expectLater(
    OdooApiClient.instance.callKw(
      model: 'test', 
      method: 'test', 
      args: [], 
      timeout: Duration(milliseconds: 100),
    ),
    throwsA(isA<OdooConnectionException>()),
  );
});
```

---

## H06: GoRouter redirect guard missing

**Severity**: 🟠 HIGH (P1)  
**File**: `lib/core/routing/app_router.dart`

### Mô tả
Không có `redirect` guard → user chưa login vẫn truy cập được `/orders`, `/work-order/1`, etc. Can thiệp vào route logic.

### Code AFTER (thêm redirect vào GoRouter constructor)
```dart
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  
  // REDIRECT GUARD
  redirect: (context, state) {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    final isLoggingIn = state.matchedLocation == RouteNames.login;
    final isSplash = state.matchedLocation == RouteNames.splash;
    
    // Cho phép splash, login không cần auth
    if (isSplash || isLoggingIn) return null;
    
    // Chưa login → redirect về login
    if (!isLoggedIn) {
      return RouteNames.login;
    }
    
    // Đã login mà đang ở login → về orders
    if (isLoggedIn && isLoggingIn) {
      return RouteNames.orders;
    }
    
    return null; // Không redirect
  },
  
  routes: [ ... ],
);
```

### Cần import
```dart
import '../auth/auth_service.dart';
```

### Test Case
```dart
// test/route_guard_test.dart
test('redirect to login when not authenticated', () async {
  // Ensure not logged in
  AuthService.instance._sessionManager._currentSession = null;
  
  final router = appRouter;
  final redirect = router.routeInformationProvider 
      ?.routerDelegate.currentConfiguration.routes
      // Verify redirect logic
      // Hoặc dùng GoRouter testing utility
});
```

---

## H09: Provider state leakage on logout

**Severity**: 🟠 HIGH (P1)  
**Files**: Các Provider files (OrdersProvider, StockProvider, TimesheetProvider, ExpenseProvider, WorkOrderProvider)

### Mô tả
Khi logout, các Provider giữ state cũ (lists, selected items) → User B login thấy data của User A trong UI cho đến khi reload.

### Fix Pattern: Thêm `clear()` method và gọi từ AuthProvider/Logout flow

**File**: `lib/features/orders/providers/orders_provider.dart`
```dart
class OrdersProvider extends ChangeNotifier {
  List<FsmOrder> _orders = [];
  FsmOrder? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;
  
  // ... existing code ...
  
  /// Clear tất cả state khi logout
  void clear() {
    _orders = [];
    _selectedOrder = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
```

**File**: `lib/features/stock/providers/stock_provider.dart`
```dart
class StockProvider extends ChangeNotifier {
  List<StockMove> _moves = [];
  Product? _scannedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  
  // ... existing code ...
  
  void clear() {
    _moves = [];
    _scannedProduct = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearScanned() {
    _scannedProduct = null;
    notifyListeners();
  }
}
```

Tương tự cho: `TimesheetProvider`, `ExpenseProvider`, `WorkOrderProvider`.

### Gọi clear khi logout
**File**: `lib/features/auth/providers/auth_provider.dart` (hoặc nơi handle logout)

```dart
class AuthProvider extends ChangeNotifier {
  // ...
  
  Future<void> logout() async {
    await _authService.logout();
    
    // Clear TẤT CẢ providers
    _ordersProvider.clear();
    _stockProvider.clear();
    _timesheetProvider.clear();
    _expenseProvider.clear();
    _workOrderProvider.clear();
    
    notifyListeners();
  }
}
```

### Test Case
```dart
// test/provider_leakage_test.dart
test('Providers cleared on logout', () async {
  // Login User A, load data
  await authProvider.login(...);
  await ordersProvider.loadOrders();
  expect(ordersProvider.orders, isNotEmpty);
  
  // Logout
  await authProvider.logout();
  
  // Verify providers cleared
  expect(ordersProvider.orders, isEmpty);
  expect(stockProvider.moves, isEmpty);
  // ...
});
```

---

## H10: Image.file without errorBuilder

**Severity**: 🟠 HIGH (P1)  
**Files**: 
- `lib/features/expense/pages/expense_page.dart` (line 326-331)
- `lib/features/expense/widgets/receipt_image_picker.dart`
- `lib/features/work_order/widgets/customer_signature_widget.dart` (line 85-88)
- `lib/features/work_order/widgets/photo_capture_widget.dart`
- `lib/screens/work_order_detail_screen.dart`

### Mô tả
`Image.file(File(path))` không có `errorBuilder` → file vật lý bị mất (xoá tay, sync conflict) gây crash layout (Red Screen of Death).

### Fix Pattern: Thêm `errorBuilder` cho TẤT CẢ `Image.file`

**File**: `lib/features/expense/pages/expense_page.dart` (line 323-332)

```dart
// BEFORE
if (expense.receiptImagePath != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(
      File(expense.receiptImagePath!),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
    ),
  )

// AFTER
if (expense.receiptImagePath != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(
      File(expense.receiptImagePath!),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 64,
          height: 64,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
        );
      },
    ),
  )
```

**File**: `lib/features/work_order/widgets/customer_signature_widget.dart` (line 83-88)

```dart
// BEFORE
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.file(
    File(widget.existingSignaturePath!),
    fit: BoxFit.contain,
  ),
)

// AFTER
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.file(
    File(widget.existingSignaturePath!),
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: 120,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text('Chữ ký không tải được', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    },
  ),
)
```

### Helper Widget tái sử dụng (khuyến nghị)
**File**: `lib/shared/widgets/safe_image_file.dart` (tạo mới)

```dart
import 'dart:io';
import 'package:flutter/material.dart';

/// Wrapper an toàn cho Image.file với errorBuilder mặc định.
class SafeImageFile extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeImageFile({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget;
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return placeholder ?? _defaultPlaceholder;
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  static const _defaultPlaceholder = Center(
    child: SizedBox(
      width: 20, height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  static const _defaultErrorWidget = Icon(
    Icons.broken_image, 
    color: Colors.grey, 
    size: 48
  );
}
```

### Test Case
```dart
// test/safe_image_test.dart
test('SafeImageFile shows error widget when file missing', () async {
  await pumpWidget(SafeImageFile(path: '/non/existent/path.png'));
  
  expect(find.byIcon(Icons.broken_image), findsOneWidget);
});
```

---

## H11: Batch photo upload try-catch scope

**Severity**: 🟠 HIGH (P1)  
**File**: `lib/features/work_order/services/work_order_service.dart`  
**Lines**: 204-294

### Mô tả
`try-catch` bao quanh toàn bộ vòng lặp `for (final path in report.photoPaths)` → một ảnh lỗi (file mất, timeout) ném exception ra ngoài, ngắt toàn bộ loop → ảnh kế tiếp không upload.

### Code BEFORE (lines 207-285)
```dart
Future<void> uploadPhotos(WorkReport report) async {
  if (report.photoPaths.isEmpty) return;

  try {
    final updatedSyncedPaths = List<String>.from(report.syncedPhotoPaths);
    final updatedEntries = List<String>.from(report.syncedAttachmentEntries);
    
    // ... build lookup maps ...

    for (final path in report.photoPaths) {
      if (updatedSyncedPaths.contains(path)) continue;
      
      // Xử lý ảnh - NẾM EXCEPTION SẼ THOÁT KHỎI VÒNG LẶP
      final file = File(path);
      if (!await file.exists()) continue;
      
      // ... upload logic ...
      
      updatedSyncedPaths.add(path);
      report.syncedPhotoPaths = updatedSyncedPaths;
      await _isar.db.writeTxn(() async {
        await _isar.db.workReports.put(report);
      });
    }
  } on OdooApiException catch (e) {
    logger.w('WorkOrderService.uploadPhotos: Lỗi Odoo API khi tải ảnh', error: e);
  } on IOException catch (e) {
    logger.w('WorkOrderService.uploadPhotos: Lỗi đọc file hoặc mạng khi tải ảnh', error: e);
  }
}
```

### Code AFTER
```dart
Future<void> uploadPhotos(WorkReport report) async {
  if (report.photoPaths.isEmpty) return;

  final updatedSyncedPaths = List<String>.from(report.syncedPhotoPaths);
  final updatedEntries = List<String>.from(report.syncedAttachmentEntries);

  // Build lookup: path → attachmentId
  final attIdByPath = <String, int>{};
  for (final entry in updatedEntries) {
    final parts = entry.split('|');
    if (parts.length == 2) {
      final val = int.tryParse(parts[1]);
      if (val != null) {
        attIdByPath[parts[0]] = val;
      }
    }
  }

  for (final path in report.photoPaths) {
    if (updatedSyncedPaths.contains(path)) {
      continue; // Bỏ qua ảnh đã sync hoàn chỉnh
    }

    // WRAP XỬ LÝ RIÊNG TỪNG FILE - TRÁNH HỎNG TOÀN BỘ HÀNG ĐỢI
    try {
      final file = File(path);
      if (!await file.exists()) {
        logger.w('WorkOrderService.uploadPhotos: File not found, skipping: $path');
        continue;
      }

      final filename = file.uri.pathSegments.last;

      // Check nếu đã có attachment ID persisted từ lần retry trước
      int attId;
      if (attIdByPath.containsKey(path) && attIdByPath[path] != null) {
        attId = attIdByPath[path]!;
        logger.i('WorkOrderService.uploadPhotos: reusing persisted attachment $attId for $filename');
      } else {
        // 1. Tạo attachment mới
        final base64String = await compute(_encodeBase64Isolate, path);
        attId = await _odoo.callKw(
          model: 'ir.attachment',
          method: 'create',
          args: [
            {
              'name': filename,
              'datas': base64String,
              'mimetype': _mimeFromExtension(path),
              'res_model': 'fsm.order',
              'res_id': report.orderOdooId,
            }
          ],
        ) as int;

        // Persist ngay "path|attId" — trước message_post để retry không tạo duplicate
        updatedEntries.add('$path|$attId');
        report.syncedAttachmentEntries = updatedEntries;
        await _isar.db.writeTxn(() async {
          await _isar.db.workReports.put(report);
        });
      }

      // 2. Post message link tới attachment
      await _odoo.callKw(
        model: 'fsm.order',
        method: 'message_post',
        args: [
          [report.orderOdooId]
        ],
        kwargs: {
          'body': 'Ảnh hiện trường: $filename',
          'message_type': 'comment',
          'subtype_xmlid': 'mail.mt_comment',
          'attachment_ids': [attId],
        },
      );

      // Cả attachment + message_post thành công → mới cập nhật syncedPhotoPaths
      updatedSyncedPaths.add(path);
      report.syncedPhotoPaths = updatedSyncedPaths;
      await _isar.db.writeTxn(() async {
        await _isar.db.workReports.put(report);
      });
    } on OdooApiException catch (e) {
      logger.w('WorkOrderService.uploadPhotos: Lỗi Odoo API cho ảnh $path', error: e);
      // CONTINUE VỚI ẢNH TIẾP THEO
    } on IOException catch (e) {
      logger.w('WorkOrderService.uploadPhotos: Lỗi đọc file cho ảnh $path', error: e);
      // CONTINUE VỚI ẢNH TIẾP THEO
    } catch (e, stackTrace) {
      logger.e('WorkOrderService.uploadPhotos: Lỗi không xác định cho ảnh $path', error: e, stackTrace: stackTrace);
      // CONTINUE VỚI ẢNH TIẾP THEO
    }
  }
}
```

### Test Case
```dart
// test/work_order_upload_test.dart
test('uploadPhotos continues after single photo failure', () async {
  // Setup: 3 photos, photo 2 sẽ fail
  final report = WorkReport.create(orderOdooId: 1);
  report.photoPaths = ['/photo1.jpg', '/photo2.jpg', '/photo3.jpg'];
  
  // Mock: photo1 OK, photo2 throw, photo3 OK
  when(odoo.callKw(model: 'ir.attachment', ...)).thenAnswer((invocation) async {
    final path = invocation.positionalArguments[0]['name'] as String;
    if (path == 'photo2.jpg') throw OdooApiException('Server error');
    return 123; // attachment ID
  });
  
  await workOrderService.uploadPhotos(report);
  
  // Verify photo1 và photo3 được sync, photo2 bị skip
  expect(report.syncedPhotoPaths, contains('/photo1.jpg'));
  expect(report.syncedPhotoPaths, contains('/photo3.jpg'));
  expect(report.syncedPhotoPaths, isNot(contains('/photo2.jpg')));
});
```

---

## Tóm tắt File Cần Sửa (Group by File)

| File | Bugs Fixed |
|------|------------|
| `lib/core/database/isar_service.dart` | C01 |
| `lib/core/database/sync_manager.dart` | C02, C03, C04 |
| `lib/core/api/odoo_client.dart` | C05, H05 |
| `lib/core/auth/auth_service.dart` | C04, C05, C06 |
| `lib/core/auth/secure_storage.dart` | (support C06) |
| `lib/core/routing/app_router.dart` | C07, H06 |
| `lib/features/orders/models/fsm_order.dart` | C06 |
| `lib/features/stock/models/stock_move.dart` | C06 |
| `lib/features/timesheet/models/timesheet_entry.dart` | C06 |
| `lib/features/expense/models/expense.dart` | C06 |
| `lib/features/work_order/models/work_report.dart` | C06 |
| `lib/features/orders/services/orders_service.dart` | C06 |
| `lib/features/stock/services/stock_service.dart` | C06 |
| `lib/features/timesheet/services/timesheet_service.dart` | C06 |
| `lib/features/expense/services/expense_service.dart` | C06 |
| `lib/features/work_order/services/work_order_service.dart` | C06, H11 |
| `lib/features/stock/pages/stock_moves_page.dart` | C07 |
| `lib/features/stock/pages/scanner_page.dart` | C07 |
| `lib/features/expense/pages/expense_page.dart` | H10 |
| `lib/features/expense/widgets/receipt_image_picker.dart` | H10 |
| `lib/features/work_order/widgets/customer_signature_widget.dart` | H10 |
| `lib/features/work_order/widgets/photo_capture_widget.dart` | H10 |
| `lib/screens/work_order_detail_screen.dart` | H10 |
| `lib/shared/widgets/safe_image_file.dart` | H10 (new helper) |
| Provider files (orders, stock, timesheet, expense, work_order) | H09 |
| `lib/features/auth/providers/auth_provider.dart` | H09 |

---

## Ưu tiên Triển Khai

1. **P0 - Critical (C01-C07)**: Fix ngay lập tức - ngăn chặn crash, data leak, broken auth flow
2. **P1 - High (H05, H06, H09, H10, H11)**: Fix trong sprint hiện tại - timeout, route guard, provider leakage, image crash, upload resilience

---

## Validation Checklist

- [ ] Tất cả P0 bugs đã có fix code
- [ ] Tất cả P1 bugs đã có fix code  
- [ ] Unit tests viết cho từng fix
- [ ] Integration test: Multiple users login/logout cycle
- [ ] Integration test: Offline → Online sync flow
- [ ] Manual test: Scanner navigation với orderId
- [ ] Manual test: Image.file errorBuilder hiển thị đúng khi file mất
- [ ] Manual test: Batch upload tiếp tục khi 1 ảnh fail
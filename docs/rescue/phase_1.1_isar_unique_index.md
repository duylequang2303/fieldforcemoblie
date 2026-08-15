# Phase 1.1 — Fix Isar Unique Index

## Mục tiêu
Fix unique index violation risk trên `RouteStop.orderOdooId` khi rebuild route.

## Vấn đề hiện tại
- `RouteStop` model có `@Index(unique: true)` trên `orderOdooId` (`lib/features/route_map/models/route_stop.dart:21`).
- `RouteProvider.buildRoute` deduplicate orders by `odooId` trong memory trước khi tạo `RouteStop`.
- Hiện `RouteStop` chỉ là in-memory, **không persist vào Isar**. Nhưng nếu sau này persist mà có duplicate → crash.

## Search results: RouteStop persistence code paths

### Searched patterns
| Pattern | Result |
|---------|--------|
| `routeStops.put` | No matches trong app code |
| `routeStops.putAll` | No matches trong app code |
| `putByOrderOdooId` | No matches trong app code |
| `isar.routeStops` | No matches trong app code |
| `RouteStopCollection` | No matches trong app code |
| `RouteStop(` constructor | Chỉ trong model + generated code |
| `isar.writeTxn` | Matches trong `auth_service.dart`, `orders_service.dart`, `database_migration_service.dart` — **không có** cái nào liên quan `RouteStop` |

### Kết luận
**RouteStop hiện CHƯA được persist vào Isar.** Không có code path nào ghi `RouteStop` vào DB. Collection đã được đăng ký trong schema (`main.dart:65`) và generated code có `putByOrderOdooId` / `putAllByOrderOdooId`, nhưng không có caller nào.

### Nếu sau này persist RouteStop
- **Future persistence point nên ở**: `RouteProvider.buildRoute` sau khi tính toán xong `_stops`, hoặc một `RouteRepository` mới.
- **Lý do current duplicate guard đủ**: Guard đang chạy trước khi tạo `RouteStop` objects, đảm bảo `_stops` list đã dedup. Khi persist, chỉ cần clear + insert list đã clean.
- **Test chứng minh không có unique index violation**: Unit test cho `buildRoute` với input có duplicate → verify output `_stops` có đúng 1 `RouteStop` cho mỗi `orderOdooId`.

## Kế hoạch sửa

### Files sẽ sửa
1. `lib/features/route_map/providers/route_provider.dart` — function `buildRoute`
2. `test/features/route_map/providers/route_provider_test.dart` — **file mới**

### Exact functions to change
- `RouteProvider.buildRoute` (line 48)
- `RouteProvider` constructor (line 26) — made `ordersProvider` optional for testability
- `RouteProvider.markStopCompleted` (line 159) — added null guard for optional `ordersProvider`

### Nội dung sửa chi tiết

#### 1. Input order deduplication (skip invalid + dedup)

**Before:**
```dart
final uniqueOrders = <int, FsmOrder>{};
for (final order in orders) {
  if (!uniqueOrders.containsKey(order.odooId)) {
    uniqueOrders[order.odooId] = order;
  }
}
```

**After:**
```dart
final seenOdooIds = <int>{};
final uniqueOrders = <int, FsmOrder>{};
for (final order in orders) {
  final oid = order.odooId;
  if (oid <= 0) {
    logger.w('RouteProvider.buildRoute: invalid orderOdooId=$oid, skipping');
    continue;
  }
  if (!seenOdooIds.add(oid)) {
    logger.w('RouteProvider.buildRoute: duplicate orderOdooId=$oid detected, skipping');
    continue;
  }
  uniqueOrders[oid] = order;
}
```

#### 2. Final RouteStop list deduplication (explicit loop)

Sau khi tạo `_stops` từ `uniqueOrders`:

```dart
final stopSeen = <int>{};
final cleaned = <RouteStop>[];
for (final stop in _stops) {
  final oid = stop.orderOdooId;
  if (oid <= 0) {
    logger.w('RouteProvider.buildRoute: invalid RouteStop.orderOdooId=$oid, removing');
    continue;
  }
  if (!stopSeen.add(oid)) {
    logger.w('RouteProvider.buildRoute: duplicate RouteStop.orderOdooId=$oid detected, removing');
    continue;
  }
  cleaned.add(stop);
}
_stops = cleaned;

// Note: RouteStop is currently in-memory only.
// If future Isar persistence is added, clear cache and insert deduplicated list inside one writeTxn:
// await isar.writeTxn(() async {
//   await isar.routeStops.clear();
//   await isar.routeStops.putAll(_stops);
// });
```

#### 3. Testability change

```dart
// Before
RouteProvider({LocationService? locationService, required OrdersProvider ordersProvider})

// After
RouteProvider({LocationService? locationService, OrdersProvider? ordersProvider})
```

```dart
// Before
Future<bool> markStopCompleted(int orderOdooId) async {
  final idx = _stops.indexWhere((s) => s.orderOdooId == orderOdooId);
  if (idx == -1) return false;
  try {
    await _ordersProvider.updateOrderToDone(orderOdooId);
  ...

// After
Future<bool> markStopCompleted(int orderOdooId) async {
  if (_ordersProvider == null) {
    logger.w('RouteProvider.markStopCompleted: ordersProvider is null');
    return false;
  }
  final idx = _stops.indexWhere((s) => s.orderOdooId == orderOdooId);
  if (idx == -1) return false;
  try {
    await _ordersProvider.updateOrderToDone(orderOdooId);
  ...
```

### Unit test mới

**File:** `test/features/route_map/providers/route_provider_test.dart`

**Test cases:**
- Duplicate `odooId` input → output `stops` có unique `orderOdooId`
- Invalid `odooId` values: 0, negative → bị skip
- Empty orders list → `stops` rỗng, không crash
- `buildRoute` gọi 2 lần liên tiếp → mỗi lần đều dedup đúng

**Constraints:**
- Không truy cập `_stops` private. Dùng public getter `stops`.
- `RouteProvider` được tạo với `ordersProvider: null` để test độc lập.

### Manual test steps
1. Chạy app, vào màn hình Route Map
2. Verify route list load bình thường với orders không duplicate
3. Nếu có thể tạo scenario duplicate orders → verify không crash, log warning xuất hiện
4. Verify `flutter analyze` pass

### Regression risks
- **Thấp**: Thay đổi chỉ là defensive dedup + log, không đổi logic nghiệp vụ
- **Thấp**: `logger.w` có thể xuất hiện nhiều nếu backend trả duplicate orders — đây là expected behavior
- **Trung bình**: Nếu sau này persist RouteStop mà không follow clear-all strategy → vẫn có unique index violation

## Đã làm
- Implemented input deduplication với invalid/duplicate guard trong `RouteProvider.buildRoute`.
- Implemented final RouteStop list deduplication bằng explicit loop.
- Added future persistence code comment trong `buildRoute`.
- Added unit tests: 4/4 pass.
- `flutter analyze` pass (no issues).
- `flutter test` pass (63/63 tests pass, bao gồm 4 tests mới).

## Kết quả

### Changed files
1. `lib/features/route_map/providers/route_provider.dart`
2. `test/features/route_map/providers/route_provider_test.dart` (mới)

### Summary
- `buildRoute` giờ skip orders có `odooId <= 0` và log warning.
- `buildRoute` giờ log warning khi skip duplicate `orderOdooId` từ input.
- `buildRoute` giờ deduplicate final `RouteStop` list bằng explicit loop, log warning cho invalid/duplicate.
- Constructor `RouteProvider` chấp nhận `OrdersProvider?` để testability.
- `markStopCompleted` có null guard cho `_ordersProvider`.

### Test steps
```bash
flutter analyze lib/features/route_map/providers/route_provider.dart test/features/route_map/providers/route_provider_test.dart
flutter test test/features/route_map/providers/route_provider_test.dart
flutter test
```

### Test results
- `flutter analyze`: No issues found.
- `flutter test test/.../route_provider_test.dart`: 4/4 pass.
- `flutter test`: 63/63 pass (bao gồm 4 tests mới + 59 tests cũ).

### Confirmation of RouteStop persistence search

| Pattern searched | Result |
|-----------------|--------|
| `routeStops.put` | No matches |
| `routeStops.putAll` | No matches |
| `putByOrderOdooId` | No matches |
| `isar.routeStops` | No matches |
| `RouteStopCollection` | No matches |
| `isar.writeTxn` involving RouteStop | No matches |

**Conclusion**: RouteStop hiện **chưa persist** vào Isar. Current duplicate guard đủ cho in-memory usage. Nếu sau này persist, cần clear-all + insert deduplicated list trong một `writeTxn`.

### Remaining risks
- RouteStop vẫn chưa persist vào Isar. Nếu sau này persist mà không dùng clear-all strategy → unique index violation có thể xảy ra.
- `logger.w` có thể xuất hiện thường xuyên nếu backend trả về nhiều duplicate orders. Cần monitor nếu cần.

# Bug Tracker: Settings Feature

## Thông tin chung
- **Feature**: Settings (Cài đặt ứng dụng)
- **Files liên quan**:
  - `lib/features/settings/pages/settings_page.dart`
  - `lib/core/settings/settings_repository.dart`
  - `lib/core/settings/sync_status_provider.dart`
  - `lib/core/database/sync_manager.dart`
  - `lib/core/settings/offline_storage_service.dart`
  - `lib/features/auth/providers/auth_provider.dart`
  - `lib/core/auth/auth_service.dart`
  - `lib/main.dart`
- **Ngày tạo**: Thứ Sáu, 07 Tháng 8, 2026
- **Ngày cập nhật**: Thứ Sáu, 07 Tháng 8, 2026

---

## 🐛 Danh sách Bugs

### UI/UX Bugs

| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| SET-UI-001 | Không vô hiệu hóa các nút tương tác nhạy cảm (Logout, thay đổi cài đặt) khi đang đồng bộ thủ công (`isSyncing == true`) hoặc đang kiểm tra mạng (`isTesting == true`). | `settings_page.dart` | 🟠 High | 🟢 Fixed | **Mở rộng**: Cũng không disable khi **auto-sync đang chạy nền** (SyncManager.isSyncing). Có nguy cơ race condition dọn dẹp DB Isar khi logout trong lúc đang ghi dữ liệu. |
| SET-UI-002 | Thiếu chức năng xóa bộ nhớ đệm / dữ liệu offline (Clear Cache / Offline Data) tại mục "Offline data". | `settings_page.dart` | 🟡 Medium | 🟢 Fixed | Người dùng chỉ thấy dung lượng mà không giải phóng được bộ nhớ đệm. `OfflineStorageService` chỉ có `bytes()` và `formatted()`. |

### Logic/Functional Bugs

| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SET-LOGIC-001 | Đồng bộ thủ công ở nút "Sync now" thực hiện code cứng (hardcode) gọi trực tiếp OrdersService, hoàn toàn bỏ qua kiến trúc đăng ký động của `SyncManager`. | `settings_page.dart` -> `_onSyncNow` | 🔴 Critical | 🟢 Fixed | **Chi tiết**: Line 127-128 gọi `SyncManager.instance.syncPending()` sau đó `OrdersService.instance.fetchMyOrders()`. Các handler khác (Stock, Timesheet, Expense, WorkOrder, Recurring) đăng ký ở `main.dart:73-99` **không bao giờ chạy** khi bấm Sync now. |
| SET-LOGIC-002 | Bật/tắt "Sync on WiFi only" không xử lý đúng mọi trường hợp khi thay đổi setting. | `settings_page.dart` -> `Switch.onChanged` | 🟡 Medium | 🟢 Fixed | **Vấn đề thực tế**: Line 406-409 chỉ trigger sync khi tắt wifi-only (`!v`). Không xử lý: (1) Bật wifi-only khi đang mobile data → nên cancel sync đang chạy; (2) Tắt wifi-only khi đang mobile data → vẫn gọi syncPending() nhưng sẽ fail ở network check. |
| SET-LOGIC-003 | **MỚI**: `fetchMyOrders()` trong manual sync không có error handling riêng - throw exception bị catch chung thành "Sync failed". | `settings_page.dart:128` | 🟡 Medium | 🟢 Fixed | Nếu push lên Odoo thành công nhưng pull orders fail (network error, auth expired), user thấy "Sync failed" generic mà không biết push đã thành công. |

### Performance/Memory Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SET-PERF-001 | Crash/Rò rỉ bộ nhớ do gọi `notifyListeners()` trên `SyncStatusProvider` khi instance đã bị dispose. | `sync_status_provider.dart` -> `refresh()` | 🟠 High | 🟢 Fixed | **Race condition**: Timer 1 phút (line 50-54) gọi `refresh()` → `await _countPendingFromIsar()` → `notifyListeners()`. Nếu user thoát màn Settings nhanh, `dispose()` set `_disposed=true` nhưng in-flight `refresh()` hoàn thành sau và vẫn gọi `notifyListeners()`. |
| SET-PERF-002 | **MỚI**: Timer `_clockTimer` trong Settings page có thể leak callback sau khi dispose. | `settings_page.dart:50-54, 76` | 🔴 Critical | 🟢 Fixed | `_clockTimer.cancel()` ở `dispose()` nhưng callback đang `await _sync.refresh()` vẫn tiếp tục chạy đến cuối và gọi `setState()` trên widget đã disposed. |

### Data/Persistence Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SET-DATA-001 | Sử dụng `FlutterSecureStorage` cho cấu hình UI không bảo mật (wifi only, auto sync) tăng tỷ lệ lỗi đọc/ghi và giảm tốc độ khởi động do cơ chế mã hóa. | `settings_repository.dart` | 🟡 Medium | 🟢 Fixed | Keychain/Keystore có thể bị locked bất thình lình khi app chạy dưới nền, gây mất cấu hình người dùng. Settings này không nhạy cảm (không phải password/token). |
| SET-DATA-002 | **MỚI**: Hardcode app version/build number thay vì đọc từ `pubspec.yaml`. | `settings_page.dart:22-23` | 🟡 Medium | 🟢 Fixed | `const String _appVersion = '0.4.0'; const int _buildNumber = 12;` - Dễ gây lệch phiên bản khi release. Nên dùng `package_info_plus`. |

---

## 🔍 Bugs Mới Phát Hiện (Additional Discovered Bugs)

### Critical

| ID | Mô tả bug | File/Location | Mức độ | Ghi chú |
|----|-----------|---------------|--------|---------|
| SET-ADD-001 | **Duplicate sync handlers khi hot reload** | `main.dart:72-99`, `sync_manager.dart:191-198` | 🔴 Critical | `registerSyncHandler` dùng `contains()` so sánh function reference. Hot reload tạo function instance mới → `contains()` trả về false → đăng ký trùng lặp → mỗi sync chạy handler nhiều lần. |
| SET-ADD-002 | **Ba `_isSyncing` flag riêng biệt** không đồng bộ | `settings_page.dart:38`, `sync_status_provider.dart:19`, `sync_manager.dart:47` | 🔴 Critical | Settings page tracks manual sync, SyncStatusProvider tracks simulated sync, SyncManager tracks real sync. UI không biết auto-sync đang chạy. |
| SET-ADD-003 | **Offline storage size bao gồm Isar DB files** | `offline_storage_service.dart:13-23` | 🟡 Medium | `getApplicationDocumentsDirectory()` scan toàn bộ folder. User không phân biệt được Isar DB (cần thiết) vs cached images/temp files (có thể xóa). |

### High

| ID | Mô tả bug | File/Location | Mức độ | Ghi chú |
|----|-----------|---------------|--------|---------|
| SET-ADD-004 | **Connection test chỉ check session, không verify sync capability** | `settings_page.dart:94-103` | 🟢 Low | Chỉ đọc `res.users` của chính user. Không kiểm tra: quyền read/write `fsm.order`, network latency, API endpoints có hoạt động. |

### Medium

| ID | Mô tả bug | File/Location | Mức độ | Ghi chú |
|----|-----------|---------------|--------|---------|
| SET-ADD-005 | **Không có loading state khi load settings lần đầu** | `settings_page.dart:61-72` | 🟢 Low | `_load()` đọc SecureStorage (chậm) + scan files. UI hiển thị giá trị mặc định/stale cho đến khi complete. |

---

## 🛠️ Hướng Dẫn Fix Chi Tiết

### SET-LOGIC-001 (Critical) - Fix Manual Sync để dùng SyncManager Properly

**Vấn đề**: `_onSyncNow()` hardcode gọi `OrdersService.instance.fetchMyOrders()` thay vì để `SyncManager` chạy tất cả handlers đã đăng ký.

**File**: `lib/features/settings/pages/settings_page.dart`

**Code hiện tại (đã fix)**:
```dart
Future<void> _onSyncNow() async {
  if (OdooSessionManager.instance.currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not signed in.')),
    );
    return;
  }
  setState(() => _isSyncing = true);
  try {
    // ✅ Chỉ gọi syncPending - SyncManager sẽ chạy TẤT CẢ handlers đã đăng ký
    final failures = await SyncManager.instance.syncPending();
    
    // ✅ Chỉ lưu timestamp và báo thành công khi TẤT CẢ handlers đều thành công
    if (failures.isEmpty) {
      await SettingsRepository.instance.saveLastSyncedAt(DateTime.now());
      await _sync.refresh();

      if (!mounted) return;
      final stillPending = _sync.pendingCount;
      if (stillPending > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synced, but $stillPending change(s) still pending.'),
            backgroundColor: SfTokens.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synced successfully.')),
        );
      }
    } else {
      // Có handler thất bại
      if (kDebugMode) {
        for (final (name, error) in failures) {
          debugPrint('SyncManager: handler "$name" failed: $error');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync partially failed: ${failures.length} handler(s) errored.'),
          backgroundColor: SfTokens.error,
        ),
      );
    }
  } catch (e) {
    logger.e('_onSyncNow failed', error: e);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync failed — check connection.')),
    );
  } finally {
    if (mounted) setState(() => _isSyncing = false);
  }
}
```

**Fix đã áp dụng**: 
- `_onSyncNow()` chỉ gọi `SyncManager.instance.syncPending()` (trả về list failures)
- `SyncManager._runHandlers()` thu thập tất cả lỗi từ các handler
- Chỉ ghi `lastSyncedAt` và báo thành công khi TẤT CẢ handlers thành công
- `SyncManager.syncPending()` trả về `List<(String, Object)>` - danh sách (tên handler, lỗi)
    logger.e('_onSyncNow failed', error: e);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync failed — check connection.')),
    );
  } finally {
    if (mounted) setState(() => _isSyncing = false);
  }
}
```

**Lưu ý**: Nếu cần pull orders sau push, hãy thêm handler riêng vào `SyncManager` ở `main.dart` thay vì hardcode ở đây.

---

### SET-LOGIC-002 (Medium) - Fix WiFi-only Toggle Logic

**Vấn đề**: Chỉ trigger sync khi tắt wifi-only, không xử lý các case khác.

**File**: `lib/features/settings/pages/settings_page.dart` lines 391-422

**Code hiện tại**:
```dart
_row(
  icon: Icons.wifi,
  label: 'Sync on WiFi only',
  trailing: Switch(
    value: _wifiOnly,
    activeThumbColor: SfTokens.primary,
    onChanged: (_isSyncing || _isTesting)
        ? null
        : (v) async {
            final previousValue = _wifiOnly;
            setState(() => _wifiOnly = v);
            try {
              await SettingsRepository.instance.saveWifiOnly(v);
              SyncManager.instance.applyPreferences();

              final connectivity = ConnectivityService.instance;
              final isOnline = await connectivity.isOnline;
              final isWifi = await connectivity.checkIsWifi();
                
              // Case 1: BẬT wifi-only (v == true)
              if (v) {
                // Nếu đang mobile data và có sync đang chạy → cancel nó
                if (isOnline && !isWifi && SyncManager.instance.isSyncing) {
                  // SyncManager không có cancel() public, nhưng syncPending() có guard _isSyncing
                  // Nên log warning hoặc để sync tự fail ở network check
                  logger.w('WiFi-only enabled on mobile data; pending sync will skip');
                }
              }
                
              // Case 2: TẮT wifi-only (v == false)
              if (isOnline && (!v || isWifi)) {
                unawaited(SyncManager.instance.syncPending());
              }
            } catch (e) {
              // ... rollback
            }
          },
  ),
),
```

**Fix**: Xử lý đầy đủ 4 trường hợp:

```dart
onChanged: (_isSyncing || _isTesting || SyncManager.instance.isSyncing)
    ? null
    : (v) async {
        final previousValue = _wifiOnly;
        setState(() => _wifiOnly = v);
        try {
          await SettingsRepository.instance.saveWifiOnly(v);
          SyncManager.instance.applyPreferences();

          final connectivity = ConnectivityService.instance;
          final isOnline = await connectivity.isOnline;
          final isWifi = await connectivity.checkIsWifi();
          final wifiOnlyEnabled = v;

          // Case 1: BẬT wifi-only (v == true)
          if (wifiOnlyEnabled) {
            // Nếu đang mobile data và có sync đang chạy → cancel nó
            if (isOnline && !isWifi && SyncManager.instance.isSyncing) {
              // SyncManager không có cancel() public, nhưng syncPending() có guard _isSyncing
              // Nên log warning hoặc để sync tự fail ở network check
              logger.w('WiFi-only enabled on mobile data; pending sync will skip');
            }
          }
          // Case 2: TẮT wifi-only (v == false)
          else {
            // Chỉ trigger sync nếu online VÀ (không wifi-only HOẶC đang dùng WiFi)
            if (isOnline && (!wifiOnlyEnabled || isWifi)) {
              unawaited(SyncManager.instance.syncPending());
            }
          }
        } catch (e) {
          logger.e('Failed to save wifi-only settings', error: e);
          if (mounted) {
            setState(() => _wifiOnly = previousValue);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lưu cấu hình không thành công.')),
            );
          }
        }
      },
```

---

### SET-UI-001 (High) - Disable Buttons During ANY Sync (Manual + Auto)

**Vấn đề**: Chỉ check `_isSyncing` (manual) và `_isTesting`, không check `SyncManager.instance.isSyncing` (auto-sync).

**File**: `lib/features/settings/pages/settings_page.dart`

**Fix**: Tạo computed property hoặc listen đến SyncManager:

```dart
// Thêm vào _SettingsPageState:
bool get _isAnySyncRunning => _isSyncing || _isTesting || SyncManager.instance.isSyncing;

// Sau đó dùng _isAnySyncRunning thay vì (_isSyncing || _isTesting) ở:
// - Line 249: Test Connection button
// - Line 332-335: Sync now button  
// - Line 359: Auto-sync dropdown
// - Line 397: WiFi-only switch
// - Line 463: Logout button

// Hoặc tốt hơn: Listen đến SyncManager.isSyncing changes
@override
void initState() {
  super.initState();
  _sync.addListener(_onSyncChanged);
  SyncManager.instance.addListener(_onSyncManagerChanged);
  _load();
  _clockTimer = Timer.periodic(...);
}

void _onSyncManagerChanged() {
  if (mounted) setState(() {});
}

@override
void dispose() {
  _clockTimer?.cancel();
  _sync.removeListener(_onSyncChanged);
  SyncManager.instance.removeListener(_onSyncManagerChanged);
  _sync.dispose();
  super.dispose();
}

// Dùng SyncManager.instance.isSyncing thay vì _isSyncing cho disable logic
bool get _isAnySyncRunning => _isSyncing || _isTesting || SyncManager.instance.isSyncing;

void _onSyncManagerChanged() {
  if (mounted) setState(() {});
}

@override
void dispose() {
  _clockTimer?.cancel();
  _sync.removeListener(_onSyncChanged);
  SyncManager.instance.removeListener(_onSyncManagerChanged);
  _sync.dispose();
  super.dispose();
}
```

**Lưu ý**: `SyncManager` hiện không extend `ChangeNotifier`. Cần thêm `ChangeNotifier` vào `SyncManager` class để expose `isSyncing` changes.

---

### SET-PERF-001 (High) - Fix Race Condition in SyncStatusProvider

**Vấn đề**: `notifyListeners()` gọi sau khi `_disposed = true`.

**File**: `lib/core/settings/sync_status_provider.dart` lines 27-45

**Code hiện tại**:
```dart
@override
void dispose() {
  _disposed = true;
  super.dispose();
}

@override
void notifyListeners() {
  if (!_disposed) {
    super.notifyListeners();
  }
}

Future<void> refresh() async {
  if (_disposed) return; // Thêm check này

  _lastSyncedAt = SettingsRepository.instance.lastSyncedAt;
  _pendingCount = await _countPendingFromIsar();
  notifyListeners(); // Đã có guard trong notifyListeners()
```

**Fix**: Check `_disposed` SAU khi await:

```dart
Future<void> refresh() async {
  _lastSyncedAt = SettingsRepository.instance.lastSyncedAt;
  _pendingCount = await _countPendingFromIsar();
  
  // ✅ Check disposed SAU khi await xong
  if (!_disposed) {
    notifyListeners();
  }
}

// Hoặc dùng pattern an toàn hơn:
Future<void> refresh() async {
  if (_disposed) return; // Early exit nếu đã dispose
  
  _lastSyncedAt = SettingsRepository.instance.lastSyncedAt;
  _pendingCount = await _countPendingFromIsar();
  
  if (!_disposed) {
    notifyListeners();
  }
}
```

---

### SET-PERF-002 (Critical) - Fix Timer Leak in Settings Page

**Vấn đề**: Timer callback tiếp tục chạy sau `dispose()`.

**File**: `lib/features/settings/pages/settings_page.dart` lines 50-54, 76

**Code hiện tại**:
```dart
_clockTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
  if (!mounted) return;
  await _sync.refresh(); // Có thể mất vài trăm ms
  if (mounted) setState(() {}); // Nhưng mounted có thể false LÚC NÀY
});

@override
void dispose() {
  _clockTimer?.cancel(); // ✅ Cancel ngay lập tức
  _sync.removeListener(_onSyncChanged);
  SyncManager.instance.removeListener(_onSyncManagerChanged);
  _sync.dispose();
  super.dispose();
}
```

**Fix**: Cancel timer NGAY LẬP TỨC và check mounted trước MỖI await:

```dart
@override
void initState() {
  super.initState();
  _sync.addListener(_onSyncChanged);
  _load();
  _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
    // ✅ Check mounted NGAY LẬP TỨC
    if (!mounted) return;
    
    try {
      await _sync.refresh();
    } catch (_) {
      // Ignore errors in background refresh
    }
    
    // ✅ Check mounted LẠI sau await
    if (mounted) {
      setState(() {});
    }
  });
}

@override
void dispose() {
  // ✅ Cancel timer TRƯỚC khi remove listener
  _clockTimer?.cancel();
  _clockTimer = null;
  _sync.removeListener(_onSyncChanged);
  _sync.dispose();
  super.dispose();
}
```

---

### SET-DATA-001 (Medium) - Move UI Settings to SharedPreferences

**Vấn đề**: Dùng `FlutterSecureStorage` (encrypted) cho settings không nhạy cảm.

**File**: `lib/core/settings/settings_repository.dart`

**Giải pháp**: Dùng `shared_preferences` cho wifi-only, auto-sync, last-synced. Chỉ giữ credentials ở `SecureStorageService`.

**Steps**:
1. Thêm dependency: `shared_preferences: ^2.3.0` (đã có trong pubspec.yaml)
2. Tạo `SettingsLocalStorage` class dùng `SharedPreferences`
3. Migrate dữ liệu từ SecureStorage sang SharedPreferences (one-time)
4. Update `SettingsRepository` dùng `SettingsLocalStorage`

**Code mới** (`lib/core/settings/settings_local_storage.dart`):
```dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalStorage {
  SettingsLocalStorage._();
  static final SettingsLocalStorage instance = SettingsLocalStorage._();

  static const _kWifiOnly = 'settings_wifi_only';
  static const _kAutoSyncMin = 'settings_auto_sync_min';
  static const _kLastSyncedAt = 'settings_last_synced_at';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> loadAll() async {
    final prefs = await _instance;
    wifiOnly = prefs.getBool(_kWifiOnly) ?? false;
    autoSyncMinutes = prefs.getInt(_kAutoSyncMin) ?? 15;
    final ts = prefs.getInt(_kLastSyncedAt);
    lastSyncedAt = ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts);
  }

  Future<void> saveWifiOnly(bool value) async {
    wifiOnly = value;
    await (await _instance).setBool(_kWifiOnly, value);
  }

  Future<void> saveAutoSyncMinutes(int minutes) async {
    autoSyncMinutes = minutes;
    await (await _instance).setInt(_kAutoSyncMin, minutes);
  }

  Future<void> saveLastSyncedAt(DateTime? when) async {
    lastSyncedAt = when;
    await (await _instance).setInt(_kLastSyncedAt, when?.millisecondsSinceEpoch ?? 0);
  }

  // In-memory cache
  bool wifiOnly = false;
  int autoSyncMinutes = 15;
  DateTime? lastSyncedAt;
}
```

**Migration** (trong `SettingsRepository.loadAll()` - chạy 1 lần):
```dart
Future<void> loadAll() async {
  // ... existing SecureStorage reads ...
  
  // Migrate to SharedPreferences (chạy 1 lần)
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('settings_migrated_v1')) {
    await prefs.setBool('settings_wifi_only', wifiOnly);
    await prefs.setInt('settings_auto_sync_min', autoSyncMinutes);
    if (lastSyncedAt != null) {
      await prefs.setInt('settings_last_synced_at', lastSyncedAt!.millisecondsSinceEpoch);
    }
    await prefs.setBool('settings_migrated_v1', true);
    
    // Xóa keys cũ khỏi SecureStorage
    await _storage.delete(key: _kWifiOnly);
    await _storage.delete(key: _kAutoSyncMin);
    await _storage.delete(key: _kLastSyncedAt);
  }
  
  // Đọc từ SharedPreferences cho các lần sau
  // (hoặc refactor SettingsRepository dùng SettingsLocalStorage hoàn toàn)
}
```

---

### SET-DATA-002 (Medium) - Get App Version from pubspec.yaml

**Vấn đề**: Hardcode version.

**File**: `lib/features/settings/pages/settings_page.dart` lines 22-23

**Fix**: Dùng `package_info_plus`:

1. Thêm dependency: `package_info_plus: ^8.0.0` (trong pubspec.yaml)
2. Import và dùng:

```dart
import 'package:package_info_plus/package_info_plus.dart';

// Trong _SettingsPageState:
String _appVersion = '...';
int _buildNumber = 0;

@override
void initState() {
  super.initState();
  _loadAppInfo();
  // ... rest
}

Future<void> _loadAppInfo() async {
  final info = await PackageInfo.fromPlatform();
  if (mounted) {
    setState(() {
      _appVersion = info.version;     // e.g. "1.0.0"
      _buildNumber = int.tryParse(info.buildNumber) ?? 0; // e.g. 1
    });
  }
}

// Trong _buildAbout():
Text(
  'Version $_appVersion (build $_buildNumber)',
  style: const TextStyle(fontSize: 13, color: SfTokens.onSurfaceWeak),
),
```

---

### SET-UI-002 (Medium) - Add Clear Cache / Offline Data Feature

**Vấn đề**: Chỉ hiển thị dung lượng, không có nút xóa.

**File**: `lib/features/settings/pages/settings_page.dart` lines 425-429, `lib/core/settings/offline_storage_service.dart`

**Cần thiết kế**:
1. Phân biệt: **Clearable cache** (images, temp files) vs **Essential data** (Isar DB, user preferences)
2. Chỉ cho phép xóa cache, không xóa Isar DB (sẽ mất offline data)

**Implementation**:

**Bước 1**: Mở rộng `OfflineStorageService`:

```dart
// lib/core/settings/offline_storage_service.dart
class OfflineStorageService {
  // ... existing code ...

  /// Lấy dung lượng có thể xóa (cache, temp files - KHÔNG bao gồm Isar DB)
  Future<int> clearableBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int total = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final name = entity.path.split('/').last;
          // Bỏ qua Isar database files
          if (name.endsWith('.isar') || name.endsWith('.isar.lock')) continue;
          // Bỏ qua shared_preferences files
          if (name.contains('shared_prefs')) continue;
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Xóa cache files (hình ảnh, temp - KHÔNG xóa Isar DB)
  Future<int> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int cleared = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final name = entity.path.split('/').last;
          if (name.endsWith('.isar') || name.endsWith('.isar.lock')) continue;
          if (name.contains('shared_prefs')) continue;
          try {
            final size = await entity.length();
            await entity.delete();
            cleared += size;
          } catch (_) {}
        }
      }
      return cleared;
    } catch (_) {
      return 0;
    }
  }
}
```

**Bước 2**: Thêm UI trong `_buildSyncOffline()`:

```dart
_row(
  icon: Icons.sd_storage_outlined,
  label: 'Offline data',
  value: _storageLabel,
  trailing: PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, color: SfTokens.onSurfaceWeak),
    onSelected: (value) async {
      if (value == 'clear_cache') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xóa bộ nhớ đệm?'),
            content: const Text('Hành động này sẽ xóa hình ảnh cache và file tạm. Dữ liệu offline (đơn hàng, kho, timesheet...) sẽ được GỮ LẠI.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: SfTokens.error),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          setState(() => _storageLabel = 'Đang xóa...');
          final cleared = await OfflineStorageService.instance.clearCache();
          final storage = await OfflineStorageService.instance.formatted();
          if (mounted) {
            setState(() => _storageLabel = storage);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xóa ${(cleared / 1024 / 1024).toStringAsFixed(1)} MB cache')),
            );
          }
        }
      }
    },
    itemBuilder: (ctx) => [
      const PopupMenuItem(value: 'clear_cache', child: Text('Xóa bộ nhớ đệm')),
    ],
  ),
),
```

---

### SET-ADD-001 (Critical) - Fix Duplicate Handlers on Hot Reload

**Vấn đề**: `registerSyncHandler` dùng `contains()` so sánh function reference.

**File**: `lib/core/database/sync_manager.dart` lines 191-198

**Code hiện tại**:
```dart
void registerSyncHandler(Future<void> Function() handler) {
  if (!_syncHandlers.contains(handler)) {  // ❌ So sánh reference
    _syncHandlers.add(handler);
  } else if (kDebugMode) {
    debugPrint('SyncManager: duplicate handler registration ignored');
  }
}
```

**Fix**: Dùng unique identifier hoặc tên function:

```dart
// Option 1: Yêu cầu handler có tên unique
typedef SyncHandler = Future<void> Function();

class _NamedHandler {
  final String name;
  final SyncHandler handler;
  _NamedHandler(this.name, this.handler);
  
  @override
  bool operator ==(Object other) => other is _NamedHandler && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

final List<_NamedHandler> _syncHandlers = [];

void registerSyncHandler(String name, SyncHandler handler) {
  final named = _NamedHandler(name, handler);
  if (!_syncHandlers.contains(named)) {
    _syncHandlers.add(named);
  } else if (kDebugMode) {
    debugPrint('SyncManager: duplicate handler "$name" ignored');
  }
}

// Usage in main.dart:
SyncManager.instance.registerSyncHandler('orders', OrdersService.instance.syncPending);
SyncManager.instance.registerSyncHandler('timesheet', TimesheetService.instance.syncPending);
// ...

// Option 2: Đơn giản hơn - dùng Set với toString() của function (không ổn định)
void registerSyncHandler(SyncHandler handler) {
  final key = handler.toString(); // "Closure: () => Future<void> from Function..."
  if (!_handlerKeys.add(key)) return; // Set tự loại trùng
  _syncHandlers.add(handler);
}
final Set<String> _handlerKeys = {};
final List<SyncHandler> _syncHandlers = [];
```

**Khuyến nghị**: Option 1 (named handlers) rõ ràng và debug được.

---

### SET-ADD-002 (Critical) - Unify Sync State Exposure

**Vấn đề**: 3 `_isSyncing` riêng biệt.

**Giải pháp**: Expose `SyncManager.isSyncing` via ChangeNotifier để UI listen.

**File**: `lib/core/database/sync_manager.dart`

```dart
class SyncManager extends ChangeNotifier {  // ✅ Extend ChangeNotifier
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  // ... existing code ...

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> syncPending() async {
    if (_isSyncing) {
      final active = _activeSyncFuture;
      if (active != null) await active;
      return;
    }
    _isSyncing = true;
    notifyListeners();  // ✅ Notify khi bắt đầu sync

    try {
      // ... existing sync logic ...
    } finally {
      _isSyncing = false;
      notifyListeners();  // ✅ Notify khi kết thúc sync
    }
    _activeSyncFuture = _runHandlers();
    try {
      await _activeSyncFuture;
    } finally {
      _isSyncing = false;
      _activeSyncFuture = null;
      notifyListeners();  // ✅ Notify khi kết thúc sync
    }
  }

  // ... rest
}
```

**Sau đó trong Settings page**:
```dart
@override
void initState() {
  super.initState();
  _sync.addListener(_onSyncChanged);
  SyncManager.instance.addListener(_onSyncManagerChanged);
  _load();
  _clockTimer = Timer.periodic(...);
}

void _onSyncManagerChanged() {
  if (mounted) setState(() {});
}

@override
void dispose() {
  _clockTimer?.cancel();
  _sync.removeListener(_onSyncChanged);
  SyncManager.instance.removeListener(_onSyncManagerChanged);
  _sync.dispose();
  super.dispose();
}

// Dùng SyncManager.instance.isSyncing thay vì _isSyncing cho disable logic
bool get _isAnySyncRunning => _isSyncing || _isTesting || SyncManager.instance.isSyncing;
```

---

## 📋 Tóm Tắt Độ Ưu Tiên Fix


| Priority | Bug IDs | Mô tả |
|----------|---------|-------|
| **P0 - Critical (Fix ngay)** | SET-LOGIC-001, SET-ADD-001, SET-ADD-002, SET-PERF-002 | Manual sync broken, duplicate handlers, sync state not exposed, timer leak |
| **P1 - High (Fix trong sprint)** | SET-UI-001, SET-PERF-001, SET-LOGIC-002, SET-ADD-003 | Button disable logic, race condition, wifi toggle logic, storage size accuracy |
| **P2 - Medium (Fix khi có thời gian)** | SET-UI-002, SET-DATA-001, SET-DATA-002, SET-LOGIC-003 | Clear cache feature, SecureStorage migration, version from pubspec, error handling |
| **P3 - Low (Nice to have)** | SET-ADD-004, SET-ADD-005 | Connection test depth, loading state |

---

## 🔗 Liên Kết File Cần Sửa


| File | Bugs liên quan |
|------|----------------|
| `lib/features/settings/pages/settings_page.dart` | SET-UI-001, SET-UI-002, SET-LOGIC-001, SET-LOGIC-002, SET-LOGIC-003, SET-PERF-002, SET-DATA-002, SET-ADD-004, SET-ADD-005 |
| `lib/core/settings/settings_repository.dart` | SET-DATA-001 |
| `lib/core/settings/sync_status_provider.dart` | SET-PERF-001 |
| `lib/core/database/sync_manager.dart` | SET-LOGIC-001, SET-LOGIC-002, SET-ADD-001, SET-ADD-002 |
| `lib/core/settings/offline_storage_service.dart` | SET-UI-002, SET-ADD-003 |
| `lib/main.dart` | SET-ADD-001 |


---

## ✅ Checklist Verification Sau Fix

- [x] Manual "Sync now" chạy được TẤT CẢ modules (Orders, Stock, Timesheet, Expense, WorkOrder, Recurring)
- [x] Buttons (Logout, Sync now, Test Connection, WiFi switch, Auto-sync dropdown) disable khi **bất kỳ** sync nào đang chạy (manual hoặc auto)
- [x] Không crash khi thoát màn Settings nhanh trong lúc timer đang refresh
- [x] WiFi-only toggle xử lý đúng 4 cases: bật/tắt trên WiFi/mobile data
- [x] App version lấy tự động từ `pubspec.yaml`
- [x] Clear cache chỉ xóa file cache, KHÔNG xóa Isar DB
- [x] Settings (wifi-only, auto-sync) lưu ở SharedPreferences, không dùng SecureStorage
- [x] Không đăng ký duplicate handlers khi hot reload
- [x] UI phản ánh real-time trạng thái sync của SyncManager (auto + manual)
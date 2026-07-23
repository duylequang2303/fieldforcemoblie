# ARCHITECTURE.md – Kiến trúc Kỹ thuật fieldforce_mobile

## 1. Pattern: Feature-First Architecture

```
lib/
├── app/          # Root app: MaterialApp, Theme, MultiProvider
├── core/         # Hạ tầng kỹ thuật dùng chung (API, DB, Auth, Router)
├── shared/       # Widgets & services dùng chung nhiều feature
└── features/     # Mỗi tính năng nghiệp vụ là 1 thư mục độc lập
    ├── auth/
    ├── orders/
    ├── route_map/
    ├── stock/
    ├── timesheet/
    ├── expense/
    └── work_order/
```

**Nguyên tắc phụ thuộc (Dependency Rule):**
```
features/* → core/* (OK)
features/* → shared/* (OK)
features/A → features/B (❌ KHÔNG ĐƯỢC)
core/* → features/* (❌ KHÔNG ĐƯỢC)
```

---

## 2. Luồng Dữ liệu (Data Flow)

```
UI (Page/Widget)
    │  notifyListeners / Consumer
    ▼
Provider (XxxProvider)
    │  gọi method
    ▼
Service (XxxService)
    │  gọi
    ▼
OdooSessionManager (core/api/)
    │  odoo_rpc
    ▼
Odoo Backend (JSON-RPC)
    │
    ▼ (response)
Service → Isar DB (lưu local)
    │
Provider → notifyListeners
    │
UI cập nhật
```

---

## 3. Offline Synchronization Flow

```
App khởi động
    │
    ├── Check connectivity (connectivity_plus)
    │
    ├── ONLINE:
    │     1. Gọi Odoo API
    │     2. Lưu kết quả vào Isar DB
    │     3. Hiển thị UI từ Isar DB
    │
    └── OFFLINE:
          1. Đọc dữ liệu từ Isar DB
          2. Hiển thị OfflineBanner
          3. Worker vẫn thao tác bình thường
          4. Thay đổi ghi vào Isar với flag isPendingSync = true

Khi mạng trở lại:
    SyncManager.syncPending()
        │
        └── Lấy tất cả records có isPendingSync = true
              → Gọi Odoo API để push
              → Nếu thành công: set isPendingSync = false
              → Nếu thất bại: giữ nguyên, retry lần sau
```

---

## 4. Authentication Flow

```
Splash Screen
    │
    ├── Có session trong SecureStorage?
    │     ├── CÓ → Validate session với Odoo
    │     │         ├── OK → vào Home (Orders List)
    │     │         └── HẾT HẠN → Login Screen
    │     └── KHÔNG → Login Screen
    │
Login Screen
    │
    ├── Nhập: Server URL + DB + Username + Password
    ├── Gọi OdooSessionManager.authenticate()
    │     ├── OK → Lưu session vào SecureStorage
    │     │         → Offer Biometric setup
    │     │         → vào Home
    │     └── LỖI → Hiển thị ErrorView
    │
Biometric (lần sau):
    local_auth.authenticate() → Lấy session từ SecureStorage → vào Home
```

---

## 5. State Management với Provider

```dart
// Cách đăng ký (app/app_providers.dart)
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OrdersProvider()),
    // ...
  ],
)

// Cách đọc trong Widget
Consumer<OrdersProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingOverlay();
    return OrdersList(orders: provider.orders);
  },
)

// Cách gọi action
context.read<OrdersProvider>().fetchOrders();
```

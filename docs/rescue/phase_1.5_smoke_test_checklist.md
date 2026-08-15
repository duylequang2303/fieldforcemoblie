# Phase 1.5 — Smoke Test Checklist

## Mục tiêu
Tạo manual smoke test checklist cho Phase 1.

## Checklist

### 1. App launches
- [ ] App mở không crash.
- [ ] Splash screen hiện, sau đó redirect vào `/shell/schedule` (nếu đã login) hoặc `/login`.

### 2. Login works
- [ ] Nhập server/db/user/pass → tap Login → vào Schedule.
- [ ] Nếu user thiếu `hr.employee` → login thành công (không block).

### 3. Orders list loads
- [ ] Màn Schedule hiện danh sách orders.
- [ ] Pull-to-refresh làm mới.
- [ ] Offline → hiện cache Isar.

### 4. Order detail opens from order list
- [ ] Tap `OrderCard` → mở `WorkOrderDetailScreen`.
- [ ] Không flash UI, không race condition.
- [ ] Thấy thông tin: tên đơn, địa điểm, khách hàng, schedule.

### 5. Order detail opens from route stop
- [ ] Vào `/route-map` → tap điểm dừng → bottom sheet hiện.
- [ ] Tap "Chi tiết" → mở `WorkOrderDetailScreen` với đúng order.

### 6. Route build does not crash Isar
- [ ] Vào `/route-map` → route list build.
- [ ] Không có crash liên quan đến Isar unique index.

### 7. Offline cache can be rebuilt safely
- [ ] Tắt mạng → mở app → thấy cache.
- [ ] Bật mạng → sync chạy → cache cập nhật.

### 8. API failure does not freeze UI
- [ ] Tắt mạng → tap refresh → thấy error, không spinner vô hạn.

### 9. AccessError on recurring does not block order detail
- [ ] Nếu backend từ chối `fsm.recurring` → order list vẫn load.
- [ ] Recurring badge không hiển thị (hoặc hiện "Không lặp").

### 10. No obvious RenderFlex overflow
- [ ] Mở order với tên dài (>50 ký tự) → không overflow.
- [ ] Mở order với địa chỉ dài → không overflow.
- [ ] Mở route map → stop card không overflow.

## Commands
```bash
flutter analyze
flutter build apk --debug
```

## Expected logs to watch
- `OrdersService.fetchMyOrders` — fetch success/failure.
- `RouteProvider.buildRoute` — route build success.
- `RecurringService.fetchRecurringRules` — AccessError handling.
- `Isar` initialization — no errors.
- `WorkOrderDetailScreen` — no overflow warnings.

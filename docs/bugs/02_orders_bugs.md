# Bug Tracker: Orders Feature

## Thông tin chung
- **Feature**: Orders Management (Quản lý đơn hàng)
- **Files liên quan**: `lib/features/orders/`
- **Models**: `FsmOrder`, `FsmRecurring`, `FsmFrequencySet`
- **Services**: `OrdersService`, `RecurringService`, `RecurringNotificationService`
- **Pages**: `orders_list_page.dart`, `order_detail_page.dart`
- **Ngày tạo**: 2026-08-06

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| ORD-UI-001 | Pull-to-refresh bị khóa hoàn toàn khi danh sách đơn hàng trống do bộ lọc | `orders_list_page.dart` | Medium | ✅ Fixed | |
| ORD-UI-002 | Gọi trực tiếp `Platform.isLinux` không có guard `kIsWeb` gây crash ứng dụng trên Web | `lib/main.dart` | High | ✅ Fixed | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-LOGIC-001 | `_parseIntervalType` không map đúng kiểu lặp của Odoo (days, weeks, months, years) | `fsm_frequency_set.dart` | Critical | ✅ Fixed | Chuyển toàn bộ kiểu lặp thành Weekly |
| ORD-LOGIC-002 | Check-in/Check-out offline hiện banner đỏ "Lỗi kết nối" thay vì thông báo lưu ngoại tuyến thành công | `order_detail_page.dart` | Medium | ✅ Fixed | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-PERF-001 | Không có | | | ✅ None | Không phát hiện rò rỉ bộ nhớ nghiêm trọng |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-SYNC-001 | Query kiểm tra Idempotency crash khi Odoo không hỗ trợ custom field `fsm_recurring_id` | `orders_service.dart` | High | ✅ Fixed | Đứt hoàn toàn luồng sync đơn định kỳ |

### Data/Validation Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-DATA-001 | Không có | | | ✅ None | |

---

## 🔴 Chi tiết từng Bug

### ORD-UI-001: Pull-to-refresh bị khóa hoàn toàn khi danh sách trống do bộ lọc
**File:** `lib/features/orders/pages/orders_list_page.dart`  
**Mức độ:** **Medium** | **Loại:** UI/UX  
**Trạng thái:** ✅ **Fixed**  

**Mô tả:**  
Khi danh sách đơn hàng trống sau khi apply filter hoặc search, trang sẽ chuyển sang hiển thị widget `_buildEmptyState()`. Tuy nhiên, widget này không được bao bởi `RefreshIndicator` cũng như không có view scrollable, dẫn đến việc người dùng không thể kéo xuống để reload như dòng chữ hướng dẫn `"Kéo xuống để tải lại"`.

**Code hiện tại (vấn đề):**
```dart
// orders_list_page.dart:56
filtered.isEmpty
    ? _buildEmptyState()
    : RefreshIndicator(
        onRefresh: provider.fetchOrders,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: filtered.length,
          itemBuilder: (context, i) => OrderCard(order: filtered[i]),
        ),
      )
```

**Khuyến nghị fix:**  
Bọc `_buildEmptyState` trong widget `RefreshIndicator` và sử dụng `ListView` hoặc `SingleChildScrollView` với `physics: AlwaysScrollableScrollPhysics()` để hỗ trợ pull-to-refresh.

---

### ORD-UI-002: Kiểm tra trực tiếp `Platform` gây crash ứng dụng trên Web
**File:** `lib/main.dart`  
**Mức độ:** **High** | **Loại:** Crash/Web Compatibility  
**Trạng thái:** ✅ **Fixed**  

**Mô tả:**  
Việc gọi `Platform.isLinux` trực tiếp tại startup mà không kiểm tra `kIsWeb` từ thư viện core Flutter sẽ sinh lỗi `Unsupported operation: Platform._operatingSystem` khi chạy ứng dụng trên trình duyệt web, gây sập app ngay lập tức.

**Code hiện tại (vấn đề):**
```dart
// main.dart:89 & 101
if (!Platform.isLinux) {
  await RecurringNotificationService.instance.rescheduleAllRecurringReminders();
}
```

**Khuyến nghị fix:**  
Sử dụng guard `!kIsWeb` trước khi kiểm tra `Platform`:
```dart
if (!kIsWeb && !Platform.isLinux) {
```

---

### ORD-LOGIC-001: `FsmFrequencySet._parseIntervalType` lỗi so khớp kiểu lặp
**File:** `lib/features/orders/models/fsm_frequency_set.dart`  
**Mức độ:** **Critical** | **Loại:** Logic/Data Integrity  
**Trạng thái:** ✅ **Fixed**  

**Mô tả:**  
Odoo FSM trả về kiểu interval_type dưới các giá trị dạng `'days'`, `'weeks'`, `'months'`, `'years'`. Trong khi đó, enum `FrequencyIntervalType` chứa các giá trị tên là `daily`, `weekly`, `monthly`, `yearly`.  
Hàm `_parseIntervalType` thực hiện so khớp trực tiếp `e.name == str`. Do tên của enum không trùng khớp với chuỗi Odoo trả về, so khớp luôn thất bại và rơi vào phương án fallback `orElse: () => FrequencyIntervalType.weekly`. Điều này làm tất cả các chuỗi lặp (hàng ngày, hàng tháng, hàng năm) bị tính toán ngày lặp tiếp theo theo kiểu hàng tuần.

**Code hiện tại (vấn đề):**
```dart
// fsm_frequency_set.dart:65
static FrequencyIntervalType _parseIntervalType(dynamic value) {
  if (value == null || value == false) return FrequencyIntervalType.weekly;
  final str = value.toString().toLowerCase();
  return FrequencyIntervalType.values.firstWhere(
    (e) => e.name == str,
    orElse: () => FrequencyIntervalType.weekly,
  );
}
```

**Khuyến nghị fix:**  
Map tường minh các giá trị chuỗi Odoo sang các phần tử enum tương ứng.

---

### ORD-LOGIC-002: Check-in/Check-out offline báo lỗi kết nối giả
**File:** `lib/features/orders/pages/order_detail_page.dart`  
**Mức độ:** **Medium** | **Loại:** UX/Logic  
**Trạng thái:** ✅ **Fixed**  

**Mô tả:**  
Khi check-in hoặc check-out tại ngoại tuyến, hệ thống lưu thành công vào Isar cục bộ và đánh dấu `isPendingSync = true` rồi tiếp tục thực thi. Tuy nhiên, do đầu ghi Odoo ném lỗi `OdooApiException` (lỗi không kết nối được backend khi offline) được rethrow, `OrdersProvider` bắt lỗi này và gán thông báo lỗi vào `provider.errorMessage`. Cuối cùng, UI nhận diện `provider.errorMessage != null` nên hiện SnackBar đỏ cảnh báo thất bại, trong khi thực tế dữ liệu local đã được cập nhật thành công và sẵn sàng để sync sau.

**Code hiện tại (vấn đề):**
```dart
// order_detail_page.dart:481
if (provider.errorMessage == null) {
  final statusText = provider.isOffline
      ? 'Check-in thành công! (Ngoại tuyến, sẽ đồng bộ sau)'
      : 'Check-in thành công!';
  // ... show success SnackBar
} else {
  // ... show error SnackBar (Connection error)
}
```

**Khuyến nghị fix:**  
Tại screen check-in/out, nếu gặp lỗi `OdooConnectionException` từ provider, hãy coi đó là một cảnh báo offline và hiển thị SnackBar thông báo Offline Success thay vì hiển thị banner lỗi đỏ.

---

### ORD-SYNC-001: Idempotency search query crash khi Odoo thiếu trường custom
**File:** `lib/features/orders/services/orders_service.dart`  
**Mức độ:** **High** | **Loại:** Sync/Reliability  
**Trạng thái:** ✅ **Fixed**  

**Mô tả:**  
Để đảm bảo tính duy nhất (Idempotency), trước khi tạo đơn lặp trên Odoo, client gọi query `search_read` để kiểm tra sự tồn tại trong đó có lọc theo `fsm_recurring_id`. Nhưng nếu Odoo DB backend không hỗ trợ trường `fsm_recurring_id`, cuộc gọi này bắn ra lỗi `OdooApiException` và không được retry. Do đó `_createOrderOnOdoo` trả về null, khiến `syncPending` bỏ qua đơn hoàn toàn.

**Code hiện tại (vấn đề):**
```dart
// orders_service.dart:804
if (order.recurringId != null && order.recurringId! > 0 && order.scheduledDateStart != null) {
  final scheduledStartStr = _formatDateTimeUtc(order.scheduledDateStart!);
  final List<dynamic> exist = await _odoo.callKw(
    model: _model,
    method: 'search_read',
    args: [[
      ['scheduled_date_start', '=', scheduledStartStr],
      ['person_id', '=', order.personId],
      ['fsm_recurring_id', '=', order.recurringId]
    ]],
    kwargs: {'fields': ['id'], 'limit': 1},
  ) as List<dynamic>;
```

**Khuyến nghị fix:**  
Bọc cuộc gọi `search_read` trong khối try-catch, và nếu gặp exception liên quan đến thuộc tính `fsm_recurring_id` không hợp lệ, hãy thực hiện lại kiểm tra mà loại trừ field custom đó, hoặc bỏ qua kiểm tra trùng lặp để tiến hành tạo trực tiếp.

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Load danh sách đơn hàng (pagination, filter, search)
- [ ] Chi tiết đơn: hiển thị đầy đủ info, trạng thái
- [ ] Tạo/sửa đơn offline -> sync khi online
- [ ] Recurring orders: tạo rule, generate instances, notification
- [ ] Xử lý conflict khi sync (server vs local)
- [ ] Hình ảnh/đính kèm đơn hàng

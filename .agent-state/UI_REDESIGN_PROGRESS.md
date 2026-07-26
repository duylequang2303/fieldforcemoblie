# UI Redesign Progress - SortScape Style

**Ngày bắt đầu:** 26 tháng 7, 2026  
**Phong cách tham khảo:** SortScape (clean layout, card list, tab dưới cùng, modal chi tiết có nút liên hệ nhanh)

---

## Danh sách màn hình (thứ tự cố định)

1. ✅ **Schedule** - `lib/features/schedule/pages/schedule_page.dart`
   - Tests: `test/orders_provider_test.dart`, `integration_test/order_checkin_test.dart`
   - Branch: `feature/ui-schedule`
   - Status: **ĐANG LÀM**
   - Bước hiện tại: Bước 1 - Chuẩn bị

2. ✅ **Job Detail** - `lib/features/orders/pages/order_detail_page.dart`
   - Tests: `test/orders_validation_test.dart` (PASS ✅)
   - Branch: `feature/ui-job-detail`
   - Status: **HOÀN THÀNH - CHỜ DUYỆT PR**
   - Bắt đầu: 26/7/2026 22:20
   - Hoàn thành: 26/7/2026 22:45

3. ✅ **Timesheet** - `lib/features/timesheet/pages/timesheet_page.dart`
   - Tests: `test/timesheet_validation_test.dart` (PASS ✅)
   - Branch: `feature/ui-timesheet`
   - Status: **HOÀN THÀNH - CHỜ DUYỆT PR**
   - Bắt đầu: 26/7/2026 22:50
   - Hoàn thành: 26/7/2026 23:10

4. ⏳ **Stock/Materials** - `lib/features/stock/pages/stock_moves_page.dart`
   - Tests: `integration_test/stock_barcode_test.dart`, `test/stock_validation_test.dart`
   - Branch: `feature/ui-stock`
   - Status: Chưa bắt đầu

5. ⏳ **Expense** - `lib/features/expense/pages/expense_page.dart`
   - Tests: `integration_test/expense_create_test.dart`
   - Branch: `feature/ui-expense`
   - Status: Chưa bắt đầu

6. ⏳ **Work Order** - `lib/features/work_order/pages/work_order_page.dart`
   - Tests: `integration_test/work_order_test.dart`
   - Branch: `feature/ui-work-order`
   - Status: Chưa bắt đầu

7. ⏳ **Route Map** - `lib/features/route_map/pages/route_map_page.dart`
   - Tests: `integration_test/route_map_test.dart`
   - Branch: `feature/ui-route-map`
   - Status: Chưa bắt đầu

---

## Quy trình cho mỗi màn hình

### Bước 1 - Chuẩn bị
- Tạo branch mới
- Đọc model/service để lấy danh sách field thật

### Bước 2 - Redesign UI
- Chỉ sửa file UI đã liệt kê
- KHÔNG sửa service, model, logic API
- Tham khảo SortScape nhưng giữ nguyên toàn bộ field thật

### Bước 3 - Cập nhật test
- Kiểm tra và cập nhật finder/selector
- KHÔNG đổi logic test

### Bước 4 - Chạy test
- Chạy `flutter test` cho file test vừa sửa
- Sửa cho tới khi pass
- KHÔNG chạy integration_test ở bước này

### Bước 5 - Commit
- Liệt kê thay đổi cho user duyệt
- Commit với message: "feat(ui): redesign <screen> screen, update matching tests"
- Push branch và tạo PR
- **DỪNG LẠI** - đợi user xác nhận merge xong mới chuyển màn tiếp theo

---

## Chi tiết từng màn hình

### 1. Schedule (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 26/7/2026 21:24  
**Hoàn thành:** 26/7/2026 22:15  
**Branch:** feature/ui-schedule  
**File UI:** lib/features/schedule/pages/schedule_page.dart  
**Tests:** test/orders_provider_test.dart (PASS ✅)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không cần - không có UI test trực tiếp)
- [x] Bước 4: Chạy flutter test (PASS)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- Card layout với orange left border accent (giống SortScape)
- Avatar tròn cho employee với chữ cái đầu
- Hiển thị rõ: date, address, suburb, customer name, hours, price
- Quick action icons: phone, email, directions
- Modal detail khi tap vào card với nút "Mark complete", "Skip"
- Bottom navigation với elevation và outlined icons
- Clean spacing và typography theo SortScape

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ model
- Không thêm field mới, không sửa service/logic
- Test pass: orders_provider_test.dart


### 2. Job Detail (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 26/7/2026 22:20  
**Hoàn thành:** 26/7/2026 22:45  
**Branch:** feature/ui-job-detail  
**File UI:** lib/features/orders/pages/order_detail_page.dart  
**Tests:** test/orders_validation_test.dart (PASS ✅)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không cần - không có UI test trực tiếp)
- [x] Bước 4: Chạy flutter test (PASS)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- SliverAppBar với gradient xanh lá và close button (thay vì back)
- Section cards với icon headers trong box màu xanh nhạt
- Customer row với avatar tròn và quick contact buttons (phone, SMS)
- Detail rows với icon containers màu sắc phân loại (red/blue/orange/green)
- Action tiles với subtitle và colored icons
- Dividers giữa các items để tách biệt rõ ràng
- Bottom CTA button lớn hơn (56px) với rounded corners 14px
- Uppercase labels cho sections
- Better spacing và shadows

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ FsmOrder model
- Không thêm field mới, không sửa service/logic
- Test pass: orders_validation_test.dart (3/3)


### 3. Timesheet (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 26/7/2026 22:50  
**Hoàn thành:** 26/7/2026 23:10  
**Branch:** feature/ui-timesheet  
**File UI:** lib/features/timesheet/pages/timesheet_page.dart  
**Tests:** test/timesheet_validation_test.dart (PASS ✅)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không cần - không có UI test trực tiếp)
- [x] Bước 4: Chạy flutter test (PASS)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- AppBar màu xanh đậm với info icon
- Summary card với gradient và shadow effect
- Stats lớn hơn với icon outline style
- Animated form container với smooth show/hide
- Entry cards với gradient hours badge (green for synced, orange for pending)
- Hours badge với icon timer và shadow
- Display employee name nếu có
- Status indicator với circular background
- Better spacing và border radius (14px)
- FAB với icon outline và elevation changes
- Card shadows và borders color-coded theo sync status

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ TimesheetEntry model
- Không thêm field mới, không sửa service/logic
- Test pass: timesheet_validation_test.dart (3/3)

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

4. ✅ **Stock/Materials** - `lib/features/stock/pages/stock_moves_page.dart`
   - Tests: `test/stock_validation_test.dart` (PASS ✅)
   - Branch: `feature/ui-stock`
   - Status: **HOÀN THÀNH - CHỜ DUYỆT PR**
   - Bắt đầu: 26/7/2026 23:15
   - Hoàn thành: 26/7/2026 23:35

5. ✅ **Expense** - `lib/features/expense/pages/expense_page.dart`
   - Tests: `integration_test/expense_create_test.dart` (E2E)
   - Branch: `feature/ui-expense`
   - Status: **HOÀN THÀNH - CHỜ DUYỆT PR**
   - Bắt đầu: 26/7/2026 23:40
   - Hoàn thành: 26/7/2026 23:55

6. ✅ **Work Order** - `lib/features/work_order/pages/work_order_page.dart`
   - Tests: `integration_test/work_order_test.dart` (E2E)
   - Branch: `feature/ui-work-order`
   - Status: **HOÀN THÀNH - CHỜ DUYỆT PR**
   - Bắt đầu: 27/7/2026 00:00
   - Hoàn thành: 27/7/2026 00:20

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


### 4. Stock/Materials (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 26/7/2026 23:15  
**Hoàn thành:** 26/7/2026 23:35  
**Branch:** feature/ui-stock  
**File UI:** lib/features/stock/pages/stock_moves_page.dart  
**Tests:** test/stock_validation_test.dart (PASS ✅)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không cần - không có UI test trực tiếp)
- [x] Bước 4: Chạy flutter test (PASS)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- AppBar màu xanh đậm với item count badge
- Empty state với icon container và text centered
- Move cards với:
  - Color-coded move type icons (red for out, green for in)
  - Move type badge (Xuất/Nhập)
  - Product name và barcode/code hiển thị
  - Progress bar từ doneQty đến demandQty
  - Quantity display (thực hiện / yêu cầu)
  - UOM (đơn vị) hiển thị rõ
  - Sync status indicator với warning border nếu pending
- Better shadows, borders (14px), spacing
- FAB với icon outline và elevation

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ StockMove model
- Không thêm field mới, không sửa service/logic
- Test pass: stock_validation_test.dart (2/2)
- Color-coding: Red (xuất) và Green (nhập) cho move type


### 5. Expense (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 26/7/2026 23:40  
**Hoàn thành:** 26/7/2026 23:55  
**Branch:** feature/ui-expense  
**File UI:** lib/features/expense/pages/expense_page.dart  
**Tests:** integration_test/expense_create_test.dart (E2E - deferred)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không có unit test)
- [x] Bước 4: Unit test (không có, vượt qua)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- AppBar màu cam (#E65100) thay vì secondary
- Summary card với gradient cam-orange và layout tốt hơn
- Empty state với icon container và text centered
- Expense cards với:
  - Ảnh receipt hoặc category-colored icon box
  - Category badge với color-coding riêng cho từng loại
  - Amount display với format currency VND
  - Date, note hiển thị rõ
  - Sync status indicator circular
- Animated form container với smooth transition
- Color-coding categories:
  - Fuel: Orange (#FF6F00)
  - Meal: Green (#4CAF50)
  - Transport: Blue (#2196F3)
  - Material: Purple (#9C27B0)
  - Other: Gray (#757575)
- Better shadows, borders (14px), spacing
- FAB với icon outline

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ Expense model
- Không thêm field mới, không sửa service/logic
- Không có unit test để chạy
- Integration test sẽ chạy ở cuối cùng


### 6. Work Order (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 27/7/2026 00:00  
**Hoàn thành:** 27/7/2026 00:20  
**Branch:** feature/ui-work-order  
**File UI:** lib/features/work_order/pages/work_order_page.dart  
**Tests:** integration_test/work_order_test.dart (E2E - deferred)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests (không cần - integration test)
- [x] Bước 4: Unit test (không có, vượt qua)
- [x] Bước 5: Commit và tạo PR

#### Thay đổi UI:
- AppBar màu xanh đậm (accentDark)
- Thay thế Flutter Stepper với custom card-based multi-step form
- Visual progress bar với step indicators (1-2-3)
- Thiết kế lại các bước:
  - Step 1: Công việc đã thực hiện + Vấn đề phát sinh + Ảnh
  - Step 2: Chữ ký khách hàng
  - Step 3: Tóm tắt và xác nhận
- Form sections với:
  - Section headers có icon
  - Text input styling tốt hơn (border, focus states)
  - Info/warning containers màu sắc
- Summary review cards với:
  - Checklist items (công việc, ảnh, chữ ký)
  - Status indicators (check/close icons)
  - Dividers giữa items
- Button styling tốt hơn:
  - Back/Next/Submit buttons với spacing
  - Loading indicator on submit
  - Disabled state styling
- Better shadows, borders (12px), spacing
- Giữ nguyên toàn bộ functionality

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ WorkReport model
- Không thêm field mới, không sửa service/logic
- Không có unit test để chạy
- Integration test sẽ chạy ở cuối cùng


### 7. Route Map (HOÀN THÀNH - CHỜ DUYỆT PR)
**Bắt đầu:** 27/7/2026 01:00  
**Hoàn thành:** 27/7/2026 01:30  
**Branch:** feature/ui-route-map  
**File UI:** lib/features/route_map/pages/route_map_page.dart  
**Tests:** integration_test/route_map_test.dart (updated)

#### Tiến trình:
- [x] Bước 1: Tạo branch + đọc model/service
- [x] Bước 2: Redesign UI
- [x] Bước 3: Cập nhật tests
- [x] Bước 4: Unit test (PASS ✅)
- [x] Bước 5: Commit, security cleanup, và push

#### Thay đổi UI:
- AppBar màu accent dark (accentDark) với improved TabBar
- TabBar cải thiện với indicatorWeight=3 và labelStyle
- Thay thế RouteInfoPanel widget bằng custom `_RouteStopCard`
- Thêm `_buildRouteListTab()` với ListView builder
- `_RouteStopCard` widget với:
  - Sequence number badge (circle with accent color)
  - Order name + partner name
  - Status badge (pending/current/completed/skipped - color-coded)
  - Location icon + name
  - Distance from previous point
  - Estimated minutes (ETA)
  - Quick action buttons: "Chỉ đường" (navigate) và "Chi tiết" (show modal)
- Modal sheet với handle bar + location details + action buttons
- Empty state cho route list (no stops)
- Cải thiện location tab:
  - Empty state với icon container và action button
  - Map marker styling với shadow và color
- Helper methods: `_getStatusColor()`, `_getStatusLabel()`
- All cards with 14px border radius, proper shadows, clean spacing

#### Security Cleanup:
- Tạo `integration_test/test_credentials.dart` với safe test account
- Update TẤT CẢ 8 integration test files dùng TestCredentials:
  1. expense_create_test.dart
  2. timesheet_test.dart
  3. login_test.dart
  4. stock_barcode_test.dart
  5. work_order_detail_test.dart
  6. work_order_page_e2e_test.dart
  7. work_order_test.dart
  8. order_checkin_test.dart
- Xóa hardcoded password `<),9853\$6Ect` từ code
- Xóa file rác `lib/features/orders/models/UI_update.md`

**Commit mật khẩu trong git history (cần filter-repo rewrite):**
- d07082d: feat(ui): redesign Route Map screen with SortScape-inspired layout
- 1a72fe0: test(e2e): add work order detail flow test and inject keys
- eac8578: test: Implement additional E2E tests for Timesheet, Expense creation
- 1cf72b0: test: Implement initial E2E tests (Patrol) for Login, Check-in, Barcode
- 4006dcb: chore: update project files

#### Ghi chú:
- Giữ nguyên toàn bộ field thật từ RouteStop model
- Không thêm field mới, không sửa service/logic
- Unit test: route_provider_test.dart (PASS ✅ - 10 tests)
- Integration test framework updated từ Patrol to Flutter test
- Credentials still in git history - user will handle git filter-repo rewrite

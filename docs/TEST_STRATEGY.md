# Chiến lược Test – Field Force Mobile

> **Mục tiêu:** Đảm bảo chất lượng app trong môi trường Offline-First, tích hợp Odoo backend.

---

## 📊 Tổng quan Test Cases

Tổng **99 Test Cases** được phân loại theo 4 nhóm:

| Loại Test | Công cụ | Số TC | Tỷ lệ Pass yêu cầu | Maintenance cost |
|---|---|---|---|---|
| **Unit Test** | `flutter test` + mock | ~20 TC | 100% | ~1h/tuần |
| **Integration Test** | `flutter test` + Isar in-memory | ~20 TC | 100% | ~2h/tuần |
| **E2E (Patrol/Maestro)** | Patrol CLI | ~15 TC | ≥95% | ~3-4h/tuần |
| **Manual Test** | Thiết bị thật + Odoo thật | ~44 TC | Không áp dụng CI | ~3-4 ngày (1 tester) |
| **Tổng** | | **99 TC** | | **~6-7h/tuần** |

---

## 🤖 1. Unit Test (~20 TC)

### Phạm vi
- **Validation logic**: Timesheet (24h, overlap), Expense (số tiền âm/trống)
- **Model parsing**: JSON → Model (FsmOrder, StockMove, TimesheetEntry, Expense, WorkReport)
- **Helper methods**: `_idFromMany`, `_nameFromMany`, `_parseStage`

### Công cụ
- `flutter test`
- `mocktail` hoặc `mockito` để mock OdooClient, ConnectivityService

### Ví dụ test case
```dart
test('EXP-06: Tạo chi phí với số tiền âm → Validation error', () {
  final expense = ExpenseFactory.sample(amount: -50000);
  expect(expense.amount, greaterThan(0)); // Hoặc assert throw ValidationException
});
```

### Maintenance
- Khi model thay đổi field → cập nhật factory method trong `test/fixtures/sample_data.dart`
- Khi validation rule thay đổi → cập nhật test assertion

---

## 🗄 2. Integration Test (~20 TC)

### Phạm vi
- **Auth flow**: Login, token storage, session timeout, offline login
- **Sync & Conflict**: Queue pending changes, sync lên Odoo, xử lý conflict
- **CRUD offline**: Tạo/sửa/xóa khi offline, đọc từ cache
- **Stage transitions**: Cập nhật stage đơn hàng, route state

### Công cụ
- `flutter test` với `Isar.openInMemory()`
- Mock OdooClient (trả về Future.error cho lỗi network)
- Test database thật (in-memory) → bắt được race condition

### Setup Isar in-memory
```dart
late Isar isar;

 setUp(() async {
   isar = await Isar.openInMemory(
     [FsmOrderSchema, StockMoveSchema, TimesheetEntrySchema, ...],
   );
   // Insert sample data
   await isar.writeTxn(() async {
     await isar.fsmOrders.putAll([FsmOrderFactory.sample(), ...]);
   });
 });
```

### Test data
- Dùng factory methods từ `test/fixtures/sample_data.dart`
- Mỗi test case tự chuẩn bị data riêng, không share state

### Maintenance
- Khi thêm field mới → update factory method
- Khi thay đổi sync logic → update mock OdooClient behavior

---

## 🎭 3. E2E Test với Patrol (~15 TC)

### Tại sao chọn Patrol?
- Flutter-native support, không cần native code (khác Maestro)
- Mock permission dễ dàng: `patrol.tap()` + permission dialog handling
- Selector ổn định hơn Maestro (dựa trên accessibility label)

### Phạm vi các TC chuyển sang E2E
| Module | TC | Luồng |
|---|---|---|
| Auth | AUTH-01 | Login thành công |
| Orders | ORD-01 | Fetch orders + pull refresh |
| Orders | ORD-05 | Check-in GPS |
| Orders | ORD-09 | Hoàn thành đơn |
| Stock | STOCK-01 | Quét mã vạch |
| Stock | STOCK-06 | Xuất kho |
| Route Map | ROUTE-03 | Định vị GPS |
| Timesheet | TIME-01 | Check-in |
| Expense | EXP-03 | Tạo chi phí + chụp ảnh |
| Work Order | WO-05 | Chụp ảnh công trình |
| Work Order | WO-07 | Ký số khách hàng |
| Work Order | WO-09 | Hoàn thành nghiệm thu |

### Setup Patrol
```yaml
# pubspec.yaml
dev_dependencies:
  patrol: ^3.0.0

# android/app/build.gradle.kts
android {
  defaultConfig {
    testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
  }
}
```

### Chạy E2E
```bash
# Chạy tất cả
patrol test

# Chạy 1 TC cụ thể
patrol test --target test_driver/login_test.dart
```

### Maintenance
- UI thay đ phải cập nhật selector
- Flaky tests: cho phép retry 2 lần, nếu vẫn fail → đưa vào Manual

---

## 👨‍🔧 4. Manual Test (~44 TC)

### Danh sách TC bắt buộc test thủ công
| Mã TC | Lý do không tự động được |
|---|---|
| AUTH-02, AUTH-03 | Mock không cover hết error message của Odoo |
| AUTH-04, AUTH-05 | Offline login cần test secure storage thật |
| SYNC-01~04 | Xung đột dữ liệu cần 2 người dùng thật |
| ORD-03, ORD-04 | Chi tiết đơn cần xem full UI |
| ORD-16~ORD-20 | Cancel flow + GPS permission |
| ROUTE-01, ROUTE-02, ROUTE-04, ROUTE-08, ROUTE-10 | Bản đồ, Google Maps, offline banner |
| STOCK-04, STOCK-05, STOCK-07, STOCK-08, STOCK-12~STOCK-15 | Stock moves list, inbound/outbound UX, multi-barcode |
| TIME-04, TIME-05 | Nhập giờ thủ công, chỉnh sửa UX |
| EXP-01, EXP-02, EXP-07~EXP-11, EXP-13~EXP-15 | Expense list, edit/delete UX, fullscreen ảnh, storage |
| WO-01~WO-04, WO-08, WO-10, WO-11, WO-14~WO-16 | Work orders list, offline, multi ảnh, reject sign |

### Môi trường test
- **Thiết bị**: Android 11+ (3-4 máy khác nhau)
- **Odoo**: Server thật (không dùng mock)
- **Network**: 4G, WiFi, Máy bay mode
- **Permissions**: Cho phép/ từ chối Camera, GPS

### Báo cáo lỗi
- Dùng template:
  ```
  [TC: ORD-05]
  Môi trường: Online, GPS ON
  Bước thực hiện: 1-2-3-4
  Kết quả thực tế: date_start không được ghi
  Kết quả mong đợi: date_start = thời gian hiện tại
  Severity: P0
  ```

---

## 🔄 Chiến lược CI/CD

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --reporter-expanded
        # Yêu cầu 100% pass

  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/integration/ --reporter-expanded
        # Yêu cầu 100% pass

  e2e-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: patrol test --flaky-test-attempts=2
        # Cho phép 95% pass, retry 2 lần
```

### Quy tắc merge
- ✅ Unit Test + Integration Test phải **100% pass**
- ✅ E2E Test phải **≥95% pass**
- ❌ Manual Test **không block** merge (log bug vào Jira)

---

## 📦 Test Data Management

### Factory Methods
File: `test/fixtures/sample_data.dart`

```dart
// Tạo order mẫu
final order = FsmOrderFactory.sample(
  odooId: 1,
  stage: FsmOrderStage.inProgress,
  isPendingSync: true,
);

// Tạo stock move pending
final move = StockMoveFactory.samplePending();

// Tạo timesheet entry
final entry = TimesheetEntryFactory.samplePending();
```

### Best Practices
1. **Mỗi test case tự chuẩn bị data** - không share state
2. **Dùng Isar in-memory** - không cần file JSON
3. **Tên rõ ràng**: `sampleDraft()`, `sampleDone()`, `samplePending()`
4. **Minimal data**: Chỉ set field cần thiết cho test case

---

## 🛠 Bảo trì (Maintenance)

### Tuần tự
| Hạng mục | Thời gian | Nội dung |
|---|---|---|
| **Monday** | ~1h | Fix Unit Test fail do code thay đổi |
| **Wednesday** | ~2h | Fix Integration Test fail, update factory methods |
| **Friday** | ~3-4h | Fix E2E flaky tests, update Patrol selectors |
| **Tổng** | **~6-7h/tuần** | |

### Khi nào phải update test?
- [ ] Thay đổi model field → update factory method
- [ ] Thay đổi API endpoint → update mock OdooClient
- [ ] Thay đổi UI layout → update Patrol selector
- [ ] Thêm feature mới → thêm TC tương ứng

---

## 📋 Checklist triển khai

- [ ] **Week 1**: Viết Unit Test cho validation logic + model parsing
- [ ] **Week 2**: Viết Integration Test cho Auth + Sync
- [ ] **Week 3**: Viết Integration Test cho Orders + Stock + Timesheet + Expense + Work Order
- [ ] **Week 4**: Setup Patrol, viết 12 E2E TC cốt lõi
- [ ] **Week 5**: Chạy regression Manual Test (44 TC) + fix bug
- [ ] **Week 6**: Integrate CI/CD + training cho team

---

## 📌 Lưu ý quan trọng

1. **Offline-First**: Tất cả test phải cover cả trường hợp mất mạng
2. **Odoo integration**: Không test Odoo API trực tiếp, chỉ test qua mock
3. **Isar schema**: Đảm bảo test dùng đúng schema version với production
4. **Permissions**: Test cả cho phép và từ chối quyền (Camera, GPS)
5. **Flaky tests**: E2E có thể fail ngẫu nhiên → cho phép retry, log lỗi rõ ràng

---

## 🔗 Tài liệu tham khảo

- [Flutter Testing](https://docs.flutter.dev/testing)
- [Patrol Docs](https://patrol.leancode.pl/)
- [Isar Database](https://isar.dev/)
- [Odoo External API](https://www.odoo.com/documentation/17.0/developer/howtos/api.html)
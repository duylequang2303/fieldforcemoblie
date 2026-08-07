# Bug Tracker: Stock Feature

## Thông tin chung
- **Feature**: Stock/Inventory (Quản lý kho, xuất nhập hàng)
- **Files liên quan**: `lib/features/stock/`
- **Models**: `Product`, `StockMove`
- **Services**: `StockService`
- **Pages**: `scanner_page.dart`, `stock_moves_page.dart`

---

## 🐛 Danh sách Bugs

### Logic/Functional Bugs

| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-LOGIC-001 | Quét lại cùng sản phẩm không cộng dồn qty | `stock_service.dart` `recordStockOut` line 142 | Critical | ✅ Fixed | Thêm else branch cộng `doneQty += qty` và `demandQty += qty` |
| STK-LOGIC-002 | Không validate qty âm/bằng 0 trước khi xuất kho | `scanner_page.dart` `_ProductFoundPanelState` line 347 | Critical | ✅ Fixed | Thêm kiểm tra `qty <= 0`, show SnackBar |

### UI/UX Bugs

| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| STK-UI-001 | `uomName`/`categoryName` hiển thị chuỗi rỗng thay vì `-` | `product.dart` `_nameFromMany` line 38 | Medium | ✅ Fixed | Đổi return type thành `String?`, trả `null` thay vì `''` |
| STK-UI-002 | Danh sách không refresh khi back thủ công từ ScannerPage | `stock_moves_page.dart` FAB `onPressed` line 99 | Medium | ✅ Fixed | Await `context.push()` rồi gọi `loadMoves` |

### Scanner/Camera Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-SCAN-001 | Torch state desync: không await `toggleTorch()` | `scanner_page.dart` line 74 | Medium | ✅ Fixed | Đổi thành async/await + try/catch |
| STK-SCAN-002 | Camera bị lock sau lỗi: `_processingBarcode` không reset | `scanner_page.dart` `onRecord` callback line 137 | High | ✅ Fixed | Bọc trong `try/finally` để đảm bảo reset |

### Performance/Memory Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-PERF-001 | `loadMoves` thiếu loading state khi reload | `stock_provider.dart` line 96 | Low | 🔵 Won't Fix | `getMovesForOrder` chỉ đọc local Isar, đủ nhanh |

### Offline/Sync Bugs

| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-SYNC-001 | Race condition: duplicate picking nếu crash giữa create và save pickingOdooId | `stock_service.dart` `_syncStockMoveToOdoo` line 283 | Low | 🟡 Known | Edge case, cần idempotency check Odoo phía sau |

---

## 📝 Checklist kiểm tra
- [x] Quét lại cùng sản phẩm: qty cộng dồn đúng
- [x] Nhập qty âm/0: bị chặn với thông báo
- [x] Lỗi khi xuất kho: camera vẫn quét được tiếp
- [x] Đơn vị tính hiển thị đúng (không rỗng)
- [x] Torch icon đồng bộ với trạng thái thực
- [x] Back từ ScannerPage: danh sách tự refresh

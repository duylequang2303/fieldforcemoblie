# Bug Tracker: Stock Feature

## Thông tin chung
- **Feature**: Stock/Inventory (Quản lý kho, xuất nhập hàng)
- **Files liên quan**: `lib/features/stock/`
- **Models**: `Product`, `StockMove`
- **Services**: `StockService`
- **Pages**: `scanner_page.dart`, `stock_moves_page.dart`
- **Ngày tạo**: $(date)

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| STK-UI-001 | | | | 🔴 Open | |
| STK-UI-002 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-LOGIC-001 | | | | 🔴 Open | |
| STK-LOGIC-002 | | | | 🔴 Open | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-SYNC-001 | | | | 🔴 Open | |

### Scanner/Camera Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| STK-SCAN-001 | | | | 🔴 Open | |
| STK-SCAN-002 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Quét mã vạch/QR code (camera permission, focus, lighting)
- [ ] Danh sách stock moves: filter, search, pagination
- [ ] Tạo stock move offline -> sync
- [ ] Validation số lượng (âm, vượt tồn kho)
- [ ] Product search/lookup
- [ ] Camera resource cleanup (dispose)
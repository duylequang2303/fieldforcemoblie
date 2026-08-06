# Bug Tracker: Orders Feature

## Thông tin chung
- **Feature**: Orders Management (Quản lý đơn hàng)
- **Files liên quan**: `lib/features/orders/`
- **Models**: `FsmOrder`, `FsmRecurring`, `FsmFrequencySet`
- **Services**: `OrdersService`, `RecurringService`, `RecurringNotificationService`
- **Pages**: `orders_list_page.dart`, `order_detail_page.dart`
- **Ngày tạo**: $(date)

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| ORD-UI-001 | | | | 🔴 Open | |
| ORD-UI-002 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-LOGIC-001 | | | | 🔴 Open | |
| ORD-LOGIC-002 | | | | 🔴 Open | |
| ORD-LOGIC-003 | | | | 🔴 Open | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-SYNC-001 | | | | 🔴 Open | |
| ORD-SYNC-002 | Recurring orders không sync đúng khi offline | | | 🔴 Open | |

### Data/Validation Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-DATA-001 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Load danh sách đơn hàng (pagination, filter, search)
- [ ] Chi tiết đơn: hiển thị đầy đủ info, trạng thái
- [ ] Tạo/sửa đơn offline -> sync khi online
- [ ] Recurring orders: tạo rule, generate instances, notification
- [ ] Xử lý conflict khi sync (server vs local)
- [ ] Hình ảnh/đính kèm đơn hàng
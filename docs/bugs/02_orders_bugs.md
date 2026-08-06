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
| ORD-UI-001 | Pull-to-refresh không hoạt động khi danh sách đơn hàng bị lọc trống. | `orders_list_page.dart` | High | ✅ Fixed | Wrapped empty state trong `RefreshIndicator` + `SingleChildScrollView`. |
| ORD-UI-002 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-LOGIC-001 | `_parseIntervalType` không map đúng các giá trị Odoo (`days/weeks/months/years`) sang enum. | `fsm_frequency_set.dart` | High | ✅ Fixed | Sử dụng `switch` để map giá trị Odoo sang `FrequencyIntervalType`. |
| ORD-LOGIC-002 | Crash khi chạy trên Web do thiếu guard `!kIsWeb` trước `!Platform.isLinux`. | `main.dart` | Critical | ✅ Fixed | Thêm guard `!kIsWeb` trước `!Platform.isLinux`. |
| ORD-LOGIC-003 | Check-in hiển thị lỗi đỏ khi offline do `_errorMessage` được set trên `OdooConnectionException`. | `orders_provider.dart` | High | ✅ Fixed | Không set `_errorMessage` khi gặp `OdooConnectionException`. |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-SYNC-001 | | | | 🔴 Open | |
| ORD-SYNC-002 | Recurring orders không sync đúng khi offline do Odoo từ chối filter `fsm_recurring_id`. | `orders_service.dart` | High | ✅ Fixed | Wrap idempotency check trong `try-catch` và bỏ filter `fsm_recurring_id` nếu Odoo từ chối. |

### Data/Validation Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| ORD-DATA-001 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [x] Load danh sách đơn hàng (pagination, filter, search)
- [x] Chi tiết đơn: hiển thị đầy đủ info, trạng thái
- [x] Tạo/sửa đơn offline -> sync khi online
- [x] Recurring orders: tạo rule, generate instances, notification
- [ ] Xử lý conflict khi sync (server vs local)
- [ ] Hình ảnh/đính kèm đơn hàng
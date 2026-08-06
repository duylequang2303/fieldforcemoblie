# Bug Tracker: Expense Feature

## Thông tin chung
- **Feature**: Expense (Chi phí, chi tiêu)
- **Files liên quan**: `lib/features/expense/`
- **Models**: `Expense`
- **Services**: `ExpenseService`
- **Pages**: `expense_page.dart`
- **Ngày tạo**: $(date)

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| EXP-UI-001 | | | | 🔴 Open | |
| EXP-UI-002 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-LOGIC-001 | | | | 🔴 Open | |
| EXP-LOGIC-002 | | | | 🔴 Open | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-SYNC-001 | | | | 🔴 Open | |

### Attachment/Receipt Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| EXP-ATT-001 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Tạo expense entry (category, amount, date, note)
- [ ] Upload hình ảnh hóa đơn/biên lai
- [ ] Offline expense -> sync
- [ ] Validation: amount > 0, required fields
- [ ] Expense categories từ server
- [ ] Approval workflow (nếu có)
- [ ] Summary/report view
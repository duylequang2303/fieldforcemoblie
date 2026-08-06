# Bug Tracker: Work Order Feature

## Thông tin chung
- **Feature**: Work Order (Lệnh làm việc, báo cáo công việc)
- **Files liên quan**: `lib/features/work_order/`
- **Models**: `WorkReport`
- **Services**: `WorkOrderService`
- **Pages**: `work_order_page.dart`, `work_order_detail_screen.dart` (trong lib/screens)
- **Ngày tạo**: $(date)

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| WO-UI-001 | | | | 🔴 Open | |
| WO-UI-002 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-LOGIC-001 | | | | 🔴 Open | |
| WO-LOGIC-002 | | | | 🔴 Open | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-SYNC-001 | | | | 🔴 Open | |

### Form/Validation Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-FORM-001 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Tạo work report (checklist, ghi chú, hình ảnh)
- [ ] Signature capture (ký tên)
- [ ] Offline work report -> sync
- [ ] Validation: required fields, photo requirements
- [ ] Work order status transitions
- [ ] Attachment handling (photos, docs)
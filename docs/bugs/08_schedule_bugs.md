# Bug Tracker: Schedule Feature

## Thông tin chung
- **Feature**: Schedule (Lịch trình, tuần hành, tài sản)
- **Files liên quan**: `lib/features/schedule/`, `lib/screens/schedule_screen.dart`
- **Models**: ScheduleVisit, ScheduleProperty, etc.
- **Services**: Schedule services
- **Pages**: 
  - `schedule_page.dart` (main)
  - `schedule_detail_page.dart`
  - `schedule_materials_page.dart`
  - `schedule_properties_list_page.dart`
  - `schedule_property_detail_page.dart`
  - `schedule_timesheet_page.dart`
  - `lib/screens/schedule_screen.dart` (UI redesign)
- **Ngày tạo**: $(date)

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| SCH-UI-001 | | | | 🔴 Open | |
| SCH-UI-002 | | | | 🔴 Open | |
| SCH-UI-003 | | | | 🔴 Open | |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SCH-LOGIC-001 | | | | 🔴 Open | |
| SCH-LOGIC-002 | | | | 🔴 Open | |
| SCH-LOGIC-003 | | | | 🔴 Open | |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SCH-PERF-001 | | | | 🔴 Open | |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SCH-SYNC-001 | | | | 🔴 Open | |

### Navigation/State Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| SCH-NAV-001 | | | | 🔴 Open | |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [ ] Schedule list: filter by date, status, property
- [ ] Schedule detail: check-in/out, navigation to property
- [ ] Materials management cho schedule
- [ ] Properties list & detail
- [ ] Timesheet integration trong schedule
- [ ] Offline schedule data -> sync
- [ ] Recurring schedule từ orders
- [ ] Notification/reminder cho upcoming visits
- [ ] Map integration (directions to property)
# Recurring Feature Implementation - Master Plan

> **Trạng thái:** PLANNING
> **Cập nhật cuối:** 2026-08-04

## Tổng quan

Implement chức năng **Recurring Tasks** (định kỳ) cho Field Force Mobile app, theo best practices của field service industry.

## Context

- Hiện tại recurring chỉ là mock UI, không có data model hay logic thực sự
- User thấy chức năng hiện tại "tào lao" vì không phản ánh thực tế
- Cần implement đúng chuẩn field service apps

## Timeline Overview

| Checkpoint | Nội dung | Duration |
|------------|----------|----------|
| CP0 | Pre-requisite Validation & Bug Fixes | 1 tuần |
| CP1 | Data Model & Schema | 1 tuần |
| CP2 | Core Recurring Logic (MVP) | 2 tuần |
| CP3 | Basic UI Integration | 1 tuần |
| CP4 | Advanced Features | 3 tuần |
| **Total** | | **8 tuần** |

## Architecture Decision

### Recurrence Patterns support
1. **Recur on Date** (fixed calendar intervals):
   - Weekly: Mỗi tuần, có thể chọn thứ (Mon, Wed, Fri...)
   - Monthly: Cùng ngày mỗi tháng
2. **Recur on Completion** (X days sau khi hoàn thành):
   - Dùng cho maintenance tasks (VD: oil change 30 days sau completion)

### Key Design Principles
- **Offline-first**: Recurring rules lưu trong Isar DB, auto-generate local trước, sync lên Odoo sau
- **Odoo là source of truth**: Prefer backend generate, app chỉ preview
- **Conflict resolution**: Odoo backend wins, local chỉ là cache
- **Audit trail**: Skip occurrence không ảnh hưởng completion audit

## Key Files & Context

### Existing Files cần modify
- `lib/features/orders/models/fsm_order.dart` - Add recurring fields
- `lib/features/orders/services/orders_service.dart` - Sync recurring data
- `lib/screens/work_order_detail_screen.dart` - Hiển thị recurring info

### New Files cần tạo
- `lib/features/orders/services/recurring_service.dart` - Core recurring logic
- `lib/features/orders/models/recurring_rule.dart` - Recurrence config model
- `lib/features/orders/widgets/recurring_badge.dart` - UI badge component

## Critical Risks (Phải fix TRƯỚC)

| # | Risk | Severity | File:Line | Status |
|---|------|----------|-----------|--------|
| 1 | `service_type` field bị loại khỏi fetch → checklist broken | BLOCKER | `orders_service.dart:50` | ⏳ Pending |
| 2 | Sync completed order dùng raw write() bypass state machine | HIGH | `orders_service.dart:537-563` | ⏳ Pending |
| 3 | syncPending() abort khi 1 order fail | MEDIUM | `orders_service.dart:690-738` | ⏳ Pending |
| 4 | Notifications chỉ schedule 7 ngày, không có background worker | MEDIUM | `recurring_notification_service.dart:57` | ⏳ Pending |
| 5 | Stage check dùng brittle string matching | MEDIUM | `recurring_service.dart:136` | ⏳ Pending |

## Next Steps

- [ ] Toggle to Act mode
- [ ] Bắt đầu Checkpoint 0: fix critical bugs
- [ ] Xem `02_PRE_REQS.md` cho chi tiết
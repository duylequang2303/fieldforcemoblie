
---

## DỰ ÁN: Fieldforce Mobile Rescue

### Tech stack
Flutter + Isar + Provider + GoRouter + Odoo RPC

### Mục tiêu
App demo được: login → orders → detail → check-in → signature/photo

### Trạng thái hiện tại
| Phase | Status |
|-------|--------|
| 1.1 Isar dedup | ✅ Done + unit tests |
| 1.2 Order detail unification | ✅ Done + widget tests |
| 1.3 API field safety | ✅ Done + widget tests |
| 1.4 Flex overflow | ⏳ Next |
| 1.5 Smoke test checklist | ⏳ Pending |
| Integration tests | 🟡 In progress |

### Files quan trọng
- Single source of truth order detail: `WorkOrderDetailScreen`
- Router: `lib/core/routing/app_router.dart`
- Route provider: `lib/features/route_map/providers/route_provider.dart`
- Session manager: `lib/core/api/odoo_session_manager.dart`

---

## NHIỆM VỤ HIỆN TẠI

Chúng ta đang ở bước: **Integration Tests cho Phase 1.2 + 1.3**

### Test strategy đã duyệt:
- Dùng REAL Odoo backend (test server, chưa release, không có data thật)
- Credentials đọc từ file `.env`
- KHÔNG MOCK — tất cả là real API calls
- Data test có prefix `TEST_` để cleanup
- Cleanup sau mỗi test (try/finally)

### Files sẽ tạo:
1. `integration_test/phase_1_2_order_detail_navigation_test.dart`
2. `integration_test/phase_1_3_api_safety_test.dart`

### Test cases Phase 1.2:
1. Login → Orders tab → Tap order → Verify WorkOrderDetailScreen
2. Login → Route Map → Tap stop → Tap "Chi tiết" → Verify detail
3. Back button từ detail → Verify quay về

### Test cases Phase 1.3:
1. Login → Verify session valid
2. Tạo timesheet "TEST_Timesheet_[timestamp]" → Verify sync to Odoo
3. Tạo expense "TEST_Expense_[timestamp]" → Verify sync to Odoo

### Constraints:
- Không đổi application code
- Không mock
- Không tạo user mới trên Odoo
- Cleanup mandatory

---

## BẮT ĐẦU

Bạn đang ở BƯỚC 1: TRÌNH BÀY.

Hãy trình bày:
1. Bạn sẽ tạo file gì?
2. Mỗi file chứa test cases nào?
3. Bạn sẽ đọc .env như thế nào?
4. Bạn sẽ cleanup như thế nào?
5. Bạn cần tôi confirm gì trước khi viết code?

SAU ĐÓ DỪNG LẠI, CHỜ TÔI DUYỆT.

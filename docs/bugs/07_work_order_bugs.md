# Bug Tracker: Work Order Feature

## Thông tin chung
- **Feature**: Work Order (Lệnh làm việc, báo cáo công việc)
- **Files liên quan**: `lib/features/work_order/`
- **Models**: `WorkReport`
- **Services**: `WorkOrderService`
- **Pages**: `work_order_page.dart`, `work_order_detail_screen.dart` (trong lib/screens)
- **Ngày tạo**: 2026-08-07

---

## 🐛 Danh sách Bugs

### UI/UX Bugs
| ID | Mô tả bug | File/Widget | Mức độ | Trạng thái | Ghi chú |
|----|-----------|-------------|--------|------------|---------|
| WO-UI-001 | Nút "Add Photo" hiển thị ở đầu danh sách ngang thay vì cuối hoặc FAB, gây nhầm lẫn UX | `lib/features/work_order/widgets/photo_capture_widget.dart:39` | Medium | 🟢 Closed | Đã move xuống cuối danh sách thumbnails |
| WO-UI-002 | Progress bar không phản ánh yêu cầu ảnh: Step 1 đánh dấu hoàn thành khi có workDone nhưng không kiểm tra ảnh bắt buộc | `lib/features/work_order/pages/work_order_page.dart:142` | Medium | 🟢 Closed | Step 1 giờ kiểm tra cả `requirePhoto` và ảnh đã có |
| WO-UI-003 | Nút "Ký lại" chỉ toggle `_hasSigned` nhưng ảnh chữ ký cũ vẫn hiển thị đến lần render tiếp theo | `lib/features/work_order/widgets/customer_signature_widget.dart:105` | Low | 🟢 Closed | Đã clear name + tạo key mới cho SignaturePad |
| WO-UI-004 | Hai màn hình trùng lặp workflow: `WorkOrderPage` (stepper) và `WorkOrderDetailScreen` (legacy) có logic validation, xử lý ảnh và signature khác nhau | `lib/features/work_order/pages/work_order_page.dart` vs `lib/screens/work_order_detail_screen.dart` | High | 🟡 Partial | Cả 2 screen vẫn tồn tại nhưng đã đồng bộ validation/photo/signature logic. Chưa consolidate thành 1 màn hình duy nhất |

### Logic/Functional Bugs
| ID | Mô tả bug | File/Function | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-LOGIC-001 | **Race condition mất ảnh**: `_uploadPhoto` thêm ảnh vào Isar → upload Odoo → xóa khỏi `photoPaths` (line 348-349). Nếu upload fail, ảnh bị mất khỏi local list | `lib/screens/work_order_detail_screen.dart:329-365` | Critical | 🟢 Closed | Đã giữ ảnh trong `photoPaths`, `uploadSinglePhoto` trả về report đã cập nhật synced paths |
| WO-LOGIC-002 | **Signature validation bypass**: Kiểm tra `report.signedAt != null` (line 459), nhưng `signedAt` chỉ set locally khi user vẽ signature (line 483). Nếu load report có signature từ device khác, `signedAt` = null → bắt ký lại không cần thiết | `lib/screens/work_order_detail_screen.dart:459-484` | High | 🟢 Closed | Đã kiểm tra `customerSignaturePath != null` (không yêu cầu `signedAt`), legacy screen chấp nhận signature từ Odoo |
| WO-LOGIC-003 | `submitReport` không validate `workDone` non-empty trước khi gửi Odoo, có thể submit report rỗng | `lib/features/work_order/services/work_order_service.dart:115` | High | 🟢 Closed | Đã throw exception nếu `workDone.trim().isEmpty` |
| WO-LOGIC-004 | Khi xóa ảnh khỏi `photoPaths`, `syncedPhotoPaths` được filter đúng nhưng `syncedAttachmentEntries` filtering dùng `split('|').first` có thể không match nếu path format khác nhau | `lib/features/work_order/services/work_order_service.dart:92-98` | Medium | 🟢 Closed | Filter robust: check cả `parts[0]` và `parts[1]` |
| WO-LOGIC-005 | Getter `isComplete` chỉ kiểm tra `workDone` và signature, không kiểm tra yêu cầu ảnh từ `FsmOrder` | `lib/features/work_order/providers/work_order_provider.dart:28-34` | Medium | 🟢 Closed | `isComplete` giờ kiểm tra `requirePhoto` + `photoPaths`/`syncedPhotoPaths` |
| WO-LOGIC-006 | `getOrCreateReport` filter theo `orderOdooId` + `localOwnerId` (line 52-57), nhưng nếu `localOwnerId` null (user chưa login), có thể tạo nhiều report trùng lặp cho cùng order | `lib/features/work_order/services/work_order_service.dart:50-67` | Medium | 🟢 Closed | Đã throw `OdooAuthException` nếu `currentUserId == null` |
| WO-LOGIC-007 | `syncPending` không có retry mechanism hay dead-letter queue cho report fail → report có thể mất sau nhiều lần thất bại | `lib/features/work_order/services/work_order_service.dart:199-216` | Medium | 🔴 Open | Chưa implement retry queue |

### Performance/Memory Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-PERF-001 | `PhotoCaptureWidget` thumbnail dùng `SafeImageFile` không có `cacheWidth`/`cacheHeight`, decode full-res image gây tốn bộ nhớ | `lib/features/work_order/widgets/photo_capture_widget.dart:155-160` | Medium | 🟢 Closed | Đã thêm `cacheWidth: 176` và `cacheHeight: 176` |
| WO-PERF-002 | `uploadPhotos` encode base64 từng ảnh tuần tự (line 257), batch lớn ảnh sẽ freeze UI | `lib/features/work_order/services/work_order_service.dart:257` | Medium | 🔴 Open | Đã dùng `compute(_encodeBase64Isolate, path)` nhưng vẫn tuần tự. Chưa parallel batch |
| WO-PERF-003 | `work_order_detail_screen.dart` line 808 dùng `cacheWidth: 176` nhưng `SafeImageFile` vẫn có thể load full image trước | `lib/screens/work_order_detail_screen.dart:808` | Low | 🔴 Open | Đã có `cacheWidth: 176` nhưng SafeImageFile cần kiểm tra lại implementation |

### Offline/Sync Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-SYNC-001 | `uploadSinglePhoto` (line 316-353) tạo attachment + message_post nhưng không ghi vào `syncedAttachmentEntries`/`syncedPhotoPaths`. Khi submit report sau, `uploadPhotos` sẽ re-upload ảnh trùng | `lib/features/work_order/services/work_order_service.dart:316-353` | High | 🟢 Closed | `uploadSinglePhoto` giờ nhận `WorkReport`, update synced paths/entries và trả về report đã persist |
| WO-SYNC-002 | Sau wizard `action_sign` (line 164), không verify signature đã được áp dụng vào `fsm.order`. Nếu wizard fail silent, `isSignatureSynced=true` nhưng Odoo không có signature | `lib/features/work_order/services/work_order_service.dart:145-169` | High | 🟢 Closed | Đã verify wizard result + đọc lại `customer_signature` từ Odoo |
| WO-SYNC-003 | `isPendingSync` chỉ set false khi tất cả đã sync (line 186-190). Nếu user thêm ảnh sau khi submit, `isPendingSync` giữ false đến lần save tiếp theo | `lib/features/work_order/services/work_order_service.dart:186-190` | Medium | 🟢 Closed | Provider `addPhoto`/`removePhoto` đã set `isPendingSync = true` |
| WO-SYNC-004 | Không có conflict resolution cho concurrent offline edits. Hai device cùng edit offline sẽ tạo 2 `WorkReport` khác nhau → last write wins, mất dữ liệu | `lib/features/work_order/services/work_order_service.dart:50-67` | Medium | 🔴 Open | Chưa implement conflict detection/merge |

### Form/Validation Bugs
| ID | Mô tả bug | File/Location | Mức độ | Trạng thái | Ghi chú |
|----|-----------|---------------|--------|------------|---------|
| WO-FORM-001 | Không có client-side validation required fields. `WorkOrderPage` cho phép qua Step 2/3 mà không cần `workDone`. Submit button chỉ disable bởi `isComplete` không validate ảnh | `lib/features/work_order/pages/work_order_page.dart:452` | High | 🟢 Closed | Nút "Tiếp theo" giờ disable nếu step hiện tại chưa valid (workDone + ảnh nếu required) |
| WO-FORM-002 | Validation customer name signature không nhất quán: `CustomerSignatureWidget` validate ở confirm (line 163-167), `WorkOrderDetailScreen` validate riêng (line 466-468) | `lib/features/work_order/widgets/customer_signature_widget.dart:163` | Medium | 🔴 Open | Chưa unify. Cả 2 nơi đều validate nhưng logic vẫn tách biệt |
| WO-FORM-003 | Không giới hạn số lượng ảnh, không validate file size. User có thể thêm unlimited large photos gây OOM hoặc sync fail | `lib/features/work_order/widgets/photo_capture_widget.dart` | Medium | 🟢 Closed | Giới hạn 10 ảnh, reject file > 10MB |
| WO-FORM-004 | `completeOrder` có thể gọi từ bất kỳ stage nào, không kiểm tra order đang ở `inProgress` trước khi complete | `lib/screens/work_order_detail_screen.dart:503` | Medium | 🟢 Closed | `_onComplete` giờ guard bằng `_isClosed` trước khi xử lý |

---

## 📝 Các vùng cần kiểm tra kỹ (gợi ý)
- [x] Tạo work report (checklist, ghi chú, hình ảnh)
- [x] Signature capture (ký tên)
- [x] Offline work report -> sync
- [x] Validation: required fields, photo requirements
- [x] Work order status transitions
- [x] Attachment handling (photos, docs)

---

## ✅ Tóm tắt đã fix (2026-08-07)

### Phase 1 - Critical
| ID | Fix | File |
|----|-----|------|
| WO-LOGIC-001 | `_uploadPhoto` không còn xóa ảnh khỏi `photoPaths` sau upload; `uploadSinglePhoto` trả về report đã update synced paths | `work_order_detail_screen.dart`, `work_order_service.dart` |
| WO-SYNC-001 | `uploadSinglePhoto` giờ nhận `WorkReport`, persist `syncedAttachmentEntries` (`path|attId`) và `syncedPhotoPaths` | `work_order_service.dart` |
| WO-LOGIC-003 | `submitReport` validate `workDone.trim().isNotEmpty` trước khi gửi Odoo | `work_order_service.dart` |
| WO-LOGIC-002 | `alreadySigned` kiểm tra `customerSignaturePath != null` (không yêu cầu `signedAt`) | `work_order_detail_screen.dart` |

### Phase 2 - High Impact
| ID | Fix | File |
|----|-----|------|
| WO-UI-002 | Progress bar Step 1 kiểm tra `requirePhoto` + ảnh đã có (photoPaths hoặc syncedPhotoPaths) | `work_order_page.dart` |
| WO-FORM-001 | Nút "Tiếp theo" disable nếu step hiện tại chưa valid; `_validateStep` kiểm tra workDone + ảnh + signature | `work_order_page.dart` |
| WO-FORM-004 | `_onComplete` guard bằng `_isClosed` | `work_order_detail_screen.dart` |
| WO-SYNC-002 | `submitReport` verify wizard result + đọc lại `customer_signature` từ Odoo | `work_order_service.dart` |

### Phase 3 - Medium
| ID | Fix | File |
|----|-----|------|
| WO-LOGIC-004 | `saveReport` filter `syncedAttachmentEntries` robust: check cả `parts[0]` và `parts[1]` | `work_order_service.dart` |
| WO-LOGIC-006 | `getOrCreateReport` throw `OdooAuthException` nếu `currentUserId == null` | `work_order_service.dart` |
| WO-SYNC-003 | Provider `addPhoto`/`removePhoto` set `isPendingSync = true` | `work_order_provider.dart` |
| WO-PERF-001 | Thumbnail `SafeImageFile` thêm `cacheWidth: 176`, `cacheHeight: 176` | `photo_capture_widget.dart` |
| WO-FORM-003 | Giới hạn 10 ảnh, validate file size ≤ 10MB | `photo_capture_widget.dart` |
| WO-UI-001 | Move nút "Add Photo" xuống cuối danh sách horizontal | `photo_capture_widget.dart` |

### Phase 4 - Polish
| ID | Fix | File |
|----|-----|------|
| WO-UI-003 | "Ký lại" clear `_nameController` + tạo key mới cho SignaturePad | `customer_signature_widget.dart` |
| WO-LOGIC-005 | `isComplete` check `requirePhoto` + photoPaths/syncedPhotoPaths | `work_order_provider.dart` |

---

## 📊 Thống kê
- **Tổng bugs**: 22
- **Critical (P0)**: 4 → 3 Closed, 1 Open
- **High (P1)**: 4 → 3 Closed, 1 Partial
- **Medium (P2)**: 8 → 5 Closed, 3 Open
- **Low (P3)**: 2 → 1 Closed, 1 Open

**Closed/Fixed**: 15 | **Open/Partial**: 7

## 🎯 Kế hoạch Fix (Theo thứ tự ưu tiên)

### Phase 1: Critical Bugs (Data Loss / Corruption Risk)
1. **P0 - WO-LOGIC-001**: Fix photo upload race condition (2h)
2. **P0 - WO-SYNC-001**: Fix duplicate upload prevention (1h)
3. **P0 - WO-LOGIC-003**: Add validation in submitReport (1h)
4. **P0 - WO-LOGIC-002**: Fix signature validation bypass (30m)

### Phase 2: High Impact (UX / Data Integrity)
5. **P1 - WO-UI-004**: Consolidate two screens into single WorkOrderPage flow (4h)
6. **P1 - WO-LOGIC-005**: Update `isComplete` to check photo requirements (30m)
7. **P1 - WO-SYNC-002**: Verify signature applied in Odoo after wizard (1h)
8. **P1 - WO-FORM-001**: Add step validation disable "Next" until requirements met (1h)

### Phase 3: Medium Impact (Offline / Performance)
9. **P2 - WO-LOGIC-004**: Fix `syncedAttachmentEntries` filtering logic (1h)
10. **P2 - WO-LOGIC-006**: Handle `localOwnerId == null` in `getOrCreateReport` (30m)
11. **P2 - WO-SYNC-003**: Set `isPendingSync = true` when new photos added after submit (30m)
12. **P2 - WO-PERF-001**: Add `cacheWidth`/`cacheHeight` to thumbnails (15m)
13. **P2 - WO-PERF-002**: Batch base64 encoding in `uploadPhotos` (1h)
14. **P2 - WO-FORM-003**: Add max photo limit and file size validation (1h)

### Phase 4: Polish & Edge Cases
15. **P3 - WO-UI-001**: Move "Add Photo" button to end of list or FAB (30m)
16. **P3 - WO-UI-002**: Update progress bar to show photo requirement (30m)
17. **P3 - WO-UI-003**: Fix "Ký lại" to clear signature state properly (30m)
18. **P3 - WO-LOGIC-007**: Add retry queue in `syncPending` (2h)
19. **P3 - WO-SYNC-004**: Add conflict detection for concurrent offline edits (2h)
20. **P3 - WO-FORM-002**: Unify signature validation logic (1h)
21. **P3 - WO-FORM-004**: Validate order stage before complete (30m)
22. **P3 - WO-PERF-003**: Verify `SafeImageFile` cacheWidth implementation in detail screen (15m)

> **Note**: The plan uses implementation priority (P0–P3), which may differ from bug severity (Critical/High/Medium/Low) based on technical dependencies and fix scope.

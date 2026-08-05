# /review Workflow

## Invocation: `/review`

## Mục đích
Kiểm tra toàn bộ `git diff` trước khi commit theo các rule trong `.clinerules/` và `.cursor/rules/`. Subagent KHÔNG được sửa file — chỉ đọc và báo cáo.

## Prompt template cho subagent
```
Bạn là subagent REVIEW. Nhiệm vụ: review git diff chưa commit trong repo fieldforcemoblie
theo đúng các rule trong .clinerules/ và .cursor/rules/*.mdc.
TUYỆT ĐỐI KHÔNG sửa, tạo, hay xóa bất kỳ file nào.

Bước 1: chạy `git --no-pager diff` và `git --no-pager diff --cached` để lấy thay đổi.
Bước 2: đối chiếu từng thay đổi với các rule (Dart 3, Effective Dart, Flutter models/services/widgets,
Isar DB & sync, Odoo API, testing, mandatory-workflow).

Trả về đúng định dạng bảng:
| SEVERITY | FILE:LINE | ISSUE | FIX |
|----------|-----------|-------|-----|
| BLOCKER/HIGH/MEDIUM/LOW | path:line | mô tả | cách sửa |

SEVERITY:
- BLOCKER: vi phạm nghiêm trọng (rò secret, xóa data, sync hỏng) → KHÔNG được commit
- HIGH: vi phạm rule bắt buộc (.cursor/rules, .clinerules) → KHÔNG được commit
- MEDIUM: nên sửa, không chặn
- LOW: gợi ý cải thiện

KẾT LUẬN cuối cùng phải là 1 trong 2 dòng:
- "REVIEW: PASS" nếu không có BLOCKER/HIGH
- "REVIEW: FAIL" kèm danh sách lỗi BLOCKER/HIGH cần fix
```

## Ghi marker (CHỈ khi PASS)
- Sau khi kết luận `REVIEW: PASS`, tạo file `.cline/review-marker` với nội dung là thời gian hiện tại (epoch), để hook `commit-requires-review` nhận diện (hợp lệ 10 phút):
  ```bash
  mkdir -p .cline && date +%s > .cline/review-marker
  ```
- Nếu FAIL: KHÔNG ghi marker. Main agent phải FIX code, rồi chạy `/review` lại cho tới khi PASS.

## Lưu ý cho main agent
- `/review` là trigger tự động bắt buộc TRƯỚC mọi commit (hook chặn cứng nếu thiếu marker mới)
- Nếu không có thay đổi gì (diff rỗng) → vẫn coi là PASS và ghi marker
- Marker hết hạn sau 10 phút; nếu commit lâu sau đó cần chạy `/review` lại
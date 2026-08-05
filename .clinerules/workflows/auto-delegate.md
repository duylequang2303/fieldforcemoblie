# Auto-Delegation Logic

## Mục đích
Cung cấp luật để agent TỰ QUYẾT ĐỊNH khi nào cần subagent, KHÔNG phụ thuộc người dùng nhớ gõ lệnh. Quy tắc bắt buộc (xem `mandatory-workflow.md`).

## Quyết định tại điểm bắt đầu task
Dựa vào kích thước và độ rủi ro của task, agent đánh giá 3 câu hỏi:

### Q1 — Cần hiểu code trước chưa? → /scout
- Task đọc **≥5 file** HOẶC chạm vùng code chưa quen thuộc
- Hành động: spawn 1 subagent `/scout` → nhận briefing → mới bắt tay làm
- Bỏ qua nếu task chỉ sửa 1-2 file ngữ cảnh đã rõ

### Q2 — Sắp commit chưa? → /review
- Trước **mọi `git commit`** → spawn 1 subagent `/review` (bắt buộc, hook chặn cứng)
- Nếu FAIL → fix code → chạy lại cho tới PASS → mới commit

### Q3 — Giải pháp khó/đa chiều? → /think
- Task phức tạp, >1 cách tiếp cận, rủi ro cao (sync/Odoo/schema)
- Hành động: spawn 3 subagents (PROPOSER/SKEPTIC/CHECKER) → tổng hợp FINAL PLAN

## Luồng tổng quát khi nhận task
```
1. Phân tích phạm vi task (số file, vùng code, rủi ro)
2. Nếu Q1 = YES → spawn /scout, nhận briefing (KHÔNG sửa file trong lúc này)
3. Nếu Q3 = YES → spawn /think để chốt hướng tiếp cận
4. Thực hiện sửa code
5. Trước commit → spawn /review; nếu FAIL fix rồi chạy lại
6. Commit (hook sẽ chặn nếu thiếu review-marker mới)
```

## Lưu ý chống lạm dụng
- Task đơn giản (1-2 file, thay đổi nhỏ) → làm trực tiếp, KHÔNG spawn
- Chỉ spawn khi thực sự cần; mỗi subagent output ngắn, có file:line cụ thể
- Subagent scope nhỏ, một nhiệm vụ duy nhất — không giao phó cả task lớn
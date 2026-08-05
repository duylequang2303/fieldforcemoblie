# Mandatory Workflow (Auto-Delegation)

## Nguyên tắc chung
Agent TỰ ĐỘNG quyết định khi nào cần subagent — người dùng KHÔNG cần nhớ gõ `/think`, `/review`, hay `/scout`. Các quy tắc dưới đây là mặc định bắt buộc, trừ khi người dùng yêu cầu cụ thể khác đi.

## Quy tắc tự động gọi subagent

### A. Scout (nghiên cứu codebase / web)
**Trigger tự động — Khi task cần đọc từ 5 file trở lên HOẶC cần hiểu vùng code chưa quen thuộc:**
1. Gọi subagent `/scout` (xem `workflows/scout.md`) TRƯỚC khi bắt tay vào làm
2. Subagent trả briefing ≤500 từ: key files, file:line refs, data flow — KHÔNG sửa file
3. Chỉ sau khi nhận briefing, main agent mới quyết định file nào cần đọc tiếp / sửa

**Ngoại lệ**: Không cần scout nếu task chỉ sửa 1-2 file đã rõ ràng ngữ cảnh.

### B. Review (kiểm tra git diff trước commit)
**Trigger tự động — BẮT BUỘC trước mọi `git commit`** (do hook `hooks/commit-requires-review` chặn cứng nếu thiếu):
1. Trước khi commit, gọi subagent `/review` (xem `workflows/review.md`)
2. Subagent đọc `git diff` → trả bảng `SEVERITY | FILE:LINE | ISSUE | FIX` — KHÔNG sửa file
3. Nếu pass (không có lỗi `BLOCKER`/`HIGH`) → subagent ghi `.cline/review-marker` (thời gian hiện tại, hợp lệ 10 phút)
4. Nếu có lỗi nghiêm trọng → FIX code trước, rồi chạy `/review` lại cho tới khi pass, rồi mới commit

### C. Think (brainstorm nhiều góc nhìn)
**Trigger tự động — Khi có bất kỳ dấu hiệu nào sau:**
- Task phức tạp, thiếu rõ ràng về giải pháp
- Có >1 cách tiếp cận đáng phân vân
- Rủi ro cao: đụng sync offline/Odoo/schema dễ gây lỗi ngầm
→ Gọi `/think <problem>` (xem `workflows/think.md`) để PROPOSER/SKEPTIC/CHECKER phân tích, rồi tổng hợp `FINAL PLAN`

## Ưu tiên đường vận chuyển subagent
1. **a2a-platform** (SSE) — ưu tiên nếu kết nối ổn định
2. **`use_subagents` / `new_task`** — fallback mặc định đáng tin cậy
> Chi tiết failover trong `workflows/think.md` §RESILIENCE (404 → fallback `new_task` ngay, không retry).

## Chống lạm dụng (tránh subagent tốn token vô ích)
- Task đơn giản (1-2 file, thay đổi nhỏ, ngữ cảnh rõ) → làm trực tiếp, KHÔNG cần subagent
- Chỉ auto-delegate khi thực sự cần: nhiều file, vùng lạ, rủi ro cao, hoặc chuẩn bị commit
- Mỗi subagent trả output ngắn gọn, có file:line cụ thể — không spam
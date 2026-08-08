# Hệ thống Agent trên opencode (thay thế Zed spawn_agent)

> **Version:** 1.0
> **Ngày:** 2026-08-08
> **Context:** Dự án chạy trên **opencode** (không còn Zed). Các workflow THINK/SCOUT/REVIEW trước đây dùng `spawn_agent` của Zed, nay chuyển sang `task` tool + subagents của opencode.

---

## 1. Thay đổi chính

| Zed (cũ) | opencode (mới) |
|-----------|-----------------|
| `spawn_agent(label, message)` | `task(subagent_type, prompt)` |
| Không có MCP support | **MCP native** — config trong `opencode.json` |
| Subagent chỉ có prompt inline | Subagent định nghĩa sẵn trong `.opencode/agent/*.md` |
| Không có custom roles | Có `proposer`, `skeptic`, `checker`, `scout`, `reviewer` |

## 2. Các subagent đã định nghĩa (`.opencode/agent/`)

| File | Vai trò | Dùng cho |
|------|---------|----------|
| `scout.md` | Research codebase, trả briefing ≤500 từ | SCOUT workflow |
| `reviewer.md` | Review git diff trước commit | REVIEW workflow |
| `proposer.md` | Đề xuất giải pháp đơn giản nhất | THINK workflow |
| `skeptic.md` | Tấn công đề xuất, tìm lỗ hổng | THINK workflow |
| `checker.md` | Verify bằng code thực tế | THINK workflow |

## 3. Cách gọi subagent trong opencode

### THINK Workflow (3 debaters song song)

```markdown
Main agent dùng `task` tool với 3 lần gọi song song:

1. task(subagent_type: "proposer", prompt: "<problem + context>")
2. task(subagent_type: "skeptic", prompt: "<problem + context>")
3. task(subagent_type: "checker", prompt: "<problem + context>")

→ Main agent tổng hợp → FINAL PLAN
```

### SCOUT Workflow

```markdown
task(subagent_type: "scout", prompt: "<target area + mission>")
→ Nhận briefing ≤500 từ → quyết định file nào đọc tiếp
```

### REVIEW Workflow

```markdown
task(subagent_type: "reviewer", prompt: "Review git diff trước commit")
→ Nhận bảng SEVERITY | FILE:LINE | ISSUE | FIX
→ PASS thì commit, FAIL thì fix rồi chạy lại
```

## 4. Quy tắc quan trọng

- **Subagent chỉ đọc, không sửa file** — mọi agent trong `.opencode/agent/` đều có `permission.edit: deny`.
- **Prompt phải self-contained** — subagent không có context conversation của main agent. Luôn include: project context, task cụ thể, output format mong muốn.
- **Không delegate task cần `.env`/credentials** — subagent không đọc được file private. Main agent giữ context và gọi API trực tiếp.
- **Main agent verify lại critical findings** — subagent report chỉ là hypothesis, cần grep/read xác nhận.
- **Chống lạm dụng** — task đơn giản (<3 tool calls, 1-2 files) làm trực tiếp, không cần subagent.

## 5. Rules nguồn (vẫn áp dụng)

- `THINK_WORKFLOW.md` — templates debaters, synthesis format
- `SCOUT_WORKFLOW.md` — research pattern, output format
- `REVIEW_WORKFLOW.md` — severity levels, checklist trước commit
- `.clinerules/mandatory-workflow.md` — auto-delegation principles

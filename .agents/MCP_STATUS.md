# MCP Support Status (migration từ Zed → opencode)

> **Updated:** 2026-08-08
> **Context:** Dự án đã chuyển từ Zed sang **opencode**. opencode HỖ TRỢ MCP protocol native.
> **Tài liệu mới:** Xem [`.agents/OPENCODE_MCP_GUIDE.md`](.agents/OPENCODE_MCP_GUIDE.md) — hướng dẫn MCP đầy đủ cho opencode.
> **⚠️ Nội dung bên dưới là reference cũ từ Zed era, giữ lại cho lịch sử migration.**

---

## ❌ TL;DR (Zed era - đã lỗi thời): Zed KHÔNG HỖ TRỢ MCP protocol

**Zed chỉ có:**
- `spawn_agent` (native subagent system)
- Standard file/terminal tools
- Knowledge graph tools

**Zed KHÔNG có:**
- MCP client built-in
- External MCP server connections
- SSE/stdio MCP transport

---

## 📊 So sánh Cline vs Zed

| Feature | Cline | Zed | Workaround in Zed |
|---------|-------|-----|-------------------|
| **MCP Client** | ✅ Native | ❌ None | `terminal` + curl |
| **a2a-platform** | ✅ SSE connection | ❌ No support | spawn_agent (3 debaters) |
| **Filesystem MCP** | ✅ Via MCP | ❌ No MCP | Native read/write tools |
| **Supermemory** | ✅ Via MCP | ❌ No MCP | Manual context docs |
| **Web Search MCP** | ✅ Via MCP | ❌ No MCP | `fetch` tool (limited) |
| **Subagents** | ✅ new_task/use_subagents | ✅ spawn_agent | ✅ Same capability |

---

## 🎯 Migration Strategy: a2a-platform → Zed spawn_agent

### What we had in Cline (a2a-platform):

```javascript
// Cline: gọi MCP server qua SSE
await mcp.call({
  server: 'a2a-platform',
  endpoint: 'https://agent-router-backend-.../mcp/sse',
  // Token đọc từ biến môi trường, không hardcode.
  // Phải export trước khi mở Cline: `set -a && . ./.env && set +a`
  auth: process.env.A2A_PLATFORM_TOKEN,
  role: 'PROPOSER',
  task: 'propose recurring approach'
})
```

### What we do in Zed (native spawn_agent):

```javascript
// Zed: spawn native subagent
spawn_agent({
  label: "PROPOSER - Recurring approach",
  message: `
    Role: PROPOSER
    Problem: [...]
    Output: CLAIM | EVIDENCE | RISK
  `
})
```

**Result:** SAME functionality, different transport

---

## ✅ Workflows ported to Zed

### 1. THINK Workflow (3 debaters)
**Cline:** 3 MCP calls to a2a-platform  
**Zed:** 3 parallel `spawn_agent` calls  
**File:** `.agents/THINK_WORKFLOW.md`

**Status:** ✅ FULLY PORTED

### 2. SCOUT Workflow (research)
**Cline:** MCP call to a2a scout + web search  
**Zed:** 1 `spawn_agent` with grep/read_file (no web search)  
**File:** `.agents/SCOUT_WORKFLOW.md`

**Status:** ✅ PORTED (minus web search)

### 3. REVIEW Workflow (pre-commit)
**Cline:** MCP call + git hook enforcement  
**Zed:** 1 `spawn_agent` + manual trigger (no hooks)  
**File:** `.agents/REVIEW_WORKFLOW.md`

**Status:** ✅ PORTED (minus auto-enforcement)

---

## 🔧 Workarounds for missing MCP features

### Web Search (missing)

**Cline had:** MCP web search server  
**Zed workaround:**
- Use `fetch` tool for known URLs
- Manual research (ask user for links)
- Delegate to user: "Can you search X and paste results?"

### Supermemory / Agent Memory (missing)

**Cline had:** MCP supermemory server  
**Zed workaround:**
- Manual context docs (PROGRESS.md, checkpoint files)
- Knowledge graph tools (search_graph, get_architecture)
- Session logs in PROGRESS.md

### Filesystem MCP (unnecessary)

**Cline had:** MCP filesystem server  
**Zed has:** Native read/write/grep/find_path tools  
**No workaround needed:** Zed native tools are better

---

## 🚫 What we WON'T port from Cline

### 1. Git hooks (`.clinerules/hooks/`)
**Why:** Zed doesn't support pre-commit hooks  
**Alternative:** Manual REVIEW workflow before commits

### 2. Review marker (`.cline/review-marker`)
**Why:** No hooks = no need for marker  
**Alternative:** Main agent tracks REVIEW state in session

### 3. a2a-platform specific configs
**Why:** No MCP support  
**Alternative:** Native spawn_agent

### 4. SSE failover logic
**Why:** No SSE transport  
**Alternative:** spawn_agent timeout handling

---

## 📁 Cleanup done (2026-08-05)

### Archived (reference only):
- ✅ `.agents/skills/a2a-mcp-connector/` → `_archived_a2a-mcp-connector/`
- ✅ `AGENTS.md §12` → marked DEPRECATED

### Kept (still relevant):
- ✅ `.clinerules/workflows/think.md` → reference for THINK logic
- ✅ `.clinerules/workflows/scout.md` → reference for SCOUT logic
- ✅ `.clinerules/workflows/review.md` → reference for REVIEW logic
- ✅ `.clinerules/mandatory-workflow.md` → principles still apply

---

## 💡 Recommendations

### For future MCP needs:

**If Zed adds MCP support later:**
1. Re-enable a2a-platform connection (token still valid)
2. Add web search MCP back to SCOUT
3. Consider supermemory MCP for long-term context

**Until then:**
- ✅ Use Zed native spawn_agent (works great)
- ✅ Manual research for web (acceptable tradeoff)
- ✅ Context docs for memory (PROGRESS.md system)

### For complex external tools:

**Option 1: Terminal wrapper**
```bash
# scripts/call_external_api.sh
curl -X POST https://some-api.com/endpoint \
  -H "Authorization: token" \
  -d "$1"
```

Then in Zed:
```javascript
terminal(command: './scripts/call_external_api.sh "task"')
```

**Option 2: Python/Node.js scripts**
```bash
# scripts/mcp_proxy.py
import requests
response = requests.post('https://mcp-server...', ...)
print(response.json())
```

---

## 📚 References

- **a2a-platform docs:** (kept in `_archived_a2a-mcp-connector/`)
- **MCP protocol spec:** https://modelcontextprotocol.io/
- **Zed spawn_agent docs:** [Zed documentation]
- **Migration guide:** This file

---

## ❓ FAQ

**Q: Có thể dùng curl để gọi a2a-platform không?**  
A: Có, nhưng không elegant. Mất SSE streaming, phải parse JSON manual. Không khuyến nghị.

**Q: Zed sẽ support MCP trong tương lai?**  
A: Chưa biết. Nếu có, sẽ update file này.

**Q: spawn_agent có đủ mạnh không?**  
A: Có. Đã test với THINK/SCOUT/REVIEW, hoạt động tốt. Parallel spawn cũng OK.

**Q: Thiếu web search có ảnh hưởng không?**  
A: Ít. Hầu hết tasks focus vào codebase. Nếu cần research, user có thể paste links.

**Q: Git hooks thiếu có vấn đề không?**  
A: Không critical. Main agent phải tự giác gọi REVIEW trước commit. Trade-off chấp nhận được.

---

**END OF DOCUMENT**

# MCP Support in opencode (thay cho MCP_STATUS.md cũ của Zed)

> **Updated:** 2026-08-08
> **Context:** Migration từ Zed (không có MCP) → opencode (MCP native)

---

## ✅ TL;DR: opencode HỖ TRỢ MCP protocol native

**opencode có:**
- ✅ MCP client built-in (config trong `opencode.json`, mục `mcp`)
- ✅ Local transport (stdio) + Remote transport (SSE/HTTPS)
- ✅ Env var interpolation (`${VAR}`)
- ✅ Native tools (read, edit, grep, bash, webfetch, task) song song với MCP

---

## 📊 So sánh Zed vs opencode

| Feature | Zed (cũ) | opencode (mới) |
|---------|----------|----------------|
| **MCP Client** | ❌ None | ✅ Native (`opencode.json` → `mcp`) |
| **Subagents** | ✅ `spawn_agent` | ✅ `task` tool + `.opencode/agent/*.md` |
| **Filesystem** | ✅ Native | ✅ Native (read/edit/grep/glob) |
| **Git** | ✅ terminal | ✅ bash + git |
| **Web** | ✅ `fetch` | ✅ webfetch |
| **Odoo MCP** | ❌ Không có | ✅ `odoo-mcp-server` (npx) |
| **Dart MCP** | ❌ Không có | ✅ `dart mcp-server` (Dart SDK) |

---

## 🎯 MCP servers đã cấu hình (opencode.json)

| Server | Type | Command | Env cần có |
|--------|------|---------|------------|
| `odoo` | local | `npx -y odoo-mcp-server` | `ODOO_URL`, `ODOO_DB`, `ODOO_USERNAME`, `ODOO_PASSWORD` |
| `dart` | local | `dart mcp-server` | Dart SDK (≥3.6, có `dart mcp-server` built-in) |

### Setup biến môi trường

Tạo file `.env` trong project root (đã có trong `.gitignore`):

```bash
ODOO_URL=https://your-odoo-instance.com
ODOO_DB=your-database
ODOO_USERNAME=your-username
ODOO_PASSWORD=your-password
```

Sau đó load `.env` trước khi chạy opencode (hoặc export trong shell):

```bash
set -a && . ./.env && set +a && opencode
```

### Env interpolation trong opencode.json

opencode tự thay `${VAR}` bằng giá trị biến môi trường:

```json
{
  "mcp": {
    "odoo": {
      "type": "local",
      "command": ["npx", "-y", "odoo-mcp-server"],
      "enabled": true,
      "env": {
        "ODOO_URL": "${ODOO_URL}",
        "ODOO_DB": "${ODOO_DB}",
        "ODOO_USERNAME": "${ODOO_USERNAME}",
        "ODOO_PASSWORD": "${ODOO_PASSWORD}"
      }
    }
  }
}
```

---

## 🔧 Workflows đã migrate sang opencode

### 1. THINK Workflow (3 debaters)
**Zed:** 3 parallel `spawn_agent`  
**opencode:** 3 parallel `task` calls với `subagent_type: proposer/skeptic/checker`  
**File:** `.agents/THINK_WORKFLOW.md` + `.opencode/agent/{proposer,skeptic,checker}.md`

### 2. SCOUT Workflow (research)
**Zed:** 1 `spawn_agent`  
**opencode:** 1 `task` call với `subagent_type: scout`  
**File:** `.agents/SCOUT_WORKFLOW.md` + `.opencode/agent/scout.md`

### 3. REVIEW Workflow (pre-commit)
**Zed:** 1 `spawn_agent` + manual trigger  
**opencode:** 1 `task` call với `subagent_type: reviewer`  
**File:** `.agents/REVIEW_WORKFLOW.md` + `.opencode/agent/reviewer.md`

---

## 🚫 Những gì KHÔNG cần nữa (từ Zed/Cline era)

1. **a2a-platform SSE** — opencode dùng subagent local, không cần a2a
2. **Zed spawn_agent syntax** — thay bằng `task` tool
3. **Cline `.clinerules/hooks/`** — git hooks không phù hợp môi trường agent; dùng REVIEW workflow thủ công

---

## 📚 References

- **MCP protocol spec:** https://modelcontextprotocol.io/
- **odoo-mcp-server:** https://www.npmjs.com/package/odoo-mcp-server
- **opencode MCP config:** `opencode.json` → `mcp`
- **opencode config schema:** https://opencode.ai/config.json

---

## ❓ FAQ

**Q: Có cần cài thêm gì cho odoo MCP không?**  
A: Chỉ cần `npx` (đã có sẵn với Node.js). Server tự download khi start.

**Q: `dart mcp-server` có sẵn không?**  
A: Có, built-in trong Dart SDK ≥3.6. Cần cài Dart SDK.

**Q: MCP server fail thì sao?**  
A: Kiểm tra: (1) env vars đã load chưa, (2) `npx` có mạng không, (3) chạy thủ công lệnh để xem lỗi.

---

**END OF DOCUMENT**

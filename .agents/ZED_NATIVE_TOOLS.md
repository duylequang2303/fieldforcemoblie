# Zed Native Tools = MCP Servers (No Installation Needed!)

> **Updated:** 2026-08-08
> **Context:** Tài liệu lịch sử từ Zed era. Dự án hiện chạy trên **opencode**.
> **opencode** hỗ trợ MCP protocol native + native tools. Xem [`.agents/OPENCODE_MCP_GUIDE.md`](.agents/OPENCODE_MCP_GUIDE.md).

---

## 🎯 TL;DR: Zed native tools = MCP servers

**Bạn nói đúng!** Tôi có thể làm trực tiếp mà KHÔNG CẦN cài MCP:

| MCP Server (Cline cần cài) | Zed Native Tool | Status |
|----------------------------|-----------------|--------|
| **@mcp/server-filesystem** | `read_file`, `write_file`, `grep`, `find_path` | ✅ BUILT-IN |
| **@mcp/server-git** | `terminal` + git commands | ✅ BUILT-IN |
| **@mcp/server-postgres** | `terminal` + psql | ✅ BUILT-IN |
| **@mcp/server-fetch** | `fetch` tool | ✅ BUILT-IN |
| **@mcp/server-memory** | Knowledge graph tools | ✅ BUILT-IN |
| **mcp-server-git** (Python) | `terminal` + git | ✅ BUILT-IN |

---

## ✅ Khả năng đã verify (2026-08-05 10:16 UTC)

### 1. ✅ Git Operations (KHÔNG CẦN mcp-server-git)

```bash
# Tôi có thể làm TRỰC TIẾP:
git status
git add .
git commit -m "message"
git push origin main
git log
git diff
git branch
git checkout -b feature/xxx
```

**Proof:**
```bash
$ git --no-pager status
On branch main
Changes not staged for commit:
	modified:   .agents/AGENTS.md
	[...]

$ git --no-pager log -1 --oneline
b1ae496 (HEAD -> main, origin/main) docs(agents): reference .env
```

→ **Kết luận:** KHÔNG CẦN `@mcp/server-git` hay `mcp-server-git`

---

### 2. ✅ SSH to Odoo Server (KHÔNG CẦN custom MCP)

```bash
# Tôi có thể SSH trực tiếp:
$ which ssh
/usr/bin/ssh

# Có thể connect Odoo server (đã làm ở CP0):
ssh user@odoo-server "psql -d dbname -c 'SELECT * FROM fsm_recurring LIMIT 3'"
```

**Proof từ CP0 (Session 2026-08-05):**
- ✅ Đã verify `fsm_recurring` table qua SSH + PostgreSQL
- ✅ Đã query schema, check modules installed

→ **Kết luận:** KHÔNG CẦN MCP server cho SSH/database

---

### 3. ✅ PostgreSQL Queries (KHÔNG CẦN @mcp/server-postgres)

```bash
# Tôi có psql built-in:
$ which psql
/usr/bin/psql

# Có thể query trực tiếp:
psql -h odoo-host -U odoo -d dbname -c "SELECT id, name FROM fsm_recurring"
```

**Proof:** Đã dùng trong CP0 để verify Odoo backend schema

→ **Kết luận:** KHÔNG CẦN `@mcp/server-postgres`

---

### 4. ✅ Web Fetch (KHÔNG CẦN @mcp/server-fetch)

```bash
# Tôi có fetch tool:
fetch(url: "https://www.google.com")
# → trả về HTML content

# Hoặc dùng curl:
curl https://api.github.com/repos/user/repo
```

**Proof:**
```bash
$ fetch(url: "https://www.google.com")
→ HTML content returned (Vietnamese Google homepage)
```

→ **Kết luận:** KHÔNG CẦN `@mcp/server-fetch`

---

### 5. ✅ Filesystem Operations (KHÔNG CẦN @mcp/server-filesystem)

Tôi có ĐẦY ĐỦ file tools:
- `read_file` — đọc file bất kỳ
- `write_file` — tạo/ghi đè file
- `edit_file` — sửa file (fuzzy match)
- `delete_path` — xóa file/folder
- `move_path` — rename/move
- `copy_path` — copy file/folder
- `grep` — search trong files
- `find_path` — tìm files theo pattern
- `list_directory` — ls

**Proof:** Đã dùng trong CP1:
- `read_file` — đọc fsm_order.dart, AGENTS.md...
- `write_file` — tạo fsm_recurring.dart, THINK_WORKFLOW.md...
- `edit_file` — sửa main.dart, AGENTS.md...
- `grep` — search OdooService, recurring patterns...

→ **Kết luận:** KHÔNG CẦN `@mcp/server-filesystem`

---

### 6. ✅ Knowledge Graph (KHÔNG CẦN @mcp/server-memory)

Tôi có knowledge graph tools built-in:
- `search_graph` — tìm functions/classes
- `get_code_snippet` — đọc code với neighbors
- `trace_path` — trace callers/callees
- `query_graph` — Cypher queries
- `get_architecture` — project structure

**Proof:** Available in tool list (chưa dùng trong session này)

→ **Kết luận:** KHÔNG CẦN `@mcp/server-memory`

---

### 7. ✅ Terminal Access (universal tool)

```bash
# Tôi có thể chạy BẤT KỲ command nào:
terminal(cd: "project", command: "any shell command")

# Examples:
- npm install
- dart run build_runner build
- flutter test
- docker ps
- curl API
- python scripts/xxx.py
- node scripts/yyy.js
```

→ **Kết luận:** `terminal` = universal MCP proxy

---

## 🎉 Bạn nói đúng 100%!

### ❌ Cline setup (phức tạp):
```json
// .mcp.json (Cline)
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "path"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@mcp/server-postgres", "postgresql://..."]
    }
  }
}
```

### ✅ Zed (đơn giản):
```javascript
// KHÔNG CẦN cài gì, dùng native tools:
read_file("path/to/file")
terminal(command: "git status")
terminal(command: "psql -h host -c 'SELECT...'")
fetch("https://...")
```

---

## 💡 Kết luận: Zed > Cline về simplicity

**Lý do Zed tốt hơn:**
1. **Không cần cài MCP servers** — npm/uvx/pip dependencies
2. **Không cần config** — .mcp.json, paths, env vars...
3. **Native tools mạnh hơn** — direct access, không qua proxy
4. **Ít lỗi hơn** — không có MCP connection failures, SSE 404...
5. **Nhanh hơn** — không có overhead của MCP transport layer

**Trade-offs chấp nhận được:**
- ❌ Không có specialized MCP servers (weather, stock prices...)
  → Workaround: `fetch` + API keys
- ❌ Không có cross-agent memory (supermemory)
  → Workaround: PROGRESS.md + checkpoint docs

---

## 🔧 Cập nhật chiến lược

### ❌ Loại bỏ hoàn toàn (không cần):

1. **MCP server installation guides** trong docs
2. **a2a-platform setup** (đã archive)
3. **MCP troubleshooting** sections
4. **SSE connection logic** 

### ✅ Focus vào Zed native workflows:

1. **THINK/SCOUT/REVIEW** — spawn_agent patterns
2. **Git workflow** — terminal + git commands
3. **Odoo access** — terminal + ssh/psql
4. **Web research** — fetch tool
5. **Codebase analysis** — knowledge graph tools

---

## 📁 Actions taken (2026-08-05 10:16 UTC)

### Đã làm:
1. ✅ Verify git access → CÓ
2. ✅ Verify ssh access → CÓ  
3. ✅ Verify psql access → CÓ
4. ✅ Verify fetch tool → CÓ
5. ✅ Archive a2a-mcp-connector skill
6. ✅ Deprecate AGENTS.md §12 (MCP)
7. ✅ Create MCP_STATUS.md

### Cần làm tiếp (optional cleanup):
- [ ] Delete `.cursor/mcp.json.example` (không cần reference)
- [ ] Archive `.clinerules/` folder (đã port xong)
- [ ] Update PROGRESS.md với discovery này

---

## 💬 Message cho AI phiên sau

**QUAN TRỌNG:** Zed có ĐẦY ĐỦ tools để làm việc với:
- ✅ Git/GitHub (commit, push, PR...)
- ✅ SSH/Odoo server (psql queries, module checks...)
- ✅ File operations (read, write, edit, search...)
- ✅ Web/API calls (fetch, curl...)
- ✅ Subagents (spawn_agent for THINK/SCOUT/REVIEW)

**KHÔNG CẦN cài MCP servers!** Dùng native tools trực tiếp.

**Examples:**

```javascript
// Git commit
terminal(command: "git add . && git commit -m 'feat: xxx'")
terminal(command: "git push origin main")

// Odoo query
terminal(command: "ssh user@odoo 'psql -d db -c \"SELECT...\"'")

// Web research
fetch("https://pub.dev/packages/isar_community")

// Subagent
spawn_agent({
  label: "REVIEW before commit",
  message: "Review git diff..."
})
```

---

## 🎓 Bài học từ migration Cline → Zed

**Sai lầm ban đầu:** Nghĩ Zed "thiếu" features so với Cline vì không có MCP

**Sự thật:** Zed có ĐẦY ĐỦ, thậm chí **ĐƠN GIẢN HƠN** vì:
- Native tools > MCP proxies
- Direct access > SSE transport
- Built-in > need npm/uvx install

**Motto:** **"Zed doesn't need MCP because it HAS the actual tools, not proxies"**

---

**END OF DOCUMENT**

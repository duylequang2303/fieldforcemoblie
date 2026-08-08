# Hướng dẫn cài opencode trên máy dev và dùng trong Zed

> **Mục đích:** Chạy opencode ngay trên máy dev (nơi có Flutter/Dart SDK) để agent build, test và phát triển app thật, trong khi vẫn dùng Zed làm editor.
> **Updated:** 2026-08-08

---

## 1. Yêu cầu trước khi cài

Kiểm tra máy dev có đủ:

| Công cụ | Cách kiểm tra | Ghi chú |
|---|---|---|
| **Node.js ≥ 20** | `node --version` | opencode là tool Node.js. Thiếu thì cài từ https://nodejs.org |
| **npm** | `npm --version` | Đi kèm Node.js |
| **Flutter SDK** | `flutter --version` | Đã có trên máy dev (3.44.x) |
| **Dart SDK** | `dart --version` | Đi kèm Flutter, cần ≥ 3.6 để có `dart mcp-server` |
| **Git** | `git --version` | Để clone project |

## 2. Cài opencode

```bash
# Cài global để dùng ở mọi thư mục
npm install -g opencode-ai

# Kiểm tra đã cài thành công
opencode --version
```

> Nếu gặp lỗi quyền trên macOS/Linux: thêm `--unsafe-perm` hoặc dùng sudo theo hướng dẫn của npm.

## 3. Clone project về máy dev

```bash
git clone <remote-url> fieldforce_mobile
cd fieldforce_mobile
flutter pub get
```

## 4. Cấu hình MCP (Odoo + Dart)

Project đã có sẵn `opencode.json` ở root. Odoo MCP cần biến môi trường từ file `.env`:

### 4.1 Tạo file `.env` (chưa có trong repo)

```bash
ODOO_URL=https://your-odoo-instance.com
ODOO_DB=your-database
ODOO_USERNAME=your-username
ODOO_PASSWORD=your-password
```

File `.env` đã có trong `.gitignore` nên không bị commit lên git.

### 4.2 Chạy opencode với `.env` đã load

```bash
# Load .env rồi mở opencode
set -a && . ./.env && set +a && opencode
```

> Lưu ý Windows (PowerShell): dùng `opencode` và export biến bằng `$env:ODOO_URL=...` trước khi chạy, hoặc đặt biến trong System Environment Variables.

## 5. Chạy opencode trong terminal của Zed

1. Mở Zed → mở project `fieldforce_mobile`
2. Mở **terminal panel tích hợp**: `Ctrl + \` (hoặc Command Palette → gõ "terminal")
3. Trong terminal Zed, chạy:

```bash
set -a && . ./.env && set +a && opencode
```

→ opencode chạy ngay trong cửa sổ Zed, cùng project, đọc chung `.agents/` rules/skills.

### Sử dụng song song Zed agent + opencode

- **Zed agent:** sửa code nhanh hằng ngày (chat panel trong editor)
- **opencode (trong terminal):** tác vụ lớn — review toàn bộ project, refactor, chạy build/test nhiều bước, dùng subagents (`task` tool) và skills

Cả hai đều dùng Flutter SDK của máy dev nên đều build/test được.

## 6. Sau khi sửa config

Khi sửa `opencode.json`, `.opencode/agent/*.md`, `.agents/skills/*/SKILL.md`:

- **Quit và restart opencode** để config mới có hiệu lực (gõ `Ctrl+C` rồi chạy lại lệnh `opencode`)

## 7. Troubleshooting

| Vấn đề | Cách xử lý |
|---|---|
| `opencode: command not found` | Cài chưa thành công — chạy lại `npm install -g opencode-ai`, hoặc kiểm tra `npm global bin` đã có trong `PATH` |
| Odoo MCP không kết nối | Kiểm tra `.env` đúng chưa, load `.env` trước khi chạy opencode, chạy thử `npx -y odoo-mcp-server` xem lỗi |
| Dart MCP fail | Kiểm tra `dart --version` ≥ 3.6; máy dev có Flutter nên sẽ chạy được |
| Mở opencode thấy thiếu skill | Skills tự scan từ `.agents/skills/**/SKILL.md` — kiểm tra thư mục còn đầy đủ không |
| Model không gọi được | Kiểm tra global config `~/.config/opencode/opencode.json` — nếu máy dev không dùng platform MonkeyCode thì cấu hình provider/model riêng (xem mục 8) |

## 8. Cấu hình model khi máy dev KHÔNG dùng platform MonkeyCode

Môi trường platform dùng model `monkeycode-basic/deepseek-v4-flash` qua proxy MonkeyCode (đã cấu hình sẵn). Trên máy dev riêng, tùy chọn:

- **OpenCode Zen / OpenCode Go:** cấu hình qua `opencode auth login` — có gói free tier
- **OpenRouter `:free`:** đăng ký tại https://openrouter.ai, lấy API key, cấu hình provider `openrouter`
- **Google Gemini free tier:** API key từ Google AI Studio
- **Local (Ollama):** chạy model local, cấu hình provider `ollama`

> Với model free, chú ý chọn model có **context ≥ 64k** (như `deepseek-v4-flash` 200k, `gemini-2.5-flash` 1M, `qwen3-coder-flash` 128k) vì project có nhiều rules + codebase Flutter. Model context nhỏ sẽ dễ đầy và bị "treo".

## 9. Các file quan trọng

| File/Thư mục | Vai trò |
|---|---|
| `opencode.json` | Config project: MCP servers, permissions, tool_output, compaction |
| `.opencode/agent/*.md` | Subagents: scout, reviewer, proposer, skeptic, checker |
| `.agents/AGENTS.md` | Quy tắc code Dart/Flutter cho AI |
| `.agents/rules/*.md` | Các rule bổ sung |
| `.agents/skills/*/SKILL.md` | Skills: FSM flow, Isar offline, Odoo RPC, Odoo test data, Flutter verify |
| `.agents/OPENCODE_MCP_GUIDE.md` | Chi tiết setup MCP cho opencode |

---

**END OF DOCUMENT**

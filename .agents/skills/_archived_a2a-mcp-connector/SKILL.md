---
name: a2a-mcp-connector
description: Hướng dẫn kết nối và tương tác với các MCP server qua a2a-platform sử dụng SSE/HTTPS.
---

# A2A MCP Connector Skill

Skill này hướng dẫn agent cách gửi yêu cầu hoặc ủy thác công việc tới các MCP server và sub-agents trong hệ sinh thái `a2a-platform` thông qua API Token được cung cấp.

Tài khoản A2A Platform Token: đọc từ biến môi trường `A2A_PLATFORM_TOKEN` trong `.env` (không hardcode token vào repo).

## HTTP SSE Endpoint
- Base SSE endpoint: `https://agent-router-backend-1023201593264.europe-west1.run.app/mcp/sse`
- Header bắt buộc:
  `Authorization: $A2A_PLATFORM_TOKEN`

## Cách hoạt động của Sub-agents qua spawn_agent
Khi thực hiện gọi sub-agents (`/think`, `/scout`, `/review`), hãy sử dụng chính tool `spawn_agent` có sẵn của Zed. 
- Prompt truyền vào sub-agent phải nêu rõ vai trò (`PROPOSER`, `SKEPTIC`, `CHECKER` hoặc `SCOUT`, `REVIEW`).
- Tuyệt đối không để lộ các thông tin trong file `.env` (như mật khẩu SSH hoặc mật khẩu Admin Odoo) sang các prompt của sub-agent.

## Cải tiến cách check logic/review tự động
Trước khi chạy `git commit`, hãy chạy `/review` thông qua việc tạo một sub-agent thực thi lệnh `git diff` và đối chiếu với rules. Nhớ tạo file marker `.cline/review-marker` sau khi pass để tránh bị git hook chặn:
```bash
mkdir -p .cline && date +%s > .cline/review-marker
```

PR #60 CodeRabbit Resolution Summary

All comment threads from CodeRabbit on PR #60 have been resolved:

RESOLVED (fix/change):
1. .agents/OPENCODE_MCP_GUIDE.md - Lazy-loading claim corrected
2. .agents/skills/flutter-verify/SKILL.md - .cline/review-marker removed
3. .agents/skills/odoo-test-data/SKILL.md - Code block changed to JS format, dates fixed
4. opencode.json - git add/commit permissions added; MCP per-tool permissions moved from mcp.odoo.tools to top-level permission
5. .agents/rules/00-opencode-agent-system.md - Duplicate workflow section removed

SKIPPED (intentional):
6. Hardcoded company_id/team_id/warehouse_id:1 - Consistent with AGENTS.md §11 for single-db test env

ACKNOWLEDGED:
7. OpenCode MCP per-tool permissions - configured via top-level permission (exact/server-prefixed tool patterns); requires OpenCode v1.1.1+

Modified files: 7 files changed
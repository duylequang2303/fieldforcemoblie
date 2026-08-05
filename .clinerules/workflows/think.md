# /think Workflow
## Invocation: `/think <problem>`

## Mechanism
1. Main agent spawns **3 debaters** via a2a-platform (preferred) or `new_task` (fallback)
2. **Routing**: All subagents routed to **Sonnet 3.5** if available
3. **Privacy**: NEVER include `.env` values or credentials in prompts
4. **Transport**: a2a-platform is `type: sse`. Known Cline bug: stale SSE session → `HTTP 404: Could not find session`. Treat 404 as "server not ready" → fallback, never hang. Cline config timeout is 90s; subagent-attempt timeout is 30s.

## Debater Roles (200 words max each, fixed format)

### 1. PROPOSER
**Goal**: Simplest viable fix
**Output Format**:
```
CLAIM | [solution description]
EVIDENCE | [file:line references supporting claim]
RISK | [potential issues]
```

### 2. SKEPTIC
**Goal**: Attack proposal
**Focus Areas**:
- Offline mode implications
- Sync conflicts with Odoo
- Schema mismatches
- Edge cases (null, empty, concurrent)
**Output Format**:
```
CLAIM | [counter-argument]
EVIDENCE | [file:line or rule references]
RISK | [why original fails]
```

### 3. CHECKER
**Goal**: Verify against real code
**Output Format**:
```
CLAIM | [validation result]
EVIDENCE | [file:line code evidence ONLY]
RISK | [confirmed/denied risks]
```

## Synthesis by Main Agent
**Fixed Format**:
```
AGREE | [if all align]
CONFLICT | [PROPOSER vs SKEPTIC points]
FINAL PLAN | [resolved approach + files to modify]
```

## RESILIENCE
1. **Per-Subagent Timeout (a2a attempt)**: 30 seconds (shorter than Cline config to fail fast)
2. **On SSE 404 — `HTTP 404: Could not find session`**:
   - This is a Cline stale-session bug, NOT a real server error.
   - Do NOT retry a2a. Fall back to `new_task` for that debater immediately.
   - Tag output as `FALLBACK-SSE-404`
3. **On Timeout (network/other)**:
   - Retry the a2a attempt ONCE after 10 seconds
   - If still dead: fall back to `new_task` for that debater
   - Tag output as `FALLBACK-TIMEOUT`
4. **If CHECKER Fails**:
   - Proceed with PROPOSER + SKEPTIC
   - Add line: `EVIDENCE UNVERIFIED` to synthesis
5. **Main Agent Reporting**:
   - Report which debaters ran on A2A vs fallback, and the fallback reason tag (`FALLBACK-SSE-404` / `FALLBACK-TIMEOUT` / `FALLBACK-NEW_TASK`)
   - Never block workflow pending a2a; always produce a synthesis.

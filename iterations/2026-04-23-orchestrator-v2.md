# 2026-04-23: Orchestrator-Subagent Pattern v2

## What Changed

User directive: "I want you to be an orchestrator, not doing stuff. If I ask something else, you will always get interrupted. Set architecture such that you are an orchestrator with team of subagents."

### 1. Architecture Redesign

**Old pattern (v1):**
- Single agent does everything via direct tool calls
- Subagents used only for parallel tasks
- Agent gets "stuck" in long operations, misses user interrupts

**New pattern (v2):**
- Orchestrator (main agent) **never executes tools directly**
- All work delegated to specialized subagent roles
- User message = immediate interrupt → terminate active subagents → re-delegate
- State externalized to filesystem/GitHub/SQLite instead of context window

### 2. Subagent Roles Defined

| Role | Purpose | Escalation Trigger |
|------|---------|-------------------|
| Inbox Monitor | Poll inboxes, auto-approve, generic reply | Non-generic message, unknown sender |
| Code Reviewer | Analyze diffs, post comments, suggest fixes | Security bug, arch dispute |
| Researcher | Deep dives, paper reading | Ambiguous direction |
| Implementer | Execute implementation plans | Test failure, ambiguous spec |
| Auditor | Security/quality checks | Critical vulnerability |

### 3. Inbox Monitor Subagent

Deployed for masumi-agent-messenger:
- Auto-approves contact requests (rule-based)
- Replies generically to "hi"/"hello"/"thanks" messages
- **Escalates to user** for anything else: posts to Telegram with context
- Runs via cron every 5 min, but logic lives in subagent prompt

### 4. Files Updated

- `research/orchestration.md` — complete rewrite with v2 pattern
- `diagrams/orchestrator-pattern.md` — new diagram with interrupt flow
- `diagrams/system-overview.md` — added Orchestrator Layer + subagent boxes

### 5. Design Principles

1. Orchestrator is thin (<5 tool calls per turn)
2. Subagents are fat (up to 50 tool calls, deep work)
3. Interrupts are cheap (state in files, not context)
4. Escalation is explicit (subagent signals "need human input")
5. No subagent nesting (leaves only, max depth = 1)

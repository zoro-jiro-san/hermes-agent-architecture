# Agent Orchestration Research

## Status: Active — v2 Orchestrator-Subagent Pattern Deployed

### Architecture Evolution

| Version | Pattern | Status |
|---------|---------|--------|
| v0 | Single agent, centralized tool dispatch | Replaced |
| v1 | Flat subagent delegation (delegate_task, max 3 parallel) | Replaced |
| v2 | Orchestrator + persistent subagent roles | **Active** |

---

### v2: Orchestrator-Subagent Pattern

**Core principle:** The main agent (orchestrator) never executes directly. It delegates all work to specialized subagents and manages their lifecycle. User interruptions are first-class — the orchestrator can spawn/terminate subagents at any time without losing state.

```
┌─────────────────────────────────────────────────────────────┐
│                       USER                                   │
│                                                              │
│  "Check masumi inbox"     "Code review this PR"              │
│         │                           │                        │
│         └───────────┬───────────────┘                        │
│                     │                                        │
│            ┌────────▼────────┐                               │
│            │  ORCHESTRATOR   │ ← Never executes directly    │
│            │  (this agent)   │   Only delegates + decides   │
│            └────────┬────────┘                               │
│                     │                                        │
│     ┌───────────────┼───────────────┐                       │
│     │               │               │                       │
│ ┌───▼───┐     ┌────▼────┐    ┌─────▼────┐                 │
│ │Masumi │     │  Code   │    │ Research │                 │
│ │Monitor│     │ Reviewer│    │  Agent   │                 │
│ │Subagent│    │Subagent │    │ Subagent │                 │
│ └───┬───┘     └────┬────┘    └─────┬────┘                 │
│     │               │               │                       │
│     └───────────────┴───────────────┘                       │
│                     │                                        │
│            ┌────────▼────────┐                               │
│            │  Result Merge   │                               │
│            │  + User Notify  │                               │
│            └─────────────────┘                               │
└─────────────────────────────────────────────────────────────┘
```

#### Orchestrator Responsibilities
1. **Parse user intent** — understand what needs doing
2. **Select subagent role** — pick the right specialized subagent
3. **Spawn with context** — give minimal but sufficient context
4. **Monitor progress** — check status if needed
5. **Handle interrupts** — if user says something new, terminate running subagents and re-delegate
6. **Merge results** — present final output to user

#### Subagent Properties
- **Isolated context** — no access to full orchestrator memory unless explicitly passed
- **Single purpose** — one role per subagent (monitor, reviewer, researcher)
- **Interruptible** — orchestrator can kill and respawn at any time
- **Escalation path** — when uncertain, subagent reports back to orchestrator (not user directly)
- **No nested delegation** — subagents are leaf workers (role=leaf), cannot spawn their own children

#### Subagent Role Definitions

| Role | Purpose | Tools | Escalation Trigger |
|------|---------|-------|-------------------|
| **Inbox Monitor** | Poll external inboxes, auto-approve, generic reply | cronjob, masumi-agent-messenger | Non-generic message, unknown sender, suspicious request |
| **Code Reviewer** | Analyze diffs, post comments, suggest fixes | terminal, file, patch, github | Security-critical finding, architectural disagreement |
| **Researcher** | Deep dives, paper reading, synthesis | web, web_extract, arxiv | Contradictory sources, needs user direction |
| **Implementer** | Execute implementation plans | terminal, file, patch, execute_code | Test failure, ambiguous spec |
| **Auditor** | Security, quality, compliance checks | search_files, read_file, terminal | Critical vulnerability found |

---

### v1 → v2 Migration Rationale

**Problem with v1:** When user sent a new message while a subagent was running, the subagent's work would be abandoned mid-task. There was no clean interrupt/Resume pattern. The orchestrator itself would get "stuck" doing work and miss user messages.

**v2 solution:**
- Orchestrator stays lightweight — never enters long tool-call sequences
- All heavy lifting is in subagents running in background or via delegate_task
- User message = immediate interrupt → orchestrator evaluates → may terminate old subagent → spawn new one
- State is externalized (files, GitHub, cron jobs) rather than in context window

---

### Historical Research

#### 2026-04-10: MEV Auction Orchestration Patterns
Insights from Solana MEV research that apply to agent orchestration:
1. **Sealed-bid auction → Model routing**: rank LLM models by cost-per-quality-token
2. **BAM's three-layer architecture → Agent tiers**: scheduling → execution → plugins/skills
3. **Multi-builder marketplace → Multi-model routing**: route across providers for resilience
4. **Sub-second finality targets**: acknowledge within 200ms even if full processing takes longer

#### 2026-04-12: Stigmergic Pressure-Field Coordination
Rodriguez (Jan 2026): LLM agents coordinating through shared artifact modification achieve **48.5% solve rate vs 1.5% for hierarchical orchestration**.

**v2 adaptation:** Subagents write results to shared filesystem artifacts (e.g., `/tmp/masumi-status.json`). The orchestrator reads these to make dispatch decisions without needing full context replay.

---

### References
- `open-multi-agent` repo for multi-agent orchestration
- Hermes delegate_task.py for current implementation
- Jito BAM architecture (bam.dev/docs)
- arXiv 2601.08129 — "Emergent Coordination in Multi-Agent Systems via Pressure Fields and Temporal Decay"
- CrewAI role-based agent teams
- Anthropic's "agents as tools" pattern

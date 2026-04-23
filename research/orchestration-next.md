# Orchestration Next Steps: v2.1 Improvements

**Date:** 2026-04-23  
**Status:** Proposed — ready for implementation  
**Scope:** Error resilience, cost routing, subagent state tracking  

---

## Gaps in Current Architecture

After reviewing all 11 diagrams and 7 research docs, three critical gaps remain:

1. **No error-handling / retry / circuit-breaker diagram** — `security-ops.md` covers malware scanning and sandboxing, but nothing addresses LLM provider outages, rate limits, or subagent crashes.
2. **No cost-routing diagram** — `token-efficiency.md` covers routing *research*, but the architecture repo has no visual for how models are actually selected per task. `system-overview.md` mentions it in one bullet with no structure.
3. **No subagent state machine** — `orchestrator-pattern.md` shows spawn/kill/merge, but subagents exist in a black box. Failed work is silently lost; there is no formal lifecycle or dead-letter queue.

These are the next concrete improvements. Each is designed to be **minimal, framework-free, and implementable in <200 lines of Python**.

---

## Proposal 1: Resilience Layer (Retry + Circuit Breaker + Fallback)

### Problem
When a provider returns 429/500/503, Hermes currently relies on LiteLLM's default retry. There is no:
- Per-provider circuit breaker (one bad provider can cascade)
- Fallback chain to alternate providers
- Dead-letter queue for failed subagent tasks

### Solution
A ~120-line wrapper around `litellm.completion()` and `delegate_task()`.

```
┌─────────────────────────────────────────────────────────────┐
│                      RESILIENCE LAYER                        │
│                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Exponential │    │   Circuit   │    │   Fallback  │     │
│  │   Backoff    │───▶│   Breaker   │───▶│    Chain    │     │
│  │  + Jitter    │    │ per provider│    │             │     │
│  └─────────────┘    └──────┬──────┘    └──────┬──────┘     │
│                             │                    │           │
│         ┌───────────────────┴────────────────────┘           │
│         │                                                  │
│         ▼                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Provider Health Map                      │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐ │   │
│  │  │ Z.AI    │  │Anthropic│  │OpenRouter│  │ Google │ │   │
│  │  │ [CLOSED]│  │ [CLOSED]│  │ [HALF]  │  │ [OPEN] │ │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                             │                              │
│         ┌───────────────────┴────────────────────┐         │
│         │                    │                    │         │
│         ▼                    ▼                    ▼         │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│  │   Primary   │     │  Secondary  │     │   Cheap     │  │
│  │   Request   │───▶ │   Request   │───▶ │   Request   │  │
│  │   (glm-4.7) │     │  (sonnet)   │     │  (haiku)    │  │
│  └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                              │
│  Subagent failure ──▶ ~/.hermes/dlq/YYYY-MM-DD-{role}.json │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Notes

```python
# agent/resilience.py — ~120 lines, zero deps beyond stdlib
class CircuitBreaker:
    def __init__(self, threshold=5, reset=30):
        self.failures = 0
        self.threshold = threshold
        self.reset = reset
        self.last_failure = None
        self.state = "closed"

class ResilientCompletion:
    FALLBACK_CHAIN = ["z.ai/glm-4.7", "anthropic/claude-sonnet-4.6", "anthropic/claude-haiku-4.5"]
    
    async def call(self, messages, model=None, **kwargs):
        for attempt, m in enumerate(self._resolve_chain(model)):
            if not breakers[m.provider].can_execute():
                continue
            try:
                resp = await litellm.acompletion(model=m.id, messages=messages, **kwargs)
                breakers[m.provider].record_success()
                return resp
            except (RateLimitError, ServiceUnavailableError) as e:
                breakers[m.provider].record_failure()
                await self._backoff(attempt)
        raise FallbackExhaustedError()
```

- **Retry**: 5 attempts, exponential backoff `2^attempt + jitter(0,1)`, max 30s.
- **Circuit breaker**: Open after 5 failures in 60s. Half-open after 30s. One probe must succeed to close.
- **Fallback**: If primary provider circuit is open, try secondary, then cheapest.
- **Subagent DLQ**: On `delegate_task` failure, serialize task + error traceback + partial results to `~/.hermes/dlq/`. Orchestrator inspects DLQ on startup and offers retry/escalate/dismiss.

### Expected Impact
- Prevents one provider outage from halting all work.
- 70% reduction in MTTR (mean time to recovery) per production literature.
- Failed subagent tasks are no longer silently lost.

---

## Proposal 2: Cost Router (Heuristic Tiered Model Selection)

### Problem
Hermes currently relies on manual `/model` selection or hardcoded defaults. There is no automatic "cheap by default, strong by exception" routing. The token-efficiency research proves 40–85% cost reduction is achievable, but nothing is wired into the architecture.

### Solution
A rule-based router that runs **before every LLM call**, adding <5ms overhead.

```
┌─────────────────────────────────────────────────────────────┐
│                    COST ROUTER LAYER                         │
│                                                              │
│   Input: task_desc + context_size + subagent_role + budget │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  HEURISTIC CLASSIFIER  (< 1ms)                       │   │
│   │                                                      │   │
│   │  1. Keyword rules (regex)                            │   │
│   │     "greeting|thanks|hi"        ──▶ CHEAP            │   │
│   │     "review|audit|security"     ──▶ STANDARD         │   │
│   │     "deep research|architecture" ──▶ PREMIUM         │   │
│   │                                                      │   │
│   │  2. Context size guard                               │   │
│   │     context > 8K tokens         ──▶ bump +1 tier     │   │
│   │                                                      │   │
│   │  3. Subagent role default                            │   │
│   │     Inbox Monitor               ──▶ CHEAP            │   │
│   │     Code Reviewer / Researcher  ──▶ STANDARD         │   │
│   │     Auditor (security)          ──▶ PREMIUM          │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  BUDGET GUARD                                        │   │
│   │                                                      │   │
│   │  daily_spend > soft_limit ($5)  ──▶ alert user       │   │
│   │  daily_spend > hard_limit ($8)  ──▶ force CHEAP      │   │
│   │  monthly_spend > cap            ──▶ halt + escalate  │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│          ┌───────────────┼───────────────┐                  │
│          ▼               ▼               ▼                  │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐              │
│   │  CHEAP   │   │ STANDARD │   │ PREMIUM  │              │
│   │ glm-4-mini│   │ glm-4.7  │   │ claude-4 │              │
│   │ haiku-4.5│   │ sonnet   │   │ opus     │              │
│   │ $0.15/M  │   │ $3.00/M  │   │ $15.00/M │              │
│   └──────────┘   └──────────┘   └──────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Notes

```python
# agent/cost_router.py — ~80 lines
ROUTER_RULES = [
    (r"\b(hi|hello|thanks|hey)\b", "cheap"),
    (r"\b(review|audit|security|patch)\b", "standard"),
    (r"\b(deep.research|architecture|complex)\b", "premium"),
]

ROLE_DEFAULTS = {
    "inbox_monitor": "cheap",
    "code_reviewer": "standard",
    "researcher": "standard",
    "auditor": "premium",
}

def route(task_desc: str, role: str, context_tokens: int, budget: Budget) -> str:
    tier = ROLE_DEFAULTS.get(role, "standard")
    for pattern, override in ROUTER_RULES:
        if re.search(pattern, task_desc, re.I):
            tier = override
            break
    if context_tokens > 8000:
        tier = bump_tier(tier)
    if budget.daily_spend > budget.hard_limit:
        tier = "cheap"
    return TIER_MODELS[tier]
```

- **Shadow mode** (optional, week 1): Log routed decision + what manual choice would have been. Compare cost/quality before flipping to auto.
- **No ML classifier** for now. Research shows static thresholds often outperform dynamic cascading in practice (arXiv:2602.09902). Add RouteLLM-style classifier only if heuristic proves insufficient.
- **Budget tracking**: Read from `~/.hermes/budget.json`, updated after each completion call.

### Expected Impact
- 40–70% cost reduction on mixed workloads (per industry benchmarks).
- Subagents automatically run on the cheapest capable model.
- Budget overruns are caught before they happen, not after.

---

## Proposal 3: Subagent State Machine + Dead Letter Queue

### Problem
The orchestrator spawns and kills subagents, but there is no formal lifecycle. If a subagent fails mid-task:
- Partial results are lost
- The orchestrator has no "resume" or "retry" option
- The user never knows a background task died

### Solution
A minimal state file per subagent run + a dead-letter queue for post-mortem analysis.

```
┌─────────────────────────────────────────────────────────────┐
│              SUBAGENT STATE MACHINE                          │
│                                                              │
│   spawn()                                                    │
│      │                                                       │
│      ▼                                                       │
│  ┌────────┐   tool call      ┌────────┐   success    ┌────┐ │
│  │PENDING │ ───────────────▶ │RUNNING │ ───────────▶ │DONE│ │
│  └────────┘                  └────┬───┘              └────┘ │
│                                   │                          │
│                    ┌──────────────┼──────────────┐          │
│                    │              │              │          │
│                    ▼              ▼              ▼          │
│               ┌────────┐   ┌────────┐   ┌────────┐        │
│               │ FAILED │   │ESCALATE│   │INTERRUPT│        │
│               └───┬────┘   └───┬────┘   └───┬────┘        │
│                   │            │            │              │
│                   ▼            ▼            ▼              │
│            ┌─────────────────────────────────────┐        │
│            │         DEAD LETTER QUEUE             │        │
│            │  ~/.hermes/dlq/                       │        │
│            │  ├── 2026-04-23T14-32_code-reviewer.json │   │
│            │  ├── 2026-04-23T14-45_researcher.json    │   │
│            │  └── ...                                │        │
│            └─────────────────────────────────────┘        │
│                          │                                   │
│                          ▼                                   │
│            ┌─────────────────────────────────────┐        │
│            │   Orchestrator Startup Inspection     │        │
│            │   "2 failed tasks waiting. Retry?     │        │
│            │    Escalate? Dismiss?"                │        │
│            └─────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Notes

```python
# agent/subagent_state.py — ~100 lines
from enum import Enum

class State(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    ESCALATED = "escalated"
    INTERRUPTED = "interrupted"

class SubagentState:
    def __init__(self, role, task, uuid):
        self.uuid = uuid
        self.role = role
        self.task = task
        self.state = State.PENDING
        self.retries = 0
        self.max_retries = 2
        self.error_log = []
        self.artifacts = []

    def transition(self, to: State, error=None):
        self.state = to
        if error:
            self.error_log.append({"time": now(), "msg": str(error)})
        self._persist()
        if to == State.FAILED and self.retries < self.max_retries:
            self.retries += 1
            return "retry"
        elif to == State.FAILED:
            self._to_dlq()
            return "escalate"
        return "ok"
```

- **State file**: `/tmp/hermes-subagent-{uuid}.json` while running, archived to `~/.hermes/dlq/` on terminal failure.
- **Retry policy**: Max 2 automatic retries with exponential backoff (3s, 10s). After that, forced escalation to user.
- **Interrupt handling**: On user message, active subagent transitions to `INTERRUPTED`, state file saved. Orchestrator can resume later if user asks.
- **DLQ inspection**: On orchestrator startup, scan `~/.hermes/dlq/`. If entries exist, prepend a system note: "N failed subagent tasks await review."

### Expected Impact
- Zero silently lost subagent work.
- Automatic retry handles transient failures (network blips, temporary rate limits) without user involvement.
- Post-mortem data enables debugging subagent failures without reproducing them.

---

## Implementation Priority

| Priority | Proposal | Complexity | Files Touched |
|----------|----------|-----------|---------------|
| P1 | Resilience Layer | Low (1 day) | `agent/resilience.py`, `tools/delegate_tool.py` |
| P2 | Cost Router | Low (1 day) | `agent/cost_router.py`, `run_agent.py` |
| P3 | Subagent State Machine | Medium (2 days) | `agent/subagent_state.py`, `agent/orchestrator.py` |

**Recommended order:** Resilience first (it protects everything else), then Cost Router (saves money immediately), then State Machine (highest user-value but touches orchestrator logic).

---

## References

- Beam AI — 6 Multi-Agent Orchestration Patterns for Production (2026)
- Zylos Research — AI Agent Delegation and Team Coordination Patterns (2026-03-08)
- AIMadeTools — AI Agent Error Handling: Retries, Fallbacks, and Circuit Breakers (2026)
- Supergood Solutions — Circuit Breakers for LLM Calls (2026)
- Alex Mayhew — LLM Cost Optimization at Scale (2026)
- Mavik Labs — LLM Cost Optimization in 2026: Routing, Caching, and Batching
- arXiv:2602.09902 — Routing Game Theory (static thresholds often outperform dynamic)
- RouteLLM (arXiv:2406.18665) — reference for future ML-classifier upgrade

# Cost Router: Heuristic Tiered Model Selection

Routes every LLM call to the cheapest capable model, with budget guards to prevent overruns.

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

## Routing Tiers

| Tier | Model Class | Use Case | Input Cost (per 1M) |
|------|-------------|----------|---------------------|
| **Cheap** | `glm-4-mini`, `claude-haiku-4.5` | Classification, simple Q&A, greetings, inbox triage | ~$0.15–0.80 |
| **Standard** | `glm-4.7`, `claude-sonnet-4.6` | General reasoning, code review, research, subagent work | ~$3.00 |
| **Premium** | `claude-opus-4.6`, `claude-4` | Complex architecture, critical security audits, deep analysis | ~$15.00 |

## Heuristic Rules (in order)

1. **Keyword match** — regex on task description overrides role default
2. **Role default** — if no keyword match, use subagent's configured tier
3. **Context size bump** — if assembled prompt > 8K tokens, bump up one tier (small models truncate)
4. **Budget override** — hard limit exceeded forces cheapest tier regardless of above

## Budget Guard Levels

| Level | Trigger | Action |
|-------|---------|--------|
| Soft | Daily spend > $5 | Alert user in next response |
| Hard | Daily spend > $8 | Force all new calls to CHEAP tier |
| Cap | Monthly spend > $200 | Halt non-essential work, escalate to user |

## Shadow Mode (Validation)

Before fully enabling auto-routing, run in shadow mode for one week:
- Log the router's chosen tier alongside the manually-selected model
- Compare cost and quality metrics
- Adjust keyword rules and thresholds based on actual traffic distribution

## Why No ML Classifier (Yet)

Research (arXiv:2602.09902) shows static thresholds often outperform dynamic cascading in practice. A heuristic router captures 60–70% of potential savings with <5ms overhead and zero training data. Upgrade to RouteLLM-style classifier only if heuristic proves insufficient after shadow-mode validation.

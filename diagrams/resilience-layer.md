# Resilience Layer: Retry, Circuit Breaker, Fallback

Protects the orchestrator and subagents from provider failures, rate limits, and cascading outages.

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

## Retry Policy

| Error Type | Retries | Backoff | Action |
|-----------|---------|---------|--------|
| Rate limit (429) | 5 | Exponential + jitter | Retry same provider |
| Server error (500/503) | 3 | Exponential + jitter | Fallback after retries |
| Timeout | 2 | Linear | Fallback immediately |
| Auth failure (401/403) | 0 | — | Fail fast |
| Context overflow | 0 | — | Compact + retry once |

## Circuit Breaker Config

```python
failure_threshold = 5      # failures in window
window_seconds = 60
reset_timeout = 30         # half-open after 30s
probes_to_close = 1        # one success closes circuit
```

## Fallback Chain

1. **Primary** — model configured for task (e.g. `glm-4.7`)
2. **Secondary** — alternate provider, same capability tier (e.g. `anthropic/claude-sonnet-4.6`)
3. **Cheap** — lowest-cost model that can complete the task (e.g. `anthropic/claude-haiku-4.5`)

## Dead Letter Queue

Failed subagent tasks are serialized to `~/.hermes/dlq/` with:
- Original task description and role
- Full error traceback
- Partial artifacts produced before failure
- Retry count

The orchestrator inspects DLQ on startup and offers retry / escalate / dismiss.

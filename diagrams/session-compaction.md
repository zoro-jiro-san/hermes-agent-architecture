# Session Compaction: Context Eviction Flow

What happens when a live session hits the context wall.

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT BUDGET CHECK                      │
│                                                              │
│   Every turn after prompt build:                             │
│                                                              │
│   assembled_tokens > (context_window × 0.85)                 │
│                          │                                   │
│                          ▼ yes                               │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              TRIGGER COMPACTION                      │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              PRESERVATION RULES                      │   │
│   │  NEVER evict:                                        │   │
│   │  • System prompt (identity, tools, safety)           │   │
│   │  • User profile + agent memory (injected)            │   │
│   │  • Active skill content (currently loaded)           │   │
│   │  • Most recent 4 turns (user + assistant + tools)    │   │
│   │  • Any turn containing an unresolved tool call       │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              EVICTION ORDER                          │   │
│   │                                                      │   │
│   │  1. Oldest tool results (summarize → drop)           │   │
│   │  2. Oldest assistant replies (summarize → drop)      │   │
│   │  3. Oldest user messages (summarize → drop)          │   │
│   │  4. Middle "anchor" summary (merge into new summary) │   │
│   │                                                      │   │
│   │  Goal: drop ~30% of token count from the middle.     │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │         ANCHORED SUMMARIZATION                       │   │
│   │                                                      │   │
│   │  Input: dropped_span (oldest N turns)                │   │
│   │         + existing_anchor (or empty)                 │   │
│   │                                                      │   │
│   │  ┌────────────┐    ┌─────────────────────────────┐  │   │
│   │  │ Cheap model│───▶│  Summarize into 4 fields:   │  │   │
│   │  │ (glm-mini) │    │  • intent — what user wanted│  │   │
│   │  └────────────┘    │  • changes — files edited   │  │   │
│   │                    │  • decisions — key choices  │  │   │
│   │                    │  • next_steps — open items  │  │   │
│   │                    └─────────────────────────────┘  │   │
│   │                              │                       │   │
│   │                              ▼                       │   │
│   │                    ┌─────────────────────────────┐  │   │
│   │                    │  Merge with old anchor      │  │   │
│   │                    │  (dedupe, update, append)   │  │   │
│   │                    └─────────────────────────────┘  │   │
│   │                              │                       │   │
│   │                              ▼                       │   │
│   │                    ┌─────────────────────────────┐  │   │
│   │                    │  New anchor (~600 tokens)   │  │   │
│   │                    │  Injected after system      │  │   │
│   │                    │  prompt, before history.    │  │   │
│   │                    └─────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              RE-ASSEMBLE PROMPT                      │   │
│   │                                                      │   │
│   │  [System] → [Anchor] → [Recent 4 turns] → [Current]  │   │
│   │                                                      │   │
│   │  Still > 85% after compaction?                       │   │
│   │    → Drop another chunk and re-summarize.            │   │
│   │    → Max 3 compaction rounds per turn.               │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              HARD FAILSAFE                           │   │
│   │                                                      │   │
│   │  After 3 rounds still over limit:                    │   │
│   │    → Halt tool use.                                  │   │
│   │    → Reply: "Session too long. Start fresh?"         │   │
│   │    → Offer /compact or /newsession command.          │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Anchor Format

The anchor is a single system message injected between the system prompt and the live conversation:

```
[SESSION SO FAR]
Intent: Refactor the auth module to use JWT instead of sessions.
Changes: auth.py (lines 12-45), login_handler.py deleted.
Decisions: Use PyJWT, keep refresh tokens in Redis, 15min expiry.
Next: Fix the 3 failing tests in test_auth.py.
```

- Fixed 4-field schema so the cheap model can't ramble.
- Hard limit: 600 tokens. If merge exceeds this, summarize the summary.
- Preserves technical specifics (file paths, error messages) that generic summaries lose.

## Why Not Just Delete Old Turns?

| Approach | Problem |
|----------|---------|
| Naive truncation | Loses the original task intent. Agent forgets what it's doing. |
| Full history re-summarize | O(n²) cost, loses file paths and error details. |
| **Anchored incremental** | O(chunk) cost, preserves trunk facts, bounded growth. |

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| compaction_trigger | 0.85 | % of context window that triggers eviction |
| preserve_recent | 4 turns | Minimum recent turns kept verbatim |
| anchor_max_tokens | 600 | Hard cap on anchor length |
| max_compaction_rounds | 3 | Rounds per turn before hard fail |
| summarizer_model | `glm-4-mini` | Cheap model for anchor updates |

## Integration Points

- **Agent Loop**: Compaction runs between `Build Prompt` and `LLM Call` (see agent-loop.md).
- **Resilience Layer**: If compaction fails, treat as context overflow → halt and escalate (see resilience-layer.md).
- **Memory System**: Anchor content is NOT saved to long-term memory. It is ephemeral session state. Durable facts are extracted at session end into agent memory (see memory-system.md).

# Memory System

How Hermes maintains persistent knowledge across sessions.

```
┌──────────────────────────────────────────────────┐
│                  MEMORY FLOW                      │
│                                                   │
│  Every Turn:                                      │
│  ┌──────────────┐                                │
│  │  User says   │                                │
│  │  something   │                                │
│  └──────┬───────┘                                │
│         │                                         │
│         ▼                                         │
│  ┌─────────────────────────────────────┐         │
│  │         INJECTED INTO PROMPT         │         │
│  │                                      │         │
│  │  ┌─────────────────────────────┐    │         │
│  │  │   USER PROFILE              │    │         │
│  │  │   - Name: Nico              │    │         │
│  │  │   - Preferences             │    │         │
│  │  │   - Cost consciousness      │    │         │
│  │  │   - Communication style     │    │         │
│  │  │   (1,375 chars max)         │    │         │
│  │  └─────────────────────────────┘    │         │
│  │                                      │         │
│  │  ┌─────────────────────────────┐    │         │
│  │  │   AGENT MEMORY (notes)      │    │         │
│  │  │   - Environment facts       │    │         │
│  │  │   - Tool quirks             │    │         │
│  │  │   - Lessons learned         │    │         │
│  │  │   - Project conventions     │    │         │
│  │  │   (2,200 chars max)         │    │         │
│  │  └─────────────────────────────┘    │         │
│  └─────────────────────────────────────┘         │
│                                                   │
│  After Tasks:                                     │
│  ┌──────────────────┐                            │
│  │  What to save?   │                            │
│  └────────┬─────────┘                            │
│           │                                       │
│     ┌─────┴─────┐                                │
│     │           │                                │
│     ▼           ▼                                │
│  ┌──────┐  ┌──────────┐                         │
│  │ User │  │ Memory   │                         │
│  │ Profile│  │ (notes)  │                         │
│  └──────┘  └──────────┘                         │
│                                                   │
│  Priority:                                        │
│  1. User corrections > preferences > habits       │
│  2. Environment facts > procedural knowledge      │
│  3. NEVER save: task logs, TODO state, temp data  │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│             SESSION RECALL                         │
│                                                   │
│  ┌──────────────────┐                            │
│  │  session_search  │                            │
│  │  (FTS5 index)    │                            │
│  └────────┬─────────┘                            │
│           │                                       │
│     ┌─────┴──────────────┐                       │
│     │                    │                        │
│     ▼                    ▼                        │
│  ┌──────────┐    ┌──────────────┐                │
│  │ Recent   │    │ Keyword      │                │
│  │ Sessions │    │ Search       │                │
│  └──────────┘    └──────────────┘                │
│                                                   │
│  Sessions stored in SQLite with full-text search  │
│  Recalled via: session_search(query="Solana")     │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│              SKILL SYSTEM                          │
│                                                   │
│  ┌─────────────────────────────────────────┐     │
│  │  ~/.hermes/skills/                       │     │
│  │  ├── github/github-auth/SKILL.md         │     │
│  │  ├── research/arxiv/SKILL.md             │     │
│  │  ├── mlops/training/unsloth/SKILL.md     │     │
│  │  └── ... (40+ skills)                    │     │
│  │                                          │     │
│  │  Procedural memory — reusable workflows  │     │
│  │  Auto-scanned and loaded per turn        │     │
│  │  Updated via skill_manage()              │     │
│  └─────────────────────────────────────────┘     │
└──────────────────────────────────────────────────┘
```

## Memory Budget

| Store | Max Size | Content |
|-------|----------|---------|
| User Profile | 1,375 chars | Who the user is, preferences, credentials |
| Agent Memory | 2,200 chars | Environment facts, conventions, lessons |
| Skills List | ~2,000 chars | Available skills scanned per turn |
| Session Search | Unlimited | Full conversation history in SQLite |

## Improvement Opportunities

1. **RAG over conversations** — Embed past sessions, retrieve relevant context dynamically instead of injecting everything
2. **Memory prioritization** — Auto-rank memories by recency and relevance
3. **Skill evolution** — Auto-update skills based on usage patterns and failure rates
4. **Cross-session task tracking** — Persistent task state that survives session boundaries
5. **Semantic memory compaction** — Merge similar memories, remove stale entries

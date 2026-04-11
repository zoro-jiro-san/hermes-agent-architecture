# Memory Management Research

## Status: Active — Deep Research (2026-04-11)

### Current Architecture
- **User Profile**: 1,375 chars — who the user is, preferences
- **Agent Memory**: 2,200 chars — environment facts, conventions, lessons
- **Session Search**: SQLite FTS5 — full conversation history
- **Skills**: File-based procedural memory in ~/.hermes/skills/
- **Context Compression**: Auto-summarize middle turns when approaching limit

### Memory Budget
| Store | Max Size | Content | Injection |
|-------|----------|---------|-----------|
| User Profile | 1,375 chars | Who the user is, preferences | Every turn |
| Agent Memory | 2,200 chars | Environment facts, conventions | Every turn |
| Skills List | ~2,000 chars | Available skills scanned per turn | Every turn |
| Session Search | Unlimited | Full conversation history in SQLite | On-demand |
| Context Compression | Dynamic | Auto-summarizes middle turns | At 85% threshold |

### Research Questions
1. **RAG over conversations** — Embed sessions, retrieve relevant context dynamically
2. **Semantic compaction** — Merge similar memories, remove stale entries
3. **Memory prioritization** — Auto-rank by recency + relevance + access frequency
4. **Hierarchical memory** — Short-term (session) → medium-term (memory) → long-term (skills)
5. **Forgetting curve** — Auto-expire low-value memories after N days

---

## 2026-04-11 Deep Research: Memory Management

### Landscape Overview

The field has consolidated around several key architectural patterns in 2025-2026:

1. **Tiered memory systems** — Letta's Core/Recall/Archival model; ByteRover's Context Tree
2. **Temporal knowledge graphs** — Zep/Graphiti's bi-temporal edge model
3. **Ebbinghaus-inspired forgetting curves** — FadeMem, MemoryBank, YourMemory
4. **Hybrid vector+graph retrieval** — Hindsight's 91.4% on LongMemEval
5. **Agent self-curation** — CrewAI's cognitive memory; ByteRover's agent-native approach
6. **Server-side compaction** — Anthropic's Context Compaction API (beta Jan 2026)

### Benchmarks (Standard Evaluation Suites)

| Benchmark | Focus | Top System | Score |
|-----------|-------|-----------|-------|
| LongMemEval | Cross-session recall | Hindsight (Gemini-3) | 91.4% |
| LOCOMO | Long conversation memory | Mem0g (graph-enhanced) | 68.4% |
| AMB (new 2026) | Million-token context | Hindsight | LifeBench/MemBench/MemSim |
| Full-context baseline | No memory mgmt | GPT-4o | 60.2% (LongMemEval) |

### Key Papers

| Paper | Date | Key Contribution |
|-------|------|------------------|
| Mem0 (ECAI 2025) | Apr 2025 | 10-approach comparison; 91% latency reduction for 6pp accuracy trade |
| Zep/Graphiti | Jan 2025 | Temporal KG; 94.8% DMR; 18.5% accuracy gain, 90% latency reduction |
| FadeMem | Jan 2026 | Dual-layer Ebbinghaus decay; 45% storage reduction, 82.1% retention |
| G-Memory | NeurIPS 2025 | Three-tier graph hierarchy for MAS; 20.89% embodied action gain |
| SimpleMem | 2025 | 50× faster than Mem0; semantic structured compression |
| ByteRover | 2026 | Agent-native hierarchical Context Tree; zero external infra |
| HIPPOCAMPUS | 2026 | Wavelet Matrix memory; compact binary signatures |
| Adaptive Budgeted Forgetting | Apr 2026 | Formalized forgetting as constrained optimization |
| Context-Folding | Oct 2025 | RL-trained active context management; 32K budget beats 327K baseline |
| ACON | 2025-26 | Gradient-free compression optimization; 26-54% token reduction |
| TACITREE | 2025 | Hierarchical tree retrieval; 30% higher accuracy, 40-60% fewer tokens |

### Open Source Implementations

| Framework | Stars | Architecture | Key Differentiator |
|-----------|-------|--------------|-------------------|
| Mem0 | ~48K | Hybrid (vector+graph+KV) | 4-scope memory; self-editing conflict resolution |
| Zep/Graphiti | — | Temporal KG (3-layer) | Bi-temporal timestamps; 94.8% DMR |
| Hindsight | ~8.8K | Multi-strategy hybrid | **91.4% LongMemEval** — SOTA |
| Letta (MemGPT) | ~21K | OS-inspired 3-tier | Agent self-edits memory blocks; sleep-time compute |
| CrewAI Memory | ~49K | Unified Cognitive | 5 cognitive operations; LLM-driven encode/recall/forget |
| Cognee | ~12K | Poly-store (graph+vector+rel) | 30+ data connectors; custom graph models |
| LangMem | — | LangGraph-native | Background memory formation; SummarizationNode |

### Frontier Provider Patterns

**Anthropic**: Server-side compaction API (beta), context editing/clearing, agent skills (progressive disclosure), memory folders
**OpenAI**: SummarizingSession, memory distillation + consolidation phases, previous_response_id chaining
**Google Vertex AI**: Memory Bank with extraction, consolidation, similarity search, TTL, revisions; Gemini Interactions API

### Forgetting Curve Implementations

| System | Decay Model | Key Parameters |
|--------|------------|----------------|
| FadeMem | Dual-layer: β=0.8 (LTM), β=1.2 (STM) | Hysteresis θ_promote=0.7, θ_demote=0.3 |
| YourMemory | Category-based λ: strategy(0.10) > fact(0.16) > assumption(0.20) > failure(0.35) | Auto-prune at strength < 0.05 |
| MemoryBank | R(t) = e^(-t/S), S increases with recall | Three modules: Writer, Retriever, Reader |
| Adaptive Budgeted | Constrained optimization: M* = argmax ΣI(m_i,t) s.t. |M'| ≤ B | Temporal decay × usage frequency × semantic alignment |
| CrewAI | LLM-driven reasoning (not formulaic) | 5 cognitive operations including active forget() |

---

## Concrete Improvement Proposals for Hermes

### P1: Memory Decay with Ebbinghaus Forgetting Curve
**What**: Add exponential decay scoring to memory entries. Each memory gets a `strength` field that decays over time: `R(t) = e^(-t/S)` where S increases on each access. Memories below 0.05 strength auto-prune.
**How**: Add `last_accessed`, `access_count`, `importance` fields to memory entries. Compute strength at injection time. Sort by strength and inject top-N within token budget.
**Impact**: Prevents stale memory accumulation; keeps ~2,200 char budget focused on relevant facts. Estimated 15-20% improvement in memory relevance.
**Complexity**: Low — modify memory injection in `prompt_builder.py`, add decay calculation.
**Priority**: **Must-have** — directly addresses the biggest gap vs. frontier systems.

### P2: Anchored Iterative Summarization for Context Compression
**What**: Replace simple context compression with anchored summarization. Maintain a running anchor document with four fields: intent, changes_made, decisions_taken, next_steps. When compressing, only summarize the new dropped span and merge into the anchor.
**How**: Modify `context_compressor.py` to maintain an anchor state. Instead of recompressing the full history, incrementally update the anchor. Scored 4.04 accuracy vs 3.74 for Anthropic native in Factory.ai benchmarks.
**Impact**: Better preservation of technical details (file paths, error messages) across long sessions. 10-15% better accuracy on multi-step tasks.
**Complexity**: Medium — requires anchor state management across compression cycles.
**Priority**: **Must-have** — the current compression loses technical details.

### P3: Hybrid Retrieval for Session Search (FTS5 + Semantic)
**What**: Add vector embeddings alongside FTS5 keyword search. Use Reciprocal Rank Fusion (RRF) to merge results from both. Route queries: lexical for exact matches, semantic for conceptual queries.
**How**: Embed session summaries at session end using a local embedding model (e.g., all-MiniLM-L6-v2 via sentence-transformers, 80MB). Store in sqlite-vec extension alongside existing FTS5 index. Query both and merge with RRF.
**Impact**: Session search currently misses conceptual matches ("that time we worked on the payment stuff" → misses session about Stripe integration). Estimated 30-40% improvement in recall.
**Complexity**: Medium — need embedding pipeline, storage, and hybrid query logic.
**Priority**: **Should-have** — FTS5 is adequate for keyword queries but fails on conceptual recall.

### P4: Memory Scoping (per-platform and per-project)
**What**: Add scope tags to memory entries. Support hierarchical scopes: `/global`, `/platform/telegram`, `/project/hermes-agent`. Inject only relevant scopes per session.
**How**: Add `scope` field to memory entries. In `prompt_builder.py`, filter by current platform and project context. Allow agents to specify scope when saving. Similar to Mem0's 4-scope model.
**Impact**: Reduces memory noise — Telegram-specific preferences don't pollute CLI sessions. Estimated 20-30% reduction in irrelevant memory injection.
**Complexity**: Low — add scope field, modify injection filter.
**Priority**: **Should-have** — increasingly important as Hermes runs on more platforms.

### P5: Background Memory Consolidation (Nightly)
**What**: A nightly cron job that consolidates the day's session summaries into the memory store. Extract facts, update existing entries, merge duplicates, prune stale entries.
**How**: New cron job that reads all sessions from the day, uses a cheap model (Gemini Flash or MiMo) to extract durable facts, and merges into memory. Similar to OpenAI's memory consolidation phase.
**Impact**: Keeps memory fresh and consolidated without burdening real-time sessions. Estimated 40-50% better memory coverage over time.
**Complexity**: Medium — need fact extraction pipeline and merge logic.
**Priority**: **Nice-to-have** — valuable but not blocking daily usage.

### P6: Temporal Awareness for Memory Entries
**What**: Add bi-temporal timestamps to memory: when the fact was learned (event_time) and when it was last validated (validation_time). When a new fact contradicts an old one, auto-invalidate.
**How**: Add `learned_at`, `last_validated`, `superseded_by` fields. When saving a new memory that contradicts existing, mark the old one as superseded. Inspired by Zep/Graphiti's bi-temporal model.
**Impact**: Prevents stale/contradictory memories. Critical for facts that change (API keys, project state, team members).
**Complexity**: Medium — need contradiction detection and validation tracking.
**Priority**: **Should-have** — contradicted memories cause recurring errors.

### P7: Progressive Disclosure for Skill Loading
**What**: Instead of injecting all 40+ skill descriptions every turn, inject only YAML frontmatter (~80 tokens per skill). Full skill content loads on demand via skill_view() when triggered.
**How**: Modify skills list injection to use frontmatter summary instead of full descriptions. Already partially implemented — but the skills list in system prompt still shows all names.
**Impact**: ~2,000 chars → ~800 chars for skills injection. Estimated 60% reduction in skill-related token overhead.
**Complexity**: Low — change what gets injected in system prompt.
**Priority**: **Must-have** — low-hanging fruit with high token savings.

---

## Implementation Priority Matrix

| # | Improvement | Impact | Complexity | Priority | Est. Token Savings |
|---|------------|--------|------------|----------|-------------------|
| P7 | Progressive skill disclosure | High | Low | **Must-have** | ~1,200 chars/turn |
| P1 | Memory decay + pruning | High | Low | **Must-have** | ~500 chars/turn (focused) |
| P2 | Anchored compression | High | Medium | **Must-have** | Better quality, not less tokens |
| P4 | Memory scoping | Medium | Low | Should-have | ~400 chars/turn |
| P3 | Hybrid session retrieval | High | Medium | Should-have | N/A (recall improvement) |
| P6 | Temporal awareness | Medium | Medium | Should-have | Prevents errors |
| P5 | Nightly consolidation | Medium | Medium | Nice-to-have | N/A (coverage improvement) |

---

## Ideas to Explore (Future)
- [ ] Vector embeddings for session search (replace FTS5 keyword search)
- [ ] Knowledge graph for entity relationships (Zep/Graphiti pattern)
- [ ] Memory consolidation: merge daily learnings into compressed knowledge
- [ ] User modeling via Honcho integration
- [ ] Reflection: periodic self-review of memory quality
- [ ] ByteRover-style Context Tree for hierarchical knowledge
- [ ] Context-Folding RL agent for active context management
- [ ] TACITREE hierarchical retrieval for session search

### Metrics to Track
- Memory hit rate: how often injected memory is relevant
- Compression ratio: how much context is saved by compression
- Session recall accuracy: does session_search return the right results?
- Memory freshness: average age of active memory entries
- Contradiction rate: how often memories conflict

### References
- Mem0: github.com/mem0ai/mem0 | arXiv:2504.19413
- Zep/Graphiti: github.com/getzep/graphiti | arXiv:2501.13956
- Hindsight: github.com/vectorize-io/hindsight
- FadeMem: github.com/ChihayaAine/FadeMem | arXiv:2601.18642
- Context-Folding: arXiv:2510.11967
- ACON: openreview.net/forum?id=x0alNh5o8v
- TACITREE: arXiv:2503.07018
- Anthropic Compaction: docs.anthropic.com/en/docs/build-with-claude/compaction
- Anthropic Context Engineering: platform.claude.com/cookbook/tool-use-context-engineering
- Atlas Long-Form Memory: github.com/pragnyanramtha/longmem
- SelRoute query routing: arXiv:2604.02431

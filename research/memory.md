# Memory Management Research

## Status: Active — Deep Research (2026-05-08)

### Current Architecture
- **User Profile**: 1,375 chars — who the user is, preferences
- **Agent Memory**: 2,200 chars — environment facts, conventions, lessons
- **Session Search**: SQLite FTS5 — full conversation history
- **Skills**: File-based procedural memory in ~/.hermes/skills/
- **Context Compression**: Auto-summarize middle turns when approaching limit

### Memory Budget
|| Store | Max Size | Content | Injection |
||-------|----------|---------|-----------||
|| User Profile | 1,375 chars | Who the user is, preferences | Every turn ||
|| Agent Memory | 2,200 chars | Environment facts, conventions | Every turn ||
|| Skills List | ~2,000 chars | Available skills scanned per turn | Every turn ||
|| Session Search | Unlimited | Full conversation history in SQLite | On-demand ||
|| Context Compression | Dynamic | Auto-summarizes middle turns | At 85% threshold ||

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

|| Benchmark | Focus | Top System | Score ||
||-----------|-------|-----------|-------||
|| LongMemEval | Cross-session recall | Hindsight (Gemini-3) | 91.4% ||
|| LOCOMO | Long conversation memory | Mem0g (graph-enhanced) | 68.4% ||
|| AMB (new 2026) | Million-token context | Hindsight | LifeBench/MemBench/MemSim ||
|| Full-context baseline | No memory mgmt | GPT-4o | 60.2% (LongMemEval) ||

### Key Papers

|| Paper | Date | Key Contribution ||
||-------|------|------------------||
|| Mem0 (ECAI 2025) | Apr 2025 | 10-approach comparison; 91% latency reduction for 6pp accuracy trade ||
|| Zep/Graphiti | Jan 2025 | Temporal KG; 94.8% DMR; 18.5% accuracy gain, 90% latency reduction ||
|| FadeMem | Jan 2026 | Dual-layer Ebbinghaus decay; 45% storage reduction, 82.1% retention ||
|| G-Memory | NeurIPS 2025 | Three-tier graph hierarchy for MAS; 20.89% embodied action gain ||
|| SimpleMem | 2025 | 50× faster than Mem0; semantic structured compression ||
|| ByteRover | 2026 | Agent-native hierarchical Context Tree; zero external infra ||
|| HIPPOCAMPUS | 2026 | Wavelet Matrix memory; compact binary signatures ||
|| Adaptive Budgeted Forgetting | Apr 2026 | Formalized forgetting as constrained optimization ||
|| Context-Folding | Oct 2025 | RL-trained active context management; 32K budget beats 327K baseline ||
|| ACON | 2025-26 | Gradient-free compression optimization; 26-54% token reduction ||
|| TACITREE | 2025 | Hierarchical tree retrieval; 30% higher accuracy, 40-60% fewer tokens ||
|| SuperLocalMemory V3.3 | Apr 2026 | 7-channel cognitive retrieval; lifecycle-aware quantization; 70.4% LoCoMo ||
|| Evolving Retrieval Memory (ERM) | Feb 2026 | Query-infused key memory; persistent improvements without forgetting ||

### Open Source Implementations (Latest Updates)

|| Framework | Stars | Architecture | Key Differentiator | Latest Update ||
||-----------|-------|--------------|-------------------|---------------||
|| Hindsight | ~12.5K | Multi-strategy hybrid | **91.4% LongMemEval** — SOTA | v0.6.0 (May 2026) ||
|| Mem0 | ~48K | Hybrid (vector+graph+KV) | 4-scope memory; self-editing conflict resolution | Active development ||
|| Zep/Graphiti | — | Temporal KG (3-layer) | Bi-temporal timestamps; 94.8% DMR | Active development ||
|| Letta (MemGPT) | ~21K | OS-inspired 3-tier | Agent self-edits memory blocks; sleep-time compute | Active development ||
|| CrewAI Memory | ~49K | Unified Cognitive | 5 cognitive operations; LLM-driven encode/recall/forget | **Unified v2 (Feb 2026)** ||
|| Cognee | ~12K | Poly-store (graph+vector+rel) | 30+ data connectors; custom graph models | Active development ||
|| SuperLocalMemory | — | 7-channel cognitive | Lifecycle quantization; zero-LLM mode | V3.3 (Apr 2026) ||

### Frontier Provider Patterns (Latest)

**Anthropic**: Server-side compaction API (beta), context editing/clearing, agent skills (progressive disclosure), memory folders
**OpenAI**: SummarizingSession, memory distillation + consolidation phases, previous_response_id chaining
**Google Vertex AI**: Memory Bank with extraction, consolidation, similarity search, TTL, revisions; Gemini Interactions API

### Memory Garbage Collection (Apr 2026 Breakthrough)

Production systems now recognize that **memory accumulation without management causes performance degradation**:

- **"Add-all" strategy**: 2,400+ records → 13% accuracy on medical tasks
- **Active management**: 248 records → 39% accuracy (**3x improvement**)

### Forgetting Curve Implementations

|| System | Decay Model | Key Parameters ||
||--------|------------|----------------||
|| FadeMem | Dual-layer: β=0.8 (LTM), β=1.2 (STM) | Hysteresis θ_promote=0.7, θ_demote=0.3 ||
|| YourMemory | Category-based λ: strategy(0.10) > fact(0.16) > assumption(0.20) > failure(0.35) | Auto-prune at strength < 0.05 ||
|| MemoryBank | R(t) = e^(-t/S), S increases with recall | Three modules: Writer, Retriever, Reader ||
|| Adaptive Budgeted | Constrained optimization: M* = argmax ΣI(m_i,t) s.t. |M'| ≤ B | Temporal decay × usage frequency × semantic alignment ||
|| CrewAI | LLM-driven reasoning (not formulaic) | 5 cognitive operations including active forget() ||
|| SuperLocalMemory | Ebbinghaus: R(t) = e^(-t/S(m)) | 4-bit quantization lifecycle: Active→32-bit→Warm→8-bit→Cold→4-bit→Archive→2-bit ||

---

## 2026-05-08 Deep Research: Latest Developments

### Memory Consolidation Revolution

**Memory Consolidation** has emerged as the critical missing piece in 2026. Production systems now implement automated consolidation pipelines:

#### 1. AgentDock's Consolidation Architecture
- **Episodic → Semantic Conversion**: Converts time-specific experiences into general knowledge
- **Memory Deduplication**: Merges similar memories using multiple similarity metrics
- **Hierarchical Abstraction**: Creates higher-level concepts from detailed memories

#### 2. Three-Tier Deduplication System
- **Tier 1 (≥ 0.98 similarity)**: Auto-merge near-identical memories without LLM
- **Tier 2 (0.80-0.98 similarity)**: LLM classifies as duplicate/related/conflicting/distinct
- **Tier 3 (< 0.80 similarity)**: Skip - too different

#### 3. Consolidation Strategies
| Strategy | Description | Use Case | Preserves Detail |
|----------|-------------|----------|------------------|
| Merge | Simple concatenation of similar content | High similarity (>0.9) | Low |
| Synthesize | LLM creates new summary from multiple | Medium similarity (0.7-0.9) | Medium |
| Abstract | Extract high-level patterns | Pattern recognition | Low |
| Hierarchy | Create parent-child relationships | Categorical organization | High |

### Active Context Compression (Focus Agent)

**Focus Agent** (Physarum polycephalum-inspired) achieves autonomous memory management:

- **22.7% token reduction** (14.9M → 11.5M tokens) while maintaining identical accuracy
- **6.0 autonomous compressions per task** on average
- **57% token savings** on individual instances
- Agent decides when to consolidate key learnings into persistent "Knowledge" blocks

### SimpleMem: 30× Token Efficiency

SimpleMem introduces semantic lossless compression with three-stage pipeline:

1. **Semantic Structured Compression**: Distills unstructured interactions into compact, multi-view indexed memory units
2. **Online Semantic Synthesis**: Intra-session process that instantly integrates related context into unified abstract representations
3. **Intent-Aware Retrieval Planning**: Infers search intent to dynamically determine retrieval scope

**Results**: 
- **26.4% F1 improvement** on average
- **Up to 30-fold reduction** in inference-time token consumption

### Hindsight v0.6.0: CrewAI Integration

Latest Hindsight release introduces seamless CrewAI integration:
- **Drop-in Storage Backend**: Implements CrewAI's `Storage` interface for `ExternalMemory`
- **Automatic Memory Flow**: CrewAI automatically stores task outputs and retrieves relevant memories
- **Per-Agent Banks**: Optionally give each agent its own isolated memory bank
- **Reflect Tool**: Agents can explicitly reason over memories with disposition-aware synthesis

### SuperLocalMemory V3.3: "The Living Brain"

Key innovations:
- **FRQAD (Fisher-Rao Quantization-Aware Distance)**: 100% correct preference for full-precision embeddings vs 85.6% cosine
- **Ebbinghaus Adaptive Forgetting**: 6.7× discriminative power between frequently accessed and unused memories
- **7-Channel Cognitive Retrieval**: Semantic, BM25, Entity Graph, Temporal, Spreading Activation, Consolidation, Hopfield
- **Lifecycle-Aware Quantization**: Active→32-bit→Warm→8-bit→Cold→4-bit→Archive→2-bit
- **70.4% accuracy** on LoCoMo benchmark (zero-LLM mode)

### Evolving Retrieval Memory (ERM)

Breakthrough approach that transforms transient query-time gains into persistent retrieval improvements:
- **Training-free framework**
- **Correctness-gated feedback**: Selectively attributes expansion signals to document keys
- **Zero inference-time overhead**: Amortizes optimal query expansion into stable index
- **13 domain testing on BEIR and BRIGHT**: Consistent gains on reasoning-intensive tasks

---

## Concrete Improvement Proposals for Hermes

### P1: Memory Consolidation Pipeline
**What**: Implement automated memory consolidation that runs as a nightly background job. Uses three-tier deduplication to merge similar memories, convert episodic to semantic knowledge, and create hierarchical abstractions.
**How**: 
1. Add consolidation job that processes memories older than 7 days
2. Implement Tier 1 auto-merge for ≥0.98 similarity (no LLM)
3. Use LLM for Tier 2 (0.80-0.98) classification and synthesis
4. Create parent-child relationships for categorized memories
**Impact**: Estimated 60-80% reduction in memory store size, 15-20% improvement in retrieval relevance
**Complexity**: Medium — requires background scheduler, LLM pipeline, and merge logic
**Priority**: **Must-have** — prevents memory bloat and improves quality

### P2: Ebbinghaus Adaptive Forgetting
**What**: Implement mathematical forgetting curve: R(t) = e^(-t/S(m)) where memory strength depends on access frequency, importance, confirmation count, and emotional salience. Low-trust memories decay 3× faster.
**How**: 
1. Add `last_accessed`, `access_count`, `importance`, `strength` fields to memory entries
2. Implement decay calculation with configurable base rate
3. Add trust scoring that accelerates decay for low-confidence memories
4. Auto-prune memories below strength threshold (0.05)
**Impact**: Prevents stale memory accumulation; keeps ~2,200 char budget focused on relevant facts. Estimated 15-20% improvement in memory relevance.
**Complexity**: Low — modify memory injection in prompt_builder.py, add decay calculation
**Priority**: **Must-have** — directly addresses the biggest gap vs. frontier systems

### P3: SuperLocalMemory-Inspired 7-Channel Retrieval
**What**: Upgrade session search from FTS5 keyword-only to 7-channel parallel retrieval fused via weighted Reciprocal Rank Fusion.
**How**:
1. Add sqlite-vec extension for semantic KNN search
2. Implement BM25 keyword search (existing FTS5)
3. Build entity graph for relationship traversal
4. Add temporal bi-timestamp tracking
5. Implement spreading activation for causal connections
6. Create consolidation gist blocks for compressed knowledge
7. Use Hopfield associative memory for pattern completion
8. Fuse results with weighted RRF and ONNX cross-encoder reranking
**Impact**: Session search currently misses conceptual matches. Estimated 30-40% improvement in recall, especially for multi-hop reasoning.
**Complexity**: High — requires multiple retrieval backends and fusion logic
**Priority**: **Should-have** — transforms session search from keyword to semantic reasoning

### P4: Progressive Skill Loading with Frontmatter Summaries
**What**: Instead of injecting all 40+ skill descriptions every turn (~2,000 chars), inject only YAML frontmatter (~80 tokens per skill). Full skill content loads on demand via skill_view() when triggered.
**How**: 
1. Modify skills list injection to extract frontmatter only
2. Cache full skill content when first accessed
3. Implement on-demand loading with LRU cache
4. Add skill dependency tracking for efficient loading
**Impact**: ~2,000 chars → ~800 chars for skills injection. Estimated 60% reduction in skill-related token overhead.
**Complexity**: Low — change what gets injected in system prompt, add caching layer
**Priority**: **Must-have** — low-hanging fruit with high token savings

### P5: Active Context Compression (Focus Pattern)
**What**: Implement autonomous context compression that monitors context usage and triggers compression when approaching limits. Agent decides what to consolidate into persistent knowledge blocks.
**How**:
1. Add context monitor that tracks token usage per turn
2. Implement compression trigger at 80% of context budget
3. Create knowledge blocks for consolidated learnings
4. Maintain reference to original memories for retrieval
5. Use agent judgment to decide compression timing and content
**Impact**: 20-30% token reduction while preserving accuracy, prevents context window overflow
**Complexity**: Medium — requires context monitoring and compression decision logic
**Priority**: **Should-have** — prevents context bloat during long sessions

### P6: Memory Scoping with Multi-Tenancy
**What**: Add scope tags to memory entries supporting hierarchical scopes: `/global`, `/platform/telegram`, `/project/hermes-agent`, `/session/xyz`. Inject only relevant scopes per session.
**How**:
1. Add `scope` field to memory entries with hierarchical path structure
2. Implement scope context that tracks current platform and project
3. Filter memory injection by scope matching
4. Add scope inheritance (child scopes inherit parent)
5. Implement scope-specific TTL and decay rates
**Impact**: Reduces memory noise — Telegram-specific preferences don't pollute CLI sessions. Estimated 20-30% reduction in irrelevant memory injection.
**Complexity**: Medium — add scope field, modify injection filter, implement scope resolution
**Priority**: **Should-have** — increasingly important as Hermes runs on more platforms

### P7: Evolving Retrieval Memory for Skills
**What**: Implement ERM-style feedback loop for skill usage. When skills are used successfully, the usage signal reinforces the skill's retrievability index.
**How**:
1. Track skill usage success/failure
2. Map usage signals to skill embeddings
3. Update skill index with success-weighted embeddings
4. Implement gradual evolution of skill representations
**Impact**: Skills that prove useful become more prominent in retrieval, improving skill selection quality over time
**Complexity**: Medium — requires usage tracking and embedding evolution
**Priority**: **Nice-to-have** — valuable but not blocking daily usage

---

## Implementation Priority Matrix (Updated)

| # | Improvement | Impact | Complexity | Priority | Est. Token Savings |
|---|------------|--------|------------|----------|-------------------|
| P4 | Progressive skill disclosure | High | Low | **Must-have** | ~1,200 chars/turn |
| P1 | Memory consolidation pipeline | High | Medium | **Must-have** | 60-80% storage reduction |
| P2 | Ebbinghaus adaptive forgetting | High | Low | **Must-have** | ~500 chars/turn (focused) |
| P5 | Active context compression | Medium | Medium | Should-have | 20-30% token reduction |
| P3 | 7-channel retrieval | High | High | Should-have | 30-40% recall improvement |
| P6 | Memory scoping | Medium | Medium | Should-have | ~400 chars/turn |
| P7 | Evolving retrieval for skills | Medium | Medium | Nice-to-have | Improved skill quality |

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
- Consolidation ratio: how much memory is merged vs. stored

### References
- Mem0: github.com/mem0ai/mem0 | arXiv:2504.19413
- Zep/Graphiti: github.com/getzep/graphiti | arXiv:2501.13956
- Hindsight: github.com/vectorize-io/hindsight | Latest v0.6.0
- FadeMem: github.com/ChihayaAine/FadeMem | arXiv:2601.18642
- Context-Folding: arXiv:2510.11967
- ACON: openreview.net/forum?id=x0alNh5o8v
- TACITREE: arXiv:2503.07018
- SuperLocalMemory: arXiv:2604.04514 | github.com/qualixar/superlocalmemory
- SimpleMem: arXiv:2601.02553v2
- Evolving Retrieval Memory: arXiv:2602.05152v1
- Anthropic Compaction: docs.anthropic.com/en/docs/build-with-claude/compaction
- AgentDock Consolidation Guide: hub.agentdock.ai/docs/memory/consolidation-guide
- Focus Agent: arXiv:2601.07190v1

---

## 2026-05-08: Latest Research Integration

### Key Breakthroughs This Quarter

1. **Memory Consolidation Maturity**: Production systems now recognize that consolidation is more important than storage. AgentDock shows 60-80% storage reduction through automated deduplication.

2. **Autonomous Compression**: Focus Agent demonstrates that models can self-regulate context with 22.7% token savings while maintaining accuracy. This enables agent-driven rather than heuristic-based compression.

3. **Multi-Channel Retrieval**: SuperLocalMemory's 7-channel approach outperforms single-vector retrieval by combining semantic, graph, temporal, and associative pathways.

4. **Ebbinghaus Mathematics**: Forgetful memory systems now use formal mathematical models (R(t) = e^(-t/S(m))) rather than heuristic approaches, enabling predictable decay profiles.

5. **CrewAI Memory Unification**: The move from 4 separate memory types to a single LLM-driven system shows the field converging on simpler, more powerful architectures.

### Implementation Strategy for Hermes

Phase 1 (Immediate - 1-2 weeks):
1. Implement P4 (Progressive skill disclosure) - Quick win
2. Implement P2 (Ebbinghaus forgetting) - Medium effort, high impact

Phase 2 (Short-term - 3-4 weeks):
1. Implement P1 (Consolidation pipeline) - Prevents memory bloat
2. Implement P6 (Memory scoping) - Improves relevance

Phase 3 (Medium-term - 5-8 weeks):
1. Implement P5 (Active compression) - Self-regulating context
2. Plan P3 (7-channel retrieval) - Major architectural change

### Hermes-Specific Optimizations

1. **Leverage existing SQLite infrastructure**: Build on session_search rather than replacing it
2. **Preserve file-based skills**: Don't move skills to database, optimize injection instead
3. **Incremental adoption**: Each improvement should work standalone before composition
4. **Hermes-specific forgetting**: Prioritize decay for tool outputs, preferences, and temporary facts
5. **Cross-platform scope isolation**: Separate Telegram/CLI/Slack memories automatically
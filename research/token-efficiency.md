# Token Efficiency Research

## Status: Active (Deep Research — 2026-04-13)

## Current Architecture
- **Prompt caching**: Anthropic static system prompts (~80% input token savings)
- **Context compression**: Gemini Flash summarizes middle turns at 85% threshold
- **Model routing**: Manual selection via /model, auto for some tasks
- **Tool result truncation**: Large outputs summarized before appending

### Token Budget Breakdown (Typical Turn)
```
System Prompt (cached)         ~4,000 tokens   (first turn only)
Memory + Skills List           ~2,000 tokens   (every turn)
Conversation History            varies          (grows over time)
Tool Results                    varies          (can be very large)
User Message                    ~100-500 tokens
─────────────────────────────────────────────────
Total per turn:                 ~6,000-50,000+ tokens
```

---

## Research Findings (2026-04-13 Deep Dive)

### 1. Adaptive Model Routing

#### Key Papers
| Paper | Key Result |
|-------|-----------|
| **RouteLLM** (ICLR 2025, arXiv:2406.18665) | **85% cost reduction** at 95% GPT-4 quality. MF router adds only **6.4ms** latency. 155 req/s on single GPU. |
| **AgentCompress** (Jan 2026, arXiv:2601.05191) | 2.37M param controller predicts complexity from first 32 tokens. **68.3% cost reduction**, 96.2% success rate. 12ms overhead. |
| **Unified Routing & Cascading** (ICML 2025, arXiv:2410.10347) | Unified framework combining routing + cascading. Optimal strategies derived. |
| **Routing Game Theory** (Feb 2026, arXiv:2602.09902) | Static thresholds often outperform dynamic cascading in practice. |

#### RouteLLM Deployment Details
- **MF router** = single matrix multiplication. 155 req/s, ~$3.32/million routing decisions.
- Drop-in OpenAI client replacement.
- Pre-trained on Chatbot Arena data, generalizes across model pairs without retraining.
- GitHub: lm-sys/RouteLLM (4,774 stars)

#### For Hermes: **Priority 2 — Should-Have**
- **Implementation**: Use RouteLLM MF router or similar lightweight classifier to route subagent tasks to appropriate models. Simple tasks → cheap models. Complex reasoning → capable models.
- **Expected impact**: 40-85% cost reduction on inference.
- **Complexity**: Medium — requires integration with provider dispatch layer.
- **First step**: Implement a simple heuristic router (regex/keyword complexity scoring) as baseline, then upgrade to MF classifier.

---

### 2. Schema/Tool Pruning

#### Key Papers
| Paper | Key Result |
|-------|-----------|
| **ITR: Instruction-Tool Retrieval** (Dec 2025, arXiv:2602.17046) | **95% per-step token reduction** (30K→1.5K tokens). **70% episode cost reduction.** Dual encoder + BM25 retrieval. |
| **SkillReducer** (Mar 2026, arXiv:2603.29919) | **48% description + 39% body compression** of 55K skills. **2.8% quality improvement** (less-is-more). Delta-debugging approach. |
| **When2Call** (NAACL 2025, arXiv:2504.18851) | Teaching LLMs when NOT to call tools — reduces unnecessary tool calls. |
| **Tool Optimization** (ACL 2025) | Joint optimization of instructions + tool descriptions reduces incomplete context. |

#### Anthropic Tool Search + `defer_loading` (Nov 2025)
- **Beta header**: `advanced-tool-use-2025-11-20`
- `defer_loading: true` on tool definitions → tools stay out of context until discovered via search
- Supports up to **10,000 tools** in catalog, returns 3-5 per search
- **Preserves prompt caching** — discovered tools append as `tool_reference` blocks, prefix untouched
- Available on Sonnet 4+, Opus 4+ (no Haiku)
- Claude Code implementation: `ENABLE_TOOL_SEARCH=auto` activates when tool defs exceed 10% of context

#### SkillReducer Technique (Directly Applicable)
1. **Routing descriptions**: Delta-debugging finds the 1-minimal subset of clauses needed for correct skill matching. Average 48% shorter.
2. **Body restructuring**: Taxonomy-driven classifier separates "actionable core rules" from "examples/background/templates". Core always loaded, supplementary on-demand.
3. **"Less-is-more" effect**: Removing noise from skills actually IMPROVES agent performance by 2.8%.

#### For Hermes: **Priority 1 — Must-Have**
- **Implementation**: Apply SkillReducer principles to existing skills. Truncate routing descriptions to essential clauses. Restructure bodies into core + supplementary sections.
- **Expected impact**: ~48% skill description reduction, ~39% skill body reduction. Net savings of ~800-1,000 tokens/turn from skills list alone.
- **Complexity**: Low — build-time preprocessing, no runtime changes.
- **Also**: Implement progressive disclosure — inject YAML frontmatter only (~80 tokens/skill), full content on demand via `skill_view()`.

---

### 3. Prompt Caching Optimization

#### Provider Comparison
| Feature | Anthropic | OpenAI | Google Gemini |
|---------|-----------|--------|---------------|
| **Cost Savings** | **90%** on cached reads | **50%** on cached tokens | **90%** cached reads |
| **Min Tokens** | 1,024 (most models) | 1,024 | 1,024 implicit |
| **Cache TTL** | 5min default, **1hr** at 2× write cost | Auto, provider-managed | Default 1hr |
| **Max Breakpoints** | 4 per request | Auto | Auto |

#### Anthropic Best Practices
1. **Static prefix, dynamic suffix**: System prompt → tool definitions → cached context → user messages
2. **4-level cache hierarchy**: Core system → project context → session data → current turn
3. **Extended 1-hour TTL**: `cache_control: {"type": "ephemeral", "ttl": "1h"}` for long-running agents
4. **`defer_loading` preserves cache**: Deferred tools don't modify prefix
5. **Monitor**: Track `cache_creation_input_tokens` vs `cache_read_input_tokens`

#### Strata (arXiv:2508.18572)
- Hierarchical context caching built on SGLang
- **5× lower TTFT** vs vLLM+LMCache
- GPU-assisted I/O for KV cache fragmentation

#### For Hermes: **Priority 1 — Must-Have**
- **Implementation**: Structure prompts as static-prefix + dynamic-suffix. Use 4 cache breakpoints. Enable 1-hour TTL for cron sessions.
- **Expected impact**: Already partially implemented. Optimizing could save additional 10-20% input token cost.
- **Complexity**: Low — prompt structure refactoring.

---

### 4. Context Compression

#### Key Papers
| Paper | Key Result |
|-------|-----------|
| **ACON** (Oct 2025, arXiv:2510.00615) | **26-54% token reduction**, 95% accuracy preserved with distilled compressors. Microsoft. |
| **AgentDiet** (Sep 2025/FSE 2026, arXiv:2509.23586) | **40-60% input token reduction**, **21-36% total cost reduction**. External reflection module identifies useless/redundant/expired info. |
| **ComprExIT** (Feb 2026, arXiv:2602.03784) | Soft context compression with ~1% additional parameters. SOTA on 6 QA benchmarks. |
| **LLMLingua** (Microsoft, 6K stars) | Up to **20× prompt compression**. LLMLingua-2 uses 355M XLM-RoBERTa, ~0.3s latency. |

#### AgentDiet: Trajectory Pruning
Identifies three waste types in agent trajectories:
1. **Useless**: Irrelevant data (cache files, verbose outputs, boilerplate)
2. **Redundant**: Same file viewed multiple times, repeated search results
3. **Expired**: Old file contents after edits, files examined during search after target found

Implementation: External `LLMreflect` (cheaper model like GPT-5 mini) processes completed steps:
- Only reduces if step is ≥500 tokens AND savings ≥θ tokens
- 2-step delay before reducing (allows context to settle)
- 40-60% input token reduction, no performance degradation

#### Anthropic Native Compaction (Jan 2026)
- Beta header: `compact-2026-01-12`
- Auto-triggers at 150K input tokens (configurable down to 50K)
- **58.6% token reduction** demonstrated
- Server-side — zero implementation effort for Anthropic users

#### For Hermes: **Priority 1 — Must-Have**
- **Implementation A (easy)**: Tool result pruning — after each tool call, trim output to essential fields. Remove boilerplate, cache files, verbose listings.
- **Implementation B (medium)**: AgentDiet-style trajectory reflection — periodically (every 5+ turns) compress older tool results by removing useless/redundant/expired content.
- **Expected impact**: 40-60% token reduction in conversation history.
- **Complexity**: Low for A, Medium for B.

---

### 5. Dynamic Context Management

#### Key Papers & Sources
| Source | Key Finding |
|--------|-------------|
| **Anthropic Tool Search** (Nov 2025) | Lazy-load tools on demand. 85%+ context reduction for tool-heavy agents. |
| **ITR Paper** (Dec 2025) | Budget-aware selector with confidence-gated fallbacks. 95% per-step reduction. |
| **Context Engineering Guide** | Lazy loading reduces 12K→4.5K tokens. **60% cost reduction** reported. |
| **Dynamic Context Loading** (GitHub) | 3-level progressive loading: descriptions → summaries → full tools. Works with MCP + litellm. |

#### Framework Overhead Comparison
| Framework | Token Overhead | Notes |
|-----------|---------------|-------|
| **LangGraph** | **+9%** | State delta passing. Best efficiency. |
| **CrewAI** | **+18%** | Per-agent system prompts. Full context sharing. |
| **AutoGen** | **+31%** | Conversational coordination. 22.7 avg LLM calls/task. |

#### Practical Techniques for Single-Agent Systems
1. **Lazy Context Loading**: Start with ~500 tokens baseline. Agent requests context on demand.
2. **Tool Search + defer_loading**: Keep 3-5 frequently-used tools loaded, defer the rest.
3. **Multi-Level Context Tiers**: Level 1 = high-level descriptions (always). Level 2 = detailed summaries (on demand). Level 3 = full content (when needed).
4. **Smart Windowing**: Recent N messages verbatim. Older messages summarized. Critical decisions preserved.
5. **Return-Value Trimming**: Tool results return only relevant fields, not full API responses.
6. **RAG for Knowledge**: Never stuff everything in context. Vector search → top-K per step.

#### For Hermes: **Priority 1 — Must-Have**
- **Implementation**: Progressive skill loading (already proposed in memory research). Tier 1 = YAML frontmatter only. Tier 2 = full skill on demand.
- **Expected impact**: ~1,200 chars/turn savings from progressive skill disclosure.
- **Complexity**: Low — changes to skill injection in system prompt.

---

## Concrete Improvement Proposals

### Must-Have (Priority 1) — Low Complexity, High Impact

| # | Improvement | How | Impact | Complexity |
|---|------------|-----|--------|------------|
| P1 | **Progressive Skill Loading** | Inject YAML frontmatter only (~80 tokens/skill), full content via `skill_view()` | ~1,200 chars/turn saved | Low |
| P2 | **Tool Result Pruning** | Trim tool outputs to essential fields. Remove boilerplate, cache files, verbose listings. | 30-50% tool result reduction | Low |
| P3 | **Skill Description Optimization** | Apply SkillReducer principles: delta-debug routing descriptions to 1-minimal subsets. Core rules always loaded, examples on-demand. | ~48% description + ~39% body compression | Low |
| P4 | **Prompt Cache Hierarchy** | 4-level cache structure: core system → project context → session data → current turn. Enable 1-hour TTL for cron. | 10-20% additional input cost savings | Low |

### Should-Have (Priority 2) — Medium Complexity, High Impact

| # | Improvement | How | Impact | Complexity |
|---|------------|-----|--------|------------|
| P5 | **AgentDiet Trajectory Compression** | External reflection module identifies useless/redundant/expired tool results. Compress every N turns. | 40-60% conversation history reduction | Medium |
| P6 | **Model Routing** | RouteLLM MF classifier or heuristic router. Simple tasks → Haiku/Flash. Complex → Sonnet/Opus. | 40-85% cost reduction | Medium |
| P7 | **Dynamic Tool Loading** | For MCP-heavy sessions, implement tool search + defer_loading. Load only relevant tools per turn. | 85%+ tool context reduction (when >20 tools) | Medium |

### Nice-to-Have (Priority 3) — Higher Complexity

| # | Improvement | How | Impact | Complexity |
|---|------------|-----|--------|------------|
| P8 | **LLMLingua Prompt Compression** | Compress system prompts, documentation, few-shot examples with LLMLingua-2 (355M model). | Up to 20× compression on static content | High |
| P9 | **ACON Distilled Compressor** | Train small compressor model for Hermes-specific context compression. | 26-54% token reduction, 95% accuracy | High |
| P10 | **Speculative Tool Calls** | Overlap tool execution with LLM generation. | Up to 196 tok/sec throughput improvement | High |

---

## Original Research Questions (Updated)

1. **Adaptive model routing** — ✅ RouteLLM achieves 85% cost savings at 6.4ms overhead. Simple static thresholds also effective per game-theory paper.
2. **Schema pruning** — ✅ ITR achieves 95% per-step reduction. Anthropic's `defer_loading` handles it natively. SkillReducer shows less-is-more.
3. **Lazy skill loading** — ✅ Progressive disclosure: frontmatter only → full content on demand. Complementary to memory research proposals.
4. **Memory compression** — ✅ AgentDiet identifies useless/redundant/expired content. 40-60% reduction achievable.
5. **Streaming optimization** — Not deeply researched; speculative tool calls (PASTE) could help.

## References

### Papers
- RouteLLM (arXiv:2406.18665) — LLM routing with preference data
- AgentCompress (arXiv:2601.05191) — Task-aware compression, 68.3% cost reduction
- ITR (arXiv:2602.17046) — Instruction-tool retrieval, 95% per-step reduction
- SkillReducer (arXiv:2603.29919) — Skill debloating, 48%+39% compression
- AgentDiet (arXiv:2509.23586) — Trajectory reduction, 40-60% savings
- ACON (arXiv:2510.00615) — Context optimization, 26-54% reduction
- LLMLingua (github.com/microsoft/LLMLingua) — Up to 20× compression
- Strata (arXiv:2508.18572) — Hierarchical context caching
- ComprExIT (arXiv:2602.03784) — Soft context compression

### Implementations
- RouteLLM: github.com/lm-sys/RouteLLM (4,774 stars)
- LLMLingua: github.com/microsoft/LLMLingua (6,000 stars)
- LLMRouter: github.com/ulab-uiuc/LLMRouter (1,634 stars)
- Dynamic Context Loading: github.com/CefBoud/DynamicContextLoading

### Provider Docs
- Anthropic Tool Search: docs.anthropic.com/en/docs/agents-and-tools/tool-use/tool-search-tool
- Anthropic Compaction: docs.anthropic.com/en/docs/build-with-claude/compaction
- Anthropic Caching: docs.anthropic.com/en/docs/build-with-claude/prompt-caching

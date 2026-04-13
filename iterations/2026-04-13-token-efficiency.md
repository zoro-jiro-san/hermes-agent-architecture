# Nightly Iteration — April 13, 2026

## Focus Area: Token Efficiency

Rotation position: #3 of 5 (Orchestration → Memory → **Token Efficiency** → Agentic Payments → Skill Evolution)

---

## Research Conducted

### Deep Dive: LLM Token Efficiency for AI Agents (2025-2026)

**Duration:** ~90 minutes | **Sources:** 30+ web searches across papers, GitHub repos, provider docs, framework comparisons

#### Papers Analyzed (10)
1. **RouteLLM** (ICLR 2025) — 85% cost reduction via MF routing classifier at 6.4ms overhead. Pre-trained on Chatbot Arena data.
2. **AgentCompress** (Jan 2026) — 2.37M param controller predicts complexity from first 32 tokens. 68.3% cost reduction, 96.2% success rate.
3. **ITR: Instruction-Tool Retrieval** (Dec 2025) — 95% per-step token reduction (30K→1.5K). 70% episode cost reduction. Dual encoder + BM25.
4. **SkillReducer** (Mar 2026) — Delta-debugging skill debloating. 48% description + 39% body compression. **2.8% quality improvement** (less-is-more).
5. **AgentDiet** (Sep 2025/FSE 2026) — 40-60% trajectory token reduction via external reflection module. Identifies useless/redundant/expired info.
6. **ACON** (Oct 2025, Microsoft) — 26-54% token reduction. Distilled compressors preserve 95% accuracy.
7. **LLMLingua** (Microsoft, 6K stars) — Up to 20× prompt compression. LLMLingua-2 uses 355M XLM-RoBERTa.
8. **Strata** (Aug 2025) — Hierarchical context caching. 5× lower TTFT vs vLLM+LMCache.
9. **ComprExIT** (Feb 2026) — Soft context compression with ~1% additional parameters.
10. **Routing Game Theory** (Feb 2026) — Static thresholds often outperform dynamic cascading in practice.

#### Frameworks Evaluated
| Framework | Token Overhead | Notes |
|-----------|---------------|-------|
| LangGraph | +9% | Best efficiency. State delta passing. |
| CrewAI | +18% | Per-agent system prompts. |
| AutoGen | +31% | Conversational coordination. |

#### Provider Caching Comparison
| Provider | Max Savings | TTL | Min Tokens |
|----------|-----------|-----|-----------|
| Anthropic | 90% | 5min-1hr | 1,024 |
| OpenAI | 50% | Auto | 1,024 |
| Gemini | 90% | 1hr | 1,024-32K |

#### Anthropic New Features Discovered
- **Tool Search + defer_loading** (Nov 2025): Lazy-load up to 10,000 tools. 85%+ tool context reduction. Preserves prompt cache.
- **Native Compaction** (Jan 2026): Server-side context compression at 150K token threshold. 58.6% reduction. Zero implementation effort.

---

## Concrete Proposals (10 improvements)

### Must-Have (4) — Low complexity, high impact
1. **P1: Progressive Skill Loading** — Inject YAML frontmatter only (~80 tokens/skill), full content via skill_view(). ~1,200 chars/turn saved. Low complexity.
2. **P2: Tool Result Pruning** — Trim outputs to essential fields. Remove boilerplate, cache files, verbose listings. 30-50% tool result reduction. Low complexity.
3. **P3: Skill Description Optimization** — Apply SkillReducer delta-debugging to routing descriptions. Separate core rules from examples. 48%+39% compression + quality improvement. Low complexity.
4. **P4: Prompt Cache Hierarchy** — 4-level cache: core system → project context → session data → current turn. Enable 1-hour TTL for cron sessions. 10-20% additional input savings. Low complexity.

### Should-Have (3) — Medium complexity, high impact
5. **P5: AgentDiet Trajectory Compression** — External reflection module compresses older tool results by identifying useless/redundant/expired content. 40-60% history reduction. Medium complexity.
6. **P6: Model Routing** — RouteLLM MF classifier or heuristic router. Simple tasks → Haiku/Flash, complex → Sonnet/Opus. 40-85% cost reduction. Medium complexity.
7. **P7: Dynamic Tool Loading** — Tool search + defer_loading for MCP-heavy sessions. 85%+ tool context reduction when >20 tools. Medium complexity.

### Nice-to-Have (3) — Higher complexity
8. **P8: LLMLingua Prompt Compression** — Compress static prompts with 355M XLM-RoBERTa. Up to 20× compression. High complexity.
9. **P9: ACON Distilled Compressor** — Train small compressor for Hermes-specific context. 26-54% reduction, 95% accuracy. High complexity.
10. **P10: Speculative Tool Calls** — Overlap tool execution with LLM generation. 196 tok/sec throughput. High complexity.

---

## Key Insights

1. **The biggest wins are the simplest**: Progressive skill loading, tool result pruning, and prompt cache structuring are all low-complexity changes that collectively save 40-60% of tokens per turn. No model training or infrastructure changes needed.

2. **"Less-is-more" is quantitatively proven**: SkillReducer showed that removing noise from skills IMPROVES performance by 2.8%. This validates aggressive pruning — verbose instructions hurt, not help.

3. **Tool schemas are the silent token sink**: ITR showed 30,000 tokens in tool schemas being reduced to 1,500 with no quality loss. For Hermes with 40+ skills, this is likely 2,000-5,000 tokens of overhead per turn that could be eliminated.

4. **AgentDiet's insight: agents can't self-compress effectively**: The reflection module MUST be external (a cheaper model reviewing the trajectory). The agent itself can't judge what's expired because it's too close to the work. This has implications for our conversation history management.

5. **Static routing beats dynamic routing**: The game-theory paper found that simple threshold-based routing ("if tokens < X, use cheap model") often outperforms complex cascading. Don't over-engineer the router.

6. **Anthropic's native features are underutilized**: Tool Search + defer_loading and server-side compaction are available now with zero implementation effort. These should be enabled before building custom solutions.

---

## Cross-Reference with Memory Research (2026-04-11)

Several token efficiency proposals complement the memory management findings:
- **P1 (Progressive Skill Loading)** directly implements "P7: Progressive Skill Disclosure" from the memory research.
- **P2 (Tool Result Pruning)** is the runtime complement to memory decay — expired tool results should be pruned from conversation history, not just memory.
- **P5 (AgentDiet Trajectory Compression)** provides the mechanism for "P2: Anchored Iterative Summarization" — compressing history while preserving anchors.

---

## Files Updated
- `research/token-efficiency.md` — Complete rewrite with deep research findings, 10 papers, provider comparisons, 10 concrete proposals
- `iterations/2026-04-13-token-efficiency.md` — This file

---

*Iteration by Toki — 2026-04-13*

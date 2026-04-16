# Hermes Agent Token Optimization Audit

Date: 2026-04-16
Model: glm-4.7 (Z.AI)
Auditor: Hermes Agent

## Current Token Burn Rate

From logs (~80K tokens per session before 429):
- Session 20260416_103403_f39725: 235 messages, ~80,224 tokens, hit 429
- Session 20260416_115300_a004a2: 236 messages, ~80,269 tokens, hit 429
- Rate limit: Z.AI 5-hour window, reset at 21:00:41

## Current Optimization Stack

### Active ✅
1. **Context Compression** (agent/context_compressor.py)
   - Threshold: 50% of context length
   - Protect: first 3 messages, last 20 messages
   - Summary: 20% of compressed content, 5% max of context
   - Tail budget: token-based, not fixed count
   - Tool pruning: replace old results with placeholder
   - Iterative summaries: preserves info across compactions

2. **Prompt Caching** (agent/prompt_caching.py)
   - Anthropic only (system_and_3 strategy)
   - 4 breakpoints: system + last 3 non-system messages
   - Cache TTL: 5m (ephemeral)

3. **Auxiliary Compression**
   - Active: using auto (glm-5.1)
   - Endpoint: https://api.z.ai/api/coding/paas/v4/

4. **Session Splits**
   - Auto-split on compression
   - Handoff with summary prefix

## Issues Found

### 1. MEDIUM — Prompt Caching Not Used on Z.AI

**Problem**: prompt_caching.py only applies cache_control for Anthropic models. Z.AI (glm-4.7, glm-5.1) bypasses this entire optimization.

**Impact**: Missing ~75% cost reduction on multi-turn conversations.

**Fix**: Extend caching to Z.AI if supported. Check Z.AI API docs for cache_control equivalent.

### 2. MEDIUM — No Token Budget Enforcement

**Problem**: compression.threshold triggers at 50% but no hard token budget per session. Rate limit (429) hits at ~80K tokens regardless of model cost.

**Impact**: Z.AI 5-hour limit reached in single session.

**Fix**: Add per-session token budget tracking. Warn at 50K, pause at 70K before hard limit.

### 3. LOW — Compression Summary Model Not Cheapest

**Problem**: summary_model = google/gemini-3-flash-preview. Z.AI has cheaper models (glm-4-air, glm-4-mini) or even OpenRouter free tiers.

**Impact**: Each compression costs more than necessary.

**Fix**: Use cheaper model or free tier for summaries.

### 4. LOW — Tool Output Pruning Too Aggressive

**Problem**: _PRUNED_TOOL_PLACEHOLDER = "[Old tool output cleared to save context space]". Placeholder length: 64 chars. If tool result was 200 chars, only saves 136 tokens.

**Impact**: Minimal savings, loses context.

**Fix**: Increase threshold from 200 to 500 chars before pruning. Or add brief one-line summary of tool result.

### 5. LOW — No Deduplication of File Reads

**Problem**: Reading same file multiple times in session adds content each time.

**Impact**: Duplicates context, burns tokens.

**Fix**: Cache file reads in session state. Return "[Already read, see above]" if seen before.

### 6. LOW — Memory Injection Every Turn

**Problem**: MEMORY.md + USER.md injected at every turn. Even if unchanged.

**Impact**: ~2K tokens per turn for redundant content.

**Fix**: Check if memory changed since last injection. Only inject if diff > 100 chars.

### 7. LOW — Tool Schemas Always Full

**Problem**: Full tool definitions sent every request. 19 tools × ~200 tokens each = ~3,800 tokens per turn.

**Impact**: Huge overhead, especially for simple queries.

**Fix**: Cache tool schemas. Send delta only when toolset changes (rare).

### 8. LOW — Session Split Frequency

**Problem**: Splits happen at compression threshold (~50% of context). Each split requires full system prompt + memory injection again.

**Impact**: Splits amplify token burn due to re-injection overhead.

**Fix**: Increase threshold to 70% or implement soft split (warn first, hard split only at 80%).

## Optimization Opportunities

### High Impact
1. **Implement token budget enforcement** — Prevent hitting rate limits
2. **Enable prompt caching for Z.AI** — If API supports it
3. **Cache tool schemas** — Save ~3,800 tokens per turn

### Medium Impact
4. **Deduplicate file reads** — Cache per session
5. **Lazy memory injection** — Only if changed
6. **Use cheapest summary model** — Switch to glm-4-mini

### Low Impact
7. **Increase tool prune threshold** — 500 chars instead of 200
8. **Reduce split frequency** — Threshold 70% instead of 50%

## Caveman Summary

Burn rate: ~80K tokens/session → hits 429 rate limit.
Compression active but Z.AI misses prompt caching (~75% savings).
Tool schemas full every turn (~3,800 tokens waste).
Memory re-injected every turn (redundant 2K tokens).

Fixes needed:
1. Token budget enforcement (warn 50K, pause 70K)
2. Cache tool schemas (send delta only)
3. Deduplicate file reads
4. Lazy memory injection
5. Cheaper summary model
6. Raise compression threshold to 70%

Expected reduction: ~40-60% token burn with all fixes.

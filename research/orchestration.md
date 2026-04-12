# Agent Orchestration Research

## Status: Active

### Current Architecture
- Single agent with tool dispatch (centralized)
- Subagent delegation for parallel tasks (delegate_task)
- Up to 3 subagents in parallel via delegate_task

### Research Questions
1. **Hierarchical vs flat delegation** — When should subagents spawn their own subagents?
2. **Shared context** — How much context should subagents receive? Currently: full context string
3. **Result aggregation** — How to merge conflicting results from parallel subagents?
4. **Failure modes** — What happens when one subagent fails mid-task?

### Ideas to Explore
- [ ] CrewAI-style role-based agent teams
- [ ] AutoGen-style conversation patterns
- [ ] LangGraph-style state machines for complex workflows
- [ ] Anthropic's "agents as tools" pattern
- [ ] Batch processing with model routing

### 2026-04-10 Update: MEV Auction Orchestration Patterns

Insights from Solana MEV research that apply to agent orchestration:

1. **Sealed-bid auction → Model routing**: Jito ranks bundles by tip-per-CU. Analogous pattern: rank LLM models by cost-per-quality-token. Route requests based on expected value density (cheaper models for mechanical work, expensive for reasoning).

2. **BAM's three-layer architecture → Agent tiers**:
   - Layer 1 (BAM Nodes/scheduling) → Hermes orchestration layer (decides which agent handles what)
   - Layer 2 (BAM Validators/execution) → Tool execution layer
   - Layer 3 (BAM Plugins/programmable ordering) → Skill system (customizable behavior)
   
3. **Multi-builder marketplace → Multi-model routing**: Solana is moving from Jito monopoly to Raiku/Paladin competition. Similarly, Hermes should route across multiple providers for resilience and cost optimization.

4. **Sub-second finality targets**: Alpenglow's 150ms finality is a useful UX benchmark. Agent responses should acknowledge within 200ms even if full processing takes longer.

### References
- `open-multi-agent` repo for multi-agent orchestration
- Hermes delegate_tool.py for current implementation
- tools/registry.py for tool dispatch pattern
- Jito BAM architecture (bam.dev/docs)
- "The Bidding Games" (arXiv:2510.14642) — RL for auction optimization

### 2026-04-12 Update: Stigmergic Pressure-Field Coordination

From daydream synthesis: Rodriguez (Jan 2026) showed LLM agents coordinating through shared artifact modification + pressure gradients achieve **48.5% solve rate vs 1.5% for hierarchical orchestration**.

**Key insight for Hermes:** Current subagent delegation (delegate_task) uses explicit context passing. A stigmergic approach would have subagents coordinate through shared filesystem artifacts instead:
- Subagent A writes partial results to a shared file
- Subagent B senses the file state and adjusts its approach
- No direct communication needed — the shared medium IS the coordination

This could be more scalable than explicit message passing, especially for 3+ parallel subagents working on related tasks.

**Reference:** arXiv 2601.08129 — "Emergent Coordination in Multi-Agent Systems via Pressure Fields and Temporal Decay"

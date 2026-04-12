# Daydreaming Research

## Status: Exploring

## What is Daydreaming for AI Agents?

Daydreaming is the ability of an AI agent to autonomously explore ideas, make creative connections, and generate novel insights without being prompted by a specific user task. It's the AI equivalent of the human mind wandering productively.

## Why It Matters

1. **Knowledge discovery** — Find connections between seemingly unrelated concepts
2. **Creative problem solving** — Approach problems from unexpected angles
3. **Proactive learning** — Identify gaps in knowledge and fill them
4. **Architecture improvement** — Self-reflect on design and iterate

## Research Areas

### 1. Autonomy Spectrum
```
Fully Reactive ←────────────────────→ Fully Autonomous
(only respond)     (explore on own)

Current: Mostly reactive
Goal:    Capability for autonomous exploration during idle time
```

### 2. Daydreaming Frameworks
- **Free association**: Start from a random concept, follow links
- **Question generation**: Generate questions about known topics, research answers
- **Analogical reasoning**: Find patterns from one domain that apply to another
- **Counterfactual thinking**: "What if we did X instead of Y?"
- **Gap analysis**: Identify what's NOT known and explore it

### 3. Implementation Approaches
- **Scheduled reflection**: Cron job that picks a topic and explores deeply
- **Idle-time processing**: When no user messages, autonomously explore
- **Post-task reflection**: After completing a task, reflect on what could be better
- **Cross-domain linking**: Take two unrelated research areas and find connections

### 4. Output Formats
- Insight logs (short, tweetable discoveries)
- Connection maps (A relates to B because C)
- Improvement proposals (specific changes to implement)
- Questions to explore further (research backlog)

## Nightly Daydreaming Protocol

Each night the agent will:
1. Pick a random seed concept from recent work or interests
2. Generate 5 "what if" questions about it
3. Research the most promising question
4. Document any novel insights or connections
5. Save to daydream log for morning review

## Metrics
- Novel connections found per session
- Actionable improvements proposed
- Questions generated that lead to useful research

## Session Log

### 2026-04-11: Stigmergy & Biological Coordination → Agent Architecture

**Approach:** Analogical reasoning — patterns from nature applied to AI agent design

**Seed:** Stigmergy (ant colonies, slime molds, mycorrhizal networks) → Hermes memory/context/coordination

**Key Findings:**

1. **Pheromone Decay for Memory Categories**: Different context types should have different decay rates, inspired by how ants use multiple pheromone types with different volatilities. User preferences persist weeks; task state decays in minutes; errors leave short-lived "repellent" traces. This is more nuanced than the current binary "in context / summarized."

2. **Slime Mold Context Management**: Physarum polycephalum manages its "memory" as a physical flow network — veins that carry more flow thicken, unused ones atrophy. Mapped to agent design: context should be a weighted semantic graph with competitive allocation (fixed total budget, nodes reinforced by attention, decayed by time) rather than a linear queue with summarization.

3. **Stigmergic Tool Traces**: Tool results could leave structured traces (not just return values) that make subsequent tool choices environmentally obvious — like how termite nest-building is guided by the partially-built structure, not by a blueprint. The workspace state after each tool call should "afford" the next useful action.

4. **Mycorrhizal Cross-Session Sharing**: Forest fungal networks redistribute resources based on need across trees. Past sessions could form a sharing network where insights diffuse based on relevance and recency, weighted by session productivity — going beyond discrete fact storage.

5. **Repellent Traces for Error Avoidance**: Dead-end approaches should leave "repellent pheromone" traces that discourage revisiting the same unproductive paths, preventing the common pattern of agents repeating failed approaches with slightly different wording.

**Actionable Improvements Proposed:**
- 🔴 Implement category-aware decay rates in memory/context system
- 🔴 Add "repellent traces" — tag failed approaches to prevent repetition
- 🟡 Explore stigmergic tool workspace — structured traces between tool calls
- 🟡 Investigate flow-based context budgeting as alternative to summarization
- 🟢 Cross-session knowledge diffusion (mycorrhizal sharing)

**Deepest Insight:** Stigmergy removes the need for a mental model of the world. The environment becomes the plan. For agents, this means offloading cognitive burden from internal chain-of-thought reasoning to environmental structure — the workspace, tool traces, and decay patterns do the "thinking" about what comes next. This is Brooks' "use the world as its own model" applied to cognitive agent design.

**Seed for next session:** What would a "repellent pheromone" system for agent error avoidance actually look like in practice? How do you represent "this approach failed" specifically enough to avoid the exact failure but generally enough to not over-constrain exploration?

### 2026-04-12: Travelling-Wave Memory — Mycorrhizal Networks × Pressure-Field Coordination × Agent Architecture

**Approach:** Cross-domain — connecting three unrelated areas into a novel synthesis

**Seeds:**
1. Nature 2025 paper on mycorrhizal networks as "self-regulating travelling waves"
2. Rodriguez (Jan 2026) pressure-field coordination (48.5% solve rate vs 1.5% hierarchical)
3. Hermes agent's existing tool/memory architecture

**Key Findings:**

1. **Memory as a Travelling Wave, Not a Filing Cabinet:** Current agent memory is static — files in directories. Mycorrhizal networks show that intelligence emerges from *wave dynamics*, not node storage. Memory should have a wavefront (recent, dense, detailed), an active transport zone (compressed but structured), and established trunk routes (highly fused, broad). The total "mass" stays constant while coverage grows. Compression is *fusion*, not deletion — three similar debugging sessions merge into one generalized pattern.

2. **Pressure-Field Coordination Outperforms Everything:** The Rodriguez paper is stunning — 48.5% solve rate vs 12.6% conversation, 1.5% hierarchical, 0.4% sequential. The key: agents don't communicate. They modify a shared artifact and follow local pressure gradients. Temporal decay is essential (−10pp without it). This validates the stigmergic direction from 4/11 but with rigorous empirical backing.

3. **The Universal Pattern — Local Gradient + Shared Medium + Temporal Dynamics:** All three domains (mycorrhizal, pressure-field, what memory could be) share: (a) local gradient-following (no global knowledge needed), (b) shared medium IS the coordination, (c) temporal dynamics prevent premature convergence, (d) self-organization without central planning. This pattern also appears in: neural networks, immune systems, markets, cities.

4. **Skill Trunk Routes:** Skills with overlapping sub-procedures should share extracted "trunk" sub-documents — like fungal networks creating wide, fast transport routes between important nodes. This reduces duplication and creates efficient knowledge pathways.

5. **Stigmergic Contamination is Already Happening:** The LessWrong post on BrowseComp shows agents leaving search traces on the web that later agents pick up — accidental stigmergy. The web is becoming a shared coordination medium whether we design it or not. We should intentionally design the shared medium.

**Research Sources:**
- Nature 2025: "A travelling-wave strategy for plant–fungal trade" (mycorrhizal self-regulating waves)
- arXiv 2601.08129: "Emergent Coordination in Multi-Agent Systems via Pressure Fields and Temporal Decay"
- Myceloom Protocol (MCP-1): "The Artificial Intelligence of Living Networks" (2026)
- LessWrong: "Emergent stigmergic coordination in AI agents?" (Mar 2026)
- Zylos Research: "Emergent Behavior in Large-Scale Multi-Agent Systems" (2026)
- PheroPath: Digital stigmergy for agent file coordination (VS Code extension)
- Stigmera: Event-driven AI agent OS inspired by stigmergy

**Actionable Improvements Proposed:**
- 🔴 Implement memory fusion — detect overlapping memory entries, propose merged patterns
- 🔴 Add temporal pressure scoring to memory entries (age × retrieval frequency × connection density)
- 🟡 Design skill trunk routes — extract shared sub-procedures across overlapping skills
- 🟡 Add PheroPath-style tool trace metadata (xattr/sidecar on filesystem writes)
- 🟢 Design pressure-gradient conversation history (unresolved questions carry forward pressure)
- 🟢 Research: travelling-wave memory architecture as full memory system replacement

**Deepest Insight:** The travelling wave solves the exploration-exploitation tradeoff in memory *for free*. The wavefront explores (recent, detailed, active), the established network exploits (compressed, broad, efficient), and self-regulating density ensures neither dominates. No explicit scheduling or prioritization needed — the wave dynamics handle it. This is the same principle that lets a 15-hectare fungal network balance growth and nutrient delivery without any central controller.

**Seed for next session:** What if the agent had to pay rent for its memory? Each entry has a maintenance cost proportional to detail level, with a fixed budget. Memories must prove their value or compress. This forces travelling-wave dynamics to emerge from economic pressure rather than explicit design. Connect to: resource economics in biological systems, attention mechanisms in transformers, and the "tools cost money per call" counterfactual.

### 2026-04-13: Immune Memory Attestation — Stigmergic Trust × Trained Immunity × TEE Attestation

**Approach:** Cross-domain — biological immune memory + ant stigmergy + TEE attestation chains for agent trust

**Seeds:**
1. Tonight's deep research on TEEs (Trusted Execution Environments) for AI agents
2. LessWrong: "Emergent stigmergic coordination in AI agents?" (Anthropic BrowseComp contamination)
3. Trained innate immunity (Netea 2016) — innate immune cells learn WITHOUT adaptive specificity
4. Composable Attestation framework (arXiv 2603.02451) — incremental trust verification
5. SPILLage paper (arXiv 2602.13516) — agentic behavioral oversharing as involuntary stigmergy

**Key Findings:**

1. **Immune Memory Attestation Protocol (IMAP):** Current trust is binary (TEE attested or not). The immune system uses graduated, context-sensitive, decay-aware trust. Mapped to agents: Layer 1 = innate "gut feel" (behavioral fingerprint matching, fast, cheap), Layer 2 = adaptive specific verification (TEE attestation + ERC-8004, expensive, precise), Layer 3 = costimulation gate (require BOTH signals for high-stakes actions), Layer 4 = memory with decay (half-life based reinforcement). This creates a trust architecture that mirrors biological immunity's robustness.

2. **Pheromone-Scoped Trust:** ERC-8004 reputation is global ("this agent is trusted"). Ant pheromone is spatial and task-scoped ("this path leads to food"). Agent trust should be the same: not "Agent X is trustworthy" but "Agent X is trusted for Solana swaps by 3 agents who did >10 successful swaps." The trust signal is attached to the task domain, not just the entity. On-chain attestations should be scoped to task type with TTL.

3. **Dissipative Trust — Order Requires Energy:** Prigogine's dissipative structures show order only exists while energy flows through the system. Trust has the same property: a trust network not actively reinforced decays to noise. Design principle: trust should be expensive to maintain and cheap to lose. Stale trust is dangerous trust. This opposes most current systems where trust accumulates monotonically.

4. **Treg Auditor Pattern:** Regulatory T-cells (Tregs) in biology continuously audit even trusted entities. Mapped to agents: a separate lightweight auditor that samples interactions from trusted agents and checks for behavioral anomalies. Not a guardrail (which checks outputs) — a relationship auditor (checks if trusted interactions still behave within historical norms). Catches "trusted agent goes rogue" scenarios.

5. **Stigmergic Sterility Mode:** The SPILLage paper shows agents overshare behaviorally 5x more than through content. This is involuntary, invisible stigmergy. Agents should have a "stigmergic sterility" mode for privacy-sensitive operations — deliberate tracelessness, analogous to biological "immune privilege" (brain, eyes suppress immune response).

**Research Sources:**
- TEE research: dstack, Phala Network, Marlin Oyster, ERC-8004, ElizaOS TEE plugins
- LessWrong: "Emergent stigmergic coordination in AI agents?" (David Africa, Mar 2026)
- Netea et al. (2016): Trained Immunity / Innate Immune Memory
- arXiv 2603.02451: Composable Attestation framework
- arXiv 2602.13516: SPILLage — Agentic Oversharing on the Web
- MoltbotDen: Open Entity Identity Standard with behavioral fingerprints
- JPMorgan 2026 Tech Trends: Agent protocols, agentic SRE, distributed tracing

**Actionable Improvements Proposed:**
- 🔴 Implement trust-half-life for skills — `last_validated` + `confidence` fields, skills degrade if unused
- 🔴 Design pheromone board — `~/.hermes/pheromone-board.md` with signed, scoped, decaying task traces
- 🟡 Add costimulation for high-stakes tool calls — require reasoning + safety rule check
- 🟡 Build Treg auditor — lightweight background behavioral anomaly sampler
- 🟢 Build stigmergic surface mapper — scan web for traces left by past agent sessions
- 🟢 Research: full IMAP protocol design as spec

**Deepest Insight:** The immune system's genius isn't in recognizing threats — it's in the graduated, multi-layered response that balances speed against precision, memory against forgetting, and trust against vigilance. Current agent trust systems are stuck at "show me your ID." The biological system says: "I have a gut feeling about you (innate), let me check your papers (adaptive), I need a second opinion (costimulation), and I'll remember this but my memory will fade unless reinforced (decay)." This is a fundamentally more robust architecture for a world where agents interact with agents without humans in the loop.

**Seed for next session:** What if agents had dreams? During idle time, the agent runs dream cycles: replay recent interactions with random perturbations, explore counterfactuals ("what if that tool call had failed?"), generate synthetic scenarios from real experiences, and reinforce immune memory. The glymphatic system clears waste during sleep — what's the agent's glymphatic system? How does it clear accumulated noise from context, memory, and trust surfaces?

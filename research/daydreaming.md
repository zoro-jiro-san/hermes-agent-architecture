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

# Hermes Agent Architecture

A living, self-improving architecture document for the Hermes AI agent. Updated daily through autonomous research and iteration.

> **Integrated with [Hermes Second Brain](https://github.com/nousresearch/hermes-second-brain)** — an AI-native knowledge management system that compiles raw research into a structured, queryable wiki with GraphRAG.

---

## Overview

Hermes is a multi-modal AI agent that operates across CLI, Telegram, Discord, Slack, and other platforms. This repository tracks its architecture evolution, design decisions, and improvement roadmap.

## Architecture Diagrams

| Diagram | Description |
|---------|-------------|
| [System Overview](diagrams/system-overview.md) | High-level agent architecture with all major components |
| [Orchestrator Pattern](diagrams/orchestrator-pattern.md) | v2: subagent roles, interrupt flow, escalation |
| [Agent Loop](diagrams/agent-loop.md) | Core conversation and tool execution loop |
| [Memory System](diagrams/memory-system.md) | Persistent memory, context management, and session recall |
| [Travelling Wave Memory](diagrams/travelling-wave-memory.md) | Biological memory model: fusion over deletion |
| [Tool Pipeline](diagrams/tool-pipeline.md) | Tool discovery, dispatch, and execution |
| [Multi-Platform Gateway](diagrams/gateway.md) | Telegram, Discord, Slack, WhatsApp adapters |
| [Nightly Pipeline](diagrams/nightly-pipeline.md) | Automated research and self-improvement cron jobs |
| [Security + Sandbox + Disk Hygiene](diagrams/security-ops.md) | Malware scanning, lightweight sandboxing, and low-disk cleanup flow |
| [Skill System](diagrams/skill-system.md) | Skill loading, discovery, and execution |
| [IMAP Trust Protocol](diagrams/imap-trust-protocol.md) | Immune Memory Attestation Protocol for agent trust |
| [Session Compaction](diagrams/session-compaction.md) | Context eviction and anchored summarization when sessions hit the wall |
| [Second Brain Integration](diagrams/second-brain-integration.md) | Daily learnings → skills → graph → wiki compounding loop |

## Second Brain Integration

Hermes integrates with **[Hermes Second Brain](https://github.com/nousresearch/hermes-second-brain)**, an AI-native knowledge management system that implements Andrej Karpathy's **LLM Wiki** pattern. Second Brain acts as Hermes's externalized, compounding knowledge cortex.

### The Compounding Loop

```
Daily Learnings → Skills → Graph → Wiki
     ↓               ↓        ↓       ↓
  New research  Procedural  Entity  Queryable
  arrives       knowledge   graph   documentation
```

1. **Daily Learnings:** New research (papers, articles, repos) is read and ingested
2. **Skill Extraction:** Patterns identified → SKILL.md files generated → symlinked into Hermes
3. **Knowledge Graph:** Entities and concepts extracted; relationships (`uses`, `implements`, `inspired_by`) built
4. **Wiki Compilation:** LLM creates/updates Markdown pages with citations and wikilinks
5. **Query & Synthesis:** Agent/human queries the knowledge base; answers can be saved back as synthesis pages (feedback loop)

### Key Benefits

- **Zero maintenance:** LLM compiles and maintains wiki; humans curate sources only
- **Provenance:** Every claim traces to a raw source file
- **Compounding:** Answers saved from queries enrich the knowledge base
- **Obsidian-native:** Files are Markdown with wikilinks; open in Obsidian for graph view
- **GraphRAG-powered:** Hybrid vector + graph retrieval for accurate, contextual answers

### Automation Schedule

Second Brain operates on a cron schedule integrated with Hermes's nightly pipeline:

- **Daily 3:30 AM:** Research ingest (RSS/arXiv → `raw/`)
- **Daily 4:00 AM:** Wiki compilation (`hermes-brain-compile --incremental`)
- **Daily 4:30 AM:** Graph update (extract edges from new pages)
- **Daily 5:00 AM:** Lint & health check
- **Weekly Sun 6:00 AM:** Deep lint + insights digest (Telegram + email)

See [full architecture](ARCHITECTURE.md#second-brain-integration-pattern) for details.

## Research Areas
## Research Areas

| Area | Status | Notes |
|------|--------|-------|
| [Agent Orchestration](research/orchestration.md) | Active | Multi-agent delegation, parallel task execution |
| [Memory Management](research/memory.md) | Active | Cross-session persistence, context compression, RAG |
| [Token Efficiency](research/token-efficiency.md) | Active | Prompt caching, compression, model routing |
| [Sandboxing](research/sandboxing.md) | Active | Lightweight command isolation for low-disk ARM runtime |
| [Daydreaming](research/daydreaming.md) | Exploring | Autonomous exploration and creative reasoning |
| [Agentic Payments](research/agentic-payments.md) | Planned | Self-managed budgets, payment rails |
| [Skill Evolution](research/skill-evolution.md) | Active | Auto-creation, maintenance, and optimization of skills |

## Daily Iterations

Every day the agent researches improvements and updates this repository. See the [iterations log](iterations/) for daily changes.

## License

MIT

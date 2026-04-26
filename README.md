# Hermes Agent Architecture

[![Second Brain](https://img.shields.io/badge/Second%20Brain-integrated-9cf)](https://github.com/nousresearch/hermes-second-brain)
[![Telemetry Bot](https://img.shields.io/badge/pi--telemetry--bot-included-brightgreen)](https://github.com/tokisaki/pi-telemetry-bot)
[![License](https://img.shields.io/badge/license-MIT-green)]

A living, self-improving architecture document for the Hermes AI agent. Updated daily through autonomous research and iteration.

> **Integrated with [Hermes Second Brain](https://github.com/nousresearch/hermes-second-brain)** — an AI-native knowledge management system that compiles raw research into a structured, queryable wiki with GraphRAG.
> **Device monitoring via [pi-telemetry-bot](https://github.com/tokisaki/pi-telemetry-bot)** — a Telegram bot for Raspberry Pi system telemetry and alerts.

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
|| [Second Brain Integration](diagrams/second-brain-integration.md) | Daily learnings → skills → graph → wiki compounding loop |
|| [Obsidian Sync Flow](diagrams/obsidian-sync-flow.md) | Real-time vault → GitHub synchronization with post-push hooks |
|| [Telegram Telemetry Architecture](diagrams/telegram-telemetry-architecture.md) | Raspberry Pi system monitoring bot and alerting |
|| [Integrated Nightly Loop](diagrams/integrated-nightly-loop.md) | Full timeline of agent + Second Brain nightly jobs |

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
2. **Skill Extraction:** Patterns identified → SKILL.md files auto-generated → symlinked into Hermes
3. **Knowledge Graph:** Entities and concepts extracted; relationships (`uses`, `implements`, `inspired_by`) built
4. **Wiki Compilation:** LLM creates/updates Markdown pages with citations and wikilinks
5. **Query & Synthesis:** Agent/human queries the knowledge base; answers can be saved back as synthesis pages (feedback loop)

### Key Benefits

- **Zero maintenance:** LLM compiles and maintains wiki; humans curate sources only
- **Provenance:** Every claim traces to a raw source file
- **Compounding:** Answers saved from queries enrich the knowledge base
- **Obsidian-native:** Files are Markdown with wikilinks; open in Obsidian for graph view
- **GraphRAG-powered:** Hybrid TF-IDF vector + graph retrieval for accurate, contextual answers
- **Real-time sync:** Obsidian edits automatically pushed to GitHub via inotify watcher (see [Obsidian Sync Flow](diagrams/obsidian-sync-flow.md))

### Integrated Automation & Nightly Loop

Second Brain jobs are fully integrated into Hermes's pipeline (see [Integrated Nightly Loop](diagrams/integrated-nightly-loop.md)):

- **06:30 daily — Compile:** `hermes-brain-compile --incremental` processes new research → updates wiki
- **06:45 daily — Graph:** Wikilink extraction auto-updates `memory/graph.edges.json`
- **07:30 Sun — Digest:** Full lint + weekly insights → Telegram summary

Additional background tasks:
- **Watcher daemon** (`watch_and_push.sh`) watches Obsidian vault → auto-commits & pushes changes
- **Post-push hooks** rebuild TF-IDF index and update graph from wikilinks
- **Telemetry Bot** monitors Raspberry Pi health; alerts pushed to Telegram ([Telemetry Bot architecture](diagrams/telegram-telemetry-architecture.md))

### Skill Auto-Extraction

From research to usable skill in one pipeline:

```
Research article → Pattern detection → SKILL.md auto-gen → Symlink → Hermes skill
```

All skills live in `synthesis/skills/` and are symlinked into `~/.hermes/skills/` instantly. Schema validated before deployment; usage feedback refines future generations.

See [full architecture](ARCHITECTURE.md#second-brain-integration-pattern) for complete details.

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

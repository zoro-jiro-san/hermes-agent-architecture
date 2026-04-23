# Hermes Agent Architecture

A living, self-improving architecture document for the Hermes AI agent. Updated daily through autonomous research and iteration.

---

## Overview

Hermes is a multi-modal AI agent that operates across CLI, Telegram, Discord, Slack, and other platforms. This repository tracks its architecture evolution, design decisions, and improvement roadmap.

## Architecture Diagrams

| Diagram | Description |
|---------|-------------|
| [System Overview](diagrams/system-overview.md) | High-level agent architecture |
| [Orchestrator Pattern](diagrams/orchestrator-pattern.md) | v2: subagent roles, interrupt flow, escalation |
| [Agent Loop](diagrams/agent-loop.md) | Core conversation and tool execution loop |
| [Memory System](diagrams/memory-system.md) | Persistent memory and context management |
| [Tool Pipeline](diagrams/tool-pipeline.md) | Tool discovery, dispatch, and execution |
| [Multi-Platform Gateway](diagrams/gateway.md) | Telegram, Discord, Slack, WhatsApp adapters |
| [Nightly Pipeline](diagrams/nightly-pipeline.md) | Automated research and self-improvement cron jobs |
| [Security + Sandbox + Disk Hygiene](diagrams/security-ops.md) | Malware scanning, lightweight sandboxing, and low-disk cleanup flow |
| [Skill System](diagrams/skill-system.md) | Skill loading, discovery, and execution |
| [IMAP Trust Protocol](diagrams/imap-trust-protocol.md) | Immune Memory Attestation Protocol for agent trust |

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

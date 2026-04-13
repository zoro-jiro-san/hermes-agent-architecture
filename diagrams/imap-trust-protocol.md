# IMAP: Immune Memory Attestation Protocol

**Created:** 2026-04-13  
**Source:** Daydream session — Stigmergic Immune Memory for Autonomous Agents

## Overview

IMAP is a proposed 4-layer trust protocol for agent-to-agent interactions, modeled on the biological immune system. Current trust is binary (attested or not). IMAP provides graduated, context-sensitive, decay-aware trust.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 IMAP Trust Protocol                  │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  Layer 4: Memory Formation & Decay            │  │
│  │  • 30-day half-life on trust memories         │  │
│  │  • Positive interactions reinforce (extend)   │  │
│  │  • Negative interactions rapidly degrade      │  │
│  │  • Context-tagged: domain X ≠ domain Y        │  │
│  └───────────────────────────────────────────────┘  │
│                      ▼                              │
│  ┌───────────────────────────────────────────────┐  │
│  │  Layer 3: Costimulation Gate                  │  │
│  │  • Requires BOTH Layer 1 + Layer 2 signals    │  │
│  │  • If only one: quarantine, observe           │  │
│  │  • Triggers for: financial txns, key sharing  │  │
│  │  • Analog: T-cell B7/CD28 costimulation       │  │
│  └───────────────────────────────────────────────┘  │
│                   ↗        ↖                        │
│  ┌─────────────────┐  ┌─────────────────────────┐  │
│  │  Layer 1:       │  │  Layer 2:               │  │
│  │  INNATE         │  │  ADAPTIVE               │  │
│  │  "Gut Feel"     │  │  "Specific Check"       │  │
│  │                 │  │                         │  │
│  │  • Behavioral   │  │  • TEE attestation      │  │
│  │    fingerprint  │  │  • ERC-8004 identity    │  │
│  │  • Embedding    │  │  • On-chain reputation  │  │
│  │    similarity   │  │  • Composable chains    │  │
│  │  • Fast, cheap  │  │  • Expensive, precise   │  │
│  │  • ~Toll-like   │  │  • ~T-cell receptor     │  │
│  │    receptors    │  │    binding              │  │
│  └─────────────────┘  └─────────────────────────┘  │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  Treg Auditor (Background)                    │  │
│  │  • Samples trusted interactions               │  │
│  │  • Checks behavioral anomalies                │  │
│  │  • Triggers rapid trust degradation on change │  │
│  │  • Separate lineage from primary agent        │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Stigmergic Pheromone Layer (External Trust Memory)

```
Agent A completes task with Agent B
         ↓
Leaves signed pheromone at task location
(signed, scoped attestation on-chain)
         ↓
Other agents "smell" pheromone
(see that trusted agent had positive interaction)
         ↓
Pheromone decays over time (TTL)
         ↓
Multiple reinforcements = stronger signal
(like ant trails with more travelers)
         ↓
Cannot be forged (requires valid attestation chain)

Trust is SPATIAL and TASK-SCOPED, not global:
"Agent X trusted for Solana swaps by 3 agents
 who each did >10 successful swaps"
NOT: "Agent X is trustworthy"
```

## Dissipative Trust Principle

```
Trust without reinforcement → decays to noise (feature, not bug)
Stale trust = dangerous trust

Design principle:
  Trust should be EXPENSIVE to maintain
  Trust should be CHEAP to lose

Opposite of: trust accumulates monotonically
Same as: dissipative structures (Prigogine)
  → Order only exists while energy flows through system
  → Trust only exists while interactions reinforce it
```

## Biological ↔ Agent Mapping

| Biological Concept | Agent Analog | Implementation |
|---|---|---|
| Toll-like receptors (TLRs) | Behavioral fingerprint matching | Lightweight embedding model |
| T-cell receptor binding | TEE attestation + ERC-8004 | dstack + on-chain registry |
| Trained innate immunity | Decaying task-specific trust scores | Half-life confidence scoring |
| B7/CD28 costimulation | Dual-signal verification | Reasoning + safety rule check |
| Memory T-cells | Persistent but decaying attestation | Attestations with TTL |
| Regulatory T-cells (Tregs) | Rogue-agent detection | Background anomaly sampling |
| Immune privilege | Non-attestable operations | Privacy-mode operations |
| Ant pheromone trails | Signed task attestations | On-chain scoped attestations |

## Hermes Implementation Ideas

1. **Trust-Half-Life for Skills** — `last_validated` + `confidence` fields; degrade unused skills
2. **Pheromone Board** — `~/.hermes/pheromone-board.md` with TTL-based trace pruning
3. **Costimulation** — Dual verification for `terminal`/`patch` on sensitive paths
4. **Treg Auditor** — Background process sampling agent actions for anomalies

---

*Diagram created by Toki — 2026-04-13*

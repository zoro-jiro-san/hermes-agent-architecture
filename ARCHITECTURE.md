# Hermes Agent Architecture

**Version:** 2.0  
**Date:** 2026-04-26  
**Status:** Living Document

> A self-improving architecture for a multi-modal, multi-platform AI agent that continuously learns from daily research and evolves its capabilities through automated knowledge compilation.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Overview](#system-overview)
3. [Core Components](#core-components)
4. [Memory & Knowledge Architecture](#memory--knowledge-architecture)
5. [Second Brain Integration Pattern](#second-brain-integration-pattern)
6. [Skill System](#skill-system)
7. [Orchestration & Agent Loop](#orchestration--agent-loop)
8. [Multi-Platform Gateway](#multi-platform-gateway)
9. [Ops & Security Layer](#ops--security-layer)
10. [Automation & Nightly Pipeline](#automation--nightly-pipeline)
11. [Evolution Roadmap](#evolution-roadmap)

---

## Executive Summary

Hermes is a **self-improving autonomous agent** designed to operate across multiple platforms (Telegram, Discord, Slack, CLI) while continuously learning from daily research and evolving its own capabilities. This architecture document is itself a living artifact — updated daily through automated research and iteration.

**Key Properties:**
- **Multi-platform:** Unified message routing across CLI, Telegram, Discord, Slack
- **Self-improving:** Daily research feeds into architecture evolution; this document updates automatically
- **Tool-augmented:** Dynamic tool discovery and execution with safety guardrails
- **Skill-based:** Procedural knowledge modularized as reusable skills
- **Knowledge-compounding:** Integration with Second Brain for persistent, queryable knowledge

**Design Philosophy:**
> Build an agent that can **research its own improvement**, **implement those improvements**, and **verify they work** — closing the loop autonomously.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        HERMES AGENT                             │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  CLI      │  │ Telegram │  │ Discord  │  │  Slack   │       │
│  │  (Rich)   │  │  Bot     │  │  Bot     │  │  Bot     │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │              │             │
│       └──────────────┴──────────────┴──────────────┘             │
│                             │                                    │
│                    ┌────────▼────────┐                          │
│                    │   Gateway /      │                          │
│                    │   CLI Router     │                          │
│                    └────────┬────────┘                          │
│                             │                                    │
│                    ┌────────▼────────┐                          │
│                    │   AIAgent Core  │                          │
│                    │  (run_agent.py) │                          │
│                    │                 │                          │
│                    │  ┌───────────┐  │                          │
│                    │  │ Prompt    │  │                          │
│                    │  │ Builder   │  │                          │
│                    │  └───────────┘  │                          │
│                    │  ┌───────────┐  │                          │
│                    │  │ Context   │  │                          │
│                    │  │ Compressor│  │                          │
│                    │  └───────────┘  │                          │
│                    │  ┌───────────┐  │                          │
│                    │  │ Memory    │  │                          │
│                    │  │ System    │  │                          │
│                    │  └───────────┘  │                          │
│                    │  ┌───────────┐  │                          │
│                    │  │Orchestrator│ │ ← delegates all work to │
│                    │  │  Layer     │ │   specialized subagents │
│                    │  └───────────┘  │                          │
│                    └────────┬────────┘                          │
│                             │                                    │
│                    ┌────────▼────────┐                          │
│                    │  Tool Registry  │                          │
│                    │  (registry.py)  │                          │
│                    └────────┬────────┘                          │
│                             │                                    │
│         ┌───────────────────┼───────────────────┐               │
│         │                   │                   │               │
│    ┌────▼────┐        ┌────▼────┐        ┌────▼────┐          │
│    │ Inbox   │        │  Code   │        │ Research│          │
│    │ Monitor │        │ Reviewer│        │  Agent  │          │
│    │Subagent │        │Subagent │        │Subagent │          │
│    └─────────┘        └─────────┘        └─────────┘          │
│                             │                                    │
│         ┌───────────┬───────┴───────┬───────────┐              │
│         │           │               │           │               │
│    ┌────▼───┐  ┌────▼───┐  ┌───────▼──┐  ┌────▼───┐          │
│    │Terminal│  │  Web   │  │ Browser  │  │ Files  │          │
│    │ Tool   │  │ Tools  │  │ Tool     │  │ Tool   │          │
│    └────────┘  └────────┘  └──────────┘  └────────┘          │
│         ┌───────────┬───────┴───────┐                         │
│         │           │               │                          │
│    ┌────▼───┐  ┌────▼───┐  ┌───────▼──┐                      │
│    │Delegate │  │  MCP   │  │ Execute  │                      │
│    │ Tool    │  │ Client │  │ Code     │                      │
│    └────────┘  └────────┘  └──────────┘                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────┐          │
│  │              LLM Provider Layer                   │          │
│  │  OpenRouter │ Anthropic │ z.ai │ Kimi │ MiniMax  │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                 │
│  ┌──────────────────────────────────────────────────┐          │
│  │              Persistent Storage                    │          │
│  │  Memory │ Skills │ Config │ Sessions │ Cron       │          │
│  └──────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Components

### User Interfaces (Top Layer)

| Interface | Description | Key Features |
|-----------|-------------|--------------|
| **CLI** | Full-featured terminal UI | Rich rendering, prompt_toolkit, skin engine, command history |
| **Telegram Bot** | Real-time messaging | Voice notes, media support, inline keyboards |
| **Discord Bot** | Server-based interaction | Channel management, slash commands |
| **Slack Bot** | Workspace integration | App mentions, thread replies |
| **WhatsApp** | Via Baileys bridge | End-to-end encryption, broadcast lists |

All platforms normalize messages into a unified `Message` schema with `platform`, `user_id`, `content`, `attachments`, and `context`.

### Gateway / Router

- **Platform adapters** normalize incoming messages into internal format
- **Session manager** tracks per-user/per-platform conversation state
- **Command registry** dispatches slash commands to handlers
- **Rate limiting** per platform per user
- **Middleware pipeline** for auth, logging, transformation

### AIAgent Core

The heart of Hermes — orchestrates the conversation lifecycle:

1. **Receive** message from gateway
2. **Build prompt** — assemble context (user profile, agent memory, skills, recent messages)
3. **LLM call** — get response (may include tool calls)
4. **Execute tools** — dispatch via tool registry, capture results
5. **Repeat** until LLM signals completion or max iterations reached
6. **Update memory** — extract learnings, update user profile/agent notes
7. **Return response** — format per platform (Markdown, voice, etc.)

**Subcomponents:**
- **Prompt Builder:** Assembles system prompt with injected memory (user profile, agent memory, skills list). Implements progressive disclosure (only shows frontmatter for skills, loads full details on demand).
- **Context Compressor:** When approaching token budget, compresses middle-turn messages using anchored summarization (preserves intent, decisions, file paths, error messages).
- **Memory System:** Manages user profile (~1,375 chars) and agent memory (~2,200 chars) with decay-based prioritization.
- **Orchestrator Layer:** Never executes tools directly. Parses intent and dispatches to specialized subagents (Inbox Monitor, Code Reviewer, Research Agent, Implementer, Auditor). Handles interrupts, aggregates parallel results, routes escalations.

### LLM Provider Layer

- **Unified interface** to multiple LLM providers (OpenAI-compatible API)
- **Model routing** based on task complexity and token budget:
  - Simple chat → cheaper model (Gemini Flash, Groq)
  - Complex reasoning → high-capability model (Claude Sonnet, GPT-4)
  - Code generation → code-specialized model (Claude Code, Codex)
- **Prompt caching** (Anthropic) for frequently-used system prompts
- **Streaming** with chunked delivery for responsive UX
- **Budget tracking** per user/session

### Persistent Storage

Hermes maintains several persistent data stores:

| Store | Location | Purpose | Format |
|-------|----------|---------|--------|
| **Memory** | SQLite (`~/.hermes/memory.db`) | User profiles, agent notes | Key-value |
| **Skills** | Filesystem (`~/.hermes/skills/`) | Procedural knowledge | Markdown (SKILL.md) |
| **Config** | YAML (`~/.hermes/config.yaml`) | Settings, preferences | YAML |
| **Sessions** | SQLite with FTS5 | Conversation history, searchable | SQLite + FTS5 |
| **Cron** | Crontab + logs | Scheduled jobs, outputs | Cron + plaintext logs |

---

## Memory & Knowledge Architecture

Hermes maintains a **tiered memory system** inspired by recent research (Mem0, Letta, FadeMem):

### Active Memory (Injected Every Turn)

| Memory Type | Max Size | Content | Injection |
|-------------|----------|---------|-----------|
| User Profile | 1,375 chars | Who user is, preferences, credentials, communication style | Every turn |
| Agent Memory | 2,200 chars | Environment facts, tool quirks, lessons learned, project conventions | Every turn |
| Skills List | ~800 chars | Frontmatter summaries of available skills (progressive disclosure) | Every turn |

**Update Rules:**
- After each task, extract **user corrections** (highest priority), **preferences**, **habits**
- Save **environment facts** (paths, configs, API endpoints)
- Save **procedural knowledge** (how to use tool X, common failure modes)
- **Never save:** task logs, temporary state, todo lists

### Long-Term Memory (On-Demand)

- **Session Search:** Full conversation history in SQLite with FTS5 full-text search
  - Recalled via `session_search(query)` function
  - Supports recent sessions and keyword search
  - **Gap:** Current implementation is purely lexical; missing semantic search

### Memory Prioritization (Upcoming)

**Ebbinghaus-style decay:** Each memory entry gets a `strength` score that decays over time: `R(t) = e^(-t/S)` where S increases on each access. Memories below threshold (0.05) auto-prune.

- `last_accessed`, `access_count`, `importance` fields
- Strength computed at injection time; top-N within token budget injected
- **Priority:** Must-have — prevents stale memory accumulation

### Context Compression

**Current:** Auto-summarize middle turns when approaching 85% token threshold.

**Upcoming: Anchored Iterative Summarization**
- Maintain running "anchor document" with: intent, changes_made, decisions_taken, next_steps
- When compressing, only summarize the new dropped span and merge into anchor
- Preserves technical details (file paths, error messages) lost in naive summarization

---

## Second Brain Integration Pattern

### Overview

**Hermes Second Brain** is an AI-native personal knowledge management system that implements Andrej Karpathy's **LLM Wiki** pattern. It serves as Hermes's **externalized, compounding knowledge cortex** — a persistent, queryable knowledge base that grows smarter over time.

> **Integration Philosophy:** Let Hermes Agent focus on **task execution** and **immediate reasoning**, while Second Brain handles **knowledge compilation**, **long-term memory structuring**, and **human-readable documentation**.

### Architecture Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    HERMES SECOND BRAIN                          │
│                                                                 │
│  ┌──────────┐         ┌──────────────┐         ┌───────────┐  │
│  │ Raw      │  Ingest │ Knowledge    │  Query  │   Feedback│  │
│  │ Sources  │ ─────→  │  Graph       │ ─────→  │   Loop    │  │
│  │ (raw/)   │         │ (graph/)     │         │           │  │
│  └──────────┘         └──────┬───────┘         └─────┬─────┘  │
│                              │                        │        │
│                              ▼                        ▼        │
│                       ┌──────────┐             ┌──────────┐   │
│                       │ Wiki     │             │ Synthesis│   │
│                       │ (wiki/)  │             │  Pages   │   │
│                       └──────────┘             └──────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ CLI tools
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    HERMES AGENT                                  │
│  (orchestrates tasks, invokes Second Brain tools as skills)    │
└─────────────────────────────────────────────────────────────────┘
```

### The Daily Learnings → Skills → Graph → Wiki Workflow

This is the **core compounding loop** of Hermes's self-improvement cycle:

```
┌─────────────────────────────────────────────────────────────────┐
│  DAILY COMPOUNDING LOOP                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  STEP 1: Daily Learnings                                        │
│  ─────────────────────                                          │
│  - New research arrives (papers, articles, repos, transcripts) │
│  - Hermes Agent reads, summarizes, extracts key findings       │
│  - Raw sources deposited in Second Brain raw/                  │
│                                                                 │
│  STEP 2: Skill Extraction                                       │
│  ─────────────────────                                          │
│  - Identify patterns that deserve procedural encapsulation     │
│  - Generate SKILL.md files (trigger conditions, steps, pitfalls)│
│  - Symlink into ~/.hermes/skills/ (immediately available)      │
│                                                                 │
│  STEP 3: Knowledge Graph Update                                 │
│  ─────────────────────────────                                  │
│  - Extract entities (people, orgs, tools, frameworks)          │
│  - Extract concepts (patterns, principles, ideas)              │
│  - Build edges: uses, integrates_with, implements, inspired_by │
│  - Store in graph/nodes.json, graph/edges.json                 │
│                                                                 │
│  STEP 4: Wiki Compilation                                       │
│  ─────────────────────                                          │
│  - LLM reads raw sources + existing wiki                       │
│  - Creates/updates entity pages, concept pages, comparisons    │
│  - Adds wikilinks, citations, change logs                      │
│  - Rebuilds index.md (table of contents)                       │
│                                                                 │
│  STEP 5: Query & Synthesis                                      │
│  ─────────────────────                                          │
│  - Agent or human asks question via hermes-brain-query         │
│  - System retrieves relevant pages + graph traversal           │
│  - LLM synthesizes answer with citations                       │
│  - Optional: save answer as synthesis page (feedback loop)     │
│                                                                 │
│  RESULT: Knowledge compounds, relationships form, wiki grows   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Three-Layer Architecture

Second Brain's architecture aligns with proven knowledge management patterns:

#### Layer 1: Raw Sources (`raw/`)

**Immutable**, curated source documents. LLM reads but never writes.

```
raw/
├── articles/         # Blog posts, summaries (Markdown)
├── papers/           # Academic papers (PDF → extracted text)
├── repos/            # GitHub repos (README + file tree)
├── transcripts/      # Voice/video transcripts (Whisper)
├── images/           # Diagrams, charts (with captions)
└── assets/           # Supporting files, data tables
```

**Frontmatter Schema:**
```yaml
---
title: "Original Title"
source_type: "article|paper|repo|transcript"
date_added: "2026-04-25"
original_url: "https://..."
sha256: "abc123..."
tags: ["topic1", "topic2"]
categories: ["research", "engineering"]
ingested_at: "2026-04-25T14:30:00Z"
---
```

#### Layer 2: Compiled Wiki (`wiki/`)

LLM-generated, human-readable Markdown knowledge base. Entirely maintained by AI.

```
wiki/
├── index.md              # Catalog of all pages
├── log.md                # Append-only action history
├── overview.md           # High-level overview
├── AGENTS_SCHEMA.md      # Agent operational guidelines
├── concepts/             # Abstract ideas, principles, frameworks
├── entities/             # Real-world objects (people, orgs, tools)
│   ├── person/
│   ├── organization/
│   ├── software/
│   └── tool/
├── sources/              # Per-source summaries
├── comparisons/          # Comparative analyses
├── synthesis/            # Saved query answers
└── drafts/               # In-progress (auto-cleaned monthly)
```

#### Layer 3: Knowledge Graph (`graph/`)

Structured representation of entities and relationships for GraphRAG queries.

**Node Types:**
- `repo`, `company`, `person`, `tool`, `framework`, `concept`, `pattern`, `tech_stack`, `skill`, `service`

**Edge Types:**
- `uses`, `integrates_with`, `inspired_by`, `part_of`, `extends`, `implements`, `produces`, `targets`, `compatible_with`, `requires`

**Query Modalities:**
- `GRAPH_COMPLETION`: "What tools does Hermes use?" → traverse `uses` edges
- `RAG_COMPLETION`: "Explain GraphRAG" → semantic search over descriptions
- `CYPHER`: Structured graph queries
- `CHUNKS`: Raw source excerpts
- `SUMMARIES`: Aggregate node summaries

### GraphRAG Integration

Second Brain uses **hybrid retrieval** combining vector similarity with graph traversal:

1. **Embed** node labels + descriptions → vector store
2. **Query:** Embed user question → find closest nodes
3. **Traverse** 1-3 hops along edges to expand context
4. **Weigh** results by citation frequency, recency, confidence
5. **Synthesize** answer with citations using LLM

**Benefits:**
- Understands relationships (Hermes → uses → LangChain → implements → RAG)
- Avoids re-discovery: relationships computed once, reused
- 30-40% improvement in recall vs. pure vector search

### CLI Tool Suite

Second Brain exposes three core tools that Hermes can invoke as skills:

#### `hermes-brain-compile` — Wiki Compiler

```bash
# Full recompile from all raw sources
hermes-brain-compile --full

# Incremental: only new/changed sources
hermes-brain-compile --incremental

# Compile specific source
hermes-brain-compile --source raw/articles/new-finding.md

# Dry-run (show changes without writing)
hermes-brain-compile --dry-run
```

**Pipeline:**
1. Hash raw sources → skip unchanged (incremental)
2. LLM extracts entities, concepts, claims
3. Create/update entity/concept pages with citations
4. Build source summary page
5. Detect contradictions → log to `log.md`
6. Rebuild `index.md` from scratch (deterministic)

#### `hermes-brain-query` — Knowledge Query

```bash
# Basic query
hermes-brain-query "What is GraphRAG?"

# Save answer as wiki page (feedback loop)
hermes-brain-query --save "GraphRAG explained" "How does GraphRAG differ from RAG?"

# Graph traversal
hermes-brain-query --cypher "MATCH (t:tool)-[:uses]->(f:framework) RETURN t, f"

# With confidence threshold
hermes-brain-query --min-confidence 0.7 "What are synthetic data risks?"
```

**Output includes:** Answer, cited sources, confidence score, related pages.

#### `hermes-brain-lint` — Health Check

```bash
# Full lint (mechanical + semantic)
hermes-brain-lint --full

# Fast mechanical-only (no LLM)
hermes-brain-lint --fast

# Specific checks
hermes-brain-lint --orphans        # Pages with no inbound links
hermes-brain-lint --broken-links   # [[wikilinks]] to missing pages
hermes-brain-lint --contradictions # Semantic conflicts
hermes-brain-lint --gaps           # High-frequency concepts lacking pages
```

**Exit codes:** 0 (OK), 1 (warnings), 2 (critical), 3 (semantic issues)

### Cron Jobs & Automation

Second Brain runs **automated jobs** to keep knowledge fresh and healthy:

| Schedule | Job | Steps |
|----------|-----|-------|
| **Hourly :15** | Health Check | `hermes-brain-lint --fast`; alert on critical errors |
| **Daily 3 AM** | Research Sync | Pull RSS/arXiv → ingest → compile → update graph → digest email |
| **Weekly Sun 6 AM** | Insight Digest | Full lint → generate insights → Telegram + email |
| **Monthly 1st 2 AM** | Deep Clean | Prune old drafts, compress logs, database VACUUM |

### Obsidian Integration

Second Brain wiki is a fully functional Obsidian vault:

```bash
# Create symlink
ln -s /home/tokisaki/work/synthesis/wiki ~/.hermes/vault

# Open Obsidian: File → Open folder → ~/.hermes/vault
```

** Recommended plugins:**
- **Dataview:** Query pages as database (`TABLE summary FROM "synthesis"`)
- **Graph View:** Visualize entity/concept relationships
- **Templater:** Standardized page templates
- **Obsidian Git:** Auto-commit wiki changes
- **Calendar:** Link daily notes to research sync

**Workflow:**
1. Hermes Agent updates `wiki/` via CLI
2. Obsidian reflects changes live
3. Human explores graph, adds personal notes in `personal/` (agent-excluded)
4. Questions answered; optionally save answers back as synthesis pages

### Skill Symlinking

Hermes Agent loads skills from `~/.hermes/skills/`. Second Brain's canonical skill files live in `synthesis/skills/`. Symlink them:

```bash
cd /home/tokisaki/work/synthesis
./symlink_setup.sh
```

Result:
```
~/.hermes/skills/mlops/obscura/          → synthesis/skills/obscura-ai-obscura/
~/.hermes/skills/autonomous-ai-agents/claude-task-master/ → synthesis/skills/chainyo-claude-task-master/
```

**Benefits:**
- Single source of truth (edit in `synthesis/`, reflected live)
- Zero duplication (same inode, two directory entries)
- Fast iteration (no copy step)

---

## Skill System

### Current State (Hermes Agent)

Hermes maintains **40+ skills** stored as Markdown files in `~/.hermes/skills/`. Each skill defines:

- **Trigger conditions:** When to invoke this skill
- **Prerequisites:** Dependencies, API keys, installations
- **Steps:** Exact commands or code to execute
- **Pitfalls:** Common failure modes and mitigations
- **Verification:** How to confirm success

**Skill lifecycle:**
1. **Storage:** SKILL.md files scanned every turn
2. **Discovery:** Built into system prompt as available capabilities
3. **Loading:** Full content fetched on demand via `skill_view(name)`
4. **Evolution:** Agent patches/creates skills post-task via `skill_manage()`

### Skill Evolution

Research directions for enhancing skill system:
- **Usage tracking:** Counters, success rates, failure patterns
- **Health scoring:** Success × recency × frequency
- **Auto-patching:** Detect failure → fix in same session
- **Deduplication:** Merge overlapping skills
- **Composition:** Skills reference each other, build hierarchies

### Integration with Second Brain

Second Brain **generates skills** from research:

1. **Research ingestion:** Raw research reports analyzed
2. **Pattern extraction:** Capability patterns identified (e.g., "MLOps pipeline", "agent orchestration")
3. **Skill generation:** SKILL.md files created with 5-step implementation plan
4. **Symlink deployment:** Skills instantly available to Hermes Agent
5. **Feedback loop:** Agent usage patterns inform skill refinement

**Example:** Research on "Cognee knowledge engine" → generates `cognee/SKILL.md` → Hermes can invoke cognitive graph reasoning.

---

## Orchestration & Agent Loop

### Multi-Agent Delegation

Hermes uses an **orchestrator pattern** where the core agent **never executes tools directly**:

```
User Message → Orchestrator parses intent → Dispatch to subagent(s) → 
Subagent executes → Result aggregation → Response to user
```

**Subagent roles:**
- **Inbox Monitor:** Processes incoming messages, prioritizes
- **Code Reviewer:** Reviews PRs, suggests improvements
- **Research Agent:** Deep dives on topics, generates summaries
- **Implementer:** Executes code changes, runs tests
- **Auditor:** Security reviews, compliance checks

**Interrupt handling:** User message immediately terminates active subagents.

### Core Agent Loop (run_agent.py)

```
while not done:
    prompt = build_prompt(messages, user_profile, agent_memory, skills)
    response = llm_call(prompt)
    
    if response.contains_tool_calls:
        results = []
        for tool_call in response.tool_calls:
            result = tool_registry.dispatch(tool_call)
            results.append(result)
        # Loop back with results as new message
    else:
        done = True
        final_response = response.content
    
    update_memory(messages, response)
```

**Key mechanisms:**
- **Iteration limit:** Prevents infinite loops
- **Budget tracking:** Token/cost limits per session
- **Context compression:** Auto-summarization at 85% threshold
- **Memory injection:** User profile + agent memory + skills injected every turn

---

## Multi-Platform Gateway

### Adapter Architecture

Each platform (Telegram, Discord, Slack, CLI) implements the `PlatformAdapter` interface:

```python
class PlatformAdapter:
    def connect(self): ...
    def send(self, user_id, message): ...
    def receive(self) -> List[Message]: ...
    def format_response(self, content) -> PlatformSpecificFormat: ...
```

**Gateway responsibilities:**
- Normalize all incoming messages to `Message` schema
- Route slash commands to COMMAND_REGISTRY
- Manage sessions (per user per platform)
- Apply rate limits and authentication
- Translate outgoing responses to platform format (Markdown → Telegram HTML, etc.)

### Session Management

- **Session key:** `{platform}:{user_id}`
- **Session data:** message history, context, budget state, active tools
- **Persistence:** SQLite with per-session tables; FTS5 for search
- **Expiry:** Inactive sessions archived after 30 days

---

## Ops & Security Layer

### Security Operations

**Malware scanning:**
- ClamAV daemon for real-time scanning
- rkhunter + Lynis for rootkit/baseline checks
- Per-file pre-processing for scraped/downloaded artifacts

**Sandboxing:**
- Bubblewrap for lightweight command isolation
- AppArmor profiles for container confinement
- Network egress restrictions for risky operations

**Disk hygiene:**
- Daily cleanup: if safely on GitHub, local temp can be removed
- Maintain < 29GB host disk usage
- Log rotation and compression

### Observability

- **Structured logging:** JSON logs with correlation IDs
- **Metrics collection:** Token usage, latency, error rates (Prometheus)
- **Alerting:** Telegram + email on critical failures
- **Audit trail:** Every tool call, LLM request, file operation logged

---

## Automation & Nightly Pipeline

### Current Nightly Schedule

```
12:00 AM  Deep Research      (new AI/Fintech/Blockchain topic)
1:30 AM   Daydreaming        (creative analogical reasoning)
3:00 AM   Self-Architecture  (improve agent internals)
3:45 AM   Malware Scan       (ClamAV + rkhunter + Lynis)
4:30 AM   News Scrape        (global AI/crypto news)
6:00 AM   Repo Update        (push findings to GitHub)
6:30 AM   Disk Cleanup       (purge local temp, enforce hygiene)
7:00 AM   Hermes Self-Update (run hermes update)
8:00 AM   Morning Summary    (Telegram delivery)
9:00 PM   Daily Learnings    (end-of-day consolidation)
10:00 PM  Repo Reminder      (confirm sync state)
```

### Second Brain Automation Integration

**Augment nightly pipeline with Second Brain jobs:**

| Cron | Job | What it does |
|------|-----|--------------|
| **Daily 3:30 AM** | Research Ingest | Pull RSS/arXiv → place in `raw/` |
| **Daily 4:00 AM** | Wiki Compile | Run `hermes-brain-compile --incremental` |
| **Daily 4:30 AM** | Graph Update | Extract edges from new pages, update `graph/` |
| **Daily 5:00 AM** | Lint & Health | Run `hermes-brain-lint --fast`, alert on critical |
| **Weekly Sun 6:00 AM** | Deep Lint & Digest | Full lint, generate insights summary, send digest |

### Daily Learnings Consolidation

At 9:00 PM, the agent:
1. Reviews all research and interactions from the day
2. Extracts salient learnings into structured format
3. Identifies patterns that merit skill extraction
4. Writes daily log entry to Second Brain `log.md`
5. Commits and pushes to GitHub

This creates a **compounding knowledge artifact** where each day builds on prior days.

---

## Evolution Roadmap

### Phase 1: Knowledge Foundation (Weeks 1-2)

**Goal:** Establish Second Brain as persistent knowledge layer

- [ ] Set up Second Brain directory structure (`raw/`, `wiki/`, `graph/`)
- [ ] Implement `AGENTS.md` schema specification
- [ ] Build basic `hermes-brain-compile` (raw → wiki)
- [ ] Build basic `hermes-brain-query` (wiki search)
- [ ] Create symlink setup script for skill sharing
- [ ] Validate with 3 sample sources

**Deliverable:** Working ingest→compile→query cycle; wiki visible in Obsidian

---

### Phase 2: Graph Integration (Weeks 3-4)

**Goal:** GraphRAG-powered knowledge retrieval

- [ ] Build initial knowledge graph from existing wiki pages
- [ ] Implement `build_edges.py` (extract relationships automatically)
- [ ] Add graph query mode to `hermes-brain-query`
- [ ] Integrate Cognee or NetworkX for graph backend
- [ ] Update compile pipeline to auto-update graph

**Deliverable:** Query "What tools does Obscura use?" returns structured graph results

---

### Phase 3: Automation (Weeks 5-6)

**Goal:** Self-sustaining knowledge pipeline

- [ ] Write cron scripts (`health_check.sh`, `daily_sync.sh`, `weekly_digest.sh`)
- [ ] Implement `hermes-brain-lint` (mechanical + semantic checks)
- [ ] Set up crontab entries and Telegram alerts
- [ ] Configure Obsidian vault with recommended plugins
- [ ] Test full automation cycle

**Deliverable:** Scheduled jobs operational; weekly digest delivered

---

### Phase 4: Integration (Weeks 7-8)

**Goal:** Seamless Hermes + Second Brain unification

- [ ] Hermes Agent invokes Second Brain tools as skills
- [ ] Daily learnings workflow automated (research → skills → graph → wiki)
- [ ] Provenance tracking: every claim cites raw source
- [ ] Contradiction detection and resolution workflow
- [ ] Skill extraction pipeline from research reports

**Deliverable:** Agent can answer queries from compiled knowledge; new research automatically compounds

---

### Phase 5: Scale & Polish (Weeks 9-12)

**Goal:** Production-ready at scale

- [ ] Migrate existing research corpus (24 reports) into Second Brain
- [ ] Populate entity pages from knowledge graph
- [ ] Bulk ingest all 40+ skills into wiki
- [ ] Performance testing at 1000+ sources
- [ ] Cost optimization (caching, batching, cheaper models)
- [ ] User manual and troubleshooting guide
- [ ] Monitoring dashboard (growth metrics, quality indicators)

**Deliverable:** Production system with 1000+ sources, automated, monitored, documented

---

## Current Research Areas

| Area | Status | Focus |
|------|--------|-------|
| **Memory Management** | Active | Decay, compression, retrieval (FadeMem, Mem0, Zep) |
| **Orchestration** | Active | Multi-agent delegation, parallel execution |
| **Token Efficiency** | Active | Prompt caching, progressive disclosure, compression |
| **Sandboxing** | Active | Lightweight isolation, security scanning |
| **Skill Evolution** | Active | Auto-creation, health scoring, composition |
| **Daydreaming** | Exploring | Analogical reasoning, creative gap analysis |

---

## Architecture Diagrams

For detailed diagrams, see `/diagrams/`:

- [System Overview](diagrams/system-overview.md) — High-level component diagram
- [Orchestrator Pattern](diagrams/orchestrator-pattern.md) — Subagent delegation flow
- [Agent Loop](diagrams/agent-loop.md) — Core conversation cycle
- [Memory System](diagrams/memory-system.md) — Tiered memory architecture
- [Travelling Wave Memory](diagrams/travelling-wave-memory.md) — Biological memory model
- [Tool Pipeline](diagrams/tool-pipeline.md) — Tool discovery and execution
- [Multi-Platform Gateway](diagrams/gateway.md) — Telegram, Discord, Slack adapters
- [Nightly Pipeline](diagrams/nightly-pipeline.md) — Automated research and ops
- [Security + Sandbox](diagrams/security-ops.md) — Hygiene and isolation
- [Skill System](diagrams/skill-system.md) — Skill lifecycle
- [IMAP Trust Protocol](diagrams/imap-trust-protocol.md) — Immune Memory Attestation
- [Session Compaction](diagrams/session-compaction.md) — Context eviction strategy

---

## Second Brain: Quick Reference

**Repositories:**
- Hermes Agent Architecture: `github.com/nousresearch/hermes-agent-architecture`
- Hermes Second Brain: `github.com/nousresearch/hermes-second-brain`

**Key Commands:**
```bash
hermes-brain-compile --incremental    # Process new research
hermes-brain-query "question"          # Ask knowledge base
hermes-brain-lint --full               # Health check
```

**Directories:**
- `raw/` — Source documents (immutable)
- `wiki/` — LLM-compiled Markdown (human-readable)
- `graph/` — Knowledge graph (machinereadable)
- `skills/` — Procedural knowledge (symlinked to Hermes)

**Automation:** Cron jobs run daily at 3 AM (sync), hourly :15 (health), weekly Sun 6 AM (digest)

**Obsidian Vault:** `~/.hermes/vault` (symlink to `wiki/`)

---

*This document is a living artifact. Sections are updated daily through autonomous research and iteration. Last updated: 2026-04-26.*

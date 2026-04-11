# System Overview

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
│                    └────────┬────────┘                          │
│                             │                                    │
│                    ┌────────▼────────┐                          │
│                    │  Tool Registry  │                          │
│                    │  (registry.py)  │                          │
│                    └────────┬────────┘                          │
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

## Component Descriptions

### User Interfaces (Top Layer)
- **CLI** — Full-featured terminal interface with Rich, prompt_toolkit, skin engine
- **Telegram Bot** — Real-time messaging with voice, media support
- **Discord Bot** — Server-based interaction
- **Slack Bot** — Workspace integration
- **WhatsApp** — Via Baileys bridge

### Gateway / Router
- Platform adapters normalize messages into unified format
- Slash commands dispatched centrally via COMMAND_REGISTRY
- Session management per platform per user

### AIAgent Core
- Orchestrates the conversation loop: send → receive → tool call → result → repeat
- Manages message history, budget tracking, iteration limits
- Delegates to prompt builder, context compressor, memory system

### Tool Registry
- Central dispatch for all tool calls
- Dynamic tool discovery based on available API keys
- Schema generation for LLM tool definitions

### LLM Provider Layer
- Unified OpenAI-compatible interface to multiple providers
- Model routing based on task complexity and budget
- Prompt caching (Anthropic), streaming responses

### Persistent Storage
- Memory: user profile + agent notes (injected every turn)
- Skills: procedural knowledge in ~/.hermes/skills/
- Config: YAML settings + .env secrets
- Sessions: SQLite with FTS5 full-text search
- Cron: Scheduled jobs with output delivery

### Ops & Security Layer (new)
- Malware scanning scripts (ClamAV daemon + rkhunter + Lynis)
- Per-file pre-processing scan for scraped/downloaded artifacts
- Lightweight sandbox runner (bubblewrap) for risky short-lived commands
- Daily post-push disk cleanup to keep 29GB host lean

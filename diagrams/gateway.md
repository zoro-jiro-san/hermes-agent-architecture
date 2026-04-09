# Multi-Platform Gateway

How Hermes connects to messaging platforms.

```
┌───────────────────────────────────────────────────────────────┐
│                     MESSAGE FLOW                               │
│                                                                │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐          │
│  │Telegr│  │Discor│  │Slack │  │WhatsA│  │Signal│          │
│  │  am  │  │  d   │  │      │  │  pp  │  │      │          │
│  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘          │
│     │         │         │         │         │                │
│     ▼         ▼         ▼         ▼         ▼                │
│  ┌─────────────────────────────────────────────────┐         │
│  │              Platform Adapters                   │         │
│  │  (gateway/platforms/*.py)                        │         │
│  │                                                  │         │
│  │  Each adapter:                                   │         │
│  │  - Connects via bot token / API key              │         │
│  │  - Normalizes messages to unified format         │         │
│  │  - Handles platform-specific features            │         │
│  │    (voice, media, threads, topics)               │         │
│  │  - Acquires scoped lock on connect               │         │
│  └──────────────────────┬──────────────────────────┘         │
│                          │                                     │
│                          ▼                                     │
│  ┌─────────────────────────────────────────────────┐         │
│  │           Gateway Router (run.py)                │         │
│  │                                                  │         │
│  │  1. Receive normalized message                   │         │
│  │  2. Check slash commands → dispatch              │         │
│  │  3. Load/create session for user                 │         │
│  │  4. Call AIAgent.run_conversation()              │         │
│  │  5. Stream response back to platform             │         │
│  └──────────────────────┬──────────────────────────┘         │
│                          │                                     │
│                          ▼                                     │
│  ┌─────────────────────────────────────────────────┐         │
│  │           Session Store (SQLite)                 │         │
│  │                                                  │         │
│  │  - Per-user conversation history                 │         │
│  │  - Platform + user_id as key                     │         │
│  │  - Auto-compression on long sessions             │         │
│  └─────────────────────────────────────────────────┘         │
└───────────────────────────────────────────────────────────────┘
```

## Platform Capabilities

| Feature | Telegram | Discord | Slack | WhatsApp |
|---------|----------|---------|-------|----------|
| Text messages | ✅ | ✅ | ✅ | ✅ |
| Voice messages | ✅ (STT/TTS) | ❌ | ❌ | ✅ |
| Media files | ✅ | ✅ | ✅ | ✅ |
| Slash commands | ✅ | ✅ | ✅ | ❌ |
| Thread/topics | ✅ | ✅ | ✅ | ❌ |
| Long polling | ✅ | Socket | Socket | Baileys |
| Webhook mode | ✅ | ✅ | ✅ | ❌ |

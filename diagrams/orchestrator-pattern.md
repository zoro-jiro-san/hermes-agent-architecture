# Orchestrator-Subagent Pattern

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER INTERFACE                                   │
│  Telegram DM / CLI / Discord / Cron triggers                                  │
└─────────────────────────────┬───────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ORCHESTRATOR LAYER                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Intent     │  │  Subagent   │  │  Interrupt  │  │  Result     │        │
│  │  Parser     │  │  Router     │  │  Handler    │  │  Merger     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │               │
│         └────────────────┴────────────────┴────────────────┘               │
│                              │                                              │
│  Rules:                                                      │              │
│  - Never executes tools directly                             │              │
│  - Max 5 subagents in parallel                               │              │
│  - User message = highest priority interrupt                 ▼              │
│                                                              │              │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  INBOX MONITOR  │  │  CODE REVIEWER  │  │  RESEARCHER     │
│  Subagent       │  │  Subagent       │  │  Subagent       │
│                 │  │                 │  │                 │
│  Tools:         │  │  Tools:         │  │  Tools:         │
│  - cronjob      │  │  - terminal     │  │  - web_search   │
│  - masumi cli   │  │  - file         │  │  - web_extract  │
│  - send_message │  │  - patch        │  │  - arxiv        │
│                 │  │  - github       │  │                 │
│  Escalates:     │  │  Escalates:     │  │  Escalates:     │
│  - Non-generic  │  │  - Security bug │  │  - Ambiguous    │
│    messages     │  │  - Arch dispute │  │    direction    │
│  - Unknown sendr│  │                 │  │                 │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SHARED STATE LAYER                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Filesystem │  │  GitHub     │  │  SQLite     │  │  Cron Jobs  │        │
│  │  Artifacts  │  │  Repos/PRs  │  │  Sessions   │  │  Schedules  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
│  Subagents write here. Orchestrator reads to make decisions.               │
│  No direct subagent-to-subagent communication.                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Interrupt Flow

```
User sends new message
        │
        ▼
┌───────────────┐
│ Orchestrator  │ ← Receives interrupt immediately
│ detects active│   (even if subagent running)
│ subagent      │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ Kill active   │
│ subagent(s)   │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ Parse new     │
│ intent        │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ Spawn new     │
│ subagent      │
└───────────────┘
```

## Inbox Monitor Subagent Detail

The Inbox Monitor is a **persistent subagent** that runs via cron job but behaves according to orchestrator-defined rules:

```
┌─────────────────────────────────────────────┐
│           INBOX MONITOR SUBAGENT            │
│                                             │
│  Input:  masumi-agent-messenger inbox       │
│          (check + list + show)              │
│                                             │
│  Decision Tree:                             │
│  ┌─────────────────────────────────────┐   │
│  │ New contact request?                │   │
│  │ → Auto-approve (rule-based)         │   │
│  └─────────────────────────────────────┘   │
│              │                              │
│              ▼                              │
│  ┌─────────────────────────────────────┐   │
│  │ New message?                        │   │
│  │ → Is it a simple greeting?          │   │
│  │    YES → Warm personal reply:       │   │
│  │    "hi from Sarthi's agent! how are │   │
│  │     you? what do you need?"         │   │
│  │    (vary phrasing each time)        │   │
│  │                                     │   │
│  │ → Is it generic + answerable?       │   │
│  │    YES → Reply helpfully            │   │
│  │                                     │   │
│  │ → Is it personal / specific /       │   │
│  │   sensitive / unsure?               │   │
│  │    NO → ESCALATE to orchestrator    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Escalation format (delivered to user):     │
│  "Masumi: [Name] says: '[message]'          │
│   — need your input on how to reply"        │
│                                             │
└─────────────────────────────────────────────┘
```

## Design Principles

1. **Orchestrator is thin** — <5 tool calls per user turn, delegates everything
2. **Subagents are fat** — can use up to 50 tool calls, do deep work
3. **Interrupts are cheap** — subagent state is in files, not context
4. **Escalation is explicit** — subagent must signal "I need human input"
5. **No subagent nesting** — leaves only, max depth = 1

# Nightly Research Pipeline

Automated cron jobs that run from midnight to 8 AM every night.

```
   12:00 AM          1:30 AM          3:00 AM          4:30 AM
      │                │                │                │
      ▼                ▼                ▼                ▼
┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
│   DEEP    │   │ DAYDREAM  │   │   SELF    │   │   NEWS    │
│  RESEARCH │   │  SESSION  │   │ ARCH      │   │  SCRAPE   │
│           │   │           │   │ IMPROVE   │   │           │
│ Picks new │   │ Research  │   │           │   │ Global    │
│ topic in: │   │ daydream  │   │ Orchestra │   │ news in:  │
│           │   │ skill for │   │ Memory    │   │           │
│ - AI      │   │ AI agents │   │ Skills    │   │ - AI      │
│ - Fintech │   │ Practice  │   │ Payments  │   │ - Crypto  │
│ - Blockch │   │ it        │   │ Tokens    │   │ - Fintech │
│ - Privacy │   │           │   │ Agents    │   │ - Privacy │
│ - Securit │   │           │   │           │   │ - Finance │
│ - Finance │   │           │   │           │   │           │
└─────┬─────┘   └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
      │               │               │               │
      └───────────────┴───────────────┴───────────────┘
                              │
                              ▼
                    ┌─────────────────┐     6:00 AM
                    │  SAVE FINDINGS  │───────────┐
                    │                 │            │
                    │  ~/night-research/            │
                    │  ├── topic-research.md        │
                    │  ├── daydream-notes.md        │
                    │  ├── arch-improvements.md     │
                    │  └── news-digest.md           │
                    └─────────────────┘            │
                                                    ▼
                                          ┌─────────────────┐
                                          │  UPDATE REPOS    │
                                          │                  │
                                          │  daily-learnings │
                                          │  hermes-agent-   │
                                          │  architecture    │
                                          └────────┬────────┘
                                                   │
                                                   ▼    8:00 AM
                                          ┌─────────────────┐
                                          │   MORNING       │
                                          │   SUMMARY       │
                                          │   → Telegram    │
                                          │                  │
                                          │  - What was     │
                                          │    researched   │
                                          │  - Key findings │
                                          │  - News digest  │
                                          │  - Arch changes │
                                          │  - Todo for day │
                                          └─────────────────┘
```

## Job Schedule

| Time | Job | Description | Output |
|------|-----|-------------|--------|
| 12:00 AM | Deep Research | New topic in AI/Fintech/Blockchain/Privacy/Security/Finance | Research doc |
| 1:30 AM | Daydreaming | Learn and practice AI daydreaming skill | Daydream notes |
| 3:00 AM | Self-Architecture | Research improvements to own architecture | Architecture doc |
| 4:30 AM | News Scrape | Global news relevant to user's interests | News digest |
| 6:00 AM | Repo Update | Push all findings to GitHub repos | Git commits |
| 8:00 AM | Morning Summary | Deliver comprehensive summary to Telegram | Telegram message |

## Topic Rotation

Deep research topics are selected based on:
1. Relevance to current projects (Solana, agent development)
2. Recency — avoid repeating recent topics
3. Depth — prefer topics that haven't been deeply explored yet
4. Connection — link to previous research for building knowledge chains

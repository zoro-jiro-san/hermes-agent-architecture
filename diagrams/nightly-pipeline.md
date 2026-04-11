# Nightly Research + Ops Pipeline

Automated cron jobs from midnight to morning, including new security and disk hygiene stages.

```
12:00   1:30    3:00    3:45    4:30      6:00      6:30      7:00      8:00
  │       │       │       │       │         │         │         │         │
  ▼       ▼       ▼       ▼       ▼         ▼         ▼         ▼         ▼
┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Deep  ││Day-  ││Self  ││Mal-  ││News  │ │Repo    │ │Disk    │ │Hermes  │ │Morning │
│Resch ││dream ││Arch  ││ware  ││Scrape│ │Push    │ │Cleanup │ │Update  │ │Summary │
└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘ └────┬───┘ └────┬───┘ └────┬───┘ └────────┘
   │       │       │       │       │          │          │          │
   └───────┴───────┴───────┴───────┴──────────┴──────────┴──────────┘
                                   Nightly knowledge + ops hardening loop
```

## Job Schedule

| Time | Job | Description | Output |
|------|-----|-------------|--------|
| 12:00 AM | Deep Research | New topic in AI/Fintech/Blockchain/Privacy/Security/Finance | Research doc |
| 1:30 AM | Daydreaming | Creative analogical reasoning and gap analysis | Daydream notes |
| 3:00 AM | Self-Architecture | Research and improve agent internals | Architecture notes |
| 3:45 AM | Malware Scan | ClamAV + rkhunter + Lynis baseline security scan | Security log |
| 4:30 AM | News Scrape | Global AI/crypto/fintech/privacy/security news | News digest |
| 6:00 AM | Repo Update | Push nightly findings to GitHub repos | Git commits |
| 6:30 AM | Disk Cleanup | Push important temp artifacts, then delete local bloat | Cleanup report |
| 7:00 AM | Hermes Self-Update | Run `hermes update` | Version log |
| 8:00 AM | Morning Summary | Deliver concise summary to Telegram | Telegram message |
| 9:00 PM | Daily Learnings | End-of-day learning consolidation | Daily log |
| 10:00 PM | Repo Reminder | Reminder to confirm repo sync state | Telegram reminder |

## Ops Additions (New)

- Malware scan added before repo push window to catch suspicious files early.
- Disk cleanup added after push to enforce: "if safely on GitHub, local copy can be removed".
- Temp artifacts are staged to private repo when useful, then purged from local disk.

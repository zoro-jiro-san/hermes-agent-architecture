# Integrated Nightly Loop

Combined timeline of Hermes Agent nightly jobs and Second Brain automation jobs, fully integrated under the agent scheduler.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INTEGRATED NIGHTY LOOP (CEST = UTC+2)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  00:00 — Deep Tech Research      [Agent Job #1]                             │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • AI/Fintech/Blockchain/Privacy/Security/Finance topic      │   │
│           │ • 3000-5000 word research document                          │   │
│           │ • Output: ~/.hermes/night-research/RESEARCH-YYYY-MM-DD.md  │   │
│           │ • Pre-check: Z.AI quota >80% → [SILENT] skip                │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  00:00 — TMP Snapshot Push           [Agent Job #2]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Archive /tmp to GitHub backup repo                        │   │
│           │ • Ensure important temp artifacts preserved                │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  00:20 — TMP Safe Cleanup            [Agent Job #3]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Clean /tmp only if same-day snapshot exists               │   │
│           │ • Avoids losing uncommitted artifacts                       │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  01:30 — Daydreaming                 [Agent Job #4]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Creative analogical reasoning gap analysis                │   │
│           │ • daydream-YYYY-MM-DD.md → push to hermes-agent-architecture │ │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  03:00 — Self-Architecture           [Agent Job #5]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Research agent's own architecture improvements            │   │
│           │ • arch-YYYY-MM-DD.md → push to hermes-agent-architecture    │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  03:45 — Daily Malware Scan          [Agent Job #6]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • ClamAV + rkhunter + Lynis                                  │   │
│           │ • Security summary → local log                               │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  04:30 — Global News Scrape          [Agent Job #7]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • AI/crypto/fintech/news aggregation                        │   │
│           │ • news-YYYY-MM-DD.md → ~/.hermes/night-research/            │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  06:00 — Repo Update & Consolidation [Agent Job #8]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Push nightly research to daily-learnings repo             │   │
│           │ • Push architecture notes to hermes-agent-architecture repo │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  06:20 — Cognee Sync                 [Agent Job #9]                         │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Sync agent research to Cognee cloud dataset               │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  06:30 — Disk Cleanup                [Agent Job #10]                        │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Purge local temp, enforce <29GB disk hygiene               │   │
│           │ • Report space freed                                          │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  06:30 — SECOND BRAIN DAILY COMPILE  [Second Brain Job #1] ⭐ NEW          │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Run: hermes-brain-compile --incremental                    │   │
│           │ • Process raw/articles/ → wiki/                              │   │
│           │ • Source: RSS/arXiv/News scrapes                              │   │
│           │ • Output: X new wiki pages, Y updated                         │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  06:45 — Knowledge Graph Update      [Second Brain Job #2] ⭐ NEW          │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Run: tools/build_edges.py                                   │   │
│           │ • Extract entity/edge relationships from new wiki pages      │   │
│           │ • Update memory/graph.nodes.json + edges.json                 │   │
│           │ • Graph size: N nodes, M edges                                │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  07:00 — Hermes Self-Update          [Agent Job #11]                        │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Run: hermes update (self-upgrade)                           │   │
│           │ • Currently failing → needs fix                               │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  07:30 — WEEKLY DIGEST ( Sundays )   [Second Brain Job #3] ⭐ NEW          │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Run: hermes-brain-lint --full --semantic                    │   │
│           │ • Run: hermes-brain-digest --weekly                            │   │
│           │ • Generate insights summary from past week                    │   │
│           │ • Post rich message to Telegram                                │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  08:00 — Morning Summary             [Agent Job #12]                        │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Concise Telegram briefing (<4000 chars)                     │   │
│           │ • Key overnight findings, research highlights                 │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  09:00 PM — Daily Learnings          [Agent Job #13]                        │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • End-of-day consolidation of daytime interactions            │   │
│           │ • Extract patterns for skill extraction                       │   │
│           │ • Write to daily_learnings repo                               │   │
│           └───────────────────────────┬─────────────────────────────────┘   │
│                                         │                                     │
│  10:00 PM — Repo Update Reminder     [Agent Job #14]                        │
│           ┌─────────────────────────────────────────────────────────────┐   │
│           │ • Check if daily-learnings & arch repos updated              │   │
│           │ • Telegram reminder if stale                                  │   │
│           └─────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Background Alerting Tasks (run every 30 min)                          │   │
│  │  ┌───────────────────────────────────────────────────────────────────┐ │   │
│  │  │ • Z.AI quota check (session %, weekly %) — if >80%, throttle     │ │   │
│  │  │ • Pi Telemetry Bot auto-alerts: temp>70°C or RAM>90%            │ │   │
│  │  │ • GitHub webhook listeners: on push → rebuild indexes            │ │   │
│  │  │ • Obsidian watcher daemon (continuous, not periodic)             │ │   │
│  │  └───────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  NOTES:                                                                      │
│  • Times in CEST (UTC+2). Adjust for local timezone.                        │
│  • "Second Brain integration" jobs are bolded (⭐).                          │
│  • Agent jobs run via hermes_cli.main gateway daemon (internal scheduler). │
│  • System cron (broken) is decommissioned; all jobs now agent-driven.      │
│  • Telegram is the primary delivery channel for summaries and alerts.      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Integration Summary

**Prior to integration:**
- System cron ran `daily_sync.sh` and `weekly_digest.sh` at broken paths (no execution)
- Second Brain compiled independently (manual `hermes-brain-compile`)
- No automatic graph updates from wikilinks
- Weekly digest tool `hermes-brain-digest` missing

**After integration:**
- ✅ Daily Compile runs at 06:30 via agent job (after Repo Update)
- ✅ Graph updates automatically after compile (post-push hook)
- ✅ Weekly digest runs Sundays 07:30 (separate agent job)
- ✅ TF-IDF index rebuilt on every wiki change (Obsidian watcher)
- ✅ All Second Brain operations now under single scheduler

## Dependencies & Ordering

```
Repo Update (06:00) ──┐
                       ├─► Daily Compile (06:30) ──► Graph Update (06:45)
TMP Snapshot (00:00) ─┘                          │
                                                  ▼
                                           Weekly Digest (Sun 07:30) ──► Telegram
```

## Artifacts Produced

|| Job | Output Location | Pushed To |
|-----|-----------------|-----------|
| Daily Compile | `wiki/` (new/updated pages) | GitHub (auto) |
| Graph Update | `memory/graph.{nodes,edges}.json` | GitHub (auto) |
| Weekly Digest | `reports/weekly_insights_YYYY-MM-DD.md` | Local + Telegram |
| Morning Summary | Telegram message | Chat 7833088241 |
| Daily Learnings | `daily-learnings/` | GitHub |

## Monitoring

Check job status:
```bash
# View agent's internal job schedule
hermes job list

# View recent outputs
ls -lt ~/.hermes/cron/output/

# Check Second Brain health
hermes-brain-lint --full

# View latest compile stats
tail -n 20 wiki/log.md

# Telemetry Bot status (Raspberry Pi)
systemctl --user status pi-telemetry-bot
```

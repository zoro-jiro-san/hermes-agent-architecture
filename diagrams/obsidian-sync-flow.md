# Real-Time Obsidian Sync Architecture

Unidirectional synchronization from local Obsidian vault to GitHub remote with automatic index and graph updates.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OBSIDIAN → GITHUB SYNC FLOW                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐                 ┌──────────────────┐                  │
│  │  Obsidian Vault  │  inotifywait    │   watch_and_push  │                  │
│  │  (~/vaults/hsb/) │ ──────────────▶ │   (daemon)       │                  │
│  │                  │   file change   │                  │                  │
│  │  *.md edits      │                 │  • detects change │                  │
│  │  wikilinks       │                 │  • debounce 3s   │                  │
│  │  graph view      │                 │  • git add/comm  │                  │
│  └────────┬─────────┘                 └────────┬─────────┘                  │
│           │                                      │                          │
│           │ edit                                │ push                      │
│           ▼                                      ▼                          │
│  ┌──────────────────┐                 ┌──────────────────┐                  │
│  │   wiki/*.md      │                 │   GitHub         │                  │
│  │   (symlinked)    │                 │   (remote)       │                  │
│  │                  │                 │                  │                  │
│  │  Changes written │                 │  • accepts push  │                  │
│  │  to repo directly│                 │  • triggers      │                  │
│  └──────────────────┘                 │    webhooks      │                  │
│                                       │  (optional)      │                  │
│                                       └────────┬─────────┘                  │
│                                                │                            │
│                                                │ post-push hooks            │
│                                                ▼                            │
│  ┌─────────────────────────────────────────────────────────────────┐         │
│  │  post_push.sh (orchestrator)                                    │         │
│  │  ┌───────────────────────────────────────────────────────────┐ │         │
│  │  │ 1. Rebuild TF-IDF Index                                   │ │         │
│  │  │    → index/embeddings/index.json                          │ │         │
│  │  │    → fast lexical search (BM25-like)                      │ │         │
│  │  ├───────────────────────────────────────────────────────────┤ │         │
│  │  │ 2. Update Knowledge Graph                                 │ │         │
│  │  │    → scan wiki/*.md for [[wikilinks]]                     │ │         │
│  │  │    → create `links_to` edges (page → page)                │ │         │
│  │  │    → merge into memory/graph.edges.json                   │ │         │
│  │  ├───────────────────────────────────────────────────────────┤ │         │
│  │  │ 3. Run Fast Lint                                          │ │         │
│  │  │    → hermes-brain-lint --fast                             │ │         │
│  │  │    → detect broken links, orphans                         │ │         │
│  │  │    → log to reports/lint_YYYY-MM-DD.json                  │ │         │
│  │  └───────────────────────────────────────────────────────────┘ │         │
│  └─────────────────────────────┬───────────────────────────────────┘         │
│                                │                                              │
│                                ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────┐         │
│  │  Fallback: cron_push.sh (6-hour batch)                          │         │
│  │  • Runs every 6 hours as consistency safety net                 │         │
│  │  • Catches edits when watcher daemon stopped                    │         │
│  │  • Also triggers post_push.sh                                   │         │
│  └─────────────────────────────────────────────────────────────────┘         │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐         │
│  │  Optional: webhook receiver (future)                             │         │
│  │  • GitHub → Telegram notifications on push                       │         │
│  │  • Alert on lint failures                                        │         │
│  └─────────────────────────────────────────────────────────────────┘         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Summary

|| File | Purpose | Trigger |
|------|---------|---------|
| `sync/watch_and_push.sh` | Inotify watcher daemon | Real-time file system events |
| `sync/cron_push.sh` | 6-hour batch push | Cron schedule (0 */6 * * *) |
| `sync/post_push.sh` | Post-push hook orchestrator | After every successful push |
| `sync/update_graph_from_wikilinks.py` | Extract `[[wikilinks]]` → graph edges | Called by post_push.sh |
| `index/embeddings/build_index.py` | TF-IDF/BM25 index builder | Called by post_push.sh |

## Data Flow Sequence

1. **Edit** note in Obsidian (vault path: `~/vaults/hermes-second-brain/`)
2. **Watch** (`inotifywait`) detects `.md` modification event
3. **Debounce** wait 3 seconds to batch rapid successive edits
4. **Commit & Push**: `git add -A` → `git commit -m "Auto: <timestamp>"` → `git push`
5. **Post-Push Hooks**:
   - Rebuild TF-IDF index for semantic + lexical search
   - Update knowledge graph with `links_to` edges from wikilinks
   - Run fast lint (mechanical checks only)
6. **GitHub Remote** now up-to-date; all indexes reflect latest state

## Key Guarantees

- **GitHub is source of truth** — local vault is editable workspace
- **Push-only direction** — no automatic pull to avoid merge conflicts
- **Atomic commits** — each change set is a single commit with timestamp
- **Index consistency** — TF-IDF and graph are always rebuild after push
- **Fallback safety** — cron_push.sh runs every 6 hours even if watcher dies

## Extensibility

Add custom post-push hooks inside `post_push.sh`:
- Send Telegram notification on success
- Trigger downstream CI/CD builds
- Update external dashboards or metrics

# 2026-04-09 — Session Learnings Update

## What Changed
- Added 7 AM Hermes self-update cron job (`hermes update`)
- Updated daily-learnings repo with nightly pipeline documentation
- Updated nightly pipeline diagram to include self-update step
- Established "commit one by one, then push" git workflow rule

## Why
- Agent needs to stay on latest version for bug fixes and new features
- Clean git history makes it easy to track what changed and revert if needed
- Single commits per change = readable git log

## Files Changed
- `diagrams/nightly-pipeline.md` — added 7 AM self-update row
- daily-learnings repo — new learnings file + README update

# Skill Evolution Research

## Status: Active

## Current State
- 40+ skills loaded from ~/.hermes/skills/
- Skills auto-scanned and listed in system prompt every turn
- Agent creates new skills after complex tasks (5+ tool calls)
- Skills patched when issues found during use

## Research Questions

1. **Auto-quality** — How to automatically detect when a skill needs updating?
2. **Usage tracking** — Track which skills are used, which fail, which are ignored
3. **Skill composition** — Can skills reference and build on each other?
4. **Skill search** — Better discovery beyond name matching
5. **Skill retirement** — Auto-archive skills that haven't been used in N days

## Improvement Ideas
- [ ] Skill usage counter (increment on each use)
- [ ] Skill health score (success rate × recency × frequency)
- [ ] Auto-patch when skill fails (detect + fix in same session)
- [ ] Skill deduplication (merge overlapping skills)
- [ ] Community skill sharing (pull from skills hub)

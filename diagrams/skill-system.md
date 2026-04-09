# Skill System

How skills provide procedural memory and reusable workflows.

```
┌──────────────────────────────────────────────────────┐
│                  SKILL LIFECYCLE                       │
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  1. STORAGE                                    │    │
│  │                                                │    │
│  │  ~/.hermes/skills/                             │    │
│  │  ├── github/                                   │    │
│  │  │   ├── github-auth/SKILL.md                  │    │
│  │  │   ├── github-pr-workflow/SKILL.md           │    │
│  │  │   └── ...                                   │    │
│  │  ├── research/                                 │    │
│  │  │   ├── arxiv/SKILL.md                        │    │
│  │  │   └── ...                                   │    │
│  │  ├── mlops/                                    │    │
│  │  │   ├── training/unsloth/SKILL.md             │    │
│  │  │   └── ...                                   │    │
│  │  └── ... (40+ skills)                          │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  2. SCANNING (every turn)                      │    │
│  │                                                │    │
│  │  agent/skill_commands.py scans skills/         │    │
│  │  Builds available_skills list → injected       │    │
│  │  into system prompt as:                        │    │
│  │                                                │    │
│  │  - name: skill-name                            │    │
│  │    description: What it does...                │    │
│  │                                                │    │
│  │  Agent sees list → loads matching skill        │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  3. LOADING (on demand)                        │    │
│  │                                                │    │
│  │  skill_view(name="github-auth")                │    │
│  │     ↓                                          │    │
│  │  Returns:                                      │    │
│  │  - SKILL.md content (instructions)             │    │
│  │  - linked_files (scripts, templates)           │    │
│  │  - readiness_status                            │    │
│  │     ↓                                          │    │
│  │  Agent follows instructions in SKILL.md        │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  4. EVOLUTION                                  │    │
│  │                                                │    │
│  │  After using a skill:                          │    │
│  │  - Found missing steps? → patch immediately    │    │
│  │  - Wrong commands? → patch immediately         │    │
│  │  - New workflow? → create new skill            │    │
│  │  - Skill outdated? → edit/rewrite              │    │
│  │                                                │    │
│  │  skill_manage(action='patch')                  │    │
│  │  skill_manage(action='create')                 │    │
│  └──────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────┘
```

## Skill Format

```yaml
---
name: skill-name
description: One-line description
version: 1.0.0
metadata:
  hermes:
    tags: [tag1, tag2]
    related_skills: [other-skill]
---

# Skill Title

## Trigger
When to use this skill

## Steps
1. Step one with exact commands
2. Step two with expected output
3. Step three with error handling

## Pitfalls
- Common mistakes to avoid

## Verification
How to confirm it worked
```

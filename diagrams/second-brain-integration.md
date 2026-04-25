# Second Brain Integration Pattern

How the Hermes Agent integrates with the Second Brain knowledge management system.

```
┌──────────────────────────────────────────────────────────────────┐
│                    DAILY COMPOUNDING LOOP                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  STEP 1: Daily Learnings                                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ • New research arrives (papers, articles, repos, transcripts)│ │
│  │ • Hermes Agent reads, summarizes, extracts key findings      │ │
│  │ • Raw sources deposited in Second Brain: raw/                │ │
│  └────────────────────────┬───────────────────────────────────┘ │
│                           │                                       │
│  STEP 2: Skill Extraction        │                               │
│  ┌──────────────────────────────▼─────────────────────────────┐ │
│  │ • Identify patterns worth procedural encapsulation         │ │
│  │ • Generate SKILL.md files (trigger, steps, pitfalls)       │ │
│  │ • Symlink into ~/.hermes/skills/ (immediately available)   │ │
│  └──────────────────────────────┬─────────────────────────────┘ │
│                                 │                                 │
│  STEP 3: Knowledge Graph Update  │                                 │
│  ┌──────────────────────────────▼─────────────────────────────┐ │
│  │ • Extract entities (people, orgs, tools, frameworks)       │ │
│  │ • Extract concepts (principles, patterns, ideas)           │ │
│  │ • Build edges: uses, implements, inspired_by, integrates_with│ │
│  │ • Store in graph/nodes.json, graph/edges.json              │ │
│  └──────────────────────────────┬─────────────────────────────┘ │
│                                 │                                 │
│  STEP 4: Wiki Compilation        │                                 │
│  ┌──────────────────────────────▼─────────────────────────────┐ │
│  │ • LLM reads raw sources + existing wiki                    │ │
│  │ • Creates/updates entity pages, concept pages, comparisons │ │
│  │ • Adds wikilinks, citations, change logs                   │ │
│  │ • Rebuilds index.md (table of contents)                    │ │
│  └──────────────────────────────┬─────────────────────────────┘ │
│                                 │                                 │
│  STEP 5: Query & Synthesis       │                                 │
│  ┌──────────────────────────────▼─────────────────────────────┐ │
│  │ • Agent or human asks: hermes-brain-query "..."            │ │
│  │ • System retrieves relevant pages + graph traversal        │ │
│  │ • LLM synthesizes answer with citations                    │ │
│  │ • Optional: save answer as synthesis page (feedback loop)  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  RESULT: Knowledge compounds, relationships form, wiki grows    │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     HERMES SECOND BRAIN                          │
│                                                                  │
│  ┌────────────────────┐               ┌──────────────────────┐  │
│  │   LAYER 1: RAW     │   Ingest      │  LAYER 2: WIKI       │  │
│  │   SOURCES          │ ────────────→ │  (Compiled Markdown) │  │
│  │                    │               │                      │  │
│  │  raw/              │               │  wiki/               │  │
│  │  ├── articles/     │               │  ├── concepts/       │  │
│  │  ├── papers/       │               │  ├── entities/       │  │
│  │  ├── repos/        │               │  ├── sources/        │  │
│  │  ├── transcripts/  │               │  ├── comparisons/    │  │
│  │  └── assets/       │               │  └── synthesis/      │  │
│  │                    │               │                      │  │
│  │  Immutable         │               │  LLM-maintained      │  │
│  │  source files      │               │  human-readable      │  │
│  └────────┬───────────┘               └──────────┬───────────┘  │
│           │                                        │              │
│           │                                        │              │
│           ▼                                        ▼              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │           INGEST PIPELINE                                 │  │
│  │  1. Extract text (universal adapters)                    │  │
│  │  2. LLM entity/concept extraction                        │  │
│  │  3. Update/create entity/concept pages                   │  │
│  │  4. Build source summary page                            │  │
│  │  5. Contradiction detection                              │  │
│  │  6. Rebuild index.md                                     │  │
│  └─────────────────────────────┬─────────────────────────────┘  │
│                                │                                 │
│                                ▼                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │           LAYER 3: KNOWLEDGE GRAPH                        │  │
│  │                                                           │  │
│  │  graph/                                                  │  │
│  │  ├── nodes.json  (entities + concepts)                  │  │
│  │  ├── edges.json  (relationships)                        │  │
│  │  └── schema.md   (edge types, node types)               │  │
│  │                                                           │  │
│  │  Node types: repo, company, person, tool, framework,    │  │
│  │              concept, pattern, tech_stack, skill, service│ │
│  │                                                           │  │
│  │  Edge types: uses, integrates_with, inspired_by,        │  │
│  │              part_of, extends, implements, produces,    │  │
│  │              targets, compatible_with, requires         │  │
│  └─────────────────────────────┬─────────────────────────────┘  │
│                                │                                 │
│                                │ GraphRAG Queries               │
│                                ▼                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │           QUERY SERVICE                                   │  │
│  │                                                           │  │
│  │  hermes-brain-query "..."                                │  │
│  │    ├─→ RAG_COMPLETION (semantic search)                  │  │
│  │    ├─→ GRAPH_COMPLETION (traverse edges)                 │  │
│  │    ├─→ CYPHER (structured query)                         │  │
│  │    ├─→ CHUNKS (raw source excerpts)                      │  │
│  │    └─→ SUMMARIES (aggregate node summaries)              │  │
│  │                                                           │  │
│  │  Output: Answer + citations + confidence + related pages │  │
│  └─────────────────────────────┬─────────────────────────────┘  │
│                                │                                 │
│                                │ --save flag                     │
│                                ▼                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │           FEEDBACK LOOP                                   │  │
│  │                                                           │  │
│  │  Answer saved as synthesis page → wiki/synthesis/       │  │
│  │  Appended to index.md                                    │  │
│  │  Logged in log.md                                        │  │
│  │  → Knowledge compounds                                   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Integration with Hermes Agent

```
┌─────────────────────────────────────────────────────────────────┐
│                HERMES AGENT (orchestrator)                       │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Daily Learnings Consolidation (9:00 PM)                   │ │
│  │  • Review day's research & interactions                    │ │
│  │  • Extract salient learnings                               │ │
│  │  • Identify skill-worthy patterns                          │ │
│  │  • Write to Second Brain raw/ + skills/                    │ │
│  └──────────────────────────────────────┬─────────────────────┘ │
│                                         │                       │
│  Query Time:                            │                       │
│  ┌──────────────────────────────────────▼─────────────────────┐ │
│  │  hermes-brain-query skill invoked                          │ │
│  │  → Search wiki + graph                                     │ │
│  │  → Retrieve relevant context                               │ │
│  │  → Synthesize answer                                       │ │
│  │  → Return to agent                                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Skill Loading:                                                  │
│  • Skills symlinked from Second Brain: synthesis/skills/       │
│  • Auto-scanned each turn → injected as frontmatter            │
│  • Full content loaded on demand via skill_view()              │
│                                                                  │
│  Feedback:                                                       │
│  • Important answers auto-saved as synthesis pages             │
│  • New skills created from successful patterns                 │
│  • Contradictions logged for review                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ CLI tools
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│           HERMES SECOND BRAIN (knowledge layer)                  │
│                                                                  │
│  hermes-brain-compile   →  Build wiki from raw sources          │
│  hermes-brain-query     →  Search knowledge base               │
│  hermes-brain-lint      →  Health checks & linting             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Knowledge Flow

### Ingestion Flow

```
User/Agent adds source
        ↓
Place in raw/{type}/YYYY-MM-DD-description.md
        ↓
Frontmatter parsed (title, type, sha256, tags)
        ↓
Universal text extraction (PDF → text, HTML → markdown, etc.)
        ↓
LLM entity & concept extraction
        ↓
For each entity: find/create entities/{type}/{slug}.md
     → Merge new claims with citations ^[source.md]
     → Append changelog
        ↓
For each concept: find/create concepts/{slug}.md
     → Weave in new insights
     → Link to affected entities
        ↓
Build source summary: sources/YYYY-MM-DD-description.md
        ↓
Contradiction detection (scan new claims vs existing pages)
        ↓
Append to log.md
        ↓
Rebuild index.md (deterministic)
```

### Query Flow

```
User/Agent asks: "What is GraphRAG?"
        ↓
Parse question → identify candidate pages (from index.md)
        ↓
Load full text of candidate pages
        ↓
LLM re-ranks by relevance (statistical scoring)
        ↓
Hybrid retrieval:
  • Semantic search (vector similarity) → candidate nodes
  • Graph traversal (1-2 hops from candidates) → expanded context
        ↓
Assemble context: node descriptions + relationships + excerpts
        ↓
LLM synthesizes answer with inline citations: [[page-slug]] or ^[source.md]
        ↓
If --save flag or answer adds new knowledge:
  → Offer to save as synthesis page (wiki/synthesis/)
  → Update index.md
  → Log action
        ↓
Return: Answer + Sources + Confidence + Related pages
```

### Feedback Loop

```
Query answer generated
        ↓
Does it add new knowledge not already in wiki?
        ├─ No → Discard (not worth storing)
        └─ Yes → Save as synthesis page
                  • wiki/synthesis/YYYY-MM-DD-title.md
                  • Proper frontmatter, citations, wikilinks
                  • Update index.md
                  • Log to log.md
                          ↓
                Next compile cycle:
                New synthesis pages become source material
                for further consolidation into entity/concept pages
```

## Skill Integration Pattern

Second Brain **generates skills** from research:

1. **Research analysis:** Raw research reports scanned for capability patterns
2. **Skill extraction:** Repos that are tools (not just docs) qualify as skills
3. **SKILL.md generation:** Includes trigger conditions, prerequisites, steps, pitfalls
4. **Symlink deployment:** `synthesis/skills/<repo>/` → `~/.hermes/skills/<category>/`
5. **Instant availability:** Hermes scans skills on next turn; skill ready to invoke

**Example:** Research on "Cognee knowledge engine" → generates `cognee/SKILL.md` → Hermes can invoke cognitive graph reasoning in tasks.

## Provenance & Auditability

Every factual claim in the wiki cites its source:

```markdown
## Key Points

- GraphRAG combines vector search with graph traversal ^[raw/articles/karpathy-llm-wiki.md]
- Cognee implements a 3-tier memory architecture ^[raw/papers/cognee-paper.pdf#section-4]
- Hermes uses anchored summarization for compression ^[research/memory.md#anchored-compression]
```

**Source citation syntax:**
- `^[raw/articles/xyz.md]` — inline citation to entire file
- `^[source.md#section-id]` — citation anchored to specific section
- `[[page-slug]]` — wikilink to another wiki page

**Audit trail:** Every wiki page's `change_log` tracks versions; `log.md` append-only record of all actions; `sources/` directory preserves per-source summaries.

## Contradiction Resolution

When new claims conflict with existing wiki content:

1. **Detection:** LLM scans new claims during ingest; flags potential contradictions
2. **Logging:** Contradiction recorded in `log.md` with confidence scores and source pointers
3. **Review:** Either automated resolution (if clear supersession) or human review
4. **Resolution:** Either update existing page (merge, clarify) or create comparison page
5. **Versioning:** Both perspectives preserved with timestamps; `last_validated` field tracks currency

## Cost & Performance

**Monthly costs (1000 sources):**

| Operation | Volume | Unit Cost | Monthly |
|-----------|--------|-----------|---------|
| Ingest (30 new sources) | 30 × 10K words | $0.75 | $22.50 |
| Full recompile (weekly) | 4 × $5.00 | $5.00 | $20.00 |
| Queries (100/month) | 100 × $0.10 | $0.10 | $10.00 |
| Lint (weekly full) | 4 × $3.00 | $3.00 | $12.00 |
| **Total** | | | **~$64.50** |

**Storage:** < 1 GB (raw + wiki + graph)

**Performance:**
- Ingest: 45 sec / 10K-word source (p99: 2 min)
- Query: 5 sec simple, 10 sec graph (p99: 30 sec)
- Full lint: 2 min (semantic), 3 sec (mechanical)

## Key Advantages vs Standalone Hermes

| Dimension | Standalone Hermes | Hermes + Second Brain |
|-----------|------------------|----------------------|
| Memory scope | Session-limited (FTS5) | Persistent, compounding wiki |
| Retrieval | Keyword search only | Hybrid vector + graph (GraphRAG) |
| Provenance | None | Full citation trail |
| Human-readable | No (binary logs) | Yes (Markdown in Obsidian) |
| Cross-session learning | Manual (skills only) | Automatic (wiki grows) |
| Knowledge graph | None | Explicit nodes + edges |
| Feedback loop | None | Answers → synthesis pages |

## Open Questions

- **Memory scoping:** Should Second Brain have per-platform, per-project namespaces? (Like Mem0's 4-scope model)
- **Forgetting curve:** When to prune stale wiki pages? Ebbinghaus decay applied to knowledge?
- **Skill discovery:** Can graph traversal suggest relevant skills based on task context?
- **Contradiction resolution:** Automated merge vs. human-in-the-loop for conflicting claims?
- **Multi-agent sharing:** Can multiple Hermes agents share a single Second Brain instance?
- **Sync frequency:** Is daily compilation sufficient or should it be real-time on research arrival?

## References

- Karpathy, A. (2026). *LLM Wiki pattern* — Twitter thread + implementation examples
- Cognee: [github.com/topoteretes/cognee](https://github.com/topoteretes/cognee) — GraphRAG knowledge engine
- Mem0: [github.com/mem0ai/mem0](https://github.com/mem0ai/mem0) — 4-scope memory with self-editing
- Zep/Graphiti: [github.com/getzep/graphiti](https://github.com/getzep/graphiti) — Temporal knowledge graphs
- FadeMem: [github.com/ChihayaAine/FadeMem](https://github.com/ChihayaAine/FadeMem) — Ebbinghaus-inspired forgetting curve
- Hindsight: [github.com/vectorize-io/hindsight](https://github.com/vectorize-io/hindsight) — Multi-strategy hybrid (91.4% LongMemEval)

---

*This diagram is part of the living architecture. Last updated: 2026-04-26.*

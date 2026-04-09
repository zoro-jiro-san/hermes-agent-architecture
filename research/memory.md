# Memory Management Research

## Status: Active

### Current Architecture
- **User Profile**: 1,375 chars — who the user is, preferences
- **Agent Memory**: 2,200 chars — environment facts, conventions, lessons
- **Session Search**: SQLite FTS5 — full conversation history
- **Skills**: File-based procedural memory in ~/.hermes/skills/
- **Context Compression**: Auto-summarize middle turns when approaching limit

### Research Questions
1. **RAG over conversations** — Embed sessions, retrieve relevant context dynamically
2. **Semantic compaction** — Merge similar memories, remove stale entries
3. **Memory prioritization** — Auto-rank by recency + relevance + access frequency
4. **Hierarchical memory** — Short-term (session) → medium-term (memory) → long-term (skills)
5. **Forgetting curve** — Auto-expire low-value memories after N days

### Ideas to Explore
- [ ] Vector embeddings for session search (replace FTS5 keyword search)
- [ ] Knowledge graph for entity relationships
- [ ] Memory consolidation: merge daily learnings into compressed knowledge
- [ ] User modeling via Honcho integration
- [ ] Reflection: periodic self-review of memory quality

### Metrics to Track
- Memory hit rate: how often injected memory is relevant
- Compression ratio: how much context is saved by compression
- Session recall accuracy: does session_search return the right results?

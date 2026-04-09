# Token Efficiency Research

## Status: Active

### Current Architecture
- **Prompt caching**: Anthropic static system prompts (~80% input token savings)
- **Context compression**: Gemini Flash summarizes middle turns at 85% threshold
- **Model routing**: Manual selection via /model, auto for some tasks
- **Tool result truncation**: Large outputs summarized before appending

### Token Budget Breakdown (Typical Turn)
```
System Prompt (cached)         ~4,000 tokens   (first turn only)
Memory + Skills List           ~2,000 tokens   (every turn)
Conversation History            varies          (grows over time)
Tool Results                    varies          (can be very large)
User Message                    ~100-500 tokens
─────────────────────────────────────────────────
Total per turn:                 ~6,000-50,000+ tokens
```

### Research Questions
1. **Adaptive model routing** — Route each subtask to optimal model automatically
2. **Schema pruning** — Remove unused tool schemas from prompt
3. **Lazy skill loading** — Only inject skill descriptions that match the task
4. **Memory compression** — Compress memory injection using shorter format
5. **Streaming optimization** — Reduce latency by streaming tool results

### Ideas to Explore
- [ ] Token counting before each API call to choose model
- [ ] Dynamic schema injection: only include relevant tools
- [ ] Conversation summarization strategies (sliding window vs pyramid)
- [ ] Caching tool results that don't change between turns
- [ ] Multi-turn prompt caching across sessions

### Cost Optimization
| Strategy | Estimated Savings | Complexity |
|----------|-------------------|------------|
| Prompt caching | 60-80% input | Already implemented |
| Model routing | 40-60% total | Medium |
| Schema pruning | 10-20% input | Low |
| Context compression | 30-50% context | Already implemented |
| Memory compression | 5-10% input | Low |

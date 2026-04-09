# Agent Orchestration Research

## Status: Active

### Current Architecture
- Single agent with tool dispatch (centralized)
- Subagent delegation for parallel tasks (delegate_task)
- Up to 3 subagents in parallel via delegate_task

### Research Questions
1. **Hierarchical vs flat delegation** — When should subagents spawn their own subagents?
2. **Shared context** — How much context should subagents receive? Currently: full context string
3. **Result aggregation** — How to merge conflicting results from parallel subagents?
4. **Failure modes** — What happens when one subagent fails mid-task?

### Ideas to Explore
- [ ] CrewAI-style role-based agent teams
- [ ] AutoGen-style conversation patterns
- [ ] LangGraph-style state machines for complex workflows
- [ ] Anthropic's "agents as tools" pattern
- [ ] Batch processing with model routing

### References
- `open-multi-agent` repo for multi-agent orchestration
- Hermes delegate_tool.py for current implementation
- tools/registry.py for tool dispatch pattern

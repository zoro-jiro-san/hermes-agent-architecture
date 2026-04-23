# Agent Loop

The core conversation loop that drives all interactions.

```
User Message
     │
     ▼
┌─────────────┐
│  Receive     │  CLI / Telegram / Discord / Slack / WhatsApp
│  Message     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Build       │  1. System prompt (identity, tools, config)
│  Prompt      │  2. Memory injection (user profile + notes)
│              │  3. Skills scan (matching skill → user message)
│              │  4. Context files (AGENTS.md, project files)
│              │  5. Conversation history
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  Compress    │────▶│  Context OK? │
│  if needed   │     │  (< 85%)     │
└──────┬──────┘     └──────┬───────┘
       │ yes               │
       ▼                   ▼
┌─────────────┐     ┌──────────────┐
│  LLM Call   │────▶│   Response   │
│  (stream)   │     │              │
└──────┬──────┘     └──────┬───────┘
       │                    │
       │           ┌────────┴────────┐
       │           │                 │
       │     ┌─────▼─────┐    ┌──────▼──────┐
       │     │  Tool Call │    │  Text Reply  │
       │     │  Request   │    │  (final)     │
       │     └─────┬──────┘    └──────────────┘
       │           │
       │     ┌─────▼──────┐
       │     │  Dispatch   │
       │     │  to Tool    │
       │     └─────┬──────┤
       │           │      │
       │     ┌─────▼───┐  │
       │     │  Agent   │  │  todo, memory — intercepted
       │     │  Tools   │  │  before handle_function_call()
       │     └─────┬───┘  │
       │           │      │
       │     ┌─────▼───┐  │
       │     │Registry │  │  All other tools
       │     │Dispatch │  │  (incl. delegate_task)
       │     └─────┬───┘  │
       │           │      │
       │     ┌─────▼──────▼┐
       │     │  Append      │
       │     │  Tool Result │
       │     │  to Messages │
       │     └─────┬────────┘
       │           │
       └───────────┘  (loop back to LLM Call)
       │
       ▼
  ┌──────────┐
  │  Return   │  Final response to user
  │  Response │  + Save trajectory if enabled
  └──────────┘
```

## Key Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| max_iterations | 90 | Max tool-call rounds per conversation |
| iteration_budget | varies | Token-based budget per conversation |
| context_threshold | 0.85 | Compression trigger (% of context window) |
| stream | true | Stream responses for real-time display |

## Optimization Opportunities

- **Prompt caching**: Anthropic supports caching static system prompts — saves ~80% input tokens on repeated conversations
- **Context compression**: Middle turns summarized by a cheap model (Gemini Flash) when approaching limit
- **Model routing**: Route simple tasks to cheap models, complex reasoning to premium
- **Tool result truncation**: Large tool outputs are summarized before appending to context

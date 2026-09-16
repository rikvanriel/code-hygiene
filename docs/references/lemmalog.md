# lemmalog

## TL;DR

Local-first working memory: assert durable decisions as facts, retrieve
them later with budget-aware context assembly. Keeps multi-session work
consistent without re-deriving constraints each time.

## Provides (2-3 checkable rules or workflow snippet)

- Assert decisions, not prose: `code-hygiene-v02 --status[1.0]--> shipped`,
  one fact per line via `lemmalog_observe`. Memories hold decisions and
  constraints, never secrets or private paths.
- Retrieve before asserting: `lemmalog_context` with a natural-language
  query plus `budget_tokens` returns relevance-selected facts with their
  verbatim source episodes — use it instead of dumping the whole store.
- Re-check before acting: a memory's claim is unverified prose until
  validated against the current diff, same weight as any other claim
  (see factual-integrity GC-01).

## License

Check upstream LICENSE (repo carries its own license file).

## Use with

Multi-session or multi-agent work where constraints must survive context
resets: v0.2 tracked its skill/reference counts and gate requirements
as lemmalog facts across turns.

## Install / wiring

```bash
# MCP server; tool names are mcp__lemmalog__lemmalog_observe,
# mcp__lemmalog__lemmalog_context, mcp__lemmalog__lemmalog_query, ...
# Wire into Phase 1 (record spec decisions) and Phase 2 (record plan
# constraints); re-query at Phase 4 review.
```

## When not to use

- Single-shot tasks with no cross-session state to keep.
- Anything secret: memory stores are queryable — keep credentials out.

## Link

- Upstream: https://github.com/JordyZomer/lemmalog

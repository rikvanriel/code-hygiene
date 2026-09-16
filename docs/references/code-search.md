# code-search (zoekt + semcode)

## TL;DR

Local code search behind MCP tools: zoekt for fast content/symbol lookup
over indexed repos, semcode for semantic cross-references the trigram
index cannot answer. Grounds review claims in the current tree.

## Provides (2-3 checkable rules or workflow snippet)

- Verify call sites, don't assert them: `mcp__zoekt__search_symbols`
  for definitions, `mcp__zoekt__search` for content,
  `mcp__zoekt__file_content` to read a hit with line numbers.
- Escalate semantically: `mcp__semcode__call_tool` for cross-reference
  queries (callers, implementations, overrides) the local index misses.
- Paste what you found: the matching lines (file plus line range) go
  into the change record verbatim instead of a paraphrase
  (see factual-integrity GC-04).

## License

- semcode: dual MIT/Apache-2.0 (LICENSE-MIT, LICENSE-APACHE upstream).
- mcp-zoekt: check upstream LICENSE.

## Use with

Any review or audit step that names files, symbols, or call sites:
self-review-gate Gate 1 (a) "did you fix all call sites", code-structure
sister-pattern check, comment-quality contradiction grep.

## Install / wiring

```bash
# MCP servers: mcp-zoekt (local zoekt index), semcode (semantic index).
# Tool names: mcp__zoekt__search, mcp__zoekt__search_symbols,
# mcp__zoekt__file_content, mcp__semcode__call_tool, ...
# Wire into Phase 3 (draft: check sister patterns) and Phase 4 (review:
# verify every named call site before claiming fixed).
```

## When not to use

- Repos too small to index — plain grep is cheaper and sufficient.
- The index is stale relative to the working tree: re-index or fall
  back to direct reads rather than citing stale hits.

## Link

- Upstream: https://github.com/jahales/mcp-zoekt
- Upstream: https://github.com/facebookexperimental/semcode

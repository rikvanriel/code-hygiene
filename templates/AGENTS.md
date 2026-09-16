# AGENTS.md template — copy to your repo root

Paste relevant sections from code-hygiene skills below. Adjust project name and tooling.

## Project discovery

Run `ls CONTRIBUTING* .github/CONTRIBUTING* CLAUDE.md AGENTS.md` — obey upstream rules first.

## Factual integrity

Never invent numbers/dates/hashes/perf claims. Every claim sourced this session. Unknown → TODO. Paste verbatim. Forward-port = re-assert.

## Upstream hygiene

Commits/comments contain ONLY upstream-relevant. Ban classes: private infra hostnames, local absolute paths (/home/<user>/...), internal tooling names. Examples use example.invalid placeholder.

## Code structure

- Helper extraction by theme, not line count.
- Function length signal: most ≤20 logical, hard 40 → extract intent-named helpers.
- Predicate bool naming: should_/is_/try_/has_/can_.
- Guard early return over deep nesting.
- Minimal obvious fix — peripheral cleanups separate commit labeled "no functional change".

## Comment quality

WHY not WHAT. 50-word paragraph cap. One source at definition. Subtle logic MUST WHY. No restating code.

## Changelog/PR

Subject ≤50 imperative. Problem in present tense first. One idea per para. Invariant not plumbing. What NOT done. Public links only. Contrast already-correct path if missed case.

## Self-review gate

Before final output/commit:
- (a) What's wrong? failure modes, invented claims, concurrent derefs before free?
- (b) Better way? one concrete alternative with tradeoff or state none.
- (c) Cut test: would cutting sentence lose actionable info for external reviewer with zero private context?

## Verification

Every step needs observable signal: log line, metric, artifact exists. Existing workload still correct after change.

# CLAUDE.md template — Claude Code contributor notes

Paste into your repo's CLAUDE.md or .claude/CLAUDE.md.

## Project discovery

Read CONTRIBUTING.md, HACKING, .github/CONTRIBUTING before any edit — obey its DCO/subject/trailer/style gates.

## Upstream hygiene

Commit messages + code comments contain ONLY upstream-relevant. No private infra hostnames, no /home/ local paths, no internal tooling names. Examples use example.invalid.

## Phase workflow

Phase 0 discovery (Step 0) → Phase 1 socratic spec (divergent, one Q/turn, closes Open Qs) → Phase 2 plan iteration (convergent, observable per step, trend vs count, ask human only on 4 triggers: ambiguity, constraint tradeoff, irreversible/high-stakes, no convergence after 2 iters) → Phase 3 code draft (code-structure + comment-quality + factual-integrity) → Phase 4 review (self-review-gate Gate1 + llm-tells) → Phase 5 changelog/PR (changelog-quality + upstream-hygiene).

## Code + comments

- WHY not WHAT, 50w cap, one source at definition.
- Extract helpers by theme, guard early return, should_/is_ predicate naming.

## Changelog

- Subject imperative ≤50. Problem first present tense. One idea per para. Contrast already-correct path if missed case. Invariant not plumbing.

## Hooks

Run ./scripts/check-hygiene.sh before commit if code-hygiene present.

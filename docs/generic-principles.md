# Generic principles (cliff notes, kernel-free)

Distilled from kernel-style, obra/superpowers, google/eng-practices — but rewritten with no kernel terminology as normative.

## Factual integrity

- Never invent numbers/dates/hashes/performance claims. Every claim sourced this session.
- Unknown → TODO, not plausible fill.
- Verify claim vs current diff + cmd output. Paste verbatim where possible.
- Forward-port = re-assert: re-validate evidence against new base, don't assume transfer.
- PR description treats unverified prose as bug same weight as wrong code.

## Change splitting

- One logical change per commit/PR — thematic grouping within series (keep same theme consecutive where dependencies/bisect allow, reviewer stays in context).
- 200 changed lines in single file triggers examination for seams (mechanical conversion vs behavioral change; move vs rewrite; helper extraction vs first caller).
- Cover letter / PR description owns ordering + prerequisites narrative.

## Comments

- WHY not WHAT, 50-word paragraph cap, one source of truth at definition not header/prototype, cross-ref not duplicate.
- Subtle logic (locking, ordering, lifetime, invariant) MUST have WHY. Obvious logic — no comment restating code.

## Code structure

- Helper extraction by theme, not line count.
- Function length cap as signal (most ≤20, hard 40) — extract intent-named helpers.
- `should_/is_/try_/has_/can_/needs_` for predicate/query bools, never action verb.
- Guard early return over goto-ladder when readable.
- Minimal obvious fix — peripheral cleanups in separate commit, "no functional change" labeled.

## Changelog / PR description

- Subject imperative ≤50 chars (When X A→B one idea per para style elsewhere).
- Body: problem/current behavior in present tense first, cause, fix as invariant restored, not plumbing, what NOT done, effect.
- Contrast already-correct path if applicable (missed case, not new pattern).
- One idea per paragraph. 50-word soft cap.
- Public links only.

## Self-review

- List failure modes, wrong assumptions, concurrent derefs before free (general resource lifecycle example).
- Re-derive numbers/claims from source.
- Cut test: would cutting this sentence lose actionable info for external reviewer with zero private context?

## Planning / iteration

- Phase 0 spec interview (socratic-spec) → spec.md with goal, constraints, non-goals, actors, edges, verification cmd+expected, 0 blocking Qs.
- Phase 1 plan iteration → plan.md with observable signal per step, until converged (one iteration no findings).
- Socratic = divergent closes ambiguity, plan-iteration = convergent splits, asks human only on 4 triggers (see plan-iteration-gate).

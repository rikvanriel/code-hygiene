<!-- generated from docs/generic-principles.md by scripts/sync-skill-refs.py — do not hand-edit -->
# Generic principles (cliff notes)

## Factual integrity

- Never invent numbers/dates/hashes/performance claims. Every claim sourced this session.
- Unknown → TODO, not plausible fill.
- Verify claim vs current diff + cmd output. Paste verbatim where possible.
- Forward-port = re-assert: re-validate evidence against new base, don't assume transfer.
- PR description treats unverified prose as bug same weight as wrong code.

## Change splitting

- One logical change per commit/PR — thematic grouping within series (keep same theme consecutive where dependencies allow, reviewer stays in context).
- 200 changed lines in single file triggers examination for seams (mechanical conversion vs behavioral change; move vs rewrite; helper extraction vs first caller).
- Cover letter / PR description owns ordering + prerequisites narrative.

## Comments

- WHY not WHAT, 50-word paragraph cap, one source of truth at definition not header/prototype, cross-ref not duplicate.
- Subtle logic (locking, ordering, lifetime, invariant) MUST have WHY. Obvious logic — no comment restating code.

## Code structure

- Helper extraction by theme, not line count.
- Function length cap as signal (most ≤20, hard 40) — extract intent-named helpers.
- `should_/is_/try_/has_/can_/needs_` for predicate/query bools, never action verb.
- Guard early return over deep nesting.
- Minimal obvious fix — peripheral cleanups in separate commit, "no functional change" labeled.

## Changelog / PR description

- Subject imperative ≤50 chars.
- Body: problem/current behavior in present tense first, cause, fix as invariant restored, not plumbing, what NOT done, effect.
- Contrast already-correct path if applicable (missed case, not new pattern).
- One idea per paragraph. 50-word soft cap.
- Public links only.

## Documentation — positive framing

- **Say what it IS, not what it isn't.** First-line description must provide checkable capability, not list of excluded origins. Bad: "This repo is X-free / not Y / no Z". Good: "Make AI-generated patches easy to review: lintable commits, WHY comments, checkable change splitting, installable via AGENTS.md / CLAUDE.md / .cursor".
- History ("started from ... but generalized"), exclusions ("we don't do ..."), and strict-project specifics belong in `CONTRIBUTING.md` provenance or `docs/references/<example>.md` as worked example — not in README tagline or normative skill description.
- This applies to own docs: README, `docs/`, skill description frontmatter. If you catch a doc defining by negation, rewrite to positive capability + link to provenance doc.

Why: reader arriving via search needs to decide in 5 sec what they get. Defining by negation forces reader to reconstruct what *is* from what *isn't* — extra hop, plus leaks internal history that's not actionable for external adopter.

Encoding: checked by `self-review-gate` cut test ("would an external maintainer with zero context understand what it *provides*?") and `llm-tells` final pass ("defines by negation").

## Self-review

- List failure modes, wrong assumptions, concurrent derefs before free (general resource lifecycle example).
- Re-derive numbers/claims from source.
- Cut test: would cutting this sentence lose actionable info for external reviewer with zero private context? Includes positive framing check.
- Plan iteration: before merge, run (a) what's wrong (b) better way (c) missing (d) boundaries explicit — see plan-iteration-gate.

## Planning / iteration

- Phase 1 spec interview (socratic-spec) → spec.md with goal, constraints, non-goals, actors, edges, verification cmd+expected, 0 blocking Qs.
- Phase 2 plan iteration → plan.md with observable signal per step, until converged (clean sweep across (a)..(d)).
- Socratic = divergent closes ambiguity, plan-iteration = convergent, asks human only on 4 triggers + missing-boundary case (see plan-iteration-gate).

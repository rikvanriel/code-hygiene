---
name: socratic-spec
description: "Socratic interview to assemble project spec — goal, constraints, non-goals, actors, edges, verification — one Q per turn until 0 blocking Qs."
version: 1.1.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [spec, planning, socratic, discovery]
    related_skills: [project-discovery, self-review-gate, plan-iteration-gate]
---

# Socratic Spec — Interview Human to Assemble Spec

Pre-plan phase. Role: divergent — close open questions and produce spec. One Q per turn until 0 blocking Qs remain.

## When this fires

≥3 steps, ambiguous goal, unclear non-goals, or user request is "build X" with no constraints listed. Socratic mode for ≤2-step trivial edits is waste — skip.

## Flow

1. Load `project-discovery` first — upstream rules bound questions you ask.
2. Start from template 7 headings (draft spec even if unknown — TODO marks blocking Q):

```markdown
# <slug> spec

## Goal — what it IS and provides (positive, checkable, not "not X" / "free")
## Constraints — must obey (performance, compatibility, style gate, DCO, existing tests)
## Non-goals — explicitly out of scope + why (link to provenance if history)
## Actors / interfaces — who calls what, ownership, lifecycle
## Edge cases — concurrency, failure, security, perf
## Verification — how we know done (cmd + expected output, not "test it")
## Open Qs — blocking questions for human
```

3. Loop: ask one pointed question per turn, capture answer into spec file, shrink Open Qs.
4. Question banks:
   - CLI/tool: invocation, input/output format, error codes, config file vs flag, backward compat breaking?
   - Library: public API surface, ownership transfer, thread-safety contract, re-entrancy?
   - Web/service: auth model, rate limiting, idempotency, storage backend?
   - Patch series: what is one logical change per commit? dependency order? observable per step?
5. Convergence: goal 1 sentence positive capability + 3-5 constraints named + non-goals named + verification concrete (cmd + expected). No "TBD" left in Goal/Verification.
6. Get human sign-off on spec before moving to plan.

Positive framing: Goal must say what it provides, not list of excluded origins. Bad: "not kernel, kernel-free". Good: "installable skills via AGENTS.md/CLAUDE.md/.cursor with confirmation gate; factual-integrity + WHY comments + changelog one idea/para; references as cliff notes not vendored". See generic-principles "Positive framing". Non-goals holds exclusions with reason, linked to CONTRIBUTING provenance, not in Goal tagline.

## How to ask

- No option enumeration inside question prose — pass as `choices` array when tool supports it. Question string = ONLY question (e.g. "Which deployment target?"), never "1) staging 2) prod".
- Provide 2-4 options when tradeoff non-obvious — but derived from discovery, not made up.
- Keep one Q/turn. Batch questions only if independent and you explicitly label A/B/C.

## Overlap clarification vs plan-iteration-gate and self-review-gate

- This skill = divergent, closes ambiguity. Success = spec.approved. Output = `spec.md`.
- `plan-iteration-gate` = convergent, from approved spec, splits into steps, runs 4 questions per iteration: (a) what's wrong (b) better way (not just split, per fix) (c) missing (d) boundaries explicit. Asks human again ONLY on triggers (ambiguity, constraint tradeoff, irreversible/high-stakes, no convergence after 2 iters + implicit missing boundary).
- `self-review-gate` Gate2 same 4Q but with Gate1 pre-ship (a) wrong (b) better way (c) missing (d) positive framing (e) cut test. Keep (b) wording in sync: "materially better way" not "better split". (d) positive framing encodes rule that Goal must not define by negation.

Flow: socratic closes → plan-iteration re-opens only when plan can't proceed without tie-breaker.

## Verification

- Every Open Q answered or explicitly deferred to Non-goals with reason.
- Constraints cite source: "CONTRIBUTING.md: subject ≤50" or "PR #123 comment".
- Verification steps paste real cmd from repo, not invented.
- Goal positive — no "not X" / "...-free" in first sentence — see generic-principles.

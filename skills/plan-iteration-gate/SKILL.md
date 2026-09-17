---
name: plan-iteration-gate
description: "Use when iterating a plan toward convergence. 4Q loop with human escalation triggers."
version: 1.2.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [planning, review, iteration]
    related_skills: [socratic-spec, project-discovery, self-review-gate]
---

# Plan Iteration Gate

Convergent phase: from approved spec → plan.md with steps, each observable. Runs 4 questions per iteration — per latest fix (b) is "better way", not just "better split".

## Trigger

Complex tasks: ≥3 steps, ambiguous, irreversible, externally visible, high-stakes, or >2 iterations expected. Skip for trivial one-liner.

## Loop — 4 questions per iteration

For each iteration ask in order (a)..(d). Patch plan, re-ask all. Loop till clean sweep (no finding across all 4).

### (a) What's wrong with this plan?

Failure modes: tight loops, unbounded state/handled queue growth, stale handles, injected input, blind suppression (try/except pass), missing fallback, per-item cost unbounded, ambiguous ownership, irreversible without guard, no verification signal, existing workload breakage not checked.

### (b) Is there a materially better way?

Not just split — arch, tradeoff, reuse, ordering, cost.

Check:
- Simpler arch (fewer moving parts, existing generic mechanism in repo or dependency already does it).
- Cheaper/stronger tradeoff (batch vs per-item, push vs poll, memoize vs recompute, cache vs refetch).
- Steps parallelizable vs must serialize — does ordering buy earlier signal?
- Existing upstream tooling / library already provides it — avoid building.
- Different representation (data structure, API shape, file format) removes a seam that forced a split.
- DRY violation creating two implementations — one generic suffices?
- Premature generalization vs duplication threshold.
- If answer is genuinely "no better way beats chosen tradeoff", state explicitly why none beats — with tradeoff (correctness/simplicity/cost/robustness), not just assertion.

Critique given approach — don't redesign goal. An alternative solving different problem is scope creep, not better. Skip only for trivial one-liner.

### (c) Is something missing from this plan?

Most common plan failures are absence, not presence.

Checklist:

- Rollback / cleanup / undo for each irreversible step
- Ownership transfer spelled out (who owns resource after hand-off)
- Non-interference verification (existing workload still correct — which test/build/log proves)
- Boundary / capacity: empty, full, concurrent, re-entrant, boundary ±1
- Observability per step: log line, metric, health endpoint, artifact exists — so correctness (right thing/right params/right place) and non-interference checkable
- Failure notification: how human knows step failed (exit code, health, alert)
- Who owns decision when ambiguous during execution (human trigger owner)
- What unblocks downstream (tag / contract / API / file existence)
- What stays out of scope and why (Non-goals carry-over)

If missing is required for plan to be safe/verifiable, it's finding — not "nice to have".

### (d) Are prerequisites and boundaries explicit?

- Upstream CONTRIBUTING / CLAUDE / AGENTS found? Which file, which section?
- External dependency version pinned? Which artifact / control?
- Irreversible step guarded (backup, feature flag, canary, confirmation gate)?
- Existing tests/build listed as non-interference signal (cmd + expected)?
- Scope limits written (what this plan does NOT do and why — positive framing: say what *is* in scope clearly, link non-goals to separate doc if long)?

### Converged criteria

Converged = one full iteration with no new finding across (a)..(d). Iterating on plan cheap; iterating on implementation wastes cycles.

Watch trend, not count. Findings shrinking each round → converging regardless of iteration count. Recurring same scale/structural → wrong altitude, rescope/restart instead of grinding.

## Plan format

```markdown
# <slug> plan

Goal: one sentence — what it IS and provides (positive, checkable), not what it isn't.
Non-goals: out of scope + why (link to spec or provenance doc, don't define main goal by negation)
Deps discovered: CONTRIBUTING.md X, recent log Y, pinned version Z
Steps:
- [ ] 1. <step> — owner, inputs/outputs, observable (cmd/log/metric/artifact), non-interference check, rollback
- [ ] 2. ...
Risks + mitigations
Rollback: strategy per irreversible step
Verification: end-to-end cmd + expected
Ownership: who decides when ambiguous
Open Qs (should be 0 if socratic done, else triggers)
```

**Positive framing in goals:** Say what it provides (capability, checkable outcome) not list of excluded origins. Bad: "kernel-free, not X". Good: "installable skills + install script that probe ~/.claude/, ~/.hermes/, AGENTS.md with confirmation gate; factual-integrity, comment WHY, changelog one idea/para". Exclusion history / "started from X but ..." belongs in CONTRIBUTING provenance or references doc.

## Human escalation — when to ask

Ask only on 4 triggers + one implicit from (c)/(d) (keeps role disjoint from socratic which is pre-plan divergent):

1. Spec ambiguity not resolvable from written spec+discovery blocks step ordering.
2. Competing constraint tradeoff needs relaxation — e.g. "minimal fix" vs "extract helpers now", "perf target needs bigger change than allowed".
3. Irreversible / externally visible / high-stakes step would execute next and plan still has >1 viable path.
4. No convergence after 2 iters same finding same scale → need scope change signal.
5. Implicit from (c)/(d): missing boundary that only human can settle (e.g. rollback downtime acceptable? canary %?) — convert to (1) or (2) with options.

How to ask:

- 1 sentence context why blocked.
- 2-4 concrete options with tradeoff (correctness/simplicity/cost).
- Your recommendation + what will happen.
- What is blocked until answer.

## Boundary vs socratic-spec

- socratic-spec: divergent pre-plan, output spec.md, closes blocking Qs.
- plan-iteration-gate (this skill): convergent post-spec, output plan.md. Re-opens human Q only when can't proceed without tie-breaker. Document boundary in both so user sees.
- Also self-review-gate Gate2 repeats same 4 questions — this skill is standalone when you want loop definition without Gate1 self-review; keep in sync (b) wording must match: "materially better way", not "better split".

## Related

- socratic-spec for pre-plan.
- self-review-gate Gate1 for per-ship self-review, Gate2 same (a)..(d) — keep (b) wording in sync.
- project-discovery Stage 0 for upstream rules bounding plan.
- factual-integrity for how to source evidence claim in plan.
- generic-principles "Positive framing" section for how to phrase Goal.

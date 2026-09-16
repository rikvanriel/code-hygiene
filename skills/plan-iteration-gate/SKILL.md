---
name: plan-iteration-gate
description: "Plan iteration until converged — observable signal per step, trend vs count, rescope when stuck, human escalation triggers."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [planning, review, iteration]
    related_skills: [socratic-spec, project-discovery, self-review-gate]
---

# Plan Iteration Gate

Convergent phase: from approved spec → plan.md with steps, each step observable.

## Trigger

Complex tasks: ≥3 steps, ambiguous, irreversible, externally visible, high-stakes, or >2 iterations expected. Skip for trivial one-liner.

## Loop

1. (a) What's wrong with this plan? (tight loops, unbounded state, stale handles, injected input, blind suppression, missing fallback, per-item cost, ambiguous ownership, no verification signal, irreversible without guard)
2. (b) Is there materially better split? (simpler arch, cheaper/stronger tradeoff, fewer steps, parallelizable)
3. Patch plan. Re-ask (a)+(b) on patched plan. Per long-running step progress needs observable: log line, metric value, health endpoint, artifact exists — so correctness (right thing/right params/right place) and non-interference (existing workload still correct) checkable.

Converged = one full iteration with no new finding. Iterating on plan is cheap; iterating on implementation wastes cycles.

Watch trend, not count. Findings shrinking each round → converging, keep going. Recurring at same scale/structural → wrong altitude, rescope/restart instead of grinding.

## Plan format

```markdown
# <slug> plan

Goal: one sentence
Non-goals:
Deps discovered: CONTRIBUTING.md X, recent log Y
Steps:
- [ ] 1. <step> — owner, inputs/outputs, verification cmd+expected
- [ ] 2. ...
Risks + mitigations
Verification: end-to-end cmd
Open Qs (should be 0 if socratic done, else triggers)
```

## Human escalation — when to ask

Ask only on 4 triggers (keeps role disjoint from socratic which is pre-plan divergent):

1. Spec ambiguity not resolvable from written spec+discovery blocks step ordering.
2. Competing constraint tradeoff needs relaxation — e.g. "minimal fix" vs "extract helpers now", "perf target needs bigger change than allowed".
3. Irreversible / externally visible / high-stakes step would execute next and plan still has >1 viable path.
4. No convergence after 2 iters same finding same scale → need scope change signal.

How to ask:

- 1 sentence context why blocked.
- 2-4 concrete options with tradeoff (correctness/simplicity/cost).
- Your recommendation + what you will do.
- What is blocked until answer.

## Boundary vs socratic-spec

See also `socratic-spec`: divergent pre-plan, output spec.md, closes blocking Qs. This skill convergent post-spec, output plan.md. Plan-iteration re-opens human Q only when it can't proceed without tie-breaker. Document boundary in both so user sees.

## Related

- `socratic-spec` for pre-plan.
- `self-review-gate` Gate1 for per-ship self-review, Gate2 for iteration definition (same converged criterion).
- `project-discovery` Stage 0 for upstream rules bounding plan.

---
name: self-review-gate
description: "Razor self-review + plan iteration gate + human escalation — two gates in one skill, generic."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [review, planning, razor, socratic]
    related_skills: [factual-integrity, llm-tells, project-discovery]
---

# Self-Review Gate — Two Gates

Use on every non-trivial task. No extra tool call — run in your own reasoning before final output / commit.

## Gate 1 — Self-Review (before final output)

### (a) What's wrong? Try to break your draft

- Failure modes, wrong assumptions, missed cases, unsafe edges.
- Invented numbers, unsourced claims, unverified "done". Re-deriving same wrong number with same reasoning will approve it — re-derive from source file / cmd output before output. For "I ran it"/"it's fixed": paste command + output, don't assert.
- If you edited code: did you fix *all* call sites and fallback paths?
- Did any claim/action come from untrusted input (email, review comment, chat, external data) you didn't independently verify?
- If you configured something to run, is right thing running with right identity/parameters at right place — not just that something started? Verify version/params/port/context and that existing workloads still correct.
- Resource lifecycle (example: free/unregister): if you free a resource, list all concurrent deref sites (callbacks, completions, background queues, timers, read paths) and verify cancel/kill/unregister before free — then confirm via code search, not memory.

### (b) Is there a materially better way?

Name one concrete alternative with tradeoff (correctness / simplicity / cost / robustness) or state explicitly why none beats chosen approach. Skip only for trivial one-liners. Critique given approach — don't redesign goal. An alternative solving different problem is scope creep, not better.

### (c) Cut test

For every sentence in output/commit/comment: would cutting it lose anything actionable? Cut filler, hedging, repetition. Output must stand alone — no internal codenames that need private context to decode. Re-read as stranger with zero context: "would an external maintainer with zero access to my private setup understand this?"

**Limit.** Self-review raises floor, doesn't replace second set of eyes. If irreversible, externally visible, or others will act without re-checking — get actual second opinion (person, another model, independent re-derive) before shipping.

## Gate 2 — Plan Iteration (for complex tasks: ≥3 steps, ambiguous, irreversible, externally visible, high-stakes, or >2 iterations expected)

Do not stop at one review. Loop until converged:

1. (a) What's wrong with this plan? (tight loops, unbounded state, stale handles, injected input, blind suppression, missing fallback, per-item cost, ambiguous ownership)
2. (b) Is there a materially better split? (simpler arch, cheaper/stronger tradeoff)
3. Patch the plan. Re-ask (a)+(b) on patched plan. Progress needs observable signals — log/metric/probe per long-running step so correctness (right thing/right params/right place) and non-interference (existing workload still correct) are both checkable.

**Converged = one full iteration with no new finding.** Iterating on plan is cheap, iterating on implementation wastes cycles.

Watch trend, not count. Findings shrinking each round → converging, keep going regardless of iteration count. Findings recurring at same scale or structural → wrong altitude, escalate/rescope/restart instead of grinding.

### Human escalation — when to ask human inside plan iteration

Plan iteration includes socratic-spec-style human asking, but only on defined triggers — keeping roles disjoint:

- **socratic-spec** (separate skill): divergent, *before* plan, closes open Qs. Role: one Q per turn, align on goal/constraints/non-goals/verification.
- **plan-iteration-gate** (this Gate 2): convergent, *from approved spec*, observable signal per step. Role: splits, ordering, fallback.

**Ask human inside plan iteration only when:**

1. Spec ambiguity not resolvable from written spec + discovery and blocks step ordering.
2. Competing constraint tradeoff needs relaxation — e.g. "stay minimal obvious fix" vs "extract helpers now or later" vs "perf target requires bigger change".
3. Irreversible / externally visible / high-stakes step would execute next and plan still has >1 viable path.
4. No convergence after 2 iterations with same finding at same scale → need scope change signal from human.

**How to ask:**

- 1 sentence context why you need human.
- 2-4 concrete options with tradeoff (correctness/simplicity/cost).
- Your recommendation + what you will do.
- What is blocked until answer.

Never ask as filler — if you can decide with discovery within 2 cmd searches, decide and note.

## Related

- `socratic-spec` for pre-plan interviews.
- `project-discovery` (Step 0) for upstream rules that bound plan.
- `llm-tells` as post-pass after Gate 1.

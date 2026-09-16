# AGENTS.md template — copy to your repo root

Paste relevant sections from code-hygiene skills. Adjust project name and tooling. This file is generic — project-specific strict rules go in docs/references/ as cliff notes.

## Project discovery

```bash
ls CONTRIBUTING* .github/CONTRIBUTING* CLAUDE.md AGENTS.md docs/
```

Obey upstream's own CONTRIBUTING/HACKING rules first. Many hygiene leaks come from skipping this.

## Factual integrity

Never invent numbers/dates/hashes/perf claims. Every claim sourced this session. Unknown → TODO not plausible fill. Paste verbatim cmd+output for "I ran it". Forward-port = re-assert.

## Upstream hygiene — sanitized v2.1 pattern

Commits + PR descriptions + code comments contain ONLY what upstream maintainer can act on with zero private context.

Banned classes (examples use placeholder only):
- Private infra hostnames (`internal.example.invalid`), private registries, local-only ports
- Local absolute paths (`/home/example-user/...`, `~/private/`) — never bare real home
- Internal tooling names, private ticket IDs, CI job names — unless project docs them
- Cross-project tribal lore unless documented dependency
- Personal dev notes ("for our infra", TODO with real user)

Re-read as external maintainer zero context. If sentence needs private context, delete/rewrite.

## Code structure

- Helper extraction by theme, not line count. Length signal most ≤20, hard 40 → extract intent-named helpers.
- Predicate bool naming: should_/is_/try_/has_/can_/needs_ not action verb for query.
- Guard early return over deep nesting.
- Minimal obvious fix — peripheral cleanups separate commit "no functional change".

## Comment quality

WHY not WHAT. 50-word cap. One source at definition. Subtle logic (locking, ordering, lifetime, invariant, ownership, barrier pairing) MUST have WHY. No restating code. Public-only context.

## Changelog / PR

Subject ≤50 imperative, problem present tense first. One idea per para. Fix as invariant restored not plumbing. What NOT done. Public links only. Contrast already-correct path if missed case.

## Self-review gate — 4Q + positive framing + cut (self-review-gate v1.2)

Before final output/commit, run in own reasoning:

Gate1 self-review:
- (a) What's wrong? failure modes, invented claims, wrong assumptions, missed cases, all call sites + fallback paths, untrusted input claims, resource lifecycle (list concurrent derefs before free, verify cancel/kill/unregister)
- (b) Is there a materially better way? one concrete alternative with tradeoff correctness/simplicity/cost/robustness or explicit no-better. Critique approach, don't redesign goal. Wording MUST be "better way" not just "better split" — split is only one dimension (arch, reuse, ordering, representation, DRY)
- (c) Is something important missing? — checklist: rollback/cleanup, ownership transfer, non-interference verification, boundary empty/full/concurrent/re-entry ±1, observability per step (log/metric/artifact/health), failure notification, who owns decision, what unblocks downstream, what stays out of scope (non-goals)
- (d) Positive framing? says what it IS not what isn't; tagline/first 3 paras no "not X"/"...-free"/"without Y". Exclusions belong in CONTRIBUTING/provenance not tagline.
- (e) Cut test: would cutting sentence lose actionable info for external reviewer zero private context?

Gate2 plan iteration (for ≥3 steps, ambiguous, irreversible, externally visible, high-stakes, >2 iters expected):
Loop until converged:
1. (a) Wrong? (b) Better way? (c) Missing? (d) Boundaries explicit?
2. Patch plan. Re-ask (a)-(d). Progress needs observable signals per long-running step.
Converged = one full iteration no new finding. Trend shrinking → converging keep going. Recurring same scale/structural → wrong altitude rescope/restart.
Human escalation inside plan iteration only on 4 triggers: ambiguity not resolvable from spec+discovery blocks ordering, competing constraint tradeoff needs relaxation, irreversible/high-stakes next with >1 path, no convergence after 2 iters same finding.

Limit: self-review raises floor, doesn't replace second eyes. If irreversible/externally visible/others act without re-check — get actual second opinion.

## Positive framing

Capability-positive docs: say what repo provides, not what it isn't. Link exclusions to provenance elsewhere. First 3 paras / tagline MUST NOT define by negation.

## Verification

Every step observable: log line, metric, artifact exists. Existing workload still correct after change.

```bash
./scripts/check-hygiene.sh HEAD   # if you have code-hygiene
```

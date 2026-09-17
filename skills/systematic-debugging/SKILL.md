---
name: systematic-debugging
description: "Use when debugging a failure. 4-phase root cause before attempting a fix."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [debugging, root-cause, reproduction, ownership, verification]
    related_skills: [factual-integrity, code-structure, change-splitting, self-review-gate]
---

# Systematic Debugging — Conduct Before Fixing

Capability: produce fix where reviewer sees cause chain, not fix narrative.

## Principle: Demand root cause before workaround

Don't reboot, don't retry loop suppression, don't blind retry. Demand cause. If unknown, TODO + collect evidence, not plausible fill.

## Phase 0 — Understand

- Who hits it, what breaks (observable failure), when: frequency, workload, recent change.
- Collect artifacts: logs, dumps, repro command, version, config, bisect if available. Paste verbatim, not paraphrase.
- Map ownership: which component owns resource, who serializes access, what synchronizes.

## Phase 1 — Reproducible case

- Minimal reproducible case that produces artifact (log line, metric, failing test, return code).
- Steps: command + expected vs actual. Save file under test/ or attached.
- If cannot repro, document why + what evidence makes fix still justified (production artifact, invariant violation provable by code inspection).

Verification:
```bash
./repro.sh 2>&1 | tee /tmp/repro.log; grep -q "EXPECTED_FAILURE" /tmp/repro.log && echo REPRO_OK
```

## Phase 2 — Minimal fix + ownership analysis

- One logical change — minimal obvious fix first.
- Ownership transfer: list all concurrent deref/callback sites (complete callback, worker queue, timer, read path). Verify cancel/kill/unregister before free via search, not memory — then confirm earliest place leak/failure can occur removed.
- Why not simpler? State explicitly. Helper extraction separate commit per change-splitting.
- Lock/deadlock: table lock order, who takes what, direction, potential cycle — even if no deadlock, write why.

## Phase 3 — Verify including non-interference + boundaries

- Repro passes: artifact gone.
- Non-interference: existing suite still passes — name suite, count.
- Boundary: empty, full, overflow/underflow, concurrent re-entry, rollback — ±1 around edge that triggered.
- Observability per step: log line, metric, health endpoint, artifact exists.
- Failure notification: how future regression noticed? Test, assertion, log, metric.
- What unblocks downstream, what stays out of scope non-goals with reason.

## 4Q gate on debugging plan

(a) What's wrong? Fixing symptom not cause, ownership misses concurrent deref, tight loop unbounded, stale handle, injected input, blind suppression?
(b) Better way? Existing generic mechanism elsewhere in codebase already handles case — reuse? Different representation avoiding special case? State explicitly if none beats with tradeoff correctness/simplicity/cost.
(c) Missing? Rollback plan, cleanup error path, who owns failure notification, boundary empty/full/concurrent/re-entry, what stays out of scope, evidence if cannot fully repro, what unblocks downstream.
(d) Boundaries explicit? CONTRIBUTING found, ext dep version pinned, irreversible guarded, tests named as non-interference signal, scope positive: provides reproducible artifact + minimal fix + ownership table, not "not reboot".

Converged = one iteration no new finding across all 4. Trend shrinking keep going. Recurring same scale wrong altitude rescope to smaller fix or bigger ownership refactor.

## Verification

```bash
git grep -n "callback\|complete\|queue_work\|mod_timer\|show(" -- <pattern> | head -n 50
make check && ./repro.sh && echo PASS
./scripts/check-hygiene.sh HEAD
```

## Related

- `factual-integrity` never invent, TODO, paste verbatim.
- `change-splitting` splitting understand vs fix into separate PRs when large, each intermediate builds.
- `self-review-gate` Gate1 (c) missing overlaps — this details per-debug specifics.
- `project-discovery` Step0 upstream bug report template.

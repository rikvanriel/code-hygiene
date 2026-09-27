---
name: pre-commit-check
description: "Use before commit or push, or when asking if work is ready. Runs hygiene, changelog, and never-invent gates."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [push, ready, gates, verification]
    related_skills: [upstream-hygiene, changelog-quality, factual-integrity, project-discovery, llm-tells]
---

# Pre-Commit Check — Verification Before Every Push

Capability: prevent push until locally verifiable hygiene gates pass. No auto-fix — explicit confirmation.

## Trigger

Before git commit, commit --amend, gh pr create, or any push of series that ships.

## Gate checklist (all must PASS, no skip without reason)

1. Project discovery: CONTRIBUTING/HACKING/AGENTS.md found? Subject convention conventional commits? Trailer Signed-off-by/DCO? Recent git log -20 reviewed? If no guide, note inferred.
   ```bash
   ls CONTRIBUTING* .github/CONTRIBUTING* AGENTS.md 2>/dev/null; git log --oneline -20 | head
   ```

2. Factual integrity: every number/hash/claim sourced this session via file/cmd/benchmark? No plausible fill where TODO belongs? Evidence pasted verbatim?

3. Changelog subject ≤50 imperative present, problem first present in body, one idea per para, invariant not plumbing, public links only.
   ```bash
   head -n1 <<< "$(git log -1 --pretty=%B --no-merges)" | wc -c
   ```

4. Upstream hygiene class check: no private infra hostnames, no local absolute paths under private mount, no internal tooling, no cross-project lore, no personal TODO handles. Examples use example.invalid / example-user placeholder only.
   ```bash
   ./scripts/check-hygiene.sh HEAD
   ```

5. Agent discovery consistency: root AGENTS.md canonical, root CLAUDE.md a short shim pointing back, generator output carrying gates (b) and (c) — verified via `./scripts/build-template.py --profile full` piped to grep, not by diffing checked-in copies (templates/ is generated and git-ignored).

6. LLM tells final pass: tagline first 3 paras not defining by negation not X/...-free, no over-bulleting, no marketing robust/seamless/elegant, no hedging Notably/Importantly.

7. Runnable if touches code: builds + non-interference test named suite + count.
   ```bash
   make check 2>&1 | tail -n 20 || true
   ```

8. Guards are enforced, not documented: a docstring or comment saying "check X before calling" is not a guard — verify the callers actually check. A presence-only gate (both halves exist) does not prove they correspond (rule text and its rationale, field and its parser, flag and its handler). When you fix a bug, look for tests that assert the *old, buggy* behaviour and fix them in the same change; when a failing test disagrees with your fix, decide which reflects reality before touching either (`self-review-gate` review hygiene owns the never-weaken-validation rule).

9. Checks run at the project's declared limit, not the tool's default: a lax default can pass input the project's own configuration would reject. And passing the automated validator is not the review standard — know what the gate does not check. CI must assert the *content* of generated artifacts, not merely that the generator exited 0.

10. Claim-check the summary: does the report state what was *not* exercised — untested areas, areas narrowed for convenience, blockers — rather than only what passed? A verification report that lists only successes is not a verification report.

11. Install/setup instructions verified on a clean machine or a fresh directory, not on the dev box: the author's machine has the dependency, the env var, and the cached artifact already.

## Human escalation format

If gate FAILS and needs tradeoff:

- 1 sentence context why blocked.
- 2-4 concrete options with tradeoff correctness/simplicity/cost.
- Recommendation + what you will do.
- What stays blocked until answer.

Never auto-skip gate as filler — if can decide with discovery within 2 searches, decide and note.

## 4Q on this gate itself

(a) Wrong? Does a check miss a case that leaked before per CONTRIBUTING learnings? **A check never seen failing is unverified — prove the red before trusting the green:** after writing or changing any scan, plant a violation and watch it fail (`./scripts/check-hygiene.sh --selftest` does this per gate in a temp tree). An earlier leak scan used an unsupported regex, errored on every run, and reported PASS indefinitely — green since birth, catching nothing.
(b) Better way? Existing generic mechanism already checks e.g. make lint — reuse vs duplicate? State if none beats with tradeoff.
(c) Missing? Rollback if push fails, failure notification path, observability per verification step, boundary empty repo/full disk/concurrent push, what stays out of scope, who owns failure notification.
(d) Boundaries explicit? Which checks are org-specific private overlay ~/.config/hygiene/extra-check.sh vs public core? Scope positive: provides verification gate with explicit confirmation, not "not auto-fix" only.

## Related

- upstream-hygiene owns banned classes — this wraps its check-hygiene.sh
- changelog-quality GC-10..GC-17 owns subject cap
- factual-integrity R0 never invent
- project-discovery Step0 ordered search
- self-review-gate Gate1 4Q + cut test post-pass after this gate

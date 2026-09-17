---
name: pre-commit-check
description: "Use before every push. Wraps verification gates — hygiene, changelog, never-invent."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [pre-commit, verification, hygiene, check]
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

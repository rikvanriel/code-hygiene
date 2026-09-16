---
name: llm-tells
description: "Strip LLM-generated tells from code, comments, changelogs — final pass before commit/PR, includes positive framing."
version: 1.1.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [review, llm, slop, readability]
    related_skills: [self-review-gate, comment-quality, changelog-quality]
---

# LLM Tells — Final Pass

Final-pass checklist for generic repo (derived from kernel-readability but project-agnostic). Run after self-review-gate Gate1 before finishing.

Scope: text your patch adds/changes. Pre-existing prose out of scope — rewriting it inflates diff and collides with later patches touching same lines. Fix in own commit.

## Verification — never invent

- [ ] Every number/quote/date/perf/hash/claim sourced this session (file, git log/show, cmd output, benchmark, crash dump, public tracker).
- [ ] If don't know, TODO — not plausible fill.
- [ ] Hashes exist in git log (`git show <hash>`) when trailer claims `Fixes: <hash>`.
- [ ] Links public and resolve — no private scheme (`file://`, local report path).
- [ ] Scope matches diff stat — no claims about untouched files.

## Changelog

- [ ] Opens with "This patch …" or fix → rewrite to open with problem/current behavior in present tense.
- [ ] Bugfix doesn't lead with real-world symptom (who hits, what breaks / how observed) → add it; race: CPU0/CPU1 ladder or sequence.
- [ ] Vague justification ("improves performance", "more efficient") — replace with number + named workload + repro, or concrete reasoning. Don't invent numbers; if none say so.
- [ ] Marketing adjectives: robust, powerful, seamless, comprehensive, elegant, gracefully — cut.
- [ ] Hedging filler: "Note that", "Importantly", "It's worth noting" — cut, state fact directly.
- [ ] Double negative ("not X, not Y") — rewrite as positive condition it describes.
- [ ] Recap/"In summary" at end — cut; end on effect or trailer.
- [ ] Bulleted lists where prose fits — convert to paras; keep bullets only for genuinely parallel items or pasted data.
- [ ] No `Fixes:`/`Link:`/`Closes:` where warranted by project CONTRIBUTING — add if project uses.
- [ ] Doesn't say what change does NOT do / limits — add if non-trivial (but phrased positively: "Scope: X, Y. Follow-up: Z" not "This is not ...").

## Positive framing — defines by negation (new)

- [ ] Tagline / first paragraph / skill description defines by what repo/thing *isn't* ("kernel-free", "not X", "no Y", "non-Z") → rewrite to what it IS and provides (capability, installable via, outcome). History / exclusion belongs in CONTRIBUTING provenance or docs/references/<example>.md as worked example, not in README tagline or normative skill description.
- [ ] Doc contains "This is not ...", "This repo is ...-free" in first 3 paragraphs → fix.
- [ ] On fix, link to generic-principles "Positive framing" where rule encoded.

Why: reader via search needs decide in 5 sec what they get. Defining by negation leaks internal history not actionable.

## Comments

- [ ] Comment restates code ("/* increment counter */") — delete.
- [ ] Doc scaffolding on private helper — downgrade to plain WHY or delete; reserve full doc for exported public APIs.
- [ ] Doc comment left describing wrong function after helper inserted — still compiles.
- [ ] Multi-para essay / numbered "plan" comment — compress to 2-8 line WHY.
- [ ] Comment now contradicted by code change — rewrite in same diff.
- [ ] Subtle logic (locking, ordering, lifetime, invariant) with NO WHY — add.
- [ ] Comment defines by negation only ("Not kernel code") → rewrite to contract.

## Code

- [ ] Function over ~40 logical lines — 40-line rule; extract intent-named helpers.
- [ ] Bare `{ }` scoping blocks — declare at function top or helper.
- [ ] goto-ladder where early returns read better — flatten.
- [ ] Drive-by changes mixed with logic change — split separate commit.
- [ ] Pre-existing code newly redundant (call turned no-op by new code, branch now unreachable) — remove, don't let comment explain dead step as if required. Check failure paths too: call unreachable on success may be only thing on early exit.
- [ ] `bool` helper action-named (`drain`, `claim`, `flush` returning bool) — should use `should_/is_/needs_/can_/has_/try_` predicate naming.
- [ ] Missing rollback/cleanup on irreversible step flagged by plan-iteration (c).

## Verification cmd

```bash
# Generic slop markers (placeholder check — adjust)
rg -n "robust|seamless|comprehensive|elegant" src/ 2>/dev/null | head
# Positive framing quick scan (first 3 paragraphs of docs/)
sed -n '1,10p' README.md | grep -i "not.*\|free\|non-" && echo "REVIEW: defines by negation?" || echo "OK"
```

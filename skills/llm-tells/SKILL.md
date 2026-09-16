---
name: llm-tells
description: "Strip LLM-generated tells from code, comments, changelogs — final pass before commit/PR."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [review, style, ai, polish]
    related_skills: [comment-quality, changelog-quality, self-review-gate]
---

# LLM Tells — Final Pass

Run as last step before git commit / PR create. Marks text "delete or rewrite if present". Category: style tells in prose/code added or changed — pre-existing prose out of scope (drive-by cleanup elsewhere inflates small fix and collides). Fix that in its own patch.

## Verification (facts first)

- [ ] Every number/quote/date/perf result sourced this session (file, cmd output, benchmark log, public tracker) — not memory. See `factual-integrity` GC-01.
- [ ] Performance before/after tables match actual benchmark output pasted verbatim; no rounded/invented deltas.
- [ ] Links resolve to public URL — never local path.
- [ ] Changelog scope matches diff stat — no claims about untouched files.

## Changelog tells

- [ ] Opens with "This patch..." or fix-first → rewrite to problem / current behavior present tense per `changelog-quality` GC-11.
- [ ] Bugfix missing real-world symptom (who hits, observable behavior) → add it; for concurrency bug add ASCII timeline of actors.
- [ ] Vague justification ("improves performance", "more efficient") → replace with number or concrete reasoning, or say TODO if not measured.
- [ ] Marketing adjectives: robust, powerful, seamless, comprehensive, elegant, gracefully, leverages, utilizes → cut.
- [ ] Hedging filler: "Note that", "Importantly", "It's worth noting", "Keep in mind", "Essentially", "Basically" → cut, state fact directly.
- [ ] Double negative ("not X, not Y", "doesn't not") → rewrite as positive condition.
- [ ] Recap / "In summary" paragraph at end → cut; end on effect or trailer.
- [ ] Bulleted lists where prose fits → convert to paragraphs; keep bullets only for pasted data or genuinely parallel items.
- [ ] Em-dash sprinkling — prefer periods / parentheses.

## Comments tells

- [ ] Restates code ("/* increment counter */") → delete.
- [ ] Kerneldoc scaffolding `/** @param` on private static helper → downgrade to `/* WHY */` or delete; reserve `/**` for public APIs.
- [ ] Doc comment left describing wrong function after helper inserted (still compiles) → fix.
- [ ] Multi-paragraph essay / numbered "plan" comment → compress to 2-8 line WHY.
- [ ] Comment now contradicted by code change → rewrite in same diff.
- [ ] Subtle locking/ordering/lifetime/invariant logic with NO why-comment → add one per `comment-quality` GC-22.

## Code tells

- [ ] Function over 40 lines → examine per `code-structure` GC-32; extract intent-named helpers.
- [ ] Bare `{}` scoping blocks → declare at function top.
- [ ] goto-ladder where early returns read better → flatten.
- [ ] Drive-by changes mixed with logic → split into separate commit.
- [ ] Pre-existing code made redundant by this change (no-op call, unreachable branch) → remove; don't comment explaining dead step as if required. Check failure paths, not just happy path: a call unreachable when every preceding step succeeds may be the only thing that runs when one bails early.
- [ ] `static bool` helper misnamed as action → rename per GC-34 `should_`/`is_`/`has_` etc.
- [ ] Templated Pros/Cons scaffolding, ornate verbs, over-bulleting in comments.

## Scoped resolution (prevents "approve my own commit")

If agent drove the tool that emitted a style notice you are addressing, the human reviewer is the other eye — do not also set yourself as approver. In single-agent mode that's self-review: say "I addressed X by Y, ready for human" rather than "LGTM".

## Automated helper (optional)

If installed, linter `scripts/check-hygiene.sh --staged` runs automated version with higher confidence bar — cluster requirement, compared against neighboring code, hard cap of 3 findings, phrased as questions rather than flat deletions. Use this checklist to fix yourself before posting, that linter as second noise-gated pass.

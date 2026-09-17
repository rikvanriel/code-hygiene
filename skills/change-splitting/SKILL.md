---
name: change-splitting
description: "Use when a change is large or mixes subjects. Splits work into reviewable one-idea units."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [splitting, bisect, review, series]
    related_skills: [changelog-quality, code-structure, factual-integrity, project-discovery]
---

# Change Splitting — One Logical Change Per Unit

Capability: reviewer can understand, build, test each unit in order without context-switching themes.

## GC-30 — One logical change per commit/PR

- One logical change spanning many files = one commit.
- Two subjects same file = two commits (avoid "please split this up, don't mix SoC with evm stuff").
- Distinct transformation buried in larger one = own commit.
- Don't over-split: 500 edits one file as 500 commits is its own error.

## GC-31 — 200-line trigger to examine for seams

When single source file ≥200 changed lines, examine for separable seams — examination required, not auto-split:

- Mechanical interface/type conversion vs behavioral change riding on top
- Code moved unchanged vs rewritten
- Case already handled correctly needing result reported differently vs genuinely new algorithm
- Helper extracted vs first caller of that helper

Document examination even when keeping together.

Verification:
```bash
git diff --stat HEAD~1 | awk 'NF>=3 && $1+$2 >=200 {print}'
```

## GC-32 — Thematic grouping, not interleaving

When series/PR stack covers multiple themes, keep same-theme consecutive where dependencies/bisect allow, reviewer stays in context. Counterpart to split-by-theme per-patch rule.

Check: `git log --oneline -20` grouping by keyword — would reviewer need to jump mental model back and forth?

## GC-33 — Incremental narrowing — parallel old and new

Before accepting N patches is ceiling because shared caller infra must change all at once, try narrowing:

- Keep old output channel alive unreached for not-yet-migrated callers
- Introduce new path for migrated ones
- Retire old only after all migrated

Standard introduce-new / migrate-one-at-a-time / remove-old. What often separates real ceiling from premature.

## GC-34 — Bisectable, builds on own

Every intermediate:

- Builds
- Passes existing tests / boots minimal
- Behaviorally coherent (no leak until later, no unbalanced refcount alone, no last-use removed N and symbol N+1 — keep same patch or order so nothing dangles)

Never introduce bug in one patch fixed later same series — squash, note after `---` if needed.

## GC-35 — Cover letter / PR description owns ordering

State cross-patch ordering, prerequisites, dep notes in cover letter / PR description, not mechanics block middle of log going into history. Number patches N/M so order unambiguous.

## 4Q gate

(a) What's wrong? Does split mix subjects, break bisect, hide transformation, 200-line trigger unchecked without seam analysis?
(b) Better way? Sweep N=2,3,4... concrete splits named patches scope dep order each builds. Materially better grouping? State explicitly if none beats with tradeoff correctness/simplicity/cost.
(c) Missing? Rollback if middle reverted, ownership transfer, non-interference test suite name, failure notification if bisect fails, what unblocks downstream, what stays out of scope (non-goals with reason).
(d) Boundaries explicit? CONTRIBUTING found for subject/trailer style, external dep version pinned, irreversible schema/migration guarded, scope positive: provides reviewable units so reviewer stays in context, not "not interleaved".

Converged = one full iteration no new finding across all 4. Trend shrinking -> keep going. Recurring same scale -> wrong altitude rescope.

## Verification

```bash
./scripts/check-hygiene.sh HEAD
./scripts/phases.py --phase 2 --profile full 2>&1 | tail -n 20
```

## Related

- `changelog-quality` GC-10..GC-17 owns subject/body
- `code-structure` owns helper extraction by theme — this owns when extraction is own patch
- `project-discovery` Step0 finds upstream splitting convention
- `factual-integrity` owns never invent — cover letter claims verified vs actual patches

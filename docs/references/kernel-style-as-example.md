# kernel-style as example of strict-project wrapper

## TL;DR

`/source/upstream/kernel-style` is a reference implementation of "how to make strict project readable" — 4-phase cumulative load, ID-anchored rationale (`<!-- GC-10 -->` → `grep ID rationale.md`), token budgets, lint scripts. Core principles are reusable here as example; their kernel-specifics stay out of core.

## Provides

- Phase model: Phase0 planning.md (non-trivial trigger), Phase1 coding.md always hot, Phase2 review.md + exemplars-routing mandatory before commit, Phase3 commit.md + changelog-style mandatory.
- ID taxonomy: `R0-*` factual integrity, `CL-*` changelog, `CS-*` code structure, `CC-*` comments, plus `<!-- ID -->` matching hot ↔ cold rationale via `check-orphan-ids.py`.
- Lint chain: `lint-changelog.py` (CL-12 50/70), `lint-code.py`, `checkpatch.pl --strict -g HEAD`, `verify-cover-letter.py`.
- Generic distilled rules we re-used: WHY not WHAT 50-word cap, one source at definition, helper extraction by theme, should_/is_ bool naming, minimal obvious fix, one idea per paragraph.

## License

MIT (same as this repo, sync purposely).

## Use with

When contributing to a strict project that needs own wrapper — copy pattern, not content. Template:

```
myproject-style/
  README.md — phases
  coding.md — structure + comment (project-agnostic bits)
  changelog.md — subject/body (project-specific caps)
  *-rationale.md — Tier3 cold, ID-anchored
  scripts/phases.py — prints cat cmds + token budget
  scripts/lint-*.py — check numbering, one-per-para ports
```

## When not to use

- For non-kernel projects: do NOT import Fixes: hash existence check or checkpatch — those are kernel-only. Use our generic core instead.
- Core stays kernel-free — this file is only example doc under references/.

## Link

- /source/upstream/kernel-style/README.md (local)
- https://github.com/torvalds/linux/Documentation/process/ (upstream inspiration, many rules distilled from there)

---
name: code-structure
description: "Use when a function is too long, nests too deep, or mixes themes. Extracts helpers that earn their names."
version: 1.0.1
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [helpers, naming, long, nested, cleanup]
    related_skills: [comment-quality, factual-integrity, self-review-gate, change-splitting]
---

# Code Structure

<!-- GC-40 --> Prefer minimal obvious fix. Do not duplicate to rename; rename is its own change when safe.

## GC-41 — Extract by logical theme, helper has intent name

- One helper = one theme. Name by what it means, not how it's implemented.
- If split introduced a dep chain, order: preparatory helper before patch that needs it, or split to separate commit with "No change in behavior" or "Prepare for..." if upstream allows preparatory trailers.
- When a hunk unrelated to patch's purpose rides along, split it out: "this doesn't affect any functionality before nor after the core of this patch" — separate commit.

## GC-42 — Function length signal (not hard gate)

- Aim: majority functions ≤20 lines. Hard smell: >40 lines → examine for extractable logical pieces.
- Size alone doesn't reveal seam; look for: mechanical conversion vs behavioral change; moved unchanged vs rewritten; case already correct just needing result reported differently vs genuinely new algorithm; helper extracted vs its first caller.
- If series grows a function across patches without anyone acting because "already long before this patch", that series still owns growth — extract at point of addition, not retrofit later (retrofit forces re-derivation of every later patch and introduces resolution errors).

## GC-43 — Guard early return over goto-ladder, bare `{}` scoping

- Flatten via early returns. Exception: real cleanup path that `goto out;` genuinely unifies — keep when saves duplication.
- Bare `{}` blocks to limit scope → declare at function top instead, or extract helper.

## GC-44 — Predicate bools `should_` / `is_` / `has_` / `can_` / `needs_` / `try_`

`static bool` helper that only tests state (even with guard flag) should use `should_`/`is_`/etc, not action verbs like `drain`/`claim`/`flush`/`schedule`. Bad: `bool flush_cache()`, Good: `bool should_flush_cache()`.

## GC-45 — Locals naming, MIN macro over ternary

- Prefer intent-revealing local name over generic `tmp`, `ret2`.
- Clamp → use language's `min`/`MIN`/`clamp` macro or stdlib, not hand-rolled ternary. Avoids future bugs.

## GC-46 — Ownership + caller clear, bool ownership intent explicit

- Who allocates → who frees? If ownership transfers, comment at transfer point and at definition, not just at call site.
- Functions that conditionally take ownership use name + bool/param that makes intent obvious, or separate try/ensure helpers.

## GC-47 — When in doubt, check existing codebase style first

Run: `git log --oneline -- <file> | head -n 20` + grep same file for sister pattern. Match whatever codebase already does over "textbook ideal".

## GC-48 — One literal, one home

When the same list, path set, or magic value appears in two or more places, hoist it to a single named definition and reference it. Duplicated literals diverge silently — copies added to one site but not the others, with no gate complaining. Applies to data (paths, IDs, thresholds), not just logic; if two copies cannot share a definition, that is a seam worth naming, not an excuse for two copies.

## Related — what belongs elsewhere

- Security invariants in comment: see `comment-quality` GC-22.
- Numbers/perf deltas: see `factual-integrity`.
- Multi-file splitting and bisectable units: see `change-splitting` GC-30..GC-35.
- Strict-project worked example: `references/kernel-style-as-example.md`.

## Verification checklist

- [ ] Every new function has one theme + intent name.
- [ ] Bool helper is predicate-named (GC-44) or renamed in same commit.
- [ ] No bare `{}` block unless justified.
- [ ] Function >40 lines: seams named + reason to keep together if not split.
- [ ] Early return flattened where possible, goto kept only when cleanup truly unified.
- [ ] No hand-rolled `a < b ? a : b`.

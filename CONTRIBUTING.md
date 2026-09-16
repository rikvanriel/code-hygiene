# Contributing to code-hygiene

## License

MIT — matches the origin of some integrated content.

## Single source principle

- factual-integrity owns GC-01..GC-06 (never invent, TODO if unknown, verify vs diff).
- changelog-quality owns GC-10..GC-17 (subject/body rules).
- comment-quality owns GC-20..GC-25 (WHY, density, source-at-definition).
- change-splitting owns GC-30..GC-35 (logical change boundaries).
- code-structure owns GC-40..GC-47 (length signal, predicate naming, ownership clarity).
- upstream-hygiene owns the class-based leak ban and Step 0 discovery.
- self-review-gate owns Gate 1/Gate 2 and the human-escalation triggers.

Others cross-reference, never restate normative text. A rule ID is *declared* by exactly one skill; cross-references elsewhere are expected and allowed.

## Generic core wording

Core `skills/` and `docs/generic-principles.md` state rules in project-generic terms that apply to any codebase. Where a rule needs a concrete example, `docs/references/kernel-style-as-example.md` shows one strict project's wrapper so the rule stays checkable without making that project's gates normative here. Rule text describes what to do; project-specific enforcement detail belongs in the reference entry for that project.

## IDs and rationale (lightweight)

- Rule IDs use `<!-- GC-NN -->` anchors or `GC-NN —` headings; declare each in one owning skill.
- Rationale lives in the owning skill's "Why" text or in a matching reference entry; grep the ID to find it on demand.
- IDs are stable once declared. To reuse a number for a different rule, renumber the old rule instead — the uniqueness check in `check-hygiene.sh` fails on a collision.

## Checks

- `./scripts/check-hygiene.sh` — must PASS before commit. It runs the same class of checks the skills teach: frontmatter present, private paths in placeholder form only, core wording project-generic, rule IDs declared once, root AGENTS canonical / root CLAUDE shim, generator output carrying the 4Q gates, no hardcoded load budgets in entry docs, commit message free of private paths.
- `./scripts/check-hygiene.sh --selftest` — proves every gate can fail. It copies the repo to a temp tree, plants one violation per gate (private path, duplicate rule ID, hardcoded load budget, broken CLAUDE shim), and asserts the real script exits non-zero for each and still passes a clean tree. Run it after touching any scan: an earlier leak scan used an unsupported regex, errored on every run, and reported PASS indefinitely.
- `./scripts/phases.py --phase N` — the source of truth for load budgets. Entry docs cite the script rather than restating a number, so adding a skill cannot leave the docs stale.

## Commit style

- Subject ≤50, imperative, problem-first.
- Body one idea per paragraph, first sentence checkable, state what the change does not do when non-trivial.
- Per upstream-hygiene: commits and comments contain only what an external maintainer can act on — no private infrastructure names, no local absolute paths, no cross-repo lore, no internal tooling names. Examples use `.invalid` / `example-user` placeholders.

## Adding a new skill or reference

- New skill: `skills/<name>/SKILL.md` with frontmatter name/description/version/author/license/tags, generic and checkable, with its own free GC- block.
- New reference: copy `docs/references/template.md`, fill TL;DR / Provides 2-3 checkable rules / License / Use with / Install / When not to use / Link, and add a row to `docs/references/index.md`. Link upstream rather than vendoring.

## Workflow

1. `./scripts/phases.py --phase 0` for discovery.
2. Ambiguous or ≥3-step work: `socratic-spec` → spec, then `plan-iteration-gate` → plan with an observable signal per step.
3. Draft with `factual-integrity` + `code-structure` + `comment-quality`.
4. `self-review-gate` Gate 1 + `llm-tells` before commit.
5. `changelog-quality` + `upstream-hygiene` when writing the message.
6. `./scripts/check-hygiene.sh` must PASS.
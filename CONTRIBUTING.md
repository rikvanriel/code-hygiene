# Contributing to code-hygiene

## License

MIT — matches origin of some integrated content, per feedback.

## Single source principle

- factual-integrity owns R0 (never invent, TODO if unknown, verify vs diff).
- changelog-quality owns subject/body rules.
- code-structure owns function length signal + predicate naming.
- comment-quality owns WHY + density + source-at-definition.
- upstream-hygiene owns class-based leak ban + Step0 discovery.
- self-review-gate owns Gate1/Gate2 + human escalation triggers.
- Others cross-ref, no duplicate normative text.

## Kernel-free core

- Core `skills/` and `docs/generic-principles.md` MUST NOT contain kernel-specific enforcement language ("This patch must have checkpatch", "Fixes: hash required", "KASAN"). Generic mentions like "style gates in CI (e.g. black, ruff, checkpatch-like)" or "Only upstream-relevant trailers: Fixes: <hash> if project uses it" are allowed as examples.
- Kernel specifics live only in `docs/references/kernel-style-as-example.md` as *example* of strict-project wrapper.

## IDs and rationale (lightweight)

- Generic rules may have `<!-- GC-10 -->` style IDs. Rationale entries live in matching `*-rationale.md` or in `docs/references/*` as "Why" section. Grep ID to find rationale on demand.
- For v0.1, IDs optional — focus on checkable wording.

## Checks

- `./scripts/check-hygiene.sh` — must PASS before commit. It runs same class of greps skills teach: no real private /home/ ref, frontmatter valid, kernel-free core.
- `scripts/phases.py --phase 5 --profile full` — token budget checkable, ~11k tok full minimal.

## Commit style

- Subject ≤50, imperative, problem-first where fix.
- Body one idea/para, first sentence = checkable, what NOT done if non-trivial.
- Per upstream-hygiene: commits/comments contain ONLY upstream-relevant — no private infra names, local paths, cross-repo refs, internal tooling names. Examples use `.invalid` / `example-user`.

## Adding new skill / reference

- Copy `docs/references/template.md` for external reference.
- New skill: `skills/<name>/SKILL.md` with frontmatter name/description/version/author/license/tags.
- Keep it generic + checkable, not aspirational.

## Workflow

1. Run `./scripts/phases.py --phase 0` for discovery.
2. If ≥3 steps ambiguous: `socratic-spec` → spec.md sign-off.
3. `plan-iteration-gate` → plan.md with observable per step.
4. Draft code with `factual-integrity` + `code-structure` + `comment-quality`.
5. `self-review-gate` Gate1 + `llm-tells` before commit.
6. `changelog-quality` + `upstream-hygiene` at commit.

## Delegation model

Local delegation runs locally and handles aux tasks. Keep ≤2 concurrent `delegate_task` at once so 2 slots remain for cron + aux.

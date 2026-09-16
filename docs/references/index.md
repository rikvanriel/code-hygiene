# Reference Catalog — Cliff Notes

External repos, skills, and tools that pair well with code-hygiene core. Core ships generic checkable rules; references tell you where deeper tooling lives, with TL;DR so you can decide whether to adopt.

Not vendored — each entry links upstream. Add new entry by copying `template.md`.

## Structure

Each reference entry `docs/references/<name>.md` has:

- TL;DR 1-2 sentences
- Provides: 2-3 checkable rules or workflow snippet
- License
- Use with: when this pairs with core
- Install snippet / wiring
- When not to use
- Link to upstream

## Core vs References

- Core (`skills/`): generic principles that apply almost anywhere — upstream-hygiene, factual-integrity, changelog/comment/code quality, self-review.
- References (`docs/references/`): deeper tooling that is project-specific or complementary — you pull in their skill/repo on top of core.

## Index (seed — flesh incrementally)

| Entry | What it gives | License | Type |
|-------|---------------|---------|------|
| [superpowers](./superpowers.md) | obra's plan/TDD/debugging skills (source of our plan) | Apache-2.0 | skills repo |
| [kernel-style-as-example](./kernel-style-as-example.md) | How kernel-style 4-phase with ID-anchored rationale works as example of strict project wrapping | MIT | example doc |
| template | How to add new reference | — | template |

Planned (add as needed, one per PR):

- `google/eng-practices` — small CLs, WHY comments, review comment quality
- `conventionalcommits.org` + `keepachangelog.com` + `commitlint` — subject/body specs many OSS enforce (map to GC- rules)
- `masoncl/review-prompts` — `/kreview /kseries /kslop` pattern for slash-command distribution (peer-review inspiration)
- Anthropic `CLAUDE.md` best practices, GitHub `copilot-instructions.md`, `.cursorrules` / Cursor / Continue.dev — distribution mechanisms, we provide template → adapter
- lint/security chain: `gitleaks`/`trufflehog`, `typos`, `editorconfig`, `pre-commit` hooks
- stacked PR: `ghstack`, `jj` (jujutsu), `git-branchless` — how change-splitting interacts
- Language style sampling: how python-style's "sample stdlib to derive guide" method generalizes

## How catalog skill uses this

`skills/catalog/` loads this index + skill frontmatter, asks 2-3 Qs about project type, recommends core subset + 2-3 relevant references, shows checklist with TL;DR, then `scripts/install.sh --install <list>` probes agent dirs.

## Adding new reference

```bash
cp docs/references/template.md docs/references/<new>.md
# fill TL;DR, Provides, License, Use with, Install, When not to use, Link
# add row to index table above
# PR should include one example of skill that benefits from it
```

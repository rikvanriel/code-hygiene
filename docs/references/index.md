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

- Core (`skills/`): generic principles that apply almost anywhere — upstream-hygiene, factual-integrity, changelog/comment/code quality, change splitting, debugging, self-review, plus sampling/pre-commit.
- References (`docs/references/`): deeper tooling that is project-specific or complementary — you pull in their skill/repo on top of core.

## Index (13 entries)

| Entry | What it gives | License | Type |
|-------|---------------|---------|------|
| [superpowers](./superpowers.md) | obra's plan/TDD/debugging skills — source of our plan iteration pattern | Apache-2.0 | skills repo |
| [kernel-style-as-example](./kernel-style-as-example.md) | How kernel-style 4-phase cumulative with ID-anchored rationale works as example wrapper for strict project | MIT | example doc |
| [changeset-idiom-example](./changeset-idiom-example.md) | Worked example: sample the project's own changesets to match its comment/message style, terminology, length | MIT | example doc |
| [google-eng-practices](./google-eng-practices.md) | Small CLs, WHY comments, reviewer quality — reviewer-centric language | CC-BY | guide |
| [conventional-commits](./conventional-commits.md) | conventionalcommits.org + keepachangelog + commitlint spec — subject/body specs | MIT / CC-BY | spec + linter |
| [review-prompts](./review-prompts.md) | /kreview /kseries /kslop slash-command distribution pattern | MIT | pattern |
| [copilot-distribution](./copilot-distribution.md) | CLAUDE.md / copilot-instructions / .cursorrules / AGENTS distribution adapter pattern | MIT | adapter |
| [lint-chain](./lint-chain.md) | gitleaks/trufflehog secret scan + typos + editorconfig + pre-commit orchestration | MIT | pre-commit chain |
| [stacked-pr](./stacked-pr.md) | ghstack / jj / git-branchless stacked PR tooling how it interacts with change-splitting GC-30..GC-35 | MIT | tooling |
| [security-audit-lite](./security-audit-lite.md) | semgrep community + visible pattern lightweight pre-commit security | MIT | security |
| [lemmalog](./lemmalog.md) | Local-first working memory: line-protocol facts, budget-aware retrieval | see upstream | memory (MCP) |
| [code-search](./code-search.md) | zoekt content/symbol lookup + semcode semantic cross-refs, both local | MIT/Apache-2.0 + see upstream | search (MCP) |
| template | How to add new reference | — | template |

Planned next (not yet stubbed):

- Language sampling worked examples per language (once `language-style-sampling` skill dogfooded on 2 repos)
- TouchDesigner / creative chain if needed

## How catalog skill uses this

`skills/catalog/` loads this index + skill frontmatter, asks 2-3 Qs about project type:

1. Where code ships? (upstream PR, internal, mail list)
2. Project has conventional commits / stacked PR / pre-commit already?
3. Agent home where you want install? (`~/.claude/skills`, `~/.hermes/skills`, `AGENTS.md`)

Recommends core subset (5-7) + 2-3 references, shows checklist with TL;DR, then `scripts/install.sh --install <list>` probes agent dirs with confirmation gate.

## Adding new reference

```bash
cp docs/references/template.md docs/references/<new>.md
# fill TL;DR, Provides, License, Use with, Install, When not to use, Link
# add row to index table above — one per PR
# PR should include one example of skill that benefits from it
# run ./scripts/check-hygiene.sh HEAD to ensure placeholder-only, positive framing
```

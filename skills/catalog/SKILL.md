---
name: catalog
description: "Use when starting work in an unfamiliar repo or unsure which hygiene skills apply. Recommends a subset."
version: 1.1.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [catalog, discovery, install, onboarding]
    related_skills: [project-discovery, upstream-hygiene, self-review-gate, change-splitting]
---

# Catalog — What's Available + Install

Use when user says "set up hygiene", "make my AI write better PRs", "what skills exist?", or wants onboarding.

## What this skill does

1. Load inventory:
   - `skills/` dirs — read frontmatter description + first para — positive framing, what skill provides not what isn't.
   - `references/index.md` — cliff notes on external repos/tools (10 entries v0.2).
   - `references/generic-principles.md` summary.
   - `AGENTS.md` canonical + `CLAUDE.md` shim note per ADR 0001.

2. Ask 2-3 discovery Qs (clarify choices array, never embed options inside question text):

   - What type of project: library, CLI tool, web service, docs, kernel/module?
   - Where does code ship: personal repo only, OSS fork/PR, company monorepo, mail list patch series?
   - Subject spec: does project already have conventional commits / commitlint / own subject style per CONTRIBUTING? — decides between `conventional-commits` reference vs changelog-quality GC-10.
   - Agent home where you want install: `~/.claude/skills`, `~/.hermes/skills`, `AGENTS.md` generic, `.cursor/rules`, `.github/copilot-instructions.md`?

3. Recommend 5-7 core + 2-3 references based on answers:

   Always unless personal repo only: `upstream-hygiene` + `factual-integrity`
   CLI/library: + `comment-quality` + `code-structure` + `changelog-quality` + `change-splitting`
   Ambiguous task incoming: + `socratic-spec` + `plan-iteration-gate` + `systematic-debugging`
   PRs to OSS: + `project-discovery` + `pre-commit-check`
   Pre-commit self-check: `self-review-gate` 4Q (a) wrong (b) better way (c) missing (d) boundaries + `llm-tells`
   New language/project with sparse style: + `language-style-sampling` + ref `google-eng-practices`
   Conventional commits detected: ref `conventional-commits` + `lint-chain`
   Stacked PR workflow: ref `stacked-pr` + core `change-splitting`

4. Present as checklist with one-sentence TL;DR per skill (cite source file path, not memory) + positive capability. Then offer install.

5. Install gate:

   - List: `scripts/install.sh --list` — probes agent homes.
   - Install: `scripts/install.sh --install <comma-list>` — requires explicit yes.
   - Generic agent: append `cat skills/<name>/SKILL.md` snippet + reference link into `AGENTS.md` with provenance comment `<!-- from code-hygiene skills/<name> -->`.
   - No auto-install ever — confirmation gate.

## Output format

```markdown
## Available — core (shipped, 15 skills v0.2)
- upstream-hygiene — public-only commits/comments class-based ban placeholder-only
- factual-integrity — never invent...
- change-splitting — one logical change per commit, 200-line seam trigger...
- systematic-debugging — 4-phase root cause...
...

## Available — references (cliff notes, not vendored, 10 entries)
- google-eng-practices — small CLs, WHY, reviewer quality
- conventional-commits — type(scope): subject spec + commitlint
- stacked-pr — ghstack/jj/git-branchless
...

## Recommended for your project (5-7 core + 2-3 refs)
- [ ] upstream-hygiene — ...
- [ ] ...
Invoke: ./scripts/install.sh --install <list>
```

## Verification — 4Q

(a) Wrong? Does catalog list skill that doesn't exist on disk, invents description, or violates upstream-hygiene placeholder-only?
(b) Better way? Existing generic mechanism — project already has AGENTS.md with rules — reuse and extend not duplicate? State if none beats with tradeoff.
(c) Missing? Rollback plan if install overwrites existing AGENTS.md, observability per install step (file exists + content hash), failure notification if skill dir not writable, what unblocks downstream (PR creation), what stays out of scope (full language lint config).
(d) Boundaries explicit? Which skills core vs reference cliff notes not vendored, dep version pinned, which checks org-specific private overlay `~/.config/hygiene/extra-check.sh`, scope positive: "provides installable skills + probe + confirmation, not auto-install".

## Anti-patterns

- Listing everything without recommendation — choice paralysis defeats purpose.
- Auto-installing without asking — never.
- Defining by negation "kernel-free" in description — positive capability per positive framing rule.
- Installing references as vendored code — only cliff notes + link, user opts in.

## Related

- `project-discovery` Step0 finds upstream CONTRIBUTING that bounds recommendation.
- `upstream-hygiene` owns banned classes — verification gate uses its check-hygiene.sh.
- `self-review-gate` 4Q own recommendation before presenting.

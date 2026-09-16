---
name: catalog
description: "Picker skill — present available hygiene skills + reference cliff notes, asks 2-3 Qs, recommends subset, offers to install."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [catalog, discovery, install, onboarding]
    related_skills: [project-discovery, upstream-hygiene, self-review-gate]
---

# Catalog — What's Available + Install

Use when user says "set up hygiene", "make my AI write better PRs", "what skills exist?", or wants onboarding.

## What this skill does

1. Load inventory:
   - `skills/` dirs (core skills we ship) — read frontmatter + first paragraph.
   - `docs/references/index.md` — cliff notes on external repos/tools.
   - `docs/generic-principles.md` summary if present.

2. Ask 2-3 discovery Qs (one turn if independent, else one per turn):
   - What type of project: kernel/module, userspace lib, CLI tool, web service, docs?
   - Where does this code go: personal repo, OSS fork, company monorepo?
   - Changelog subject spec: conventional commits, imperative ≤50, or none?

   Tool: `clarify` with choices array — never embed options inside question text.

3. Recommend 5-7 core skills + 2-3 reference adapters based on answers:
   - Always: `upstream-hygiene` + `factual-integrity` unless personal repo only.
   - CLI/library: `comment-quality` + `code-structure` + `changelog-quality`.
   - PRs to OSS: add `project-discovery`.
   - Ambiguous task incoming: `socratic-spec` + `plan-iteration-gate`.
   - Pre-commit self-check: `self-review-gate` + `llm-tells`.

4. Present as checklist with one-sentence TL;DR per skill (cite source file — not memory). Then offer install.

5. Install gate:
   - Present `scripts/install.sh --list` + `--install <comma-list>` for detected agents.
   - Probes: `~/.claude/skills/` (Claude Code), `~/.hermes/skills/` (Hermes), `.cursor/rules/`, `.github/copilot-instructions.md`, generic `AGENTS.md`.
   - Require explicit confirmation before writing any file — no auto-install.
   - For generic agent: `cat skills/<name>/SKILL.md >> AGENTS.md` + reference.

## Output format

```markdown
## Available — core (shipped)
- upstream-hygiene — ...
- factual-integrity — ...
...

## Available — references (cliff notes, not vendored)
- obra/superpowers — plan/TDD/debug — see docs/references/superpowers.md
...

## Recommended for your project
- [ ] upstream-hygiene — ...
- [ ] ...
Invoke: ./scripts/install.sh --install <list>
```

## Verification

- Every listed external ref has `docs/references/<name>.md` with TL;DR, Provides 2-3 checkable rules, License, Install snippet, When not to use, Link.
- No external repo vendored — only cliff notes + link.
- Install script prints what it would write before writing, asks yes/no.

## Anti-patterns

- Listing everything without recommendation — choice paralysis, defeats purpose.
- Auto-installing without asking — never.

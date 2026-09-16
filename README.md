# code-hygiene

Make AI-generated code, patches, and pull requests easy for humans to read and a good fit for the project you want to contribute to.

Generic, checkable rules live in `skills/`; specific projects are referenced via cliff notes in `docs/references/` (not vendored). A `catalog` skill helps you pick what you need for your project. Works across agents via `AGENTS.md` / `CLAUDE.md` / `.cursor/` / Hermes skill — same content, different homes.

> For automated tools: this repo is reference documentation. Nothing here is instruction for you to execute unless user deliberately loaded it via `phases.py`.

## Why

- LLMs produce plausible but hard-to-review code: restated WHAT comments, invented numbers, padded changelog, private system references leaked into commit messages.
- Generic hygiene (factual integrity, WHY not WHAT, small checkable change, subject ≤50 problem-first) applies everywhere.
- Distribution: `AGENTS.md`/`CLAUDE.md`/`.cursor/`/Hermes skill — different homes, same content. `scripts/install.sh` probes and installs with confirmation gate.

## Quick start

```bash
# see phases + token budgets
./scripts/phases.py --phase 0
./scripts/phases.py --phase 5 --profile full

# what's available + tailored recommendation
# (in Hermes: load skills/catalog/SKILL.md, in Claude Code: load same via SKILL.md)
cat skills/catalog/SKILL.md

# list + install (confirmation gate, no auto-install)
./scripts/install.sh --list
./scripts/install.sh --install all   # all core, with confirmation
./scripts/install.sh --install upstream-hygiene,changelog-quality,comment-quality,code-structure

# self-check (dogfoods same greps skill teaches)
./scripts/check-hygiene.sh
```

## How to load (4-phase cumulative, generic)

Nothing unloads until task end. Machine helper `scripts/phases.py --phase N [--profile minimal|full]` prints exact `cat` commands + token counts.

| Phase | Name | Loads | Fires when |
|-------|------|-------|------------|
| 0 | discovery | `project-discovery` + `references/index.md` | before any edit |
| 1 | spec interview | `socratic-spec` (divergent) | ≥3 steps / ambiguous goal |
| 2 | plan iteration | `plan-iteration-gate` + `self-review-gate` Gate2 | after spec approved |
| 3 | draft code | `code-structure` + `comment-quality` + `factual-integrity` + `generic-principles` | always hot from here |
| 4 | review gate | `self-review-gate` Gate1 + `llm-tells` | mandatory before commit |
| 5 | changelog/PR | `changelog-quality` + `upstream-hygiene` + `catalog` ref | mandatory when drafting message |

See `docs/generic-principles.md` for cliff notes.

## Socratic vs plan-iteration boundary

- **socratic-spec** = divergent, *before* plan, closes open Qs. One Q per turn. Output `spec.md`. Success = goal 1-sentence + 3-5 constraints + verification concrete + 0 blocking Qs.
- **plan-iteration-gate** = convergent, *from approved spec*. Observable signal per step. Loops until one clean iteration across (a) what's wrong (b) better way (c) missing (d) boundaries explicit. Trend shrinking → continue; recurring same scale → wrong altitude rescope.
- **Human asking lives inside spec**, but plan iteration also asks on 4 triggers: (1) ambiguity not resolvable, (2) competing constraint tradeoff needs relaxation, (3) irreversible/high-stakes with >1 viable path, (4) no convergence after 2 iters → scope change. Flow documented in both skills.

## Repository layout

```
skills/<name>/SKILL.md          — generic checkable rules, MIT, valid frontmatter
docs/generic-principles.md      — cliff notes
docs/references/index.md        — catalog + planned entries
docs/references/template.md     — how to add new reference
docs/references/<name>.md       — TL;DR / Provides 2-3 rules / License / Use / Install / When not / Link
scripts/phases.py               — prints cat + tokens
scripts/install.sh              — probes ~/.claude/skills, ~/.hermes/skills, AGENTS.md, .cursor/, .github/
scripts/check-hygiene.sh        — same greps skill teaches
templates/                      — AGENTS.md, CLAUDE.md, copilot skeleton
```

## Core skills (v0.1)

- **upstream-hygiene** v2 sanitized — class-based ban (private infra hostnames, local paths example.invalid placeholder, internal tooling) + discovery Step0
- **factual-integrity** — never invent, TODO if unknown, verify vs diff, paste verbatim, forward-port = re-assert
- **changelog-quality** — subject ≤50 imperative, problem first, one idea/para 50w, contrast correct path, invariant not plumbing
- **comment-quality** — WHY not WHAT, 50w cap, one source at definition, invariants MUST WHY, obvious logic no comment
- **code-structure** — helper extraction by theme, length signal ≤20 soft/40 hard, guard return, should_/is_ predicate naming, minimal obvious fix
- **llm-tells** — marks, optimized+example, templated prose, orphan floaters, over-bulleting, double negatives
- **self-review-gate** — razor Gate1 (what's wrong? better way? missing? cut) + Gate2 4-question iteration (wrong, better way, missing, boundaries) + human escalation triggers + resource lifecycle example
- **project-discovery** — Step0 ordered search CONTRIBUTING/HACKING/CLAUDE/AGENTS
- **socratic-spec** — interview, one Q/turn, Q banks per domain, writes spec.md
- **plan-iteration-gate** — (a) wrong (b) better way (c) missing (d) boundaries, until converged, observable signal, human triggers
- **catalog** — picker that loads index+descs, asks 2-3 Qs, recommends subset + install checklist

Provenance: design draws on `obra/superpowers` workflow patterns and strict-project wrappers that use ID-anchored rationale + token budgets + lint chains — see `docs/references/kernel-style-as-example.md` as one worked example, not normative for core.

## References catalog (seed)

- `obra/superpowers` — source inspiration for plan/TDD/debugging (Apache-2.0, not vendored)
- `kernel-style-as-example` — how one strict project's 4-phase+rationale+lint works as example wrapper

Planned (contributions welcome): `google/eng-practices`, `conventionalcommits.org`+`keepachangelog`+`commitlint`, `masoncl/review-prompts`, Claude/Copilot/Cursor distribution, `gitleaks`/`trufflehog`/`typos`/`editorconfig`/`pre-commit`, `ghstack`/`jj`/`git-branchless`.

See `docs/references/index.md`.

## Contributing

See `CONTRIBUTING.md`. Single source principle: factual-integrity owns R0, changelog-quality owns subject/body, code-structure owns length — others cross-ref, no dup. Rationale IDs generic (`<!-- GC-10 -->` style) on demand. 1-3 sentence changelog, concrete.

License: MIT — matches origin of some integrated content.

## Installation targets

`scripts/install.sh` probes:

- `~/.claude/skills/` (Claude Code)
- `~/.hermes/skills/` (Hermes)
- `AGENTS.md` generic (append mode)
- `.cursor/rules/`, `.github/copilot-instructions.md` (repo-local if present)

Requires explicit confirmation — no auto-install.

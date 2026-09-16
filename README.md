# code-hygiene

Make AI-generated code, patches, and pull requests easy for humans to read and a good fit for the project you want to contribute to.

Generic, checkable rules live in `skills/`; specific projects and tools are covered by cliff notes in `docs/references/` (not vendored). A `catalog` skill asks a few questions and recommends what to install. Works across agents via `AGENTS.md` / `CLAUDE.md` / `.cursor/` / Hermes skill — same content, different homes.

> For automated tools: this repo is reference documentation. Nothing here is instruction for you to execute unless a user deliberately loaded it via `phases.py`.

## Why

- LLMs produce plausible but hard-to-review code: restated WHAT comments, invented numbers, padded changelog, private system references leaked into commit messages.
- Generic hygiene (factual integrity, WHY not WHAT, small checkable change, subject ≤50 problem-first) applies everywhere.
- Distribution: `AGENTS.md`/`CLAUDE.md`/`.cursor/`/agent skill — different homes, same content. `scripts/install.sh` probes and installs with a confirmation gate.

## Quick start

```bash
# see phases + current token budgets
./scripts/phases.py --phase 0
./scripts/phases.py --phase 5 --profile full

# what's available + tailored recommendation
cat skills/catalog/SKILL.md

# list + install (confirmation gate, no auto-install)
./scripts/install.sh --list
./scripts/install.sh --install all

# self-check — also run ./scripts/check-hygiene.sh --selftest to prove the scan can fail
./scripts/check-hygiene.sh
```

## How to load (6 phases, cumulative — nothing unloads until task end)

`scripts/phases.py --phase N [--profile minimal|full]` prints the exact `cat` commands and current token counts.

| Phase | Name | Loads | Fires when |
|-------|------|-------|------------|
| 0 | discovery | `project-discovery` + `references/index.md` | before any edit |
| 1 | spec interview | `socratic-spec` (divergent) | ≥3 steps / ambiguous goal |
| 2 | plan iteration | `plan-iteration-gate` + `self-review-gate` Gate2 | after spec approved |
| 3 | draft code | `code-structure` + `comment-quality` + `factual-integrity` + `generic-principles` | always hot from here |
| 4 | review gate | `self-review-gate` Gate1 + `llm-tells` | mandatory before commit |
| 5 | changelog/PR | `changelog-quality` + `upstream-hygiene` | mandatory when drafting message |

See `docs/generic-principles.md` for the cliff-note summary.

## The 4-question iteration gate

Plan iteration and self-review both run the same four questions, looping until one full pass adds no finding:

- **(a) What's wrong?** — failure modes, wrong assumptions, missed cases, unsafe edges, invented claims, all call sites and fallback paths.
- **(b) Is there a materially better way?** — architecture, tradeoff, reuse of an existing mechanism, ordering, representation, DRY. State explicitly when nothing beats the current approach. This is broader than "better split".
- **(c) Is something important missing?** — rollback/cleanup, ownership transfer, non-interference verification, boundary cases (empty/full/concurrent/re-entry ±1), observability per step, failure notification, who owns the decision, what it unblocks, what stays out of scope.
- **(d) Are boundaries and framing explicit?** — upstream CONTRIBUTING rules found, dependency versions pinned, irreversible steps guarded, and the description says what the change *is* and provides rather than what it is not.

Converged = one full iteration with no new finding. Findings shrinking → keep going; findings recurring at the same scale → wrong altitude, rescope instead of grinding.

## Socratic vs plan-iteration boundary

- **socratic-spec** — divergent, before a plan, closes open questions. One question per turn. Output `spec.md`: goal in one sentence, 3-5 constraints, concrete verification, 0 blocking questions.
- **plan-iteration-gate** — convergent, from an approved spec. Observable signal per step. Loops over (a)-(d). Human asking lives inside spec, and plan iteration additionally asks on four triggers: ambiguity not resolvable, competing constraint tradeoff needing relaxation, irreversible/high-stakes with more than one viable path, or no convergence after two iterations.

## Repository layout

```
AGENTS.md                       — canonical contributor notes (agents discover this)
CLAUDE.md                       — thin shim pointing at AGENTS.md
skills/<name>/SKILL.md          — generic checkable rules, MIT, valid frontmatter
docs/generic-principles.md      — cliff-note summary
docs/adr/                       — decisions (canonical AGENTS + shim CLAUDE; rule IDs)
docs/references/index.md        — catalog of external references
docs/references/template.md     — how to add a reference
docs/references/<name>.md       — TL;DR / Provides 2-3 rules / License / Use / Install / When not / Link
scripts/phases.py               — prints cat commands + token budgets
scripts/install.sh              — probes ~/.claude/skills, ~/.hermes/skills, AGENTS.md, .cursor/, .github/
scripts/check-hygiene.sh        — dogfood self-check + --selftest
templates/                      — AGENTS.md + CLAUDE.md distribution copies for other repos
.github/workflows/check.yml     — CI running the self-check
```

## Core skills (15)

Rules:

- **factual-integrity** (GC-01..GC-06) — never invent, TODO if unknown, verify against the diff, paste verbatim, forward-port means re-assert.
- **code-structure** (GC-40..GC-47) — helper extraction by theme, function length signal, guard early return, predicate naming, ownership clarity, minimal obvious fix.
- **comment-quality** (GC-20..GC-25) — WHY not WHAT, density caps, one source of truth at the definition, subtle logic must have WHY.
- **changelog-quality** (GC-10..GC-17) — imperative subject ≤50, problem first, one idea per paragraph, contrast the already-correct path, invariant not plumbing.
- **change-splitting** (GC-30..GC-35) — one logical change per commit, 200-line seam-examination trigger, thematic grouping, bisectable units, incremental narrowing.
- **llm-tells** — final pass stripping AI tells from code, comments, and changelog, including framing by negation.
- **upstream-hygiene** v2.1 — class-based private-context ban with placeholder examples, plus Step 0 discovery of upstream's own rules.

Process:

- **project-discovery** — Step 0 ordered search for CONTRIBUTING / HACKING / AGENTS.
- **socratic-spec** — interview to assemble a spec, one question per turn.
- **plan-iteration-gate** — the 4-question loop until converged, with observable signals.
- **self-review-gate** — Gate 1 self-review plus Gate 2 plan iteration plus human-escalation triggers.
- **systematic-debugging** — understand, reproduce, minimal fix with ownership analysis, verify including non-interference; root cause before reboot.
- **pre-commit-check** — wraps the runnable checks before a push, no auto-fix.
- **language-style-sampling** — derive a style guide by sampling authoritative sources for the language in use.
- **catalog** — picker: asks about project type and where the code goes, then recommends a subset and offers to install.

## References catalog (10)

- `superpowers` — obra's plan/TDD/debugging skill set (Apache-2.0), source inspiration for the planning skills.
- `kernel-style-as-example` — a strict project's phased load + ID-anchored rationale + lint chain, as one worked wrapper example.
- `google-eng-practices` — small changes, clear description, reviewer quality.
- `conventional-commits` — subject/body specs plus commitlint, mapped to the changelog-quality rules.
- `review-prompts` — distributing review as slash-commands.
- `copilot-distribution` — CLAUDE.md, copilot-instructions, .cursorrules, AGENTS.md homes and adapters.
- `lint-chain` — gitleaks/trufflehog, typos, editorconfig, pre-commit hooks.
- `stacked-pr` — ghstack, jj, git-branchless and how they interact with change splitting.
- `security-audit-lite` — lightweight pre-commit security signals.
- `template` — how to add a new entry.

See `docs/references/index.md`.

## Contributing

See `CONTRIBUTING.md`. Single-source principle: each rule block has one owning skill, others cross-reference it. Rule IDs are global (`GC-NN`) and declared in exactly one skill — `check-hygiene.sh` enforces that, along with placeholder-only examples and the AGENTS/CLAUDE note pattern.

License: MIT — matches the origin of some integrated content.
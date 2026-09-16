# AGENTS.md — code-hygiene contributor notes

This repo defines generic, checkable hygiene rules in `skills/` and curated cliff notes in `docs/references/` for skills/tools elsewhere (not vendored). A `catalog` skill helps pick what to install.

## Project discovery

Before editing anything:

```bash
ls CONTRIBUTING.md .github/CONTRIBUTING* templates/AGENTS.md docs/references/index.md
./scripts/phases.py --phase 0
```

Obey CONTRIBUTING.md single-source principle (factual-integrity owns R0, changelog-quality owns subject/body, etc).

## Phase workflow — 6 phases, cumulative, nothing unloads

1. **Phase 0 — project discovery:** `skills/project-discovery/SKILL.md` + `docs/references/index.md`
2. **Phase 1 — spec interview:** `skills/socratic-spec/SKILL.md` — divergent, one Q/turn, closes Open Qs → spec.md
3. **Phase 2 — plan iteration:** `skills/plan-iteration-gate/SKILL.md` — convergent 4Q loop:
   - (a) What's wrong? — tight loops, unbounded state, stale handles, injected input, blind suppression, ambiguous ownership, no verification signal
   - (b) Is there a materially better way? — arch, tradeoff, reuse, ordering, cost, representation, DRY — state explicitly if none beats with tradeoff. Not just "better split".
   - (c) Is something important missing? — rollback/cleanup, ownership transfer, non-interference verification, boundary cases empty/full/concurrent/re-entry ±1, observability per step (log/metric/artifact), failure notification, who owns decision, what unblocks downstream, what stays out of scope
   - (d) Are boundaries explicit? — CONTRIBUTING found, dep version pinned, irreversible guarded, tests as non-interference signal, scope limits positive not negative
   - Observable signal per step, trend vs count, rescope when stuck at same scale
   - Ask human only on 4 triggers: ambiguity unresolvable from spec+discovery, constraint tradeoff needs relaxation, irreversible/high-stakes with >1 path, no convergence after 2 iters same finding → need scope change
4. **Phase 3 — code draft:** `code-structure` + `comment-quality` + `factual-integrity`
5. **Phase 4 — self-review:** `self-review-gate` v1.2 — Gate1 before final output:
   - (a) What's wrong? failure modes, invented claims, concurrent derefs before free, all call sites
   - (b) Is there a materially better way? one concrete alternative with tradeoff or explicit no-better
   - (c) Is something important missing? same checklist as (c) above + ownership transfer, cleanup, boundary
   - (d) Positive framing? says what it IS not what isn't; tagline/first 3 paras no "not X"/"...-free"
   - (e) Cut test: would cutting sentence lose actionable info for external reviewer with zero private context?
   - Limit: raises floor, doesn't replace second eyes. If irreversible/externally visible/others act without re-check — get second opinion.
   Gate2 = same 4Q as plan-iteration.
6. **Phase 5 — changelog/PR:** `changelog-quality` + `upstream-hygiene` v2.1 self-dogfoods

`./scripts/phases.py --phase N [--profile minimal|full]` prints exact cat commands + token budgets. Full ~6781w ~11.5k tok.

## Factual integrity (R0)

- Never invent numbers/dates/hashes/perf claims. Every claim sourced this session.
- Unknown → TODO, not plausible fill.
- Paste verbatim (cmd + output) for "I ran it" / "it's fixed". Don't assert.
- Forward-port = re-assert against new base, not assumed transfer.

## Upstream hygiene v2.1 — sanitized, class-based

Commits, PR descriptions, code comments contain ONLY what upstream maintainer can act on with zero private context.

Banned classes (use example.invalid per RFC 2606, example-user per placeholder):

- Private infra hostnames (`build-host-01.internal.example.invalid`), private registry URLs, local ports unique to env
- Local absolute paths (`/home/example-user/projects/...`, `~/private/`, `C:\Users\example-user\`), never bare real home
- Internal tooling/process: private scripts, cron, ticket IDs, CI job names — unless project documents them
- Cross-project tribal lore unless documented dependency
- Personal dev notes: TODO with real username, "for our perf lab", internal machine names

Re-read as external maintainer zero context. If sentence needs private context to understand, delete/rewrite.

Org-specific real-suffix scanner lives in private overlay `~/.config/upstream-hygiene/extra-check.sh` — never in this repo. Core examples use placeholders only.

Verification before push: `./scripts/check-hygiene.sh HEAD` + `./scripts/install.sh --list`

## Code structure

- Helper extraction by theme, not line count.
- Function length signal: most ≤20 logical, hard 40 → extract intent-named helpers.
- Predicate bools: should_/is_/try_/has_/can_/needs_, not action verb for query.
- Guard early return over deep nesting / goto-ladder when readable.
- Minimal obvious fix — peripheral cleanups separate commit labeled "no functional change".

## Comment quality

- WHY not WHAT. 50-word paragraph soft cap. One source at definition, not header/prototype.
- Subtle logic (locking, ordering, lifetime, invariant, barrier pairing, ownership transfer, validation decision) MUST have WHY: who serializes, what can race, what pairs where, why safe here.
- Comment contradicted by diff → rewrite in same diff. Stale worse than none.
- Public-only context — no private mounts, no "like our fix in other-repo".
- Removal is cleanup, separate drive-by unless explaining logic you change now.

## Changelog / PR

- Subject ≤50 imperative present tense, no period. Opens with problem/current behavior, not "This patch...".
- Body: problem → cause → fix as invariant restored (not plumbing) → what NOT done → effect.
- One idea per paragraph, 50w soft cap.
- Contrast already-correct path if missed case: "GET path already validates; POST was only one that did not."
- Public links only. Treat unverified prose as bug same weight as wrong code.

## Positive framing

Say what it IS, not what it isn't. Capability-positive: "Generic checkable rules in skills/; specific projects as cliff notes in references/; catalog picker + install.sh with confirmation gate."

Exclusion history/provenance belongs in CONTRIBUTING.md and docs/references/kernel-style-as-example.md — not tagline/first 3 paras.

Encoded as check: self-review-gate Gate1 (d) and llm-tells final pass flag first-3-paras defining by "not X" / "...-free" / "without Y". Socratic Goal must be positive capability, non-goals holds exclusions.

## Distribution

- templates/AGENTS.md + templates/CLAUDE.md — distribution copies for OTHER repos to copy from.
- Root AGENTS.md canonical here; root CLAUDE.md thin shim pointing here.
- scripts/install.sh probes ~/.claude/skills, ~/.hermes/skills, AGENTS.md, .cursor/, .github/ with confirmation gate, no auto-install.
- check-hygiene.sh enforces frontmatter, placeholder-only hygiene, root ↔ templates sync.

## Verification

Every step needs observable signal: log line, metric, artifact exists. Existing workload still correct after change. check-hygiene.sh MUST PASS before commit. No bare /home/<real> without example marker in skills/docs.

---
name: skill-authoring
description: "Use when writing, editing, or reviewing a skill's description, tags, structure, or size. Matches triggers to loading context."
version: 1.1.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [description, tags, frontmatter, new-skill, verbose, duplicate, split, references]
    related_skills: [catalog, llm-tells, self-review-gate]
---

# Skill Authoring — Write Skills That Load When Needed

A skill's description and tags are load-time matching material, not
documentation. Write them from the perspective of an AI deciding what to
load for the task in front of it — never from the perspective of the
skill's author describing what's inside.

Every sentence in a skill earns its place the way output does: the cut test in
`self-review-gate` (e) applies to skill and reference text too — if cutting a
sentence would change no reader action, cut it.

## GC-50 — Description opens with the triggering situation

Start with `Use when <situation>.` naming the working context, then one
clause on the outcome. The trigger must land inside the first 57
characters — that is all the skill index shows.

- Good: `Use when debugging a failure — failing test, crash, broken
  behavior. Finds root cause before fixing.`
- Bad: `Systematic debugging — 4-phase root cause: understand,
  reproducible case, ...` (names the method, not the moment).

## GC-51 — Audit against ~6 usage situations per skill

Before finalizing a description, enumerate about half a dozen concrete
situations where the skill could help, written from the user's side
(writing a commit, amending history, a reviewer asking to split,
deciding whether work is ready, hitting a crash or flake). For each,
check whether the situation's vocabulary appears in the description's
first 57 characters or the tags. Add what's missing; leave clean skills
untouched.

## GC-52 — Tags carry trigger vocabulary, not the skill name

Tags must add match terms the description lacks: verbs and nouns a
worker would use (`leak`, `crash`, `flaky`, `cover-letter`,
`clarification`, `escalation`). Never repeat the skill's own name or
category — a tag identical to the skill name matches nothing new.

Split precision across the two fields: descriptions carry
high-precision triggers (situations where the skill is almost certainly
relevant — hidden seams, unreadable functions, stale comments), tags
carry common-but-vague situations (large, mixed) that match often but
discriminate little. Descriptions discriminate, tags recall — a vague
situation in the 57-char window wastes it, while a precise one in tags
is never reached because tag matching only helps when the description
did not already match.

## GC-53 — New skill checklist

- Frontmatter: name, trigger-first description, version, author,
  license, platforms, tags, related_skills.
- Own free GC- block; rule IDs declared exactly once repo-wide. "Free" is measured
  against CONTRIBUTING's range map, not against this file alone: a declared range
  reserves its whole span, so a neighbour's unused number is still taken. Check the
  map before allocating.
- `references/` for entries the skill links (synced from docs/, never
  hand-edited); runnable scripts stay checkout-resident.
- related_skills lists the skills this one pairs with at load time.

## GC-54 — A rule that is not reachable from the always-loaded context is not a rule

A rule that only lives in a file nobody loads at the moment of action will be violated by every future reader, including you. Every mandatory rule needs a trigger line in the context that is loaded when the situation arises — the entry document, the phase file, the skill that fires on that task — and the trigger line says when it applies. Verifying this is mechanical: for each mandatory rule, name the file that gets loaded when its trigger fires, and check the rule is in it.

## GC-55 — Write guidance so its entry point is self-sufficient

A reader who lands on the entry file must be able to reach everything the guidance needs: relative links resolve, referenced files exist, and the order to read them is stated. An entry point that names a document which has moved, or that assumes a directory layout the reader does not have, sends the reader hunting instead of working.

## GC-56 — Project-specific knowledge belongs in a scoped skill, not in always-loaded memory

Facts that apply to one project (its layout, its quirks, its commands) load only for that project's work. Putting them in globally loaded memory spends every future task's attention on a topic that is not in front of it, and buries the cross-project facts that do apply. When a note is project-specific, put it in that project's skill; when it is a general lesson, put it in the general skill.

## GC-57 — Capture a discovered repeatable method as a skill, including why it works

When something you worked out is repeatable — a procedure, a diagnostic order, a pitfall with a fix — write it down as guidance in the same session, with the reason it works and the failure it prevents, not just the steps. The steps alone are re-derived at the same cost by the next reader; the reason is what lets them adapt it when the situation differs. Record the dead ends too: what was tried and ruled out saves the next attempt the same detour.

## GC-58 — One home per piece of guidance: supersede it, don't repeat it

When a rule replaces an earlier one, the earlier text goes in the same change. Two versions left side by side — old sentence beside new, a note that contradicts the rule above it — make the reader obey whichever they read first, and the stale one looks equally current. Sediment accumulates quietly: each addition looks additive and the file drifts into saying several things at once. Making a change also means removing what it replaced.

The same obligation covers a copy that was never a replacement: guidance written twice in different words, in another skill, another section, or a reference. Keep one copy at its owner — the skill whose ID block covers it — and cross-reference it by ID elsewhere. Two copies look equally current, so a reader follows whichever they meet first, and a later correction lands in only one of them. Guidance means a rule, a procedure, an example, or a verification step; repeated vocabulary, a shared term, and a name repeated for clarity are not duplicates — they are the form a cross-reference takes.

Detection is a review pass, not a gate: long duplicated lines surface with the command under Verification. Read them and decide. A gate on this would fire on legitimate cross-reference phrases, which is why the rule lives here rather than in `check-hygiene.sh`.

## GC-59 — Split a skill body by load frequency, not by topic

A skill is read in order to act, and one use rarely needs everything in it. Keep resident what every use needs — the rule text, its trigger, the verification command, the one-line why, and one canonical invocation example per supported shape. Move what only the hard case needs into `references/<topic>.md`: worked examples, long rationale, edge-case taxonomies, per-language detail, incident history, transcripts. Split by how often the material is needed, not by which subject it belongs to — the grouping that feels tidy is often the one needed on every use.

Prose describes, examples get copied — usually without reading the rest. A skill that prescribes an invocation carries the correct pattern copy-paste-ready; pitfalls back up the example, never substitute for it. A skill with warnings but no correct pattern is unfinished: the reader reconstructs the shape from prose and reconstructs it wrong.

- **The pointer stays hot.** A reference nobody is told to open is dead weight: the body keeps a routing line stating what the file holds and when to open it.
- **Split evidence, never obligations.** GC-54's test decides — if a rule must be obeyed when its trigger fires, it belongs in the file loaded at that moment. A rule moved into a reference has been demoted to optional reading.
- **Do not restate the budget.** Cite `./scripts/phases.py --phase N`; the signal of a good split is the hot file's cost dropping and the phase total dropping with it, because references are not in the phase lists.
- **References are not hand-written.** They land as `docs/references/<name>.md` plus a `skills/references.manifest` line, so one canonical copy exists and install materializes it. Runnable scripts stay checkout-resident.

## Verification

```bash
./scripts/check-hygiene.sh HEAD
grep -nE "owns GC-" CONTRIBUTING.md                                       # the range map: allocate outside every declared span
grep -h "^description:" skills/*/SKILL.md | awk '{ print length($0) }'  # descriptions stay one line
awk 'length($0)>=80' skills/*/SKILL.md | sed 's/^ *//' | sort | uniq -d   # duplicated guidance to read
./scripts/phases.py --phase 4                                             # what a phase costs, from the source
```

---
name: skill-authoring
description: "Use when writing, editing, or reviewing a skill's description, tags, or structure. Matches triggers to loading context."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [skill, authoring, description, tags, discovery, frontmatter]
    related_skills: [catalog, llm-tells, self-review-gate]
---

# Skill Authoring — Write Skills That Load When Needed

A skill's description and tags are load-time matching material, not
documentation. Write them from the perspective of an AI deciding what to
load for the task in front of it — never from the perspective of the
skill's author describing what's inside.

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

## GC-53 — New skill checklist

- Frontmatter: name, trigger-first description, version, author,
  license, platforms, tags, related_skills.
- Own free GC- block; rule IDs declared exactly once repo-wide.
- `references/` for entries the skill links (synced from docs/, never
  hand-edited); runnable scripts stay checkout-resident.
- related_skills lists the skills this one pairs with at load time.

## Verification

```bash
./scripts/check-hygiene.sh HEAD
grep -h "^description:" skills/*/SKILL.md | awk '{ print length($0) }'  # descriptions stay one line
```

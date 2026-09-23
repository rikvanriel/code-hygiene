---
name: project-discovery
description: "Use before editing anything in a repo or asking how a project wants contributions. Finds upstream's own rules."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [upstream, contributing, new-repo, guidelines]
    related_skills: [upstream-hygiene, self-review-gate]
---

# Project Discovery — Step 0

Run before any code edit, changelog draft, or PR.

## Search in order (first hit wins — keep first that exists)

1. `CONTRIBUTING.md` / `CONTRIBUTING.rst` / `CONTRIBUTING` at repo root
2. `.github/CONTRIBUTING.md`
3. `docs/CONTRIBUTING.md` / `doc/contributing.*`
4. `HACKING` / `HACKING.md` / `ps/HACKING`
5. `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/` / `.github/copilot-instructions.md` (agent contributor notes if repo ships them)
6. `README.md` / `README.rst` section "Contributing" / "Pull Requests" / "How to Contribute"
7. `src/CONTRIBUTING` (e.g. Exim)
8. Fallback, and always worth the minute: sample the project's own changesets.
   `git log --oneline -20 -- <paths you will modify>`, then `git show` a
   handful of them, ideally by different authors. Written guides rarely cover
   comment and message idiom, so read it off the history and mimic what
   upstream does.

## Command

```bash
ls -1 CONTRIBUTING* 2>/dev/null; ls -1 .github/CONTRIBUTING* 2>/dev/null; \
ls -1 doc/contributing* docs/CONTRIBUTING* 2>/dev/null; \
ls -1 src/CONTRIBUTING 2>/dev/null; \
ls -1 HACKING* ps/HACKING 2>/dev/null; \
ls -1 CLAUDE.md AGENTS.md 2>/dev/null; \
grep -i -n "contribut\|pull.request\|coding.style\|DCO\|sign.*off" README.md README.rst 2>/dev/null | head -n 30
```

## What to extract into spec/plan

- DCO / Signed-off-by required?
- Subject convention (imperative ≤50? conventional commits? scope prefix?)
- Trailer style (`Fixes:`, `Closes:`, `Co-authored-by:` public name no email vs with?)
- Style gates run in CI (formatter, linter, `checkpatch`-like)
- PR template / issue template in `.github/`
- External doc pointer (e.g. devguide.python.org) — follow external doc.
- Agent-specific rules (`CLAUDE.md`) that override generic style at file level?

## Match the project's idiom — comments and changelog

Fit the change to the codebase you are touching: style, terminology, and length
of both comments and the commit message.

- Sample the changesets of the files you will modify, not the repo's whole
  history — idiom differs by subsystem (driver vs core, tests vs docs,
  hand-written vs generated).
- Match three things: style (WHY block vs no comment, prose vs bullets, tense
  and voice), terminology (use the project's own names for its concepts; a
  synonym reads as a second concept), and length (the paragraph and subject
  caps this project actually uses — they refine the generic defaults here, they
  do not replace them).
- Written rules win where they exist and are current; when practice diverges
  from a written rule, follow the written rule and say so in the message.
- Check: `git log -p -3 -- <path>` beside your own diff — do the comment shape
  and message shape look like they came from the same project?

Worked example: `docs/references/changeset-idiom-example.md`.

## Write down

Create `.hermes/plans/<date>_<slug>/discovery.md` or `docs/discovery/<project>.md` with:

- Which file found (path)
- 5-10 bullet summary of must-obey rules
- Link to source file line range
- Anything ambiguous → open Q for human

## When to skip

Trivial one-line fix where recent `git log --oneline -10` subject pattern is obvious and repo has no CONTRIBUTING — still note that you looked and found none.

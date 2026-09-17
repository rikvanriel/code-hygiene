---
name: project-discovery
description: "Use before editing anything in a repo. Finds and follows upstream's own contribution rules."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [discovery, upstream, contributing]
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
8. Fallback: `git log --oneline -20` to infer subject/trailer style when no guide exists — mimic what upstream does.

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

## Write down

Create `.hermes/plans/<date>_<slug>/discovery.md` or `docs/discovery/<project>.md` with:

- Which file found (path)
- 5-10 bullet summary of must-obey rules
- Link to source file line range
- Anything ambiguous → open Q for human

## When to skip

Trivial one-line fix where recent `git log --oneline -10` subject pattern is obvious and repo has no CONTRIBUTING — still note that you looked and found none.

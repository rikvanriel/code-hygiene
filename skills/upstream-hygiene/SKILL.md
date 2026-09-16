---
name: upstream-hygiene
description: "Upstream-only commits and comments — sanitized, class-based ban, no private names."
version: 2.0.0
author: Rik van Riel, code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [commit, changelog, comments, upstream, hygiene, sanitization]
    related_skills: [changelog-quality, factual-integrity, comment-quality]
---

# Upstream Hygiene — Public Only

## When to Use

- Before `git commit`, `git commit --amend`, `gh pr create`, or pushing a PR/series that ships upstream.
- Writing ANY commit message, PR description, or code comment destined for an OSS repo you don't exclusively own.
- Cleaning up changelogs/comments that leaked private context.

**Load this skill whenever touching commit messages, PR descriptions, or comments that will be public.**

## Core Rule

> Commit messages, PR descriptions, and code comments contain ONLY content an upstream maintainer can act on. No private infra, no local paths, no internal tooling, no cross-project tribal knowledge unless documented dependency.

Re-read as an external maintainer with zero context about your private setup. If a sentence requires private context to understand, delete or rewrite it.

## Step 0 — Discover and Obey Upstream's Own Rules

Before drafting, locate the project's contributor workflow. Many hygiene leaks come from skipping this.

Search in order (first hit wins):

1. `CONTRIBUTING.md` / `CONTRIBUTING.rst` / `CONTRIBUTING` at root
2. `.github/CONTRIBUTING.md`
3. `docs/CONTRIBUTING.md` / `doc/contributing.*`
4. `HACKING` / `HACKING.md` / `ps/HACKING`
5. `CLAUDE.md` / `AGENTS.md` (agent contributor notes)
6. `README.md` / `README.rst` section "Contributing" / "Pull Requests" / "How to Contribute"
7. Recent `git log --oneline -20` to infer subject/trailer style when no guide exists

Once found, obey: DCO / Signed-off-by, subject convention, trailer style, style gates in CI (black, ruff, checkpatch, etc), PR template.

This skill's ban rules apply *on top* — upstream never asks for private paths, so there is no conflict.

## Banned Classes (audit these)

Do not enumerate private names — ban classes, with `example.invalid` placeholders per RFC 2606/6761:

1. **Private infrastructure identifiers:** internal hostnames (`build-host-01.internal.example.invalid`), VPN domains, private registry URLs, local ports unique to your env (`http://localhost:12345`), private model/server names.
2. **Local filesystem paths:** `/home/<user>`, `/data/<private>`, `~/private/`, `/tmp/private-*`, `C:\Users\<user>\`, any absolute path under a private mount. Example placeholder: `/home/example-user/projects/...` → never in upstream.
3. **Internal tooling/process:** private scripts, cron jobs, internal ticket IDs, private CI job names, local-only wrappers — unless the project documents them.
4. **Cross-project references:** "like our fix in <other-repo>" unless there is a direct documented dependency (import, API, shared lib). Upstream fix should stand alone.
5. **Personal dev notes:** `TODO(johndoe)`, "we do X in our infra", "for our perf lab", internal benchmark machine names.

**Why class-based:** Listing private names to ban them leaks them. Teach the agent the class, use `example.invalid` in examples, never paste real private suffixes into a skill or commit.

## Allowed Content

- Root cause phrased as "When X, A→B because C" observable from upstream code.
- Minimal reproducing steps using only upstream files/symbols.
- Upstream file references (`src/handler.py:123` if relevant).
- Invariant restored by fix.
- Public links only: `https://github.com/<org>/<repo>/issues/N`, `https://discuss.example.invalid/t/...` if that's upstream's forum — must be public. Never `~/.cache/...` or local report paths (keep those in local notes).

## Verification — before every push

```bash
# Generic hygiene gate — catch private classes (adjust patterns to your org's suffixes locally, never commit real suffixes)
# 1) Absolute private paths that slipped into commit message
git log -1 --pretty=%B | grep -E "^/|/home/|/data/|C:\\\\" && echo "FAIL: local path in commit" || echo "OK"

# 2) Comment diff scanner — added comments with private classes
git diff HEAD~1 | grep -E "^\+\s*(//|#|/\*|\*)" | grep -iE "internal.example.invalid|example\.invalid.*private|TODO$username" && echo "REVIEW: placeholder leaked or TODO" || echo "OK"

# 3) Public-only Link: trailer must not be a file:// or ~/. path
git log -1 --pretty=%B | grep -i "^Link:" | grep -E "file://|/home/|/data/|~/" && echo "FAIL: private Link:" || echo "OK"
```

Org-specific scanner (e.g. your internal domain suffix) lives in your private dotfiles, not in this repo.

## Fixing Leaked History

If private context already shipped:

1. Rewrite local commit with `git commit --amend` before push.
2. If pushed to PR, force-push cleaned commit + note "cleaned private references" — no need to detail what was removed.
3. Never add a commit that lists what was leaked to "explain" it — that doubles the leak.

## Pitfalls

- Copy-pasting from internal design doc → rewrite from scratch for upstream.
- Helper explanation "we use this in our infra" → explain WHY for upstream future reader who can't see your infra.
- Generic helper behavior belongs in code comment/doc, not changelog.
- `Link:` must be public and resolve — not `~/.cache/...` .

---
name: upstream-hygiene
description: "Use before commit, amend, push, or PR, or when cleaning a tainted message. Keeps private context out of public history."
version: 2.1.0
author: Rik van Riel, code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [commit, push, pr, comments, upstream, leak, sanitization]
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

Once found, obey: DCO / Signed-off-by, subject convention, trailer style, style gates in CI, PR template.

This skill's ban rules apply *on top* — upstream never asks for private paths, so there is no conflict.

## Banned Classes (audit these)

Do not enumerate private names — ban classes, with `example.invalid` placeholders per RFC 2606/6761:

1. **Private infrastructure identifiers:** internal hostnames (`build-host-01.internal.example.invalid`), VPN domains, private registry URLs, local ports unique to your env (`http://localhost:12345`), private model/server names.
2. **Local filesystem paths:** home dir of real user (`$HOME/...`), private data mounts (`/srv/private/...`), Windows user profile (`C:\Users\<name>\...`), `/tmp/`-scoped report paths. Example placeholder that IS allowed in docs: `/home/example-user/projects/...` — but never a real user dir.
3. **Internal tooling/process:** private scripts, cron jobs, internal ticket IDs, private CI job names, local-only wrappers — unless project documents them.
4. **Cross-project references:** "like our fix in <other-repo>" unless direct documented dependency (import, API, shared lib). Upstream fix should stand alone.
5. **Personal dev notes:** `TODO(<real-person>)`, "we do X in our infra", "for our perf lab", internal benchmark machine names.

**Why class-based:** Listing private names to ban them leaks them. Teach agent the class, use `example.invalid` in examples, never paste real private suffixes into skill or commit.

**Self-dogfood:** This skill's own verification snippets MUST NOT contain literal banned-class examples as searchable strings (e.g. bare absolute home dir path or internal domain). They must use placeholder tokens (`example-user`, `example.invalid`) plus a comment showing where org-specific suffix lives in your private dotfiles, not here.

## Allowed Content

- Root cause phrased as "When X, A→B because C" observable from upstream code.
- Minimal reproducing steps using only upstream files/symbols.
- Upstream file references (`src/handler.py:123` if relevant).
- Invariant restored by fix.
- Public links only: `https://github.com/<org>/<repo>/issues/N`, public forum URLs. Never local report paths (keep those in local notes).

## Verification — before every push

Keep org-specific real-suffix checks in your private dotfiles/shims, not in this file. This file uses placeholder-based checks only (self-dogfoods).

```bash
# 1) Commit message must not contain bare $HOME or example-home placeholder slipped as real path via copy-paste
#    Real check lives in private overlay — this is skeleton:
git log -1 --pretty=%B | grep -E "example\.invalid.*real-user|TODO\(.*@your-company" && echo "REVIEW: placeholder misuse" || echo "OK"

# 2) Added comments with private classes — scans for internal.todo markers
#    Grep uses placeholder tokens, not real private domains:
git diff HEAD~1 2>/dev/null | grep -E "^\+\s*(//|#|/\*|\*)" | grep -i "internal\.example\.invalid" && echo "REVIEW: example marker still present — strip before commit" || echo "OK"

# 3) Link: trailer must be public http(s) only — private schemes banned
git log -1 --pretty=%B | grep -i "^Link:" | grep -E "file://|example\.invalid/private" && echo "FAIL: private Link:" || echo "OK"
```

Org-specific scanner (your internal domain suffixes, real home root regex, tool codenames) lives in private overlay: `~/.config/upstream-hygiene/extra-check.sh` or equivalent hook — never in this repo. See template in `docs/references/*` for where to wire.

## Fixing Leaked History

If private context already shipped:

1. Rewrite local commit with `git commit --amend` before push.
2. If pushed to PR, force-push cleaned commit + note "cleaned private references" — no need to detail what was removed.
3. Never add a commit that lists what was leaked to "explain" it — doubles leak.

## Pitfalls

- Copy-pasting from internal design doc → rewrite from scratch for upstream.
- Helper explanation "we use this in our infra" → explain WHY for upstream future reader who can't see your infra.
- Generic helper behavior belongs in code comment/doc, not changelog.
- Link: must be public and resolve — not local cache path.
- Verification snippets leaking banned class themselves (this skill v2.0 did exactly that — fixed in v2.1 to use placeholder-only regex so file self-dogfoods).

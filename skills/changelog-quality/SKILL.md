---
name: changelog-quality
description: "Use when drafting or reviewing a commit message, changelog entry, cover letter, or PR description. States problem, cause, fix invariant."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [commit, pr, cover-letter, review, message]
    related_skills: [factual-integrity, upstream-hygiene, comment-quality]
---

# Changelog Quality

## Subject line

<!-- GC-10 --> Imperative, present tense, ≤50 chars. E.g. "Fix open redirect on login POST via crafted next_url". No "This patch..." or "Adds/fixes" — verb first.

<!-- GC-10b --> If project uses conventional commits, defer to that spec (see `references/conventional-commits.md` stub). GC-10 applies only when project has no subject spec.

Verification:
```bash
head -n1 <<< "$(git log -1 --pretty=%B)" | wc -c  # ≤50
```

## Body

### GC-11 — Open with problem / current behavior in present tense, not the fix

Bad: "This patch adds validation for..."
Good: "The POST login path redirects to any URL supplied in `next_url` without checking the host."

### GC-12 — One idea per paragraph, ≤50-word cap per paragraph aim

Structure: problem → cause → fix (one idea) → effect/limits → test (optional). 2-3 cites max per paragraph. No bullet lists where prose fits — keep bullets only for pasted data or truly parallel items.

Rewrite over-bulleting:
- Problem: plain paragraph.
- Cause: "When X, A→B because C" one sentence present tense.
- Fix: one sentence invariant + what change trades. Impl details belong in code comment, not changelog.

### GC-13 — When fixing a gap that other paths already handle, name the contrast

"The GET path and logout already validate `next_url` against the configured host; the POST path was the only one that did not." Tells reviewer this is a missed case, not new pattern.

### GC-14 — Fix paragraph = invariant restored, not implementation plumbing

Bad: "Split drain into __drain(root, sync) where sync=false uses trylock and sync=true uses blocking mutex, call __drain(memcg,true)+flush..."
Good: "Fix by having the offline path wait for pending work for the memcg before freeing it."

Split helper, sync bool, trylock vs mutex belong in code comments/doc, not changelog.

### GC-15 — Say what change does NOT do / its limits if non-trivial

Scope guard: "Does not change behavior for GET", "No fast-path impact".

### GC-16 — Trailer / footer

- Only upstream-relevant trailers: `Fixes: <hash>` if project uses it (kernel, etc), `Closes: #N`, `Link: <public-url>` (must be public). Never `Link: ~/.cache/...`.
- `Signed-off-by:`, `Co-authored-by:` per upstream's convention — discover via `CONTRIBUTING.md` + recent `git log`.
- No internal trailer.

### GC-17 — Generic length gate

No CL-12 50/70 exact — use 50 char subject aim, 72 body wrap convention when project doesn't specify otherwise.

## Verification

```bash
git log -1 --pretty=%B > "$TMPDIR/msg"
awk 'NR==1{print length": "$0} length>50 && NR==1{print "FAIL subject >50"}' "$TMPDIR/msg"
./scripts/check-hygiene.sh --msg "$TMPDIR/msg" 2>&1 | head -n 20
```

## Anti-patterns → rewrite

- Recap/summary paragraph at end → cut, end on effect or trailer.
- Marketing: robust, powerful, seamless, comprehensive, elegant, gracefully → cut.
- Hedging filler: "Note that", "Importantly", "It's worth noting" → cut, state fact.
- Double negatives: "not X, not Y" → positive condition it actually describes.
- Em-dash sprinkling — prefer periods / parentheses.

## Related

- `code-hygiene` distills further to `references/generic-principles.md`.
- `upstream-hygiene` Step 0: discover upstream's own rules first, then apply GC-10..GC-17 on top.

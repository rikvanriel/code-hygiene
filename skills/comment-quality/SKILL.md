---
name: comment-quality
description: "Use when writing, reviewing, or cleaning up code comments. WHY not WHAT, invariants get WHY."
version: 1.0.1
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [comments, readability, documentation]
    related_skills: [code-structure, changelog-quality, upstream-hygiene]
---

# Comment Quality

<!-- GC-20 --> Comments explain WHY code does this, not WHAT the next line does.

## Rules

### GC-20 — WHY not WHAT, density

- "/* increment counter */" → delete (code says WHAT, comment must say WHY).
- Multi-paragraph essay / numbered plan comment → compress to 2-8 line WHY block. Link to issue/pr for long history, not in comment.
- Doc scaffolding `/** @param` on private/internal helper → downgrade to plain `/*` WHY block or delete. Reserve full doc for exported public APIs. Grep for `name - summary` + `@param:` to catch — scaffolding appears under both markers.
- 50-word para cap aim (see changelog GC-12) applies to comments too.

### GC-21 — Placement, one source of truth at definition

- Doc comment lives at definition, not prototype/header when they differ. Header can have brief one-liner or none — deep WHY at def.
- Helper inserted? Doc left describing wrong function after insert still compiles — read for it.

### GC-22 — Subtle logic MUST have WHY

Genuinely subtle logic with no WHY comment is a bug. Check:

- Locking / ordering / lifetime / invariant / barriering / ownership transfer.
- Security / validation decision: why safe here but not elsewhere.
- Concurrency: who serializes, what can race, what barrier pairs where.

If you can answer "why not simpler?" you need a comment.

### GC-23 — Comment now contradicted by code change → rewrite in same diff

Stale comment is worse than none. When changing code, grep nearby comments for contradiction and update them in same commit. Don't let comment explain dead step as if required.

### GC-24 — Public-only context

Per `upstream-hygiene`: no private infra, no internal mount paths, no "this is like our fix in X" cross-project lore. If comment needs external pairing, name only upstream public symbols, e.g. "Pair with update_cache() — must hold lock per contract in cache.c".

### GC-25 — Comment removal is cleanup, not fix — separate drive-by

Removing a long-wrong comment mixed with logic change inflates diff. Do: separate commit "Remove stale comment — no behavior change" or fold only when that stale comment explains logic you are changing now.

## Anti-patterns

| Bad | What to do |
|-----|-----------|
| `i++; // increment i` | delete |
| 20-line plan comment explaining iteration history | compress to invariant + Link to pr/issue |
| `/** This helper does X @param y */` on static private | `/* X because Y */` or delete if obvious |
| Comment says "see jira IN-123" | public link or gist: "See #123" |
| Comment describes other project's fix | rewrite for this project's invariants |

## Positive framing for comments too

Applies from generic-principles "Positive framing". Comment that says "This is not kernel code" or "This is not X" is defining by negation — rewrite to what it IS and its contract. Provenance ("was previously ...") belongs in commit message or docs/references, not in code comment that ships.

## Verification

Use placeholder tokens for verification examples (self-dogfoods upstream-hygiene).

```bash
# Stale pattern: probe nearby file for contradictory TODO
git diff --unified=0 | grep -A2 -B2 "TODO\|XXX\|HACK"
# Private leakage — real scanner lives in private overlay; skeleton here uses placeholder marker
git diff HEAD 2>/dev/null | grep -E "^\+\s*(//|#|/\*|\*)" | grep -i "example\.invalid" && echo "REVIEW: placeholder marker still present — strip or rewrite" || echo OK
```

## Related

- `code-structure` owns helper extraction — this skill owns what comment moves with it.
- `upstream-hygiene` owns banned classes — this skill references it for examples.
- `generic-principles` Positive framing — where tagline rule encoded.

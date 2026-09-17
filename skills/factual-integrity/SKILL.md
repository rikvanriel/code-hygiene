---
name: factual-integrity
description: "Use when writing or verifying claims — numbers, hashes, quotes, perf results. Sources or TODOs it."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [claims, numbers, invented, unverified]
    related_skills: [upstream-hygiene, self-review-gate, changelog-quality]
---

# Factual Integrity

<!-- GC-01 --> Never invent a number, hash, benchmark result, error message, perf delta, or reproducer output. If you didn't run it or read it this session, you don't know it.

## Rules

### GC-01 — Every claim sourced this session (file, cmd output, issue tracker, benchmark log — not memory) — not invented

- Numbers, before/after tables, error messages, logs: paste verbatim from tool output. No rounded/invented deltas.
- Commit hashes must resolve via `git show <hash>` — if it doesn't exist, don't cite it.
- Links must resolve to a public URL, not a local file path.

### GC-02 — If you don't know, TODO — not plausible fill

Put `TODO: measure X` in code comment or changelog when data missing, not a made-up value. A missing benchmark is less harmful than a fabricated one the reviewer builds a decision on.

### GC-03 — Verify claim vs diff before writing it

Changelog scope must match `git diff --stat` — no claims about files untouched by diff.

### GC-04 — Cover letter / PR description claims checked against each patch's own current changelog/diff, not earlier draft or pre-split version

After splitting/moving hunks, re-derive every number from its owning patch's current diff. Cover letters go stale first.

### GC-05 — Forward-port = re-assert all claims

When porting onto newer base, every number, error message, function size, and reproduction step must be re-measured on new base. Old numbers surviving a rebase are wrong until proven current.

### GC-06 — Treat unverified prose as a bug on par with wrong code

Unverified "improves performance by 10%" without measurement is a bug. Gate with `scripts/check-hygiene.sh`.

## Workflow insert

1. Run command / read file.
2. Paste output verbatim into scratch.
3. Draft sentence *from* that paste.
4. Link pasted source in commit note for reviewer ("repro: `cmd` → see log").

## Verification

```bash
# Every number in the staged changelog must have a tool log backing it this session
git log -1 --pretty=%B | grep -E "[0-9]+%|[0-9]+ms" && echo "VERIFY: number present -> needs cmd log in scratch/PR body" || echo "OK"
git log -1 --pretty=%B | tr '\n' '\0' | xargs -0 -I{} sh -c 'echo "{}" | grep -oE "[a-f0-9]{7,40}" | while read h; do git show --oneline -s $h 2>&1 >/dev/null || echo "FAIL: hash $h not found"; done; echo OK'
```

## Anti-patterns

| Bad | Good |
|-----|------|
| "This improves throughput significantly" | "Before: 1200 req/s, After: 1350 req/s (+12.5%), workload `bench.sh --profile fast`, 3 runs median. Log: ..." |
| Commit claims "fixes race in X and leak in Y" but diff only touches X | Split or trim changelog to diff scope |
| Pasted old benchmark from previous branch | Re-run on current base, new numbers |

## Related

- `changelog-quality` for prose shape (GC-01/02 here = fact gate, there = shape).
- `upstream-hygiene` for what belongs in commit vs local notes (benchmark logs stay local or linked via artifact, not pasted into upstream commit unless project wants them).

---
name: artifact-handoff
description: "Use when handing an artifact to someone, or trusting one you received — identity, provenance, verification."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [artifacts, handoff, provenance, cache, verification]
    related_skills: [evidence-discipline, factual-integrity, project-discovery]
---

# Artifact Handoff

Capability: an artifact that leaves your hands can be identified, traced to its inputs, and trusted by whoever receives it — and an artifact you receive can be checked before you act on it.

## Trigger

Producing a file for a person or another system (report, render, dataset, package, index, cache); receiving one; writing a derived value that will be read later.

## Rules

### GC-80 — A handed-over artifact identifies itself

The filename or an on-artifact label carries the source it came from, the run or date, and the parameters that shaped it. A label burned into the artifact survives a chat client that hides filenames; a directory listing does not. When several versions of the same artifact exist, the identifier is what keeps "the one I sent" from being a guess — for anyone, including you tomorrow.

### GC-81 — A generated artifact retains the inputs it was derived from

A digest, summary, report or generated file records which source revision, size, or window it was computed from, so its claims stay re-verifiable after the logs rotate and the intermediate files are cleaned. A generated claim whose inputs are gone is indistinguishable from an invented one.

### GC-82 — A cached or derived value records its provenance and invalidates on change

Anything cached, memoized, precomputed or otherwise derived carries the identity of what it was computed from (source version, file size and mtime, a hash, a parameter set) and is recomputed when that identity changes. Serving a cached result built from a different input is the quiet failure: the value looks fresh and is wrong.

### GC-83 — Read back what you wrote

After writing to a store — memory, index, database, cache, file — read the value back from that store to confirm it is retrievable and correct. A successful write call is not evidence the value is there: dropped writes, silent schema mismatches and stale copies are all invisible until something reads.

### GC-84 — A local success is not a remote state

A successful push is not a merged change; a submitted form is not an accepted value; a locally-correct file is not a deployed one. Confirm the state you actually care about with a fresh read of the authoritative source, and report the distinction between "I sent it" and "it landed".

## Verification

```bash
# Artifact identity: name carries source + run, and the hash of what you send
sha256sum dist/*.tar.gz && ls -l dist/ | head
# Cache provenance: the key includes the input identity, not just the request
grep -rn "mtime\|sha256\|version" cache/ --include='*.py' | head -n 5
# Read-back after write
grep -rn "read_back\|verify_written\|assert .*exists" src/ --include='*.py' | head -n 5
```

## Anti-patterns

| Bad | Good |
|-----|------|
| `output.mp4` sent with the run described in chat | `steadycut_run3_ride42_hfov120.mp4`, parameters also drawn on the first frame |
| "Wrote 37 facts" as proof of persistence | Dump them back from the store and count again |
| Cache keyed on the request only | Key includes source identity; invalidated when it changes |
| "Pushed, so it's done" | Read back the merged state, or say "sent, not yet landed" |

## Related

- `evidence-discipline` GC-68 — verify the artifact you deliver is the one you measured.
- `factual-integrity` — a claim with no retained source is unverifiable; this skill keeps the source.
- `project-discovery` — where the project's own artifact and cache conventions live.

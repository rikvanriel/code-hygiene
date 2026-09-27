---
name: repo-hygiene
description: "Use when something must not live in a maintained source tree — paths, runtime state, data, duplicates."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [repository, layout, paths, config, duplicates]
    related_skills: [code-structure, upstream-hygiene, project-discovery]
---

# Repo Hygiene — What Does Not Belong in the Tree

Capability: decides where a value, a file or a script belongs, so a maintained repository stays reproducible on another machine and does not accumulate state nobody can re-derive.

## Trigger

Adding a file to a repo, introducing a path or a constant into code or tests, keeping a value the code reads at runtime, writing a script during investigation, or producing a copy of something already in the tree.

## Rules

### GC-90 — No machine-specific absolute paths in code, tests, or scripts

The location is a parameter, or it is resolved from a standard location relative to the project, the user's home, or the platform's convention. An absolute path from your machine breaks on every other machine and turns a test into a local-only test that passes where it was written and fails in CI. This is the test-and-tool variant of the upstream-hygiene ban: the commit-message scan will not catch it, because it lives in the source.

### GC-91 — Runtime values live in configuration, not in the code

A threshold, allow-list, host list, prompt, or tunable that a user may need to change at runtime belongs in an external configuration file (with a documented default), not hardcoded in the script or module. Hardcoding is the reason a later change becomes a code change, a rebuild, and a release.

### GC-92 — A generic module contains no case-specific constants

If a module is advertised as reusable, generic, or policy-independent, it cannot carry constants that belong to one case, one vendor, or one deployment: those either come in as parameters or stay in the caller. A "generic" module with a case constant is a special-case module wearing a generic name, and every future caller inherits the assumption.

### GC-93 — Mutable and machine-derived data lives outside the source tree

Device registries, calibrated or measured parameters, discovered mappings, caches, and anything else produced by running the code goes in the user's configuration or data directory, never committed into the source. Measured data in the tree is (a) wrong on the next machine, (b) indistinguishable from a constant someone intended, and (c) re-derived by every user who reads it as fact.

### GC-94 — Throwaway scripts do not accumulate in the repository

Investigations produce scripts; the repository does not keep them unless one is promoted to a maintained tool, in which case it gets a name, a place, and tests like anything else. An experiment left in the tree reads as supported functionality, and the next reader has to work out whether it is.

### GC-95 — One canonical copy; the second copy is generated

Never keep two hand-maintained copies of the same content in a repo. One file is canonical and any second copy is produced from it at install, build or generate time, with the mechanism committed alongside — a manifest, a generator, or a symlink — so the copy cannot drift. Two hand-edited copies always diverge, and the divergence surfaces as a bug in whichever one the reader did not open.

### GC-96 — Run services and helper scripts at the least privilege they need

Install as the privileged user when that is required, then run as an unprivileged user; keep binaries and configuration non-writable by the account that runs them; give a helper the narrowest remote credential that does its job. Privilege is a property of the running process, not of the installer, so "we installed it as root" is not a reason for it to run as root.

## Verification

```bash
# Absolute local paths in code and tests (should return nothing outside placeholders)
grep -rnE "^(#|//).*(/[a-z]+/)+[a-z]" src/ tests/ 2>/dev/null | grep -v example | head
# Runtime tunables in external config, not literals
grep -rnE "(threshold|timeout|host|allow.?list) *=" src/ --include='*.py' | head
# Two copies of the same file?
git ls-files | xargs -r -n1 basename | sort | uniq -d | head
# Generated copy is actually generated
grep -rn "generate\|manifest\|copy" Makefile scripts/*.sh 2>/dev/null | head -n 5
```

## Anti-patterns

| Bad | Good |
|-----|------|
| `INPUT = "/home/example-user/data/fixture"` in a test | Fixture path resolved from the test directory or an env var with a default |
| `MAX_RETRIES = 7` deep in the module | Config key with a documented default |
| Machine-measured coefficients committed as constants | Measured at run time into the user's config directory |
| Three analysis scripts left in `tools/` after an investigation | One promoted tool with tests; the rest in a scratch directory |
| Vendored copy of a doc also hand-edited in the repo | Canonical doc plus a generator that materializes the copy |

## Related

- `upstream-hygiene` — banned classes *inside* commits and comments; this skill covers where things live in the tree.
- `code-structure` — one literal, one home; module boundaries and helper extraction.
- `project-discovery` — the project's own layout and config conventions come first.

---
name: language-style-sampling
description: "Use when adopting an unfamiliar language or codebase style. Derives a guide by sampling."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [style, sampling, guide, authoring]
    related_skills: [project-discovery, code-structure, comment-quality, changelog-quality]
---

# Language Style Sampling — Derive Guide From Sample

Capability: produce checkable style rules for any project/language by sampling authoritative sources, not LLM prior.

## When

Before authoring new skill or CONTRIBUTING style section for language/project whose CONTRIBUTING is sparse, or onboarding new repo.

## Method

1. Discover authoritative sources ordered:
   - Language official style: Effective Go, PEP8 / Google Python Style, Rust API Guidelines, Mozilla JS Guide, clang-format doc, project's own CONTRIBUTING/HACKING.
   - Sample 3-5 real files from canon (stdlib, well-maintained cited repo), not random snippets. Paste paths.

2. Extract checkable rules — 5 categories:
   - Naming: files, functions, predicate bools should_/is_/try_, constants, packages.
   - Comment density: WHY not WHAT, where doc lives definition vs header, subtle logic MUST WHY.
   - Error handling: return vs exception, wrapping, logging level, sentinel vs typed.
   - Function length signal: typical ≤20 logical, hard 40 — what prompts extraction and how to name helper by intent theme.
   - Trailing hygiene: public links only, banned class private paths, subject style if conventional commits enforced.

3. Encode as checkable rules with example paths/hashes:
   - Each cites source file + line or commit hash, not vague widely used.
   - Distinguish rule (must) vs signal (exam trigger) vs anti-pattern (delete/rewrite).
   - Positive framing: what it provides, not only exclusions.

4. Verify by scoring real diffs:
   - Run sampled rules against 2-3 recent diffs, note true positive rate. Rework if <50% actionable.
   - Dogfood: ./scripts/check-hygiene.sh variant for language-specific lint if project has one.

## Example generic

- Sampled src/handlers/ 3 files: avg function 18 lines, 2 helpers extracted by theme auth vs validation.
- Derived: Function length signal most ≤20 hard 40 → extract intent-named helpers with example paths src/handler_a.go:42 as evidence.
- Not obviously short vague — number vs source.

## Anti-patterns

| Bad | Why | Better |
|-----|-----|--------|
| "Use short names" | not checkable | "≤20 chars local, 2-3 words intent helper, predicate should_/is_ per code-structure" |
| Generates guide from memory without sampling | violates factual-integrity R0 never invent | Sample 3-5 files paste paths + cmd output |
| Copies kernel terms verbatim into Python project | wrong authority | Adapt signal not terminology — bisectable becomes CI must pass per commit in stack |

## 4Q

(a) Wrong? Rules invented without sampling? Examples use private paths?
(b) Better way? Existing generic mechanism e.g. golangci-lint config — reuse rather than duplicate?
(c) Missing? Rollback if new guide conflicts with upstream CONTRIBUTING, non-interference verification existing CI still green, boundary empty file/generated file, failure notification if guide drifts, who owns decision, what unblocks downstream.
(d) Boundaries explicit? Which sources authoritative vs supplemental, which checks org-specific private overlay ~/.config/hygiene/extra-check.sh, scope positive: provides method that produces checkable guide sampled from canon, not list of excluded things.

## Verification

```bash
ls -R <sample-path>/ | head -n 50; wc -l <sample-files>
./scripts/check-hygiene.sh HEAD 2>&1 | tail -n 20
```

## Related

- project-discovery Step0 ordered search upstream CONTRIBUTING
- code-structure helper extraction by theme predicate naming — this method derives those for new language
- comment-quality WHY rules sampled source shows where WHY required
- factual-integrity never invent — sampling as evidence

# Changeset idiom — worked example of sampling a project's style

## TL;DR

How to read a project's comment and commit-message conventions off its own
changesets when no written guide covers them: pick the files you will modify,
sample their recent history with `git log`/`git show`, and match style,
terminology, and length. Generic core caps (subject ≤50, 50-word paragraphs)
are the *fallback*, not the *target*.

## Provides

- Sampling recipe, concretely:
  ```bash
  git log --oneline -20 -- <paths you will modify>   # subject shape
  git show <hash> of 2-3 commits that touched the same files,
      by different authors                           # comment + body shape
  git log -p -3 -- <path>                            # final against-your-own-diff check
  ```
  Never sample only the current series' own patches: patch 10 of a series
  whose history window is patches 2, 3, and 5 calibrates the draft against
  the series' own prose — if that prose was LLM-written, the check validates
  the draft against itself. Diverse authors measure the file's norm, not one
  contributor's habits.
- Three dimensions to match, with example signals:
  - Style — WHY block vs no comment; prose vs bulleted body; present vs past tense;
    imperative vs descriptive subjects.
  - Terminology — the project's own concept names; a synonym for an existing
    concept reads as a second concept (e.g. if the codebase says "route", do not
    introduce "endpoint" for the same thing).
  - Length — actual subject/paragraph lengths in `git log`, which can differ from
    the generic 50-char/50-word caps in `changelog-quality` GC-10/GC-12.
- Decision order: written rule (CONTRIBUTING/CLAUDE.md) > sampled practice >
  generic default. When written rule and practice disagree, follow the written
  rule and note the divergence in the message.

## License

MIT.

## Use with

- `project-discovery` (owning skill) — run before any edit, changelog draft, or PR.
- `comment-quality` (GC-20..GC-25) — the sampled style tells you whether the project
  wants a WHY block at all, and at what density.
- `changelog-quality` (GC-10..GC-17) — sampled subjects refine the 50-char cap:
  a project that ships 72-char conventional-commit subjects is a project that
  ships 72-char subjects.

## Install / wiring

Via `skills/references.manifest` (attached to the three skills above):

```bash
project-discovery	references/changeset-idiom-example.md	docs/references/changeset-idiom-example.md
comment-quality	references/changeset-idiom-example.md	docs/references/changeset-idiom-example.md
changelog-quality	references/changeset-idiom-example.md	docs/references/changeset-idiom-example.md
```

## When not to use

- Project ships a complete written style guide with enforced linters — follow
  those; sampling is the fallback when the written layer is sparse or silent
  about comments/messages.
- Trivial one-line fix where the surrounding idiom is already visible in the
  same file — sampling three commits is still faster than guessing, but
  unnecessary depth is code smell.

## Link

- Owning rule: `skills/project-discovery/SKILL.md` § "Match the project's idiom — comments and changelog"
- Pattern model: `docs/references/kernel-style-as-example.md` (worked-example reference convention)

<!-- generated from docs/references/conventional-commits.md by scripts/sync-skill-refs.py — do not hand-edit -->
# Reference: conventional commits + keep a changelog + commitlint

## TL;DR

Specs for commit subject/body shape many OSS enforce. Maps to code-hygiene changelog-quality GC-10..GC-17 with concrete linters.

## Provides

- **conventionalcommits.org spec:** `type(scope): subject` structure + breaking `!` marker. Checkable via `commitlint` config. When project uses it, GC-10 subject rule defers to this spec — see `conventionalcommits.org`.
- **keepachangelog.com:** changelog sections (Added/Changed/Fixed) that map PR description structure.
- **Linter:** `npx commitlint --edit` gate for pre-commit-check.

## License

MIT / CC-BY.

## Use with

`changelog-quality`, `pre-commit-check`. If project-discovery finds `.commitlintrc` or `CONTRIBUTING.md` mentions conventional commits, this reference is authoritative for subject shape.

## Install / wiring

```bash
npm install --save-dev @commitlint/{cli,config-conventional}
echo '{extends:["@commitlint/config-conventional"]}' > commitlint.config.json
npx husky set .husky/commit-msg "npx commitlint --edit $1"
```

Plus `./scripts/check-hygiene.sh HEAD` still for upstream-hygiene banned classes.

## When not to use

Kernel, many Python/C projects use own subject style (imperative problem-first, no type prefix) — don't force conventional when upstream doesn't use it. Project-discovery decides.

## Link

https://www.conventionalcommits.org/en/v1.0.0/
https://keepachangelog.com/
https://github.com/conventional-changelog/commitlint

# Reference: lint and secret scanning chain

## TL;DR

Pre-commit chain for catching private leaks and trivial fixes locally before push — complements upstream-hygiene + llm-tells self-review.

## Provides

- **Secret leak prevention:** `gitleaks` / `trufflehog` detect tokens, private keys before commit — class-based not name-based, avoids leaking while teaching.
- **Typo fence:** `typos` / `codespell` for commit message + comment typos.
- **Editor consistency:** `editorconfig` for newline/EOL/indent so style gate doesn't block hygiene.
- **Orchestration:** `pre-commit` framework that runs chain as hook, not as rewrite — explicit gate per pre-commit-check skill.

## License

MIT / Apache-2.0 per tool.

## Use with

`upstream-hygiene`, `llm-tells`, `pre-commit-check`. Chain runs before `./scripts/check-hygiene.sh HEAD`.

## Install / wiring

```yaml
# .pre-commit-config.yaml excerpt
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.x
    hooks: [{id: gitleaks}]
  - repo: https://github.com/crate-ci/typos
    rev: v1.x
    hooks: [{id: typos}]
  - repo: local
    hooks:
      - id: check-hygiene
        name: code-hygiene upstream class check
        entry: ./scripts/check-hygiene.sh HEAD
        language: system
        stages: [pre-push]
```

Then `pre-commit install --hook-type pre-commit --hook-type pre-push`.

## When not to use

When project already defines `.pre-commit-config.yaml` with overlapping tools — merge don't duplicate. Org-specific secret suffix scanner lives in private overlay `~/.config/hygiene/extra-check.sh`, not in this repo per upstream-hygiene.

## Link

https://github.com/gitleaks/gitleaks
https://github.com/trufflesecurity/trufflehog
https://github.com/crate-ci/typos
https://pre-commit.com/

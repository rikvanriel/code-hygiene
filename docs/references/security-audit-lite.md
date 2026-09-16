# Reference: security audit lite (pre-commit)

## TL;DR

Lightweight security signals via visible pattern grep and semgrep community rules — not full audit, but catches common Web/secret mishandlings early.

## Provides

- **Visible pattern scan:** e.g. `password` in URL param, unsanitized path join with user input, no rate limit on auth. Maps to doc hygiene same as lint-chain — catch before review.
- **semgrep community guardrails:** `p/python.lang.security` etc as pre-commit hook, low noise.
- **Mapping to pre-commit-check:** stage runs same as check-hygiene but opt-in.

## License

MIT / LGPL per rule.

## Use with

`pre-commit-check`, `lint-chain`, `systematic-debugging` Phase0 ownership analysis.

## Install / wiring

```yaml
repos:
  - repo: https://github.com/semgrep/semgrep
    rev: v1.x
    hooks:
      - id: semgrep
        args: [--config, p/python, --error]
        stages: [pre-commit]
```

## When not to use

When project already has full SAST in CI — don't duplicate, reference existing. Not replacement for manual security review.

## Link

https://semgrep.dev/explore
https://github.com/returntocorp/semgrep

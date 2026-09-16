# Reference: google/eng-practices

## TL;DR

Google's engineering practices guide distilled: small changes, clear description, reviewer quality, ownership. Complements code-hygiene's splitting and comment quality with reviewer-centric language.

## Provides

- **Small CLs:** reviewer understands whole change in one sitting — thematic not file-size bound. Maps to GC-30/31 change-splitting.
- **WHY comments:** same as code-hygiene comment-quality GC-20..GC-24 — explains reasoning, not restating code.
- **Review comment quality:** reviewer asks question or states actionable request, not vague "this seems wrong".

## License

CC-BY per repo.

## Use with

`change-splitting`, `comment-quality`, `code-structure`, `changelog-quality`. When project has no own review guide, this is authority.

## Install / wiring

Link from CONTRIBUTING.md -> `https://google.github.io/eng-practices/review/`. No skill to install — interpretive reference only.

## When not to use

When upstream has its own review guide that conflicts — that guide wins per project-discovery Step0.

## Link

https://google.github.io/eng-practices/

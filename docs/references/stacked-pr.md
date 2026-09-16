# Reference: stacked PR tooling

## TL;DR

Tools that help ship change-splitting's many bisectable commits as Stack or landed series — ghstack, jujutsu jj, git-branchless. Maps how GC-30..GC-35 PR description ordering translates to stacked diffs.

## Provides

- **ghstack:** maps GitHub PR comment to commit trailer, keeps linear stack reviewable as series — matches patch-series ordering narrative.
- **jj (jujutsu):** VCS that treats branch as explicit, automatic rebase across stack when parent changes — reduces cost of keeping each commit buildable.
- **git-branchless:** git extension that makes stack workflow ergonomic without changing remote — `git test` per commit, `git move` parent.

## License

MIT / Apache-2.0 per tool.

## Use with

`change-splitting`, `changelog-quality`, `project-discovery`. When project-discovery finds stack already used, obey its convention for cover letter.

## Install / wiring

```bash
pipx install ghstack
# or
cargo install jj-cli
# or
cargo install git-branchless
```

Workflow (generic):

```bash
# draft stack
git commit -m "Split mechanical conversion" # GC-31
git commit -m "Add new algorithm using new interface" # GC-31
ghstack --stack-title "Add X: split by seam"  # or jj/git-branchless equivalent
# each PR/commit shows it builds own: CI per commit
```

## When not to use

When upstream uses mailing list patch series not GitHub — use `git send-email` flow instead, cover letter owns ordering per GC-35. Don't force stacked PR when project prefers single PR.

## Link

https://github.com/ezyang/ghstack
https://github.com/martinvonz/jj
https://github.com/arxanas/git-branchless

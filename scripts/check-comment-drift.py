#!/usr/bin/env python3
"""check-comment-drift.py — report comments and docstrings still asserting a removed identifier.

Usage:
  check-comment-drift.py <repo> [rev] [base]   base defaults to rev^
  check-comment-drift.py --selftest            prove the check can fail

Why this exists: a removal is a rename in reverse (`change-splitting` GC-36).
Code that still calls a removed name fails loudly, so it gets fixed; a comment or
docstring that still promises it is reported by no compiler and is read as a
contract (`comment-quality` GC-23). This finds the survivors so the same commit
can settle them, and so a reviewer can see the grep instead of trusting a claim.

Deliberately narrow in scope, loose in precision — it reports, it never edits:

  * candidates are identifiers taken from the diff's removed lines;
  * a candidate is dropped when it was never code at the base revision (a word
    that only ever lived in prose is not a removed symbol) or when the
    post-change tree still contains it in CODE (then prose naming it is fine);
  * so a removed name that is ALSO an ordinary English word surfaces every prose
    use of that word — each hit is a prompt to look, not a verdict;
  * a file that is prose by nature (markdown/rst/text) counts as prose;
  * Python prose is classified with tokenize + ast (comments and docstrings,
    including multi-line docstrings, which a line-prefix test misses);
  * other languages fall back to a comment-prefix test on the line.

This enforces the rule where it bites: at the commit that removes the behaviour.
It cannot see prose that narrates an older removal — that half of GC-23 ("write
what is true now") stays a review rule, because hunting for phrases like "was
removed" flags legitimate writing.

Exit status: 0 clean, 1 drift found, 2 usage/setup error.
"""

import argparse
import ast
import io
import keyword
import os
import re
import shutil
import subprocess
import sys
import tempfile
import tokenize

TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
COMMENT_PREFIXES = ("#", "//", "/*", "*/", "*", "--", ";", "<!--")
PROSE_SUFFIXES = (".md", ".rst", ".txt")
# Keywords and ubiquitous builtins are not symbols whose removal leaves prose stale.
STOPWORDS = set(keyword.kwlist) | {
    "self", "cls", "str", "int", "float", "dict", "list", "set", "tuple", "len",
    "print", "range", "enumerate", "Exception", "ValueError", "TypeError", "None",
}


def git(repo, *args):
    """Run git in repo; return stdout ('' on failure when the caller tolerates it)."""
    r = subprocess.run(["git", "-C", str(repo), *args],
                       capture_output=True, text=True, errors="replace")
    return r.stdout if r.returncode == 0 else ""


def preflight(repo, rev, base):
    """Fail loudly on a bad repo or revision — a silent empty diff reads as 'clean'."""
    for r in (rev, base):
        if not git(repo, "rev-parse", "--verify", "--quiet", f"{r}^{{commit}}").strip():
            print(f"check-comment-drift: cannot resolve {r!r} in {repo}", file=sys.stderr)
            return False
    return True


def python_prose_lines(src):
    """1-based line numbers that are comments or docstrings in a Python source."""
    prose = set()
    try:
        for tok in tokenize.generate_tokens(io.StringIO(src).readline):
            if tok.type == tokenize.COMMENT:
                prose.add(tok.start[0])
    except (tokenize.TokenError, IndentationError, SyntaxError):
        pass
    try:
        tree = ast.parse(src)
    except SyntaxError:
        return prose
    for node in ast.walk(tree):
        body = getattr(node, "body", None)
        if not isinstance(body, list) or not body:
            continue
        first = body[0]
        value = getattr(first, "value", None)
        if isinstance(first, ast.Expr) and isinstance(value, ast.Constant) and isinstance(value.value, str):
            start = getattr(first, "lineno", 1)
            end = getattr(first, "end_lineno", start)
            prose.update(range(start, end + 1))
    return prose


def removed_identifiers(repo, base, rev):
    diff = git(repo, "diff", "--unified=0", f"{base}..{rev}")
    names = set()
    for line in diff.splitlines():
        if line.startswith("-") and not line.startswith("---"):
            names.update(TOKEN_RE.findall(line[1:]))
    return names


def hits(repo, rev, name, prose_cache):
    """(code_hits, prose_hits) for one identifier at one revision."""
    code_hits, prose_hits = 0, []
    out = git(repo, "grep", "-n", "-I", "--full-name", "-e", rf"\b{name}\b", rev)
    for line in out.splitlines():
        parts = line.split(":", 3)
        if len(parts) < 4:
            continue
        _, path, lineno, text = parts
        src = prose_cache.get((rev, path))
        if src is None:
            src = git(repo, "show", f"{rev}:{path}")
            prose_cache[(rev, path)] = src
        if path.endswith(".py"):
            is_prose = lineno.isdigit() and int(lineno) in python_prose_lines(src)
        else:
            stripped = text.strip()
            is_prose = path.endswith(PROSE_SUFFIXES) or stripped.startswith(COMMENT_PREFIXES)
        if is_prose:
            prose_hits.append((path, lineno, text.strip()[:140]))
        else:
            code_hits += 1
            break
    return code_hits, prose_hits


def scan(repo, base, rev, names, prose_cache):
    """name -> prose hits, for names that WERE code at base and are code-free at rev."""
    findings = {}
    for name in sorted(names):
        if name in STOPWORDS:
            continue
        if hits(repo, base, name, prose_cache)[0] == 0:
            continue                      # never a code symbol — prose word, not drift
        code_hits, prose_hits = hits(repo, rev, name, prose_cache)
        if prose_hits and not code_hits:
            findings[name] = prose_hits
    return findings


def check(repo, rev, base):
    if not preflight(repo, rev, base):
        return 2
    names = removed_identifiers(repo, base, rev)
    findings = scan(repo, base, rev, names, {})
    print(f"check-comment-drift: {repo} {base}..{rev}")
    print(f"  removed identifiers considered: {len(names)}")
    if not findings:
        print("  no comment or docstring still asserts a removed identifier")
        return 0
    for name, hits in sorted(findings.items()):
        print(f"  {name}: gone from code, still asserted in prose")
        for path, lineno, text in hits:
            print(f"    {path}:{lineno}: {text}")
    print("FAIL: prose still asserts behaviour this change removed "
          "(comment-quality GC-23: state what is true now, put the retraction in the changelog)")
    return 1


def _run(args, cwd):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True, errors="replace")


def selftest():
    """Prove the check can fail: plant the drift, then plant the fixed version."""
    tmp = tempfile.mkdtemp(prefix="comment-drift-selftest-")
    rc = 0
    ident = ["-c", "user.email=example@example.invalid", "-c", "user.name=example-user"]
    module = "def sweep():\n"

    def build(tmp_repo, fixed):
        os.makedirs(tmp_repo, exist_ok=True)
        _run(["git", "init", "-q"], tmp_repo)
        doc = ("Returns a dict. The `shaded` key is True when the band is dark.\n"
               if not fixed else
               "Returns a dict. A refusal is a refusal: no pitch is invented, for any cause.\n")
        with open(os.path.join(tmp_repo, "sweep.py"), "w") as f:
            f.write(f'def sweep():\n    """{doc}"""\n    return {{"shaded": True, "reason": "x"}}\n')
        _run(["git", "add", "-A"], tmp_repo)
        _run(["git", *ident, "commit", "-qm", "init"], tmp_repo)
        return tmp_repo

    def remove_key(tmp_repo):
        with open(os.path.join(tmp_repo, "sweep.py")) as f:
            src = f.read()
        src = src.replace('    return {"shaded": True, "reason": "x"}\n',
                          '    return {"reason": "x"}\n')
        with open(os.path.join(tmp_repo, "sweep.py"), "w") as f:
            f.write(src)
        _run(["git", "add", "-A"], tmp_repo)
        _run(["git", *ident, "commit", "-qm", "retract the diagnosis"], tmp_repo)
        return tmp_repo

    try:
        drifted = remove_key(build(os.path.join(tmp, "drifted"), fixed=False))
        if check(drifted, "HEAD", "HEAD^") != 1:
            print("  FAIL planted docstring drift was NOT detected")
            rc = 1
        else:
            print("  ok   planted docstring drift detected")

        clean = remove_key(build(os.path.join(tmp, "clean"), fixed=True))
        if check(clean, "HEAD", "HEAD^") != 0:
            print("  FAIL fixed wording wrongly flagged")
            rc = 1
        else:
            print("  ok   fixed wording passes")

        if check(clean, "HEAD", "HEAD") != 0:
            print("  FAIL empty diff wrongly flagged")
            rc = 1
        else:
            print("  ok   empty diff passes")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return rc


def main():
    ap = argparse.ArgumentParser(description="report prose still asserting removed identifiers")
    ap.add_argument("repo", nargs="?", help="path to the git repository to inspect")
    ap.add_argument("rev", nargs="?", default="HEAD", help="revision holding the change (default HEAD)")
    ap.add_argument("base", nargs="?", default=None, help="base revision (default rev^)")
    ap.add_argument("--selftest", action="store_true", help="prove the check can fail")
    args = ap.parse_args()

    if args.selftest:
        print("## check-comment-drift --selftest")
        rc = selftest()
        print("PASS: the check fails on planted drift and passes the fixed wording"
              if rc == 0 else "FAIL (self-test)")
        return rc
    if not args.repo:
        ap.error("a repository path is required (or --selftest)")
    base = args.base or f"{args.rev}^"
    return check(args.repo, args.rev, base)


if __name__ == "__main__":
    sys.exit(main())

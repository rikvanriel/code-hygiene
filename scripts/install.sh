#!/usr/bin/env bash
# install.sh — install code-hygiene skills into detected agent homes.
# No auto-install — requires --install <comma-list> and confirmation.
# Usage:
#   ./scripts/install.sh --list
#   ./scripts/install.sh --install upstream-hygiene,factual-integrity,...
#   ./scripts/install.sh --install all  (installs all generic core)
#   ./scripts/install.sh --agent AGENTS.md --install all  (single generic file target)
#   ./scripts/install.sh --check            (report missing/drifted installs vs repo HEAD)
#   ./scripts/install.sh --check --diff     (also show unified diffs)
#   ./scripts/install.sh --update           (apply clean updates; customized installs reported, not touched)
#
# Update model: installed copies are matched against the repo's own git
# history, so no state file is needed. For each skill, the installed file
# (A) is compared to repo HEAD (B); when they differ, history is walked to
# find the commit (C) whose blob matches A — the version last installed.
# A==B means current; A==C!=B means a clean update is available; A!=C means
# locally customized (ask your LLM to import the upstream changes by hand).

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"

detect() {
  echo "## Detected agent homes"
  for p in "$HOME/.claude/skills" "$HOME/.hermes/skills" "$HOME/.config/hermes/skills"; do
    if [ -d "$(dirname "$p")" ]; then
      echo " - $(dirname "$p") -> $p $([ -d "$p" ] && echo exists || echo will-create)"
    else
      echo " - $(dirname "$p") (not present)"
    fi
  done
  for p in ".cursor/rules" ".github" ; do
    [ -e "$p" ] && echo " - ./$p (repo-local)" || echo " - ./$p (not in repo, skip)"
  done
}

list_skills() {
  echo "## Available skills (from $SKILLS_DIR)"
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    name="$(basename "$d")"
    # handle description: may be >- multiline — read 2 lines after, strip quotes/indent
    desc=$(awk '/^description:/{flag=1; sub(/^description:[[:space:]]*/, ""); if ($0 ~ /^>/) {getline; while ($0 ~ /^  /){gsub(/^ +/," "); printf "%s", $0; getline} print ""; exit} else {gsub(/^[ ">-]*/, ""); gsub(/"$/, ""); print; exit}}' "$d/SKILL.md" | head -c 160)
    [ -z "$desc" ] && desc=$(grep -m1 'description:' "$d/SKILL.md" | sed 's/.*description: *//' | tr -d '"' | head -c 160)
    echo " - $name — $desc"
  done
  echo ""
  echo "## References"
  if [ -d "$REPO/docs/references" ]; then
    ls "$REPO/docs/references" | sed 's/^/ - /'
  fi
}

# Agent homes that receive installs. Kept in one place so --install,
# --check, and --update probe the same targets.
agent_targets() {
  local agent="${1:-auto}"
  if [ "$agent" != "auto" ]; then
    printf '%s\n' "$agent"
    return
  fi
  local base
  for base in "$HOME/.claude/skills" "$HOME/.hermes/skills"; do
    if [ -d "$(dirname "$base")" ] || [ -d "$base" ]; then
      printf '%s\n' "$base"
    fi
  done
}

# installed_version <skill> <installed-file>
# Prints the newest commit whose blob for skills/<skill>/SKILL.md matches
# the installed file, or nothing when no historical blob matches.
installed_version() {
  local skill="$1" file="$2"
  local want commit blob
  want="$(git -C "$REPO" hash-object "$file" 2>/dev/null)" || return 0
  while read -r commit; do
    blob="$(git -C "$REPO" rev-parse "$commit:skills/$skill/SKILL.md" 2>/dev/null)" || continue
    if [ "$blob" = "$want" ]; then
      printf '%s\n' "$commit"
      return 0
    fi
  done < <(git -C "$REPO" log --format=%H -- "skills/$skill/SKILL.md")
}

# skill_status <skill> <installed-file>
# Prints one of: current | missing | update-available:<C> | customized:<C> | foreign
# Compares against the worktree file (not HEAD) so uncommitted repo edits
# still detect as updates; history identifies the installed version.
skill_status() {
  local skill="$1" file="$2"
  if [ ! -f "$file" ]; then
    echo "missing"
    return
  fi
  if cmp -s "$file" "$SKILLS_DIR/$skill/SKILL.md"; then
    echo "current"
    return
  fi
  local ver worktree_changed
  ver="$(installed_version "$skill" "$file")"
  if [ -z "$ver" ]; then
    echo "foreign"
    return
  fi
  worktree_changed=0
  git -C "$REPO" diff --quiet "$ver" -- "skills/$skill/SKILL.md" || worktree_changed=1
  if [ "$worktree_changed" = 0 ]; then
    echo "customized:$ver"
  else
    echo "update-available:$ver"
  fi
}

check_installs() {          # $1 = show diffs (0/1); $2 = agent
  local showdiff="$1" agent="$2"
  local rc=0 skill target file st ver
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    skill="$(basename "$d")"
    while read -r target; do
      file="$target/$skill/SKILL.md"
      st="$(skill_status "$skill" "$file")"
      case "$st" in
        current) echo " - $skill @ $target: current" ;;
        missing) echo " - $skill @ $target: MISSING (not installed)"; rc=1 ;;
        update-available:*)
          ver="${st#update-available:}"
          echo " - $skill @ $target: update available (installed ${ver:0:12}, repo moved on)"
          if [ "$showdiff" = 1 ]; then
            git -C "$REPO" diff "$ver" HEAD -- "skills/$skill/SKILL.md" | head -n 60
          fi
          rc=1 ;;
        customized:*)
          ver="${st#customized:}"
          echo " - $skill @ $target: CUSTOMIZED locally (matches ${ver:0:12}) — not touching; ask your LLM to import upstream changes by hand"
          if [ "$showdiff" = 1 ]; then
            echo "   --- your customizations (installed vs $ver) ---"
            diff -u <(git -C "$REPO" show "$ver:skills/$skill/SKILL.md") "$file" | head -n 40 || true
          fi
          rc=1 ;;
        foreign)
          echo " - $skill @ $target: FOREIGN (matches no repo version) — not touching; ask your LLM to import upstream changes by hand"
          rc=1 ;;
      esac
    done < <(agent_targets "$agent")
  done
  return $rc
}

update_installs() {         # $1 = agent
  local agent="$1"
  local rc=0 skill target file st
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    skill="$(basename "$d")"
    while read -r target; do
      file="$target/$skill/SKILL.md"
      st="$(skill_status "$skill" "$file")"
      case "$st" in
        current) echo " - $skill @ $target: current" ;;
        missing)
          mkdir -p "$(dirname "$file")"
          cp "$SKILLS_DIR/$skill/SKILL.md" "$file"
          echo " - $skill @ $target: installed (was missing)"; rc=1 ;;
        update-available:*)
          cp "$SKILLS_DIR/$skill/SKILL.md" "$file"
          echo " - $skill @ $target: updated to HEAD"; rc=1 ;;
        customized:*|foreign)
          echo " - $skill @ $target: $st — skipped; ask your LLM to import upstream changes by hand"
          rc=1 ;;
      esac
    done < <(agent_targets "$agent")
  done
  return $rc
}

install_skills() {
  local raw="$1"
  local agent="${2:-auto}"
  local list
  if [ "$raw" = "all" ]; then
    list="$(for d in "$SKILLS_DIR"/*/; do [ -f "$d/SKILL.md" ] && basename "$d"; done | tr '\n' ',' | sed 's/,$//')"
  else
    list="$raw"
  fi

  IFS=',' read -ra SKILLS <<< "$list"
  echo "## Will install skills: ${SKILLS[*]}"
  echo "## Agent target: $agent (auto = probe ~/.claude/skills + ~/.hermes/skills)"
  local targets=()
  if [ "$agent" = "auto" ]; then
    for base in "$HOME/.claude/skills" "$HOME/.hermes/skills"; do
      if [ -d "$(dirname "$base")" ] || [ -d "$base" ]; then
        targets+=("$base")
      fi
    done
    # generic fallback
    if [ ${#targets[@]} -eq 0 ]; then
      targets=("AGENTS.md")
    fi
  else
    targets=("$agent")
  fi

  echo "## Targets: ${targets[*]}"
  echo "## Preview (first file that would be written):"
  for s in "${SKILLS[@]}"; do
    src="$SKILLS_DIR/$s/SKILL.md"
    [ -f "$src" ] || { echo "  SKIP $s — not found at $src"; continue; }
    echo "  src=$src"
    for t in "${targets[@]}"; do
      if [[ "$t" == *.md ]]; then
        echo "    -> append to $t (generic AGENTS.md/copy-paste mode)"
      else
        echo "    -> $t/$s/SKILL.md"
      fi
    done
  done

  read -p "Proceed? (y/N) " -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  for s in "${SKILLS[@]}"; do
    src="$SKILLS_DIR/$s/SKILL.md"
    [ -f "$src" ] || continue
    for t in "${targets[@]}"; do
      if [[ "$t" == *.md ]]; then
        echo "## Appending $s to $t"
        cat "$src" >> "$t"
        echo -e "\n---\n" >> "$t"
      else
        dst="$t/$s/SKILL.md"
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "Installed $dst"
      fi
    done
  done
  echo "Done."
}

case "${1:-}" in
  --list|--ls) detect; echo ""; list_skills ;;
  --install) install_skills "${2:-}" "${4:-auto}" ;;
  --check)
    showdiff=0; agent="auto"
    for a in "${2:-}" "${3:-}" "${4:-}"; do
      case "$a" in --diff) showdiff=1 ;; --agent) ;; *) [ -n "$a" ] && agent="$a" ;; esac
    done
    check_installs "$showdiff" "$agent" ;;
  --update)
    agent="auto"
    for a in "${2:-}" "${3:-}"; do [ -n "$a" ] && [ "$a" != "--diff" ] && agent="$a"; done
    update_installs "$agent" ;;
  *) echo "Usage: $0 --list | --install <comma-list|all> [--agent path] | --check [--diff] | --update"; detect; echo ""; list_skills ;;
esac

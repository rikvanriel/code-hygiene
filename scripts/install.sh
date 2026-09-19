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
# Update model: SKILL.md copies are matched against the repo's own git
# history, so no state file is needed. Reference files are materialized from
# skills/references.manifest and compared directly with their canonical docs.
# A customized SKILL.md is preserved; drifted references are regenerated.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"

# Every agent home probed by --install/--check/--update and shown by --list.
# Single source: detect() and agent_targets() both expand this.
AGENT_SKILL_HOMES=(
  "$HOME/.claude/skills"
  "$HOME/.hermes/skills"
  "$HOME/.config/hermes/skills"
  "$HOME/.agents/skills"
  "$HOME/.openclaw/skills"
  "$HOME/.config/opencode/skills"
)

detect() {
  echo "## Detected agent homes"
  local p
  for p in "${AGENT_SKILL_HOMES[@]}"; do
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
  for base in "${AGENT_SKILL_HOMES[@]}"; do
    if [ -d "$(dirname "$base")" ] || [ -d "$base" ]; then
      printf '%s\n' "$base"
    fi
  done
}

# materialize_skill <skill> <destination>
# Copy the skill plus the canonical references listed in the repository manifest.
materialize_skill() {
  local skill="$1" dst="$2" ref_skill rel src
  mkdir -p "$dst"
  cp "$SKILLS_DIR/$skill/SKILL.md" "$dst/SKILL.md"
  while IFS=$'\t' read -r ref_skill rel src; do
    [[ -z "$ref_skill" || "$ref_skill" == \#* ]] && continue
    [ "$ref_skill" = "$skill" ] || continue
    [ -f "$REPO/$src" ] || { echo "Missing manifest source: $src" >&2; return 1; }
    mkdir -p "$dst/$(dirname "$rel")"
    cp "$REPO/$src" "$dst/$rel"
  done < "$SKILLS_DIR/references.manifest"
}

# reference_status <skill> <installed-dir>
# Prints current | missing | drifted for manifest-listed references.
reference_status() {
  local skill="$1" dir="$2" ref_skill rel src
  while IFS=$'\t' read -r ref_skill rel src; do
    [[ -z "$ref_skill" || "$ref_skill" == \#* ]] && continue
    [ "$ref_skill" = "$skill" ] || continue
    if [ ! -f "$dir/$rel" ]; then
      echo "missing"; return
    fi
    if ! cmp -s "$REPO/$src" "$dir/$rel"; then
      echo "drifted"; return
    fi
  done < "$SKILLS_DIR/references.manifest"
  echo "current"
}

# installed_version <skill> <installed-file> <repo-relpath>
# Prints the newest commit whose blob for skills/<skill>/<relpath> matches
# the installed file, or nothing when no historical blob matches.
installed_version() {
  local skill="$1" file="$2" rel="$3"
  local want commit blob
  want="$(git -C "$REPO" hash-object "$file" 2>/dev/null)" || return 0
  while read -r commit; do
    blob="$(git -C "$REPO" rev-parse "$commit:skills/$skill/$rel" 2>/dev/null)" || continue
    if [ "$blob" = "$want" ]; then
      printf '%s\n' "$commit"
      return 0
    fi
  done < <(git -C "$REPO" log --format=%H -- "skills/$skill/$rel")
}

# file_status <skill> <installed-file> <repo-relpath>
# Prints one of: current | missing | update-available:<C> | customized:<C> | foreign
# Compares against the worktree file (not HEAD) so uncommitted repo edits
# still detect as updates; history identifies the installed version.
file_status() {
  local skill="$1" file="$2" rel="$3"
  if [ ! -f "$file" ]; then
    echo "missing"
    return
  fi
  if cmp -s "$file" "$SKILLS_DIR/$skill/$rel"; then
    echo "current"
    return
  fi
  local ver worktree_changed
  ver="$(installed_version "$skill" "$file" "$rel")"
  if [ -z "$ver" ]; then
    echo "foreign"
    return
  fi
  worktree_changed=0
  git -C "$REPO" diff --quiet "$ver" -- "skills/$skill/$rel" || worktree_changed=1
  if [ "$worktree_changed" = 0 ]; then
    echo "customized:$ver"
  else
    echo "update-available:$ver"
  fi
}

# skill_status <skill> <installed-dir>
# Track SKILL.md through git history and manifest-listed references by content.
skill_status() {
  local skill="$1" dir="$2" st refs
  st="$(file_status "$skill" "$dir/SKILL.md" "SKILL.md")"
  case "$st" in
    missing|foreign|customized:*|update-available:*) echo "$st"; return ;;
  esac
  refs="$(reference_status "$skill" "$dir")"
  [ "$refs" = "current" ] && echo "current" || echo "$refs"
}

check_installs() {          # $1 = show diffs (0/1); $2 = agent
  local showdiff="$1" agent="$2"
  local rc=0 skill target dir st ver
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    skill="$(basename "$d")"
    while read -r target; do
      dir="$target/$skill"
      st="$(skill_status "$skill" "$dir")"
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
        drifted)
          echo " - $skill @ $target: reference files differ from canonical docs"
          rc=1 ;;
        customized:*)
          ver="${st#customized:}"
          echo " - $skill @ $target: CUSTOMIZED locally (matches ${ver:0:12}) — not touching; ask your LLM to import upstream changes by hand"
          if [ "$showdiff" = 1 ]; then
            echo "   --- your customizations (installed vs $ver) ---"
            diff -ru "$dir" "$SKILLS_DIR/$skill" --exclude=.git 2>/dev/null | head -n 40 || true
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
  local rc=0 skill target dir st
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    skill="$(basename "$d")"
    while read -r target; do
      dir="$target/$skill"
      st="$(skill_status "$skill" "$dir")"
      case "$st" in
        current) echo " - $skill @ $target: current" ;;
        missing)
          materialize_skill "$skill" "$dir"
          echo " - $skill @ $target: installed (was missing)"; rc=1 ;;
        update-available:*|drifted)
          materialize_skill "$skill" "$dir"
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
  echo "## Agent target: $agent (auto = probe claude + hermes + agents + openclaw + opencode homes)"
  local targets=()
  if [ "$agent" = "auto" ]; then
    while read -r base; do targets+=("$base"); done < <(agent_targets "auto")
    # generic fallback
    if [ ${#targets[@]} -eq 0 ]; then
      targets=("AGENTS.md")
    fi
  else
    targets=("$agent")
  fi

  echo "## Targets: ${targets[*]}"
  echo "## Preview (first files that would be written):"
  for s in "${SKILLS[@]}"; do
    src="$SKILLS_DIR/$s/SKILL.md"
    [ -f "$src" ] || { echo "  SKIP $s — not found at $src"; continue; }
    echo "  src=$SKILLS_DIR/$s/SKILL.md (plus manifest-listed references/)"
    for t in "${targets[@]}"; do
      if [[ "$t" == *.md ]]; then
        echo "    -> append SKILL.md to $t (generic AGENTS.md/copy-paste mode)"
      else
        echo "    -> $t/$s/"
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
        dst="$t/$s"
        materialize_skill "$s" "$dst"
        echo "Installed $dst/"
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

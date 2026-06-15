#!/usr/bin/env bash
# Refresh the GLOBAL ~/.claude Databricks skill catalog + databricks-gotchas references
# from the vibe-tools repo's freshly-synced .claude/skills/ and docs/agent_docs/.
#
# Why this exists: the repo's .claude/skills/ holds the official `databricks aitools`
# catalog already dereferenced to real dirs (via scripts/sync-databricks-skills.sh).
# Copying those to ~/.claude/skills/ == running the installer globally, with no CLI
# v1.0.0 dependency and no auth disruption. This script makes that one command.
#
# Usage:
#   refresh-global-databricks-skills.sh [REPO_ROOT]
#   REPO_ROOT defaults to ~/code/vibe-tools (override via arg or $VIBE_TOOLS_ROOT).
#
# Idempotent: re-run any time to re-sync. Workshop-specific skills are never promoted.

set -euo pipefail
shopt -s nullglob

REPO_ROOT="${1:-${VIBE_TOOLS_ROOT:-$HOME/code/vibe-tools}}"
SRC="$REPO_ROOT/.claude/skills"
AGENT_DOCS="$REPO_ROOT/docs/agent_docs"
DST="$HOME/.claude/skills"

# Workshop-coupled skills that should stay in the repo only (never promoted to global).
EXCLUDE="sync-genie-skills data-profiler slides"

# Portable hand-authored references that back the global databricks-gotchas skill.
GOTCHAS_REFS="databricks-sql-udf-gotchas databricks-uc-governance-gotchas databricks-apps-gotchas databricks-ai-dev-kit-mcp-gotchas lakebase-introspection"

# Quiet no-op when the repo isn't present (e.g. SessionStart hook firing in an
# unrelated project) — absence is not an error worth surfacing every session.
[[ -d "$SRC" ]] || { echo "note: repo skills dir not found ($SRC) — nothing to refresh." >&2; exit 0; }
mkdir -p "$DST"

echo "==> Refreshing global Databricks catalog from $SRC"
added=0; bumped=0; skipped=0
for d in "$SRC"/*/; do
  name="$(basename "${d%/}")"
  case " $EXCLUDE " in *" $name "*) echo "    skip (workshop): $name"; skipped=$((skipped+1)); continue;; esac
  if [[ -d "$DST/$name" ]]; then tag="bump"; bumped=$((bumped+1)); else tag="ADD "; added=$((added+1)); fi
  rm -rf "${DST:?}/$name"
  cp -R "${d%/}" "$DST/$name"
  echo "    $tag $name"
done
echo "    -> $added added, $bumped version-bumped, $skipped skipped"

# Refresh the databricks-gotchas skill's references (the SKILL.md router is preserved).
if [[ -d "$AGENT_DOCS" ]]; then
  echo "==> Refreshing databricks-gotchas references from $AGENT_DOCS"
  mkdir -p "$DST/databricks-gotchas/references"
  refreshed=0
  for ref in $GOTCHAS_REFS; do
    if [[ -f "$AGENT_DOCS/$ref.md" ]]; then
      cp "$AGENT_DOCS/$ref.md" "$DST/databricks-gotchas/references/$ref.md"
      refreshed=$((refreshed+1))
    else
      echo "    warn: missing $ref.md in agent_docs" >&2
    fi
  done
  echo "    -> $refreshed references refreshed"
else
  echo "==> (skipping gotchas refresh — $AGENT_DOCS not found)"
fi

echo ""
echo "✓ Global Databricks skills refreshed. Total skills: $(ls -d "$DST"/*/ 2>/dev/null | wc -l | tr -d ' ')"

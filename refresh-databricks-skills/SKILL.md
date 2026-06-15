---
name: refresh-databricks-skills
description: >-
  Refresh the user's GLOBAL ~/.claude Databricks skill catalog and the databricks-gotchas references
  from the vibe-tools repo's already-synced .claude/skills/ and docs/agent_docs/. Use when the user asks
  to "refresh my databricks skills", "update global databricks skills", "re-sync the databricks catalog
  globally", "pull the latest databricks skills into global", or after the vibe-tools repo has re-run its
  own sync (scripts/sync-databricks-skills.sh) and the global copies are now stale. Copies catalog skill
  dirs repo → global (additive + version-bump, never deletes), skips workshop-specific skills, and refreshes
  the gotchas reference files. No Databricks CLI upgrade or re-auth required.
---

# Refresh Global Databricks Skills

The user keeps a global Databricks skill catalog in `~/.claude/skills/` that is a snapshot of the vibe-tools
repo's `.claude/skills/` (which itself is the official `databricks aitools` catalog, dereferenced to real
dirs by `scripts/sync-databricks-skills.sh`). The global copies do **not** auto-update — run this skill to
re-sync them.

## How to run

```bash
bash ~/.claude/skills/refresh-databricks-skills/refresh-global-databricks-skills.sh
```

The repo root defaults to `~/code/vibe-tools`. If the repo lives elsewhere, pass it explicitly:

```bash
bash ~/.claude/skills/refresh-databricks-skills/refresh-global-databricks-skills.sh /path/to/vibe-tools
```

## What it does

1. Copies every catalog skill dir from `<repo>/.claude/skills/` → `~/.claude/skills/`, **adding** new ones and
   **version-bumping** existing ones. It never deletes a global skill.
2. **Skips** the workshop-coupled skills that should stay repo-only: `sync-genie-skills`, `data-profiler`, `slides`.
3. Refreshes the `databricks-gotchas` skill's `references/*.md` from `<repo>/docs/agent_docs/` (preserving the
   skill's own `SKILL.md` router).
4. Prints a per-skill `ADD`/`bump`/`skip` summary and the final global skill count.

Idempotent — safe to re-run any time.

## When the repo itself is stale

This script only moves the repo's *current* catalog into global. To pull a **newer upstream catalog release**
first, the user runs the repo's own sync (`scripts/sync-databricks-skills.sh`), which needs Databricks CLI
v1.0.0+ (`aitools` subcommand) and a one-time `databricks auth login` after upgrading. Then run this skill to
propagate to global. Report this dependency if the user wants the latest upstream rather than the vendored copy.

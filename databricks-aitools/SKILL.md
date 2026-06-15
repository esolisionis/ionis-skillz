---
name: databricks-aitools
description: >
  Use for the `databricks experimental aitools tools` CLI subgroup: the
  lightest terminal path for running SQL against a Databricks SQL warehouse
  (single or parallel batch), inspecting table schemas with sample rows and
  null counts, resolving the default warehouse ID, and managing async SQL
  statement lifecycle (submit / get / status / cancel). Use whenever the
  user wants to run SQL, peek at a table, look up a warehouse, or
  fire-and-forget a long-running statement from the shell / CLI / terminal
  ("run this query", "describe this table", "what's in
  catalog.schema.table", "show me a few rows", "what warehouse am I on",
  "kick off a query and come back later", "cancel this statement"). Prefer
  this over DBSQL MCP and AI Dev Kit MCP for read-only SQL and schema
  discovery. Covers: `tools query`, `tools discover-schema`, `tools
  get-default-warehouse`, `tools statement {submit,get,status,cancel}`,
  warehouse resolution, `DATABRICKS_WAREHOUSE_ID`, output formats (text /
  json / csv), batch execution + `--concurrency`, auto-start behavior,
  `.sql` input, stdin piping, and `--profile` targeting. If the user
  mentions `aitools` or `databricks experimental`, this applies. **Does
  NOT** cover the separate `databricks aitools` (no `experimental`) group
  used for installing coding-agent skills — see the disambiguation block
  inside.
disable-model-invocation: false
---

# Databricks Experimental AI Tools CLI

CLI subgroup: `databricks experimental aitools tools`. As of CLI v1.0.0
(2026-05-21) this lives alongside an unrelated `databricks aitools` group
— read the disambiguation block below before delegating to either. The
`experimental` namespace does **not** appear in `databricks --help`, so
jump straight to `databricks experimental aitools tools --help` for the
latest surface (flags expand between releases).

## Two groups share the name "aitools" (read first)

Since CLI **v1.0.0**, two unrelated command groups share the `aitools` name. Pick the right one before doing anything else.

| Group                                  | Purpose                                                                                                                          | Covered by this skill?                                  |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `databricks aitools`                   | Install / list / update / uninstall coding-agent skills (Claude Code, Cursor, Codex CLI, OpenCode, GitHub Copilot, Antigravity) from `github.com/databricks/databricks-agent-skills` | ❌ — run `databricks aitools --help` for that surface  |
| `databricks experimental aitools tools` | SQL execution, schema discovery, warehouse resolution, async statement lifecycle from the terminal                              | ✅ — everything below                                  |

The two groups share zero subcommands. The keyword `experimental` is the discriminator — if you see `databricks aitools install`, it's the new skills-management group; if you see `databricks experimental aitools tools query`, it's this skill.

## Why this skill exists

For read-only SQL and schema peeking from the terminal, this is the lightest path: one binary, one call, JSON / CSV / text out. No MCP handshake, no Python runtime, no SDK boilerplate. Reach for heavier tooling (MCP, SDK) only when the lighter path genuinely can't do the job.

## Pick the right command

| Task                                                                                        | Command                                                              |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Run SQL (single statement, or parallel batch)                                               | `tools query`                                                        |
| Describe one or more tables — columns, sample rows, nulls                                   | `tools discover-schema`                                              |
| Print the resolved default warehouse ID                                                     | `tools get-default-warehouse`                                        |
| Fire-and-forget a long-running statement, then harvest / poll / cancel from a separate call | `tools statement submit` → `tools statement get` (or `status` / `cancel`) |

Everything else (creating pipelines, serving endpoints, Vector Search, Genie, Lakebase, grants) needs a different tool — see **When NOT to use** below.

## Stability

These subcommands are **machine-oriented helpers for AI agents**. Output is JSON when stdout is not a TTY (single-query mode) or always JSON (batch / multi-statement mode). They have **no stability guarantees** — output shape, flag names, and behavior can change between releases. Do not hard-code parsers around specific JSON field names across CLI versions; re-check after upgrades.

## Quick recipes

Common chains. Each is copy-pasteable.

**Resolve warehouse, then run a query against it:**

```bash
WH=$(databricks experimental aitools tools get-default-warehouse)
databricks experimental aitools tools query -w "$WH" "SELECT COUNT(*) FROM samples.nyctaxi.trips"
```

Only useful when the default is stopped and you want to skip auto-start on `query` — otherwise `tools query` resolves + auto-starts in one shot.

**Peek at one or more tables before writing a join:**

```bash
databricks experimental aitools tools discover-schema \
  samples.nyctaxi.trips samples.tpch.lineitem samples.tpch.orders
```

Returns columns, 5 sample rows, and null counts per column for each table. Multi-table runs share a statement budget — tune with `--concurrency` (default 8) if you're hitting a slow warehouse or rate limits.

**Pipe JSON into jq:**

```bash
databricks experimental aitools tools query --output json \
  "SELECT pickup_zip, COUNT(*) AS trips FROM samples.nyctaxi.trips GROUP BY 1 ORDER BY 2 DESC LIMIT 5" \
  | jq '.[] | {zip: .pickup_zip, trips: .trips}'
```

**Export to CSV (new in v1.0.0):**

```bash
databricks experimental aitools tools query --output csv \
  "SELECT * FROM samples.nyctaxi.trips LIMIT 100" > trips.csv
```

**Run a `.sql` file (avoids shell escaping pain):**

```bash
databricks experimental aitools tools query -f scripts/monthly_revenue.sql
# or, if the positional arg ends in .sql and the file exists, it auto-reads:
databricks experimental aitools tools query scripts/monthly_revenue.sql
```

**Run multiple queries in parallel (batch mode, new in v1.0.0):**

```bash
databricks experimental aitools tools query \
  -f scripts/q1.sql -f scripts/q2.sql \
  "SELECT COUNT(*) FROM samples.nyctaxi.trips" \
  --concurrency 4
```

Multi-query output is always JSON. Exit code is non-zero if any query failed.

**Async lifecycle — fire and check back later (new in v1.0.0):**

```bash
ID=$(databricks experimental aitools tools statement submit \
       -w "$WH" "SELECT pg_sleep(60), 1" | jq -r .statement_id)

databricks experimental aitools tools statement status "$ID"   # peek, non-blocking
databricks experimental aitools tools statement get "$ID"      # blocks until terminal
databricks experimental aitools tools statement cancel "$ID"   # stop it
```

**Target a specific workspace profile:**

```bash
databricks experimental aitools tools query --profile prod "SELECT current_catalog()"
```

---

## Command reference

### `tools query`

Run one or more SQL statements against a Databricks SQL warehouse.

```bash
databricks experimental aitools tools query "SELECT 1"                       # inline SQL
databricks experimental aitools tools query my_query.sql                      # auto-detected by .sql extension
databricks experimental aitools tools query -f my_query.sql                   # explicit file flag
echo "SELECT * FROM catalog.schema.t" | databricks experimental aitools tools query  # stdin
databricks experimental aitools tools query -w <warehouse-id> "SELECT 1"      # pin warehouse
databricks experimental aitools tools query --output json "SELECT 1"          # force JSON even in TTY
databricks experimental aitools tools query --output csv "SELECT 1, 'a'"      # CSV (v1.0.0+)
databricks experimental aitools tools query -f q1.sql -f q2.sql "SELECT 3"    # batch / parallel
```

**Flags:**

| Flag            | Short | Purpose                                                          |
| --------------- | ----- | ---------------------------------------------------------------- |
| `--warehouse`   | `-w`  | SQL warehouse ID (skips auto-resolution)                         |
| `--file`        | `-f`  | Path to a `.sql` file — **repeatable** in v1.0.0+ for batch runs |
| `--output`      | `-o`  | `text` (default), `json`, or `csv`                               |
| `--concurrency` |       | Max in-flight statements when running a batch (default 8)        |
| `--profile`     | `-p`  | Named profile from `~/.databrickscfg`                            |

**SQL input modes:**

1. `--file` flag (repeatable in v1.0.0+ — pair with positional SQLs to run a batch)
2. Positional argument(s) — if a positional ends in `.sql` AND the file exists, it's read as a file; otherwise treated as literal SQL. Multiple positionals run as a batch.
3. Stdin (only in non-interactive mode, only when no positional and no `--file` is given)

**Single-statement output:**

- JSON when stdout is not a TTY OR `--output json` is set — a single JSON array of row objects.
- CSV when `--output csv` is set.
- Interactive tables in TTY mode; large results open an interactive table browser.

**Batch output (any time multiple `--file` or positional SQLs are given):**

- **Always JSON**, regardless of TTY / `--output`. Shape:
  ```jsonc
  [
    {
      "sql":          "<the SQL>",
      "statement_id": "01ef...",
      "state":        "SUCCEEDED" | "FAILED" | "CANCELED",
      "elapsed_ms":   1234,
      "columns":      [...],   // present on SUCCEEDED
      "rows":         [...],   // present on SUCCEEDED
      "error":        {...}    // present on non-success
    },
    ...
  ]
  ```
- **Result order**: all `--file` inputs first (in flag order), then positional SQLs (in arg order). Stable so you can correlate results to inputs without parsing the `sql` field.
- **Exit code**: non-zero if any statement in the batch failed.

**Warehouse resolution priority:**

1. `--warehouse` / `-w` flag
2. `DATABRICKS_WAREHOUSE_ID` env var
3. Auto-detected available warehouse (consults the user's SQL UI default and falls back to a running warehouse)

**Execution behavior:**

- Submits each statement async, then polls until terminal. Multi-query mode runs up to `--concurrency` in parallel.
- Ctrl+C cancels in-flight statements server-side via `CancelExecution`.
- Fetches all result chunks if results span multiple pages.
- **Auto-starts a stopped warehouse** when needed. (`query` and `discover-schema` auto-start; `get-default-warehouse` and `statement *` do not.)

**SQL cleaning gotcha** (`UNRESOLVED_MAP_KEY`): the shell can eat your quotes around a map key. Fix by either:

- Using single quotes inside double-quoted SQL: `"SELECT attrs['user_id'] FROM events"`
- Or putting the SQL in a `.sql` file and passing `--file`.

---

### `tools discover-schema`

Inspect one or more tables — columns, types, sample data, total row count, and null counts per column.

```bash
databricks experimental aitools tools discover-schema samples.nyctaxi.trips
databricks experimental aitools tools discover-schema c.s.t1 c.s.t2 c.s.t3
databricks experimental aitools tools discover-schema --concurrency 4 c.s.big_table
```

Needs ≥1 positional arg in `CATALOG.SCHEMA.TABLE` format.

**Flags:**

| Flag            | Purpose                                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------------------- |
| `--concurrency` | Max SQL statements in flight at once across all tables AND probes (DESCRIBE, sample SELECT, null counts) — default 8 |

**Output per table:**

1. **COLUMNS** — name + data type
2. **SAMPLE DATA** — 5-row preview, each row numbered
3. **NULL COUNTS** — total row count + null count per column

Multiple tables → divider lines between sections. Errors on individual tables appear inline without aborting the batch — handy for "show me all three" one-shots.

**Cancellation:** Ctrl+C cancels in-flight statements server-side via `CancelExecution` before exit.

Uses the same warehouse resolution and auto-start behavior as `query`.

---

### `tools get-default-warehouse`

```bash
databricks experimental aitools tools get-default-warehouse                # text: ID only
databricks experimental aitools tools get-default-warehouse --output json  # JSON: id, name, state
# {"id":"abc123def456","name":"My Warehouse","state":"RUNNING"}
```

No args. Same resolution priority as `query`. **Does NOT auto-start** the warehouse — if you just want to run a query, let `tools query` handle both. Use this when you specifically need the ID before deciding whether to auto-start it.

---

### `tools statement` (async SQL lifecycle — new in v1.0.0)

Low-level command tree for asynchronous SQL execution. Use when:

- A query is expected to take many minutes (jobs, ML training, large rewrites) and you don't want to hold a synchronous CLI process open.
- You want to track multiple in-flight statements with their own IDs from different shells / scripts.
- You want to cancel a specific statement without taking down the rest.

For "I want results now," reach for `tools query` instead — it does its own polling.

| Subcommand | Purpose                                                                       | Blocks?       | Cancels server-side on Ctrl+C? |
| ---------- | ----------------------------------------------------------------------------- | ------------- | ------------------------------ |
| `submit`   | Fire a statement and return `statement_id` immediately, no polling            | No            | N/A (returns instantly)        |
| `status`   | Single GET against the Statements API — peek at current state without polling | No            | N/A                            |
| `get`      | Poll until terminal, emit `columns` + `rows` on success or `error` on failure | **Yes**       | **No** — only polling stops; the statement keeps running. Use `cancel` to stop it server-side. |
| `cancel`   | Request cancellation; optimistically reports `state=CANCELED`                 | No            | N/A                            |

**`submit`:**

```bash
databricks experimental aitools tools statement submit "SELECT pg_sleep(60)" --warehouse <wh>
databricks experimental aitools tools statement submit --file long_query.sql --warehouse <wh>
```

Flags: `-f/--file` (single file, NOT repeatable here), `-w/--warehouse`. Accepts positional SQL, `--file`, or stdin (same priority as `query`).

**`get` / `status` / `cancel`** all take a single positional `STATEMENT_ID`.

**Output shape:** All four subcommands emit a JSON object with at least `statement_id` and `state`. `get` adds `columns` and `rows` on `SUCCEEDED`. Any subcommand may emit an `error` object on non-success terminal states.

**Important cancellation asymmetry vs `query`:**

- `query` cancels server-side on Ctrl+C (synchronous path, the user explicitly invoked it).
- `statement get` only stops _polling_ on Ctrl+C — the server-side statement keeps running. Use `statement cancel <id>` to terminate it for real. This is intentional: a polling abort should be cheap, and if you've already invested compute in a long-running statement you might want to reconnect to it later, not throw it away.

`statement get` may emit an error object after `cancel` confirms server-side cancellation; the post-cancel state is usually `CANCELED`. Use `statement status` after a `cancel` if you need to be certain.

---

## Environment variables

| Variable                    | Purpose                                                                                     |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| `DATABRICKS_WAREHOUSE_ID`   | Overrides warehouse for `query`, `discover-schema`, `get-default-warehouse`, `statement *`  |
| `DATABRICKS_CONFIG_PROFILE` | Named profile from `~/.databrickscfg` (same as `--profile`)                                 |
| `DATABRICKS_HOST`           | Workspace URL                                                                               |
| `DATABRICKS_TOKEN`          | Auth token (PAT)                                                                            |
| `DATABRICKS_AUTH_STORAGE`   | `plaintext` to keep file-backed OAuth caches (v1.0.0+ default is OS keyring)                |

## Authentication

All `tools` subcommands use the standard Databricks workspace client. If auth is missing, the CLI prints available profiles from `~/.databrickscfg` and asks you to pick. Standard auth methods (profiles, env vars, OAuth) apply. Pass `--profile <name>` on any command to target a specific workspace without mutating env vars.

**v1.0.0 breaking change — OAuth token storage:** Interactive-login OAuth tokens (`auth_type = databricks-cli`) are now stored in the OS-native secure store by default — Keychain on macOS, Credential Manager on Windows, Secret Service on Linux. After upgrading, run `databricks auth login` once per profile to re-authenticate; tokens cached by older versions are not migrated. To keep file-backed storage, set `DATABRICKS_AUTH_STORAGE=plaintext` (or add `auth_storage = plaintext` under `[__settings__]` in `~/.databrickscfg`) and re-run `databricks auth login`. Headless Linux containers without a D-Bus session bus fall back to the file cache transparently.

---

## When NOT to use

Reach for something else in these cases:

- **Creating or managing Databricks resources** (Genie spaces, Vector Search, Lakebase, dashboards, apps, pipelines, serving endpoints, UC grants/tags, monitors, sharing) → AI Dev Kit MCP (`mcp__ai-dev-kit__manage_*`). This skill is read-only.
- **Installing coding-agent skills into Claude Code / Cursor / Codex / OpenCode / Copilot / Antigravity** → `databricks aitools install` (the other `aitools` group — no `experimental`). Not this skill.
- **SQL inside an MCP-driven flow** (agent already holding an MCP session, or you need typed async polling semantics) → `dbsql-dev` MCP. This skill is for terminal/CLI contexts.
- **Complex multi-step automation** (paging, typed responses, retry logic, error branching, programmatic pipelines) → Databricks Python SDK. `tools query` is a one-shot or fan-out batch primitive, not a pipeline.
- **Workspace files, notebooks, clusters, jobs CRUD** → main `databricks` CLI. The `aitools` surface covers only SQL read + schema discovery + warehouse resolution + async statement lifecycle.
- **Semantic / NL search over a Genie space or Vector Search index** → `genie-dais` (or `genie-lab` for capstone bakehouse) or `vs-dev` MCPs. `tools query` only runs SQL literally.

## See also

- Project `CLAUDE.md` → **Databricks Tool Routing** for the full decision matrix across CLI / MCP / SDK.
- `databricks --help`, `databricks aitools --help` (skills management), and `databricks experimental aitools tools --help` (this skill's surface) for the current flag surface (expands between releases — check before assuming older behavior still applies).
- CLI v1.0.0 release notes: https://github.com/databricks/cli/releases/tag/v1.0.0 — the first GA release; semantic versioning starts here.

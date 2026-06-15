---
name: databricks-gotchas
description: >-
  Hard-won Databricks traps and their canonical fixes — load BEFORE writing the code, not after it breaks.
  Use when: authoring CREATE FUNCTION bodies (scalar or TVF), ai_query UDFs, or correlated scalar subqueries
  (LIMIT IS_UNFOLDABLE, QUALIFY scope, MUST_AGGREGATE, ai_query-in-aggregate non-determinism); attaching UC
  row filters / column masks or debugging "my consumer still sees filtered data" (ALTER SET ROW FILTER works on
  TABLEs + STREAMING TABLEs but NOT MVs/VIEWs → inline-WHERE secure-view pattern; is_account_group_member vs
  is_member scope; UDF invoker semantics); building / deploying / debugging Databricks Apps (value_from snake_case,
  apps get config false alarm, apps start no-op); calling ai-dev-kit manage_* MCP tools and verifying via get
  actions or compare-and-reconcile (manage_genie get returns empty table_identifiers — truth in serialized_space;
  description boilerplate round-trip append; manage_dashboard textbox_spec normalization); or discovering databases
  within a Lakebase instance via the Postgres catalog. Applies to ANY Databricks project, not a specific repo.
---

# Databricks Gotchas

A library of Databricks failure modes that are non-obvious, cost real debugging time, and have a known canonical
fix. Each reference is a self-contained domain doc. **Read the matching reference file BEFORE writing code in that
domain** — these are the traps you only learn by hitting them.

This is a deferred-load router: don't read every file. Match the task to the table below and read only what applies.

| Read this reference | When the task touches |
|---|---|
| `references/databricks-sql-udf-gotchas.md` | Writing `CREATE FUNCTION` bodies (scalar OR TVF), `ai_query` UDFs, or correlated scalar subqueries. Covers `LIMIT <udf_param>` IS_UNFOLDABLE, QUALIFY scope, correlated-scalar MUST_AGGREGATE, `ai_query` non-determinism in aggregates, and the inline-`ai_query`-for-batch vs UDF-for-single-row-drilldown split. |
| `references/databricks-uc-governance-gotchas.md` | Attaching row filters / column masks to UC objects, granting EXECUTE on governance UDFs, or debugging "my consumer still sees filtered data." Covers `ALTER … SET ROW FILTER` on TABLEs + STREAMING TABLEs but NOT MVs/VIEWs (→ inline-`WHERE` secure-view pattern), `is_account_group_member` vs `is_member` scope on serverless, the 5-rung permission ladder, and UDF invoker semantics. |
| `references/databricks-apps-gotchas.md` | Building, deploying, or debugging any Databricks App. Covers `value_from` snake_case, the `apps get config:{}` false alarm, `apps start` being a no-op, and MCP tools surfacing raw SDK errors. |
| `references/databricks-ai-dev-kit-mcp-gotchas.md` | Writing agent code that calls `mcp__ai-dev-kit__manage_*` tools AND verifies via `get` actions or compare-and-reconcile flows. Covers `manage_genie get` returning empty `table_identifiers` (truth lives in `serialized_space.data_sources.tables`), description-boilerplate round-trip append compounding, and `manage_dashboard` `textbox_spec`-in / `multilineTextboxSpec.lines[]`-out normalization. |
| `references/lakebase-introspection.md` | Discovering which databases exist inside a Lakebase (managed Postgres) instance via the PG system catalog. |

## How to use

1. Identify the domain from the task (SQL UDF? UC governance? App? ai-dev-kit MCP? Lakebase discovery?).
2. Read the single matching reference file in full before writing code — the traps are interdependent within a doc.
3. Examples in the references may use illustrative table names; the **trap and the fix are the portable part**, not the schema.

## Related

- For general Databricks CLI / SQL / pipeline / app authoring (not traps), use the `databricks-*` catalog skills
  (`databricks-dbsql`, `databricks-apps`, `databricks-unity-catalog`, `databricks-lakebase`, etc.). This skill is the
  **gotchas layer** that sits on top of them — load it alongside the relevant catalog skill, not instead of it.

# Databricks Apps Gotchas

Load when: building, deploying, debugging, or modifying any Databricks App (including MCP-server-as-App, Streamlit / Dash / Gradio / FastAPI apps, dashboards backed by an App). These are silent-failure modes the CLI/server tolerates without warnings — every one cost hours to diagnose the first time.

---

## 1. Env-var bindings to bundle resources

**Use snake_case `value_from`, NOT camelCase `valueFrom`.** The bundle CLI silently drops unknown fields with no validation error. Writing `valueFrom: <resource>` is a no-op; the env var ends up empty on the running container, and the app fails at runtime with a misleading error (e.g. `run_sql` returns "warehouse_id is required" because `DATABRICKS_WAREHOUSE_ID` is unset).

```yaml
# CORRECT — snake_case
env:
  - name: DATABRICKS_WAREHOUSE_ID
    value_from: warehouse

# WRONG — silently dropped by the CLI; env var ends up empty
env:
  - name: DATABRICKS_WAREHOUSE_ID
    valueFrom: warehouse
```

Verify the canonical field name with the schema directly:

```bash
databricks bundle schema | grep value_from
# Look for the apps.EnvVar definition — confirms snake_case
```

**Both files must use snake_case:**
- `<app-dir>/app.yaml` — the runtime config the deployed app reads at startup
- `bundle/resources/<app>.app.yml` — the bundle's `config.env` block declared in the DAB resource

Working example: see `custom-mcp/app.yaml` + `bundle/resources/mcp-custom-app.app.yml` — both bind `DATABRICKS_WAREHOUSE_ID` to the bound `warehouse` resource via `value_from`.

---

## 2. `databricks apps get` returns `config: {}` regardless of actual env vars

The `config` field in the apps get API response is **metadata-only**. It does NOT reflect the running container's actual env vars or command. Don't waste time inspecting it for env-var verification — the field is empty even when env vars ARE set correctly.

To verify env-var injection, you must do an empirical test: invoke a tool on the deployed app that depends on the env var, and check the response.

Example with `mcp-custom-app`:

```python
# Call run_sql WITHOUT an explicit warehouse_id argument:
#   - If DATABRICKS_WAREHOUSE_ID env var is set → run_sql succeeds
#   - If it's not set → run_sql returns {"error": "warehouse_id is required..."}
```

---

## 3. `databricks apps start` is a no-op if the app is already RUNNING

The CLI prints `App 'X' is already running` and returns success — but doesn't actually restart the container. To force a restart that picks up new env vars or source code, run the bundle's app resource:

```bash
cd <bundle-dir>
databricks bundle run <app_resource_name> -t <target> --profile <p>
```

This re-uploads source from the bundle, applies the app config (command, env, resources), and restarts the entrypoint. Confirm the restart by comparing `active_deployment.deployment_id` in `databricks apps get` before and after.

For the DAIS26 workshop's `mcp-custom-app`:

```bash
cd bundle
databricks bundle run mcp_custom_app -t dais --profile dais
```

---

## 4. MCP tools wrapping the Databricks SDK must surface `error.message`

When wrapping the Databricks SDK in an MCP tool (run_sql, query_genie, job runners, pipeline status checks, anything that returns a `StatementResponse` / `JobRun` / `PipelineUpdate` with `status.error`), always extract and return the underlying error from `response.status.error.message` (and `.error_code` if present).

Returning only `status: FAILED` without the error string forces calling agents to **guess** the failure cause. They consistently guess wrong, blaming the most recent thing in their context window. A missing UDF EXECUTE grant gets misattributed to "warehouse permission". A bad warehouse_id gets misattributed to "schema doesn't exist". The cascade burns hours of fake-fix attempts.

```python
# CORRECT — diagnostic, ~3 extra lines
result: dict = {
    "status": status,
    "warehouse_id": wh,
    "columns": columns,
    "rows": rows,
    "row_count": len(rows),
}
if response.status and response.status.error:
    result["error"] = response.status.error.message
    if getattr(response.status.error, "error_code", None):
        result["error_code"] = response.status.error.error_code
return result

# WRONG — error swallowed; agents confabulate causes
return {
    "status": status,
    "columns": [],
    "rows": [],
    "row_count": 0,
}
```

Apply this pattern to any new SDK-wrapping MCP tool you write. The fix is ~3 lines per tool; the upside is every future SQL failure being diagnostic instead of guess-driven.

Reference implementation: `custom-mcp/server/tools.py` `run_sql`.

---

## 5. The complete env-var injection picture (precedence)

Databricks Apps merges env vars from two sources at deploy/restart time:

1. **Bundle YAML `config.env`** in `bundle/resources/<app>.app.yml` — declarative, version-controlled, gets applied via the apps API when `bundle run` happens
2. **`<app-dir>/app.yaml` `env`** — runtime config the app source ships; read by the app at startup

In practice the safe pattern is to **declare every env var in the bundle YAML** (snake_case `value_from` for resource-bound vars, plain `value` for literals) so it's all in one place and version-controlled. The `app.yaml` env block is kept as a backup but shouldn't be your source of truth for env-var declarations.

---

## When you suspect Apps misconfiguration

1. **`databricks apps get <name> -o json`** — get app health + deployment_id + bound resources (note: `config: {}` is normal, see #2)
2. **`databricks bundle schema | grep value_from`** — verify your `app.yaml` / bundle YAML matches the canonical schema
3. **Empirical tool test** — invoke a tool that depends on the suspect env var
4. **Force a fresh deploy** — `bundle deploy` + `bundle run <app_resource>` produces a new `deployment_id`; if the new deployment_id matches your local source's content hash (visible in `active_deployment.deployment_artifacts.source_code_path`), your patch is live

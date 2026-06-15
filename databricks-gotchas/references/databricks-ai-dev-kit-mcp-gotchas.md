# ai-dev-kit MCP Shape Gotchas

Load when: writing agent code that calls `mcp__ai-dev-kit__manage_*` tools (Genie, dashboard, pipeline, etc.) AND that VERIFIES results — especially via `get` actions, OR comparing local JSON state vs remote workspace state. These are MCP-server-layer normalizations, NOT bugs in the underlying Databricks platform — `manage_*` tools accept user-friendly input shapes but normalize to canonical storage shapes on the way through, so `create` input shape ≠ `get` output shape for several fields. Compare-and-reconcile flows that don't normalize will see false-positive drift.

All findings below were surfaced during the 2026-05-26 DAIS26 retail-c360 demo build.

---

## 1. `manage_genie action=get` returns empty `table_identifiers` even when tables ARE wired

`mcp__ai-dev-kit__manage_genie action=get` returns `table_identifiers: []` at the top level of the response, **regardless of how many tables are actually wired into the space**. The actual table list lives in `serialized_space.data_sources.tables[*].identifier` — only populated when you call `get` with `include_serialized_space=true`.

**Silent-failure trap**: an assertion like `assert get(sid).table_identifiers == expected_list` will FALSELY fail. The space IS correctly wired; just the get-response shape misleads.

**Three reliable verification paths**:

1. **Trust the `create_or_update` return value** — the `table_count` field is accurate at create time:
   ```python
   result = manage_genie(action="create_or_update", display_name="X", table_identifiers=[...], ...)
   assert result["table_count"] == 3  # this works
   ```

2. **Call `get` with `include_serialized_space=true`** and parse the nested structure:
   ```python
   resp = manage_genie(action="get", space_id=sid, include_serialized_space=True)
   tbls = json.loads(resp["serialized_space"])["data_sources"]["tables"]
   tbl_names = [t["identifier"] for t in tbls]
   ```

3. **DO NOT use** `databricks genie get-space <id>` (CLI) for wiring verification — it's even thinner than the MCP's plain `get`; returns NEITHER tables NOR sample questions, just title + warehouse_id.

Verified 2026-05-26 against the retail-c360 Genie space (3 tables wired via `create_or_update`, `table_count: 3` in create return, `table_identifiers: []` in plain `get`, full 3-table list in `serialized_space`).

---

## 2. `manage_genie` appends `\n\nBuilt with Databricks AI Dev Kit` to user-supplied descriptions

User-supplied `description` text gets a trailing `\n\nBuilt with Databricks AI Dev Kit` appended by the MCP server (visible in both `get` response and `serialized_space`). The append happens at create time and is stored as part of the persisted description.

**Cosmetic — not load-bearing**. Doesn't break governance, query routing, or sample-question matching. But two flows to be aware of:

1. **Description-content matching** (e.g., agent code that searches spaces by description substring): the trailing tag is part of the persisted text. Searches for exact-match descriptions will fail; substring searches are unaffected.

2. **Round-trip export → re-import migrations**: if you `export` a space's description and re-supply it on `import`, the MCP appends the tag AGAIN to the already-tagged text. After N round-trips, the description becomes:
   ```
   <user_description>
   
   Built with Databricks AI Dev Kit
   
   Built with Databricks AI Dev Kit
   
   ... (N copies)
   ```
   Strip the trailing tag before re-import to avoid compounding. The cleanest pattern: strip `re.sub(r'\n\nBuilt with Databricks AI Dev Kit$', '', description)` on every export.

Verified 2026-05-26 against the retail-c360 Genie space — first-create description showed the tag in both `get` response and `serialized_space`.

---

## 3. `manage_dashboard` accepts `textbox_spec` on input, stores `multilineTextboxSpec.lines[]` on read

`mcp__ai-dev-kit__manage_dashboard action=create_or_update` accepts text widgets in TWO equivalent input shapes — short-form `{"textbox_spec": "..."}` (string) OR long-form `{"multilineTextboxSpec": {"lines": [...]}}` (object) — but `action=get` ALWAYS returns the long-form shape regardless of which form you used on create. A round-trip export-then-reimport morphs the structure from input format A → output format B.

**Mechanism**: the MCP server normalizes text widget definitions to a canonical Lakeview JSON shape on the way through, mirroring how the underlying Databricks SDK stores them. `textbox_spec` is a syntactic-sugar input that gets desugared into `multilineTextboxSpec.lines` (splitting on newlines into the line array). Normalization is one-way: input → canonical → store. There's no reverse-normalization on read.

**Three places to handle this**:

1. **Single-create deploys**: doesn't matter which form you use. Both succeed.

2. **Compare-and-reconcile diff flows** (agent code that diffs local JSON state vs remote workspace state): normalize the local-side `textbox_spec` strings to `multilineTextboxSpec.lines[]` arrays BEFORE diffing. Otherwise every diff falsely shows "text widgets changed" even when they're identical.

3. **Persisted-in-repo dashboard JSON** (e.g., `e2e/demo-retail-c360/dashboards/*.lvdash.json`): pick one canonical form for the file and stick with it. The retail-c360 file uses short-form for readability; if you re-export from the workspace, the export will be long-form. Don't auto-overwrite the repo file from a workspace export without re-converting (or accept the form change and use long-form everywhere).

Verified 2026-05-26 against the retail-c360 dashboard — `"textbox_spec": "# Retail C360 — Churn Analytics"` sent as input, `"multilineTextboxSpec": {"lines": ["# Retail C360 — Churn Analytics"]}` returned on `get`.

---

## 4. `manage_pipeline` has NO standalone `run` / `start-update` action — `update` conflates config-change with trigger

`mcp__ai-dev-kit__manage_pipeline` exposes `create | create_or_update | get | update | delete | find_by_name` — no `run` or `start-update`. To trigger a deployed pipeline, the only MCP path is `action=update` with `start_run=true` AND all required config fields (`name + catalog + schema + workspace_file_paths`). Omitting `catalog + schema` errors with `"Changing a UC pipeline to a HMS pipeline is not allowed"` (the MCP defaults missing fields to `None`, which the tool interprets as a config-change to HMS). Omitting `name` errors with `"name must be set"`. Result: there is no trigger-only path through the MCP for an existing well-configured pipeline.

**Mechanism**: the MCP wrapper conflates "update config" with "trigger run" via the `start_run=true` parameter. Update without start_run is a config-only edit; update with start_run is a config-edit-plus-trigger. There's no trigger-only-without-edit path. Internally, every `update` call validates the full config payload, even when the caller only wants to start an update on the existing config.

**Three places to handle this**:

1. **Workshop Phase 3 (visible-MCP-call beat)**: use `mcp__ai-dev-kit__manage_pipeline action=find_by_name name=retail-c360-pipeline` to get the pipeline_id (1 visible MCP call), then CLI `databricks pipelines start-update <pipeline_id> --profile dais` for the trigger. Preserves ≥1 visible MCP tool call for the audience while sidestepping the config-coupling.

2. **Agent code that needs to trigger an existing pipeline programmatically**: use the Python SDK directly — `w.pipelines.start_update(pipeline_id=..., full_refresh=False)`. Cleaner than the MCP for non-workshop production code.

3. **If you must use MCP only** (e.g., constrained tool-surface environment): supply the full config payload from a `get` call's response, set `start_run=true`, send back through `update`. Awkward but works.

**Patch recommendation (upstream)**: ADD an `action=run` to `mcp__ai-dev-kit__manage_pipeline` that takes only `pipeline_id + full_refresh + wait_for_completion` — no config-update coupling. Would close this gap.

Discovered 2026-05-27 during the retail-c360 workshop kickoff regen. Logged in `.c360-regen-issues-2026-05-27-1132utc.md` Issue 5.

---

## 5. `manage_genie create_or_update` silently mints a NEW orphan space when called with partial fields

`mcp__ai-dev-kit__manage_genie` exposes a single `action=create_or_update` (no separate `create_space` / `add_sample_question` / `update_description` actions — those names are NOT in the surface). The action is documented as "idempotent by display_name" but exhibits a specific anti-pattern: calling it a SECOND time with the same title BUT a subset of the original fields (e.g., omitting `description` or `table_identifiers` because you only want to add a question) silently mints a NEW space with an auto-timestamp-suffixed title (`Retail C360 — Churn Analytics 2026-05-27 11:51:43`). The original space is left untouched; the orphan must be deleted via a separate `action=delete` call.

**Mechanism**: the idempotency check uses an exact-match-by-title comparison, BUT the MCP layer treats missing fields as "this is a different object" rather than "patch only the fields present." So a partial-update call fails the title-equality check (because internally the partial-update is treated as a CREATE attempt, not an UPDATE), and the create-collision auto-suffix kicks in to produce a unique title.

**Two places to handle this**:

1. **Always pass ALL fields on every `create_or_update` call**: include `title`, `description`, `warehouse_id`, `table_identifiers`, `sample_questions`, even on what you intend as a partial update. This is awkward (the caller may not have the original `description` text around) but it's the only way to avoid orphan minting. Read the current space's full payload via `action=get` first if needed.

2. **Use `action=update` for true partial patches** — `update` requires `space_id` as a parameter (the orphan-minting path is `create_or_update` WITHOUT space_id, falling back to title-match). If you have the space_id from a prior `create_or_update` or `find_by_name` response, `update` is the correct path; if you only have the title, your only "update" route is to first `find_by_name` to resolve space_id.

**Verified 2026-05-27 c360 Phase 6**: Worker 6 issued an initial `create_or_update` (created the canonical space), then a SECOND `create_or_update` to add sample questions without re-passing `description` or `table_identifiers` — the second call orphan-minted `Retail C360 — Churn Analytics 2026-05-27 11:51:43`. Worker cleaned up via `action=delete`, then re-issued `create_or_update` with all fields including `sample_questions=[...]` array. Final state: 1 canonical space. Logged in `.c360-regen-issues-2026-05-27-1132utc.md` Issue 6.

**Related**: §1 (`get` returns empty `table_identifiers`) — the same truth-source asymmetry surfacing on read; here it surfaces on write.

---

## When you suspect an ai-dev-kit MCP shape bug

1. **Get response field is empty when you expected populated data** (`table_identifiers`, `sample_questions`, `tags`, etc.): try the `get` call again with `include_serialized_space=true` (Genie) or read the full `serialized_dashboard` (dashboard). The truth often lives in the nested serialized payload, not the top-level convenience fields. The convenience fields are best-effort summaries; the serialized payload is the contract.

2. **Round-trip export → import doesn't round-trip cleanly** (description grew, text widget shape changed, etc.): check whether the MCP appends boilerplate (§2) or normalizes shapes (§3) on the way through. Strip the appended boilerplate before re-import; pick one canonical shape and convert local state to match before diffing.

3. **Compare-and-reconcile is reporting drift for objects you didn't touch**: the source-of-drift is almost certainly an MCP-side normalization, not a workspace-side mutation. Print the remote object's `serialized_*` payload and look for shape mismatches against your local-side input format. Fix by normalizing your local state once on each diff cycle.

4. **CLI vs MCP responses disagree on the same object**: the MCP wraps the SDK with extra fields (and sometimes loses fields); the CLI is closer to the raw REST API. For wiring-truth verification of complex configs (Genie spaces, dashboards), the MCP's `serialized_*` payload is the most complete source. For quick "does the object exist" checks, either works.

5. **You're about to file an issue against Databricks platform for one of these**: pause — these are MCP-server-layer artifacts of the user-friendliness layer (`textbox_spec` shorthand, `Built with...` branding tag, `table_identifiers` summary field). Filing them against the platform won't reach the right team. The MCP server lives in the `ai-dev-kit` repo / package; fixes there require an MCP version bump, not a Databricks API change.

---

## Promotion criteria for adding new findings

This doc was promoted from 3 individual memory entries when the promotion criterion ("2+ findings across cards 8+9") was met during the 2026-05-26 retail-c360 build. The discipline is: surface a finding in a session → save as memory → if 2+ memories accumulate in the same gotcha family, graduate to a project agent_doc. Going forward, additional ai-dev-kit MCP shape findings should be saved as memories first, then folded into a new numbered section here once verified independently in at least one subsequent session.

Each new section should follow the §1/§2/§3 template: symptom → mechanism → how to handle in 2-3 flow contexts → date verified + reference card.

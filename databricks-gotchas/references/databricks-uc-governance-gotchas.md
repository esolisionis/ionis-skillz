# Databricks Unity Catalog Governance Gotchas

Load when: applying row filters, column masks, or grants to UC tables/views/MVs/STs; verifying governance enforcement on serverless; reasoning about admin escape hatches; debugging "my consumer still sees the data I just filtered out". The DAIS26 workshop reference implementation lives in [`e2e/demo-retail-c360/scripts/06_apply_governance.py`](../../e2e/demo-retail-c360/scripts/06_apply_governance.py) — it applies governance to `users_silver` (a streaming table) only. The §1 inline-`WHERE` secure-view pattern is documented as a production extension for MV consumers; not enacted in the workshop demo path.

---

## 1. `ALTER ... SET ROW FILTER` only attaches to TABLEs and STREAMING TABLEs — not VIEWs or MATERIALIZED VIEWs

**The `ALTER ... SET ROW FILTER` syntax has narrower object-type support than the surface API suggests.** Empirical compatibility matrix (verified during DAIS26 workshop hardening, 2026-05-26):

| Object type | `ALTER ... SET ROW FILTER` works? | Failure mode if you try anyway |
|---|---|---|
| **TABLE (Delta managed/external)** | ✅ Yes | — |
| **STREAMING TABLE** (`@dp.table` SDP outputs like `users_silver`) | ✅ Yes | — |
| **MATERIALIZED VIEW** | ❌ No | `UNSUPPORTED_FEATURE.*` or `EXPECT_TABLE_NOT_VIEW.NO_ALTERNATIVE` |
| **VIEW (regular)** | ❌ No | `PARSE_SYNTAX_ERROR` on `ALTER VIEW` (it's not in the grammar); `EXPECT_TABLE_NOT_VIEW.NO_ALTERNATIVE` on `ALTER TABLE` |

The Databricks SQL reference for `ALTER VIEW` lists only: `RENAME TO`, `SET/UNSET TBLPROPERTIES`, `AS <select>`, `OWNER TO`. Row filters are not part of the `ALTER VIEW` grammar — so the natural-feeling workaround "wrap the MV in a view, then `ALTER VIEW SET ROW FILTER`" silently doesn't exist either. The real workaround is the inline-`WHERE` pattern below.

### Workshop scope (DAIS26 c360 demo)

The workshop demo filters `users_silver` only — that's a streaming table, takes `ALTER ... SET ROW FILTER` cleanly, and is enough to demonstrate end-to-end UC governance enforcement at the SQL layer for the demo narrative (Sarah masked, Yuki filtered from `users_silver`). Comprehensive filter coverage to MV consumers is documented below as a **production extension** — the pattern attendees take home and apply in their own projects when MV-backed consumers (dashboards, Genie spaces, batch UDFs) need the same governance posture.

### Production extension — inline filter UDF call in a wrapping VIEW body

To filter a materialized view's consumers (or any object that doesn't accept `ALTER ... SET ROW FILTER`), the working pattern is to wrap the MV in a regular VIEW whose body inlines the filter UDF call in its `WHERE` clause. The UDF is invoker-evaluated at query time (per §5), so the row filter applies per-caller-identity — query-time semantics are **identical** to what `SET ROW FILTER` would produce.

```sql
-- WORKING pattern: inline filter call in view body's WHERE clause
CREATE OR REPLACE VIEW dais26_vibe.retail_c360.churn_features_secured AS
  SELECT *
  FROM dais26_vibe.retail_c360.churn_features
  WHERE dais26_vibe.retail_c360.country_allowlist_filter(country);

-- Consumers query the view, never the raw MV
GRANT SELECT ON VIEW dais26_vibe.retail_c360.churn_features_secured TO `<consumer_sp>`;
```

```sql
-- ANTI-PATTERN: ALTER VIEW SET ROW FILTER does NOT exist
-- PARSE_SYNTAX_ERROR — not part of the ALTER VIEW grammar
ALTER VIEW dais26_vibe.retail_c360.churn_features_secured
  SET ROW FILTER dais26_vibe.retail_c360.country_allowlist_filter ON (country);
```

Three downstream design rules that follow when you adopt the inline-`WHERE` pattern:

1. **Consumers query the view, never the raw MV.** Downstream SQL UDFs, dashboards, Genie spaces, and batch jobs all read `FROM churn_features_secured`. If any consumer hits the raw MV path, the filter is bypassed.

2. **Function bodies must be re-issued when governance lands later.** If you `CREATE FUNCTION` bodies reading `FROM <raw_mv>` BEFORE the secured view exists, those functions still query the unfiltered base. `CREATE OR REPLACE FUNCTION` with `FROM <secured_view>` to close the loop.

3. **Use the secure view's name as the canonical reference everywhere.** Once `churn_features_secured` exists, every dashboard query, Genie wiring, and agent peer references it. The raw MV remains available for admins (in the `admins` account group) to query directly when full-fidelity analytics is needed.

---

## 2. `is_account_group_member` vs `is_member` — scope matters on serverless

**`is_account_group_member('<group>')` checks against the Databricks **account-level** identity provider; `is_member('<group>')` checks against the **workspace-level** group registry.** On serverless compute, account-group semantics are usually what you want because serverless executes against the account identity model. The two predicates can return different results for the same caller depending on which scope the `'admins'` group exists in.

| Predicate | What it checks | When to use |
|-----------|----------------|-------------|
| `is_account_group_member('admins')` | Account-level admin group | Default for serverless; production-correct for SCIM-managed identities; the DAIS26 workshop standard |
| `is_member('admins')` | Workspace-level group | When the demo needs a presenter visible as admin on direct CLI access without setting up an account group |

**The DAIS26 workshop standard is `is_account_group_member('admins')`.** This means the presenter (running direct CLI queries with their personal identity, which is typically NOT in an `admins` account group) sees masked data — which is actually a teachable moment, not a limitation: *"watch, even I see `***` here because I'm not in the admins account group; the only way to see clear data is through the agent SP path, which is governed by UC."*

To see clear data on direct CLI without changing the predicate: create a `c360-admins` **account group** (Databricks account console, not workspace settings) and add the presenter. Or for a one-off demo, temporarily switch the mask UDF to `is_member('admins')` — but revert before handoff.

---

## 3. Inline `WHERE` filters in MV bodies look like governance but aren't

A surface-level "fix" that doesn't deliver role-based row filtering:

```sql
-- LOOKS LIKE governance, ISN'T governance
CREATE OR REPLACE MATERIALIZED VIEW churn_features AS
  SELECT ...
  FROM users JOIN orders ...
  WHERE country IN ('USA','UK','France');
```

This filters at **materialization time** — every consumer sees only USA/UK/France rows, with **no role distinction**. There's no `is_account_group_member` escape hatch for admins. The data isn't `filtered`, it's `excluded` from the storage layer entirely. Admin analytics, audit, and lineage all lose access to the non-allowlisted rows.

If you want role-based row filtering (admins see all, non-admins see subset), you MUST go through `SET ROW FILTER` on a wrappable object (table or view) — see §1.

---

## 4. The 5-rung permission ladder for governed tables

To query a UC table/view with mask + row filter applied, the calling identity needs all five rungs:

1. **SELECT on the table/view** (or schema-level grant)
2. **USE CATALOG on the parent catalog**
3. **USE SCHEMA on the parent schema**
4. **EXECUTE on the mask UDF** (every mask function the touched columns reference)
5. **EXECUTE on the row filter UDF**

Schema-level grants cover all current AND future objects in the schema — the simplest path:

```sql
GRANT USE CATALOG ON CATALOG dais26_vibe TO `<principal>`;
GRANT USE SCHEMA ON SCHEMA dais26_vibe.retail_c360 TO `<principal>`;
GRANT SELECT ON SCHEMA dais26_vibe.retail_c360 TO `<principal>`;
GRANT EXECUTE ON SCHEMA dais26_vibe.retail_c360 TO `<principal>`;
```

**Symptom of a missing rung 4 or 5**: query returns no rows AND no obvious error. UC silently treats the missing-EXECUTE condition as "filter returns FALSE", indistinguishable from "row matched the filter but evaluated to false". Always grant EXECUTE at the schema level so consumer principals inherit it across mask/filter UDFs.

---

## 5. UC SQL UDF security mode determines whose identity drives filter evaluation

UC SQL functions default to **invoker semantics** where supported (DBR 16+ generally): when the caller invokes the function, the function body executes against the **caller's** identity, so row filters/masks attached to underlying tables apply to the caller, not the function owner.

This is why the DAIS26 retail-agent demo's M2M SP sees filtered data through `top_customers_by_ltv` — the SP's identity (not the function owner's) drives the row filter on `churn_features_secured`. If the function were defined with definer semantics (the owner's identity), then admin-owned functions would bypass the filter and leak rows to non-admin callers.

Verify with `DESCRIBE FUNCTION <name>` and look for the security clause. Explicitly set `SQL SECURITY INVOKER` on the `CREATE FUNCTION` statement if you need to be certain. **The corollary**: if you re-create a function pointing at a secured view, you also need to make sure the caller has the 5 rungs (§4) on both the function AND the underlying view+mask+filter UDFs.

---

## 6. Parallel `aitools query --file` is a silent race for multi-column SET MASK on the same table

**Verified 2026-05-26 during DAIS26 c360 rehearsal Card 6.**

Running multiple `ALTER TABLE ... ALTER COLUMN <col> SET MASK <udf>` statements **against the same table** in parallel via `databricks experimental aitools tools query --file <a> --file <b> --file <c>` is a silent race condition. **All statements return `state: SUCCEEDED`** in the per-statement result envelope (with valid `statement_id` + `elapsed_ms` each), but **only the last commit's mask persists** in the table metadata. The other attachments vanish without error.

```bash
# WRONG — silent race on shared table-metadata surface
databricks experimental aitools tools query -w <w> --profile dais -o json \
  --file set_mask_firstname.sql \
  --file set_mask_lastname.sql \
  --file set_mask_address.sql
# Returns 3x SUCCEEDED. DESCRIBE EXTENDED reveals only ONE mask attached.
```

```bash
# RIGHT — serialize each ALTER through its own aitools call
databricks experimental aitools tools query -w <w> --profile dais \
  "ALTER TABLE users_silver ALTER COLUMN firstname SET MASK mask_string_pii" -o json && \
databricks experimental aitools tools query -w <w> --profile dais \
  "ALTER TABLE users_silver ALTER COLUMN lastname SET MASK mask_string_pii" -o json && \
databricks experimental aitools tools query -w <w> --profile dais \
  "ALTER TABLE users_silver ALTER COLUMN address SET MASK mask_string_pii" -o json
```

### Failure semantics

- All N statements report `state: SUCCEEDED` with valid statement_ids
- Only the LAST commit's mask persists; first N-1 are silently dropped
- `DESCRIBE EXTENDED <table>` reveals the truth — `# Column Masks` section shows only one column
- Subsequent SELECT against unmasked columns returns CLEAR values (the masks aren't there to redact them)
- **Internal inconsistency is the diagnostic clue:** if a row filter (table-level metadata) AND column masks (per-column metadata) ran in the same parallel batch, the row filter usually attaches cleanly (different namespace) while the masks race. The "row filter works but mask doesn't" pattern is the giveaway — both UDFs use the same `is_account_group_member('admins')` predicate, so divergent behavior between filter and mask can only mean one of them didn't attach.

### Mechanism

`aitools query --file` parallelizes statement submission across the Statement Execution API. Each statement gets its own warehouse session. Three concurrent `ALTER COLUMN SET MASK` against the same table contend for the same table-metadata commit slot — Databricks' optimistic-concurrency commit protocol lets the last writer win, but doesn't surface the conflict to the losers (they observe their own commit succeeded in their session view, oblivious to the subsequent overwrite). The same-column-namespace (per-column-mask portion of the table descriptor) is the race surface.

**Cross-namespace DDL is safe** — applying 1 row filter + 1 column mask in parallel is fine, because they touch different parts of the table descriptor. The race is specifically column-mask-vs-column-mask on the same table.

### Canonical evasion pattern

`e2e/demo-retail-c360/scripts/06_apply_governance.py` evades this with a Python for-loop:

```python
# Python SDK loop — each iteration awaits SUCCEEDED before issuing the next
for label, sql in apply_masks_sql + apply_row_filter_sql:
  run_sql_batch(w, warehouse_id, [(label, sql)])
```

`run_sql_batch` awaits each statement's SUCCEEDED state before issuing the next. This is the SDK-side equivalent of the `&&`-chained shell pattern above — both produce a guaranteed-serial submission order.

### Verification gate

After any multi-column mask application, run `DESCRIBE EXTENDED <table>` and confirm every expected mask appears under `# Column Masks`. **Never trust per-statement `SUCCEEDED` alone** for shared-metadata DDL.

---

## When you suspect a governance bug

1. **Row filter / mask failed to attach.** Check the object type — `ALTER ... SET ROW FILTER` works on TABLE + VIEW; NOT on MATERIALIZED VIEW + STREAMING TABLE. If the target is an MV/ST, use the secure view wrapper from §1.

2. **"I see clear data when I expect masked"** (or vice versa). Check the predicate (`is_account_group_member` vs `is_member` from §2) against your account/workspace group membership. Serverless skews toward account-group semantics.

3. **Consumer queries return no rows when expected.** Walk the 5-rung ladder in §4. The most commonly-missed rung is schema-level GRANT EXECUTE on the mask/filter UDFs — easy to forget when granting only SELECT.

4. **"Function still returns Japan rows after I added the row filter."** Three culprits to check in order: (a) the function queries the raw MV instead of the secured view (§1 design rule #2) — `CREATE OR REPLACE` with the new FROM body; (b) the function was created with definer semantics, bypassing the caller's identity (§5); (c) the caller IS an admin and the filter UDF's `is_account_group_member('admins') OR ...` short-circuits to TRUE.

5. **Re-running governance script wipes prior attachments.** `bundle run <pipeline> --full-refresh-all` recreates streaming tables from scratch, dropping any column masks or row filters attached via `ALTER TABLE`. Always re-run `06_apply_governance.py` (or the equivalent Card 6 DDL) after a full refresh — that's the standard heal pass.

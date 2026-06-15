# Databricks SQL UDF Authoring Gotchas

Load when: writing `CREATE FUNCTION` bodies (scalar OR table-valued), `ai_query` UDFs, or correlated subqueries inside UC functions. These are planner-time errors with cryptic SQLSTATEs that bite the first time you parameterize a UDF — every one cost real diagnosis time during DAIS26 workshop hardening. The reference implementations live in [`e2e/demo-retail-c360/scripts/02_create_uc_funcs.py`](../../e2e/demo-retail-c360/scripts/02_create_uc_funcs.py) (analytic TVFs) and [`e2e/demo-retail-c360/scripts/03_create_ai_funcs.py`](../../e2e/demo-retail-c360/scripts/03_create_ai_funcs.py) (`ai_query`-backed UDFs).

---

## 1. `LIMIT <udf_param>` fails — planner-time constant-folding requirement

**`LIMIT n` where `n` is a UDF parameter fails with `INVALID_LIMIT_LIKE_EXPRESSION.IS_UNFOLDABLE` (SQLSTATE `42K0E`).** The Databricks SQL planner requires `LIMIT` (and `OFFSET`, `TABLESAMPLE`, `PIVOT IN`-list) to evaluate to a *constant at plan time*. UDF parameters are known only at *invocation time*, so they're fundamentally non-foldable. The planner error reads `outer(<func_name>.<param>) is not foldable` — note the `outer(...)` wrapper, which tells you Spark DID see the param, it just can't fold it into a literal.

```sql
-- WRONG — fails at CREATE FUNCTION time with IS_UNFOLDABLE
CREATE OR REPLACE FUNCTION top_customers_by_ltv(n INT)
  RETURNS TABLE(user_id BIGINT, lifetime_spend DECIMAL(14,2))
  RETURN
    SELECT user_id, lifetime_spend
    FROM churn_features
    ORDER BY lifetime_spend DESC
    LIMIT n
```

**Working pattern** — `ROW_NUMBER() OVER (...)` in a subquery + outer `WHERE _rn <= n`:

```sql
-- RIGHT — universally portable, stable cardinality (returns exactly n rows)
CREATE OR REPLACE FUNCTION top_customers_by_ltv(n INT)
  RETURNS TABLE(user_id BIGINT, lifetime_spend DECIMAL(14,2))
  RETURN (
    SELECT user_id, lifetime_spend
    FROM (
      SELECT
        user_id,
        lifetime_spend,
        ROW_NUMBER() OVER (ORDER BY lifetime_spend DESC) AS _rn
      FROM churn_features
    )
    WHERE _rn <= n
  )
```

Use `ROW_NUMBER()` (not `RANK()`) for stable cardinality — `RANK()` admits ties and returns ≥ n rows.

---

## 2. `QUALIFY <udf_param>` fails with a DIFFERENT error — scope, not folding

A natural-feeling alternative — `QUALIFY ROW_NUMBER() OVER (...) <= n` — also fails, but with `UNRESOLVED_COLUMN.WITH_SUGGESTION` (SQLSTATE `42703`), not `IS_UNFOLDABLE`. QUALIFY is rewritten internally into a wrapping subquery + filter, which puts the UDF parameter "two scopes deep" relative to the function body root. The planner's parameter-resolution path doesn't reach into the QUALIFY scope, so `n` reads as an unbound column reference. The error message even suggests column names from the table because the resolver thinks `n` is supposed to be a column.

```sql
-- WRONG — UNRESOLVED_COLUMN; QUALIFY's rewritten scope can't see UDF params
RETURN
  SELECT user_id, lifetime_spend
  FROM churn_features
  QUALIFY ROW_NUMBER() OVER (ORDER BY lifetime_spend DESC) <= n
```

The subquery + WHERE pattern in §1 is the **universally portable replacement**. It works on every DBR version because the UDF parameter sits at the outer SELECT's WHERE clause — one scope from the function body root, not two.

---

## 3. Correlated scalar subqueries MUST aggregate — even with unique-key filters

A correlated scalar subquery inside a UC function body fails with `MUST_AGGREGATE_CORRELATED_SCALAR_SUBQUERY` (SQLSTATE `0A000`), even when the WHERE filter targets a unique key (e.g., `WHERE user_id = uid` against a primary key). The Databricks planner doesn't reason about uniqueness constraints; it requires the inner SELECT to be wrapped in an aggregate.

```sql
-- WRONG — fails even though user_id is unique
RETURN
  (SELECT country FROM users_silver WHERE user_id = uid)

-- RIGHT — wrap in ANY_VALUE (semantically equivalent for unique keys)
RETURN
  (SELECT ANY_VALUE(country) FROM users_silver WHERE user_id = uid)
```

This bites scalar UDFs that fetch single attributes by primary key — exactly the pattern `predict_churn(uid)` and `generate_marketing_copy(uid)` use. `ANY_VALUE` is the cleanest wrap; `MAX` / `MIN` work too if you want stable ordering semantics.

---

## 4. `ai_query` can't sit inside an aggregate — non-deterministic function rule

`ai_query` is non-deterministic by definition (LLM responses vary per call). Embedding it directly inside an aggregate raises `AGGREGATE_FUNCTION_WITH_NONDETERMINISTIC_EXPRESSION` at planner time.

```sql
-- WRONG — ai_query inside MAX/COLLECT_LIST/ANY_VALUE is rejected
SELECT MAX(ai_query('endpoint', prompt)) FROM ...
```

**Pattern**: build the prompt deterministically inside the aggregate (via `ANY_VALUE`), then call `ai_query` ONCE at the outer level.

```sql
-- RIGHT — ANY_VALUE wraps the deterministic prompt-builder; ai_query runs once outside
CREATE OR REPLACE FUNCTION predict_churn(uid BIGINT)
  RETURNS STRING
  RETURN
    ai_query(
      'databricks-claude-opus-4-6',
      (SELECT ANY_VALUE(CONCAT(
         'Classify churn risk (HIGH/MEDIUM/LOW) for customer: ',
         'lifetime_spend=$', lifetime_spend,
         ', orders=', lifetime_orders,
         ', days_since_last=', days_since_last_order,
         ', recent_30d_events=', recent_event_count_30d
       ))
       FROM churn_features WHERE user_id = uid)
    )
```

> **Endpoint pin:** the `ai_query` examples here use `databricks-claude-opus-4-6` deliberately — Opus 4.7 and 4.8 are READY on the workspace but neither supports `ai_query` BATCH inference (both 4xx `PERMISSION_DENIED` "not supported for batch inference"). Real-time chat works on the newer models; only the batch path `ai_query` uses is gated. Re-probe (`ai_query('databricks-claude-opus-4-X','ok')`) on each new Opus release before bumping the batch endpoint.

The inner SELECT is deterministic from the planner's point of view (the aggregate produces a single string), and `ai_query` is called exactly once per UDF invocation. This combines the §3 fix (aggregate-wrap the correlated subquery) with the §4 fix (ai_query at the outer scope).

---

## 5. UC function parameter visibility — what works, what doesn't

UDF parameters are visible in most SQL contexts but NOT in constant-folding-required positions or in scoped-rewrite positions:

| Position | UDF param OK? | Why |
|----------|---------------|-----|
| `WHERE <col> = <param>` | ✅ Yes | Standard filter — evaluated per row at runtime |
| `WHERE <col> BETWEEN <p1> AND <p2>` | ✅ Yes | Same as above |
| `GROUP BY` / `ORDER BY` | ✅ Yes | Param fixed for the duration of the call |
| Projection (`SELECT <param> AS ...`) | ✅ Yes | Constant within the call |
| JOIN ON clauses | ✅ Yes | Runtime evaluation |
| Window function `PARTITION BY` / `ORDER BY` | ✅ Yes | Param fixed for the call |
| `LIMIT <param>` | ❌ No | Constant-folding required at plan time |
| `OFFSET <param>` | ❌ No | Same as LIMIT |
| `TABLESAMPLE (<param>)` | ❌ No | Same |
| `PIVOT (<agg> FOR col IN (<param>))` | ❌ No | Plan-time IN-list |
| `QUALIFY <... param ...>` | ❌ No | Different reason: scope, not folding |

The trap is that the planner errors look similar ("invalid", "unresolved") but split into two distinct bug families: **foldability** (LIMIT/OFFSET/TABLESAMPLE/PIVOT — SQLSTATE `42K0E`) and **scope** (QUALIFY — SQLSTATE `42703`). The universal cure for both is the §1 subquery + WHERE rewrite.

---

## 6. UDF bodies that correlate-subquery against the table they read from serialize multi-row outer calls

A UC SQL UDF whose body shape is `SELECT <agg-or-ai_query>(...) FROM <table> WHERE <pk> = <udf_param>` works fine on single-row calls but **serializes** when called against a multi-row outer SELECT. Example — `predict_churn(uid)` body:

```sql
CREATE OR REPLACE FUNCTION predict_churn(uid BIGINT) RETURNS STRING
RETURN
  SELECT ai_query('databricks-claude-opus-4-6', ANY_VALUE(CONCAT(...prompt...)))
  FROM dais26_vibe.retail_c360.churn_features
  WHERE user_id = uid
```

Single-row call: `SELECT predict_churn(3312)` completes in ~4s (one ai_query call against the endpoint).

Multi-row outer call: `SELECT predict_churn(user_id) FROM (... LIMIT 10)` hangs >3 minutes and may never complete. A 10-row CTAS with this UDF in the projection list is effectively unusable.

**Mechanism**: the planner can't fan out correlated-subquery inner scans across endpoint concurrency. For each outer row, the planner executes a separate inner `SELECT ... FROM churn_features WHERE user_id = uid` scan, each of which contains a separate `ai_query` call. These don't parallelize the way an inline `ai_query` against the outer SELECT's already-projected columns would. Effective concurrency for the UDF-wrapped path is 1; the same workload with inline `ai_query` parallelizes up to the endpoint's ~15 concurrency slots.

**Two places to handle this**:

1. **Batch scoring**: use INLINE `ai_query()` in the outer SELECT's projection list, with the prompt-builder consuming the outer SELECT's columns directly. No UDF wrapper. Example — the workshop's Phase 8 CTAS:

   ```sql
   CREATE OR REPLACE TABLE churn_predictions AS
   SELECT
     user_id, country, lifetime_spend, lifetime_orders, days_since_last_order,
     churn_risk AS gold_rule_tier,
     ai_query(
       'databricks-claude-opus-4-6',
       CONCAT('Classify... ', CAST(lifetime_spend AS STRING), ...)
     ) AS ai_predicted_tier,
     current_timestamp() AS scored_at
   FROM (
     SELECT * FROM churn_features
     WHERE churn_risk IN ('HIGH','MEDIUM')
     ORDER BY lifetime_spend DESC
     LIMIT 10
   )
   ```

   Wall-clock for 10 rows: ~8 seconds (warehouse parallelizes 10 ai_query calls across endpoint concurrency).

2. **Single-row drill-down**: KEEP the `predict_churn(uid)` UDF for single-row callers (apps, agent peers, ad-hoc queries). The UDF abstraction is worth the per-call overhead when N=1.

**Long-term fix (if you must batch via UDF)**: redesign the UDF to take all required columns as parameters instead of pulling them from a correlated subquery — e.g., `predict_churn_v2(lifetime_spend DECIMAL, lifetime_orders BIGINT, days_since_last_order INT, recent_event_count_30d INT) RETURNS STRING RETURN ai_query(...)`. Pure-scalar inputs eliminate the correlated-subquery serialization. Cost: callers must pass all 4 columns instead of just `user_id`.

**Diagnosis flow when you suspect this is firing**:

1. Single-row call works in ~seconds → multi-row UDF call hangs (no error, no timeout, no rows returned).
2. Run a directly-comparable INLINE `ai_query` (same prompt, same model, multi-row) — if THAT completes in seconds, the UDF wrapper is the bottleneck, not the endpoint.
3. Check the UDF body: any `FROM <table> WHERE <pk> = <udf_param>` correlated pattern is the trigger.

Discovered 2026-05-27 c360 Phase 8 (Issue 16 in `.c360-regen-issues-2026-05-27.md`). The 2026-04-21 replica-doc Phase 8 §Action step 2 already noted this pattern as a fallback option — that fallback is now the canonical workshop path.

---

## When you suspect a UDF authoring bug

1. **Read the SQLSTATE first** — `42K0E` = foldability (rewrite as subquery + WHERE), `42703` = scope (same rewrite), `0A000` = correlated aggregate (wrap with `ANY_VALUE`), `AGGREGATE_FUNCTION_WITH_NONDETERMINISTIC_EXPRESSION` = move `ai_query` outside the aggregate
2. **Test the UDF body as an inline query first** — `SELECT ... FROM (UDF body) WHERE ...` lets you bind the would-be parameter as a literal and confirm the body works before wrapping it in `CREATE FUNCTION`
3. **Mirror the canonical pattern** — [`e2e/demo-retail-c360/scripts/02_create_uc_funcs.py`](../../e2e/demo-retail-c360/scripts/02_create_uc_funcs.py) is the validated TVF reference (top_customers_by_ltv uses `ROW_NUMBER + WHERE _rn <= n`); [`e2e/demo-retail-c360/scripts/03_create_ai_funcs.py`](../../e2e/demo-retail-c360/scripts/03_create_ai_funcs.py) is the validated `ai_query` UDF reference (predict_churn wraps the prompt-builder in `ANY_VALUE`)
4. **For `ai_query` specifically** — load the `databricks-ai-functions` skill for the recommended single-call structure + serving endpoint selection
5. **`databricks experimental aitools tools query --file` is single-statement-per-call** — multi-statement DDL bundled in one file fails with `[PARSE_SYNTAX_ERROR]`. Split into one statement per file, or use multiple `--file` flags (run in parallel, NOT serial — mind ordering for dependent objects)

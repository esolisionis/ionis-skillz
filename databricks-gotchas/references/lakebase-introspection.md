# Lakebase Introspection

## Problem

The Databricks CLI, REST API, and AI Dev Kit MCP can list Lakebase Autoscaling *projects* / *branches* / *endpoints* / *databases* but cannot peek inside a PostgreSQL database — schemas, tables, columns, row counts, etc. are owned by Postgres itself, not the Databricks control plane.

## Solution: Direct PG Connection via SDK (Autoscaling)

Connect directly via the SDK and query PostgreSQL's system catalog:

```python
# Run with: uv run --with psycopg2-binary python <script>
from databricks.sdk import WorkspaceClient
from urllib.parse import quote_plus
import psycopg2

PROJECT = "dais26-retail-lakebase"   # autoscaling project id
BRANCH = "production"
ENDPOINT = "primary"
endpoint_resource = f"projects/{PROJECT}/branches/{BRANCH}/endpoints/{ENDPOINT}"

w = WorkspaceClient()
cred = w.postgres.generate_database_credential(endpoint=endpoint_resource)
ep = w.postgres.get_endpoint(name=endpoint_resource)
if ep.status is None or ep.status.hosts is None or ep.status.hosts.host is None:
    raise RuntimeError(f"endpoint {endpoint_resource} has no resolvable host")
host = ep.status.hosts.host
user = w.current_user.me().user_name

dsn = (
    f"postgresql://{quote_plus(user)}:{quote_plus(cred.token)}"
    f"@{host}:5432/postgres?sslmode=require"
)
conn = psycopg2.connect(dsn)
cur = conn.cursor()
cur.execute("SELECT datname FROM pg_database WHERE datistemplate = false")
for row in cur.fetchall():
    print(row[0])
```

## Notes

- Connect to the `postgres` database (always exists) as the bootstrap entry point.
- The same technique works for any PG introspection (`pg_tables`, `information_schema`, etc.).
- For SDK-level discovery without a PG connection: `w.postgres.list_projects()`, `w.postgres.list_branches(parent=project_resource)`, `w.postgres.list_endpoints(parent=branch_resource)`, `w.postgres.list_databases(parent=branch_resource)`.
- Endpoint host comes from `w.postgres.get_endpoint(name=...).status.hosts.host` — null-guard it; a paused endpoint or one still spinning up after scale-to-zero may not report a host yet.
- Credentials are short-lived (~15 min). Mint a fresh one per long-running session; do not stash for reuse across calls.

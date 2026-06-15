# Databricks Connect Reference

## Overview

Databricks Connect lets you run Spark code locally that executes on a remote Databricks cluster or serverless compute. The local Python process handles driver logic while the cluster runs distributed operations.

## Authentication

### Profile-Based (Recommended)

Configure a Databricks CLI profile:

```bash
databricks auth login --profile dev
```

Then use it in code:

```python
from databricks.connect import DatabricksSession

spark = DatabricksSession.builder.profile("dev").serverless().getOrCreate()
```

### Environment Variables

```bash
export DATABRICKS_HOST="https://<workspace>.cloud.databricks.com"
export DATABRICKS_TOKEN="dapi..."
```

```python
spark = DatabricksSession.builder.serverless().getOrCreate()
```

## Version Compatibility for Serverless

Serverless compute requires specific Databricks Connect versions. Not all versions support `.serverless()` — using an incompatible version raises `SparkConnectGrpcException`.

| Version Range | Serverless Version | Python |
|---|---|---|
| **17.2.x – 17.3.x** | Serverless v4 | 3.12 |
| 16.4.1 – <17.0 | Serverless v3 | 3.12 |
| 15.4.10 – <16.0 | Serverless v2 | 3.11 |

**Important:** Versions 18.0+ and 16.0–16.4.0 do **not** support serverless. The scaffold pins `>=17.2,<18` to stay in the compatible range.

See: https://docs.databricks.com/aws/en/dev-tools/databricks-connect/requirements

## Serverless vs. Cluster

### Serverless (Default in scaffold)

```python
spark = DatabricksSession.builder.profile("dev").serverless().getOrCreate()
```

- No cluster to manage — starts in seconds
- Pay-per-query billing
- Best for development and interactive work
- **Requires `databricks-connect>=17.2,<18`** (see compatibility table above)

### Classic Cluster

```python
spark = (
    DatabricksSession.builder
    .profile("dev")
    .clusterId("<cluster-id>")
    .getOrCreate()
)
```

- Fixed cluster — must be running
- Better for long-running workloads
- Required for certain Spark features not yet on serverless

## Verifying Connectivity

The scaffold includes `src/connect_session.py` which:

1. Connects via the `dev` profile using serverless
2. Prints workspace URL and cluster ID
3. Prints local Python version
4. Queries `samples.nyctaxi.trips` (available in all workspaces)

```bash
uv run python src/connect_session.py
```

Expected output:

```
<workspace>.cloud.databricks.com
<cluster-id>
sys.version_info(major=3, minor=12, ...)
+----+---+---+...
|... |...|...|...
```

## Working with Polars

Convert Spark DataFrames to Polars for local processing:

```python
import polars as pl

# Spark → Pandas → Polars
sdf = spark.table("samples.nyctaxi.trips").limit(10000)
pdf = sdf.toPandas()
df = pl.from_pandas(pdf)

# Or use Spark → Arrow → Polars (zero-copy when possible)
arrow_table = sdf.toPandas()  # Uses Arrow under the hood with spark.conf pyarrow enabled
df = pl.from_arrow(arrow_table)
```

## Common Patterns

### Read Delta Table

```python
df = spark.table("catalog.schema.table")
df = spark.read.format("delta").load("/path/to/table")
```

### Write Delta Table

```python
sdf.write.format("delta").mode("overwrite").saveAsTable("catalog.schema.table")
```

### SQL Queries

```python
result = spark.sql("SELECT * FROM samples.nyctaxi.trips WHERE trip_distance > 10")
result.show(20, False)
```

### Temporary Views

```python
sdf.createOrReplaceTempView("my_view")
spark.sql("SELECT count(*) FROM my_view").show()
```

## Limitations

- **No RDD API** — Databricks Connect only supports DataFrame/SQL operations
- **No SparkContext** — `sc` is not available
- **UDF restrictions** — UDFs must be serializable and may have limitations on serverless
- **File access** — Local file paths don't work; use DBFS, Unity Catalog volumes, or cloud storage

---
name: databricks-icon-lookup
description: Retrieves and looks up relevant Databricks icons from the databricks-icons repository and generates CDN-hosted jsDelivr embed URLs. Use when creating D2 diagrams, slides, presentations, or any content requiring Databricks product icons.
disable-model-invocation: false
---

# Databricks Icon Lookup Agent

This agent specializes in searching, discovering, and providing CDN-hosted embed URLs for Databricks icons from the `robkisk/databricks-icons` repository.

## CDN Base URL

```
https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/
```

## How to Search for Icons

### Step 1: Identify the Icon Category

Icons are organized into several categories:

| Category | Description | Best For |
|----------|-------------|----------|
| **Product Icons (Full Color Container)** | Main product icons with colored backgrounds | Diagrams, slides, presentations |
| **Product Icons (Full Color)** | Main product icons without container | Inline usage, smaller contexts |
| **Primary Icons** | Feature-specific icons (navy/orange/white variants) | Detailed architecture diagrams |
| **UI Icons** | Interface elements (arrows, charts, status indicators) | UI mockups, detailed flows |
| **Blog/ERG Icons** | Internal branding and employee network icons | Internal presentations |

### Step 2: Match User Request to Icon

Use these keyword mappings to find the right icon:

| User Mentions | Icon Name | CDN Path |
|---------------|-----------|----------|
| Unity Catalog, UC, governance, catalog | Unity Catalog | `general-icons/unity-catalog-icon-full-color-container.svg` |
| Databricks SQL, DBSQL, SQL warehouse | Databricks SQL | `general-icons/databricks-sql-icon-full-color-container.svg` |
| Mosaic AI, AI, ML, machine learning | Mosaic AI | `general-icons/mosaic-ai-icon-full-color-container.svg` |
| Lakeflow, orchestration, workflows | Lakeflow | `general-icons/lakeflow-icon-full-color-container.svg` |
| Lakeflow Jobs, jobs, scheduling | Lakeflow Jobs | `general-icons/lakeflow-jobs-icon-full-color-container.svg` |
| Lakeflow Pipelines, DLT, SDP, pipelines | Lakeflow Declarative Pipelines | `general-icons/lakeflow-declarative-pipelines-icon-full-color-container.svg` |
| Lakeflow Connect, ingestion, connectors | Lakeflow Connect | `general-icons/lakeflow-connect-icon-full-color-container.svg` |
| Lakeflow Designer, visual pipelines | Lakeflow Designer | `general-icons/lakeflow-designer-icon-full-color-container.svg` |
| Notebooks, notebook, interactive | Notebooks | `general-icons/notebooks-icon-full-color-container.svg` |
| Delta Sharing, sharing, data sharing | Delta Sharing | `general-icons/delta-sharing-icon-full-color-container.svg` |
| Genie, AI/BI Genie, natural language | AI/BI Genie | `general-icons/ai-bi-genie-icon-full-color-container.svg` |
| Dashboards, AI/BI Dashboards, BI | AI/BI Dashboards | `general-icons/ai-bi-dashboards-icon-full-color-container.svg` |
| Apps, Databricks Apps | Apps | `general-icons/apps-icon-full-color-container.svg` |
| Lakehouse, lakehouse architecture | Lakehouse | `general-icons/lakehouse-icon-full-color-container.svg` |
| Streaming, real-time, data streaming | Data Streaming | `general-icons/data-streaming-icon-full-color-container.svg` |
| Marketplace, partner solutions | Marketplace | `general-icons/marketplace-icon-full-color-container.svg` |
| Photon, query engine, fast queries | Photon | `general-icons/photon-icon-full-color-container.svg` |
| Lakebase, Postgres, PostgreSQL | Lakebase | `general-icons/lakebase-icon-full-color-container.svg` |
| Clean Rooms, data clean rooms | Clean Rooms | `general-icons/clean-rooms-icon-full-color-container.svg` |
| Agent Bricks, agents | Agent Bricks | `general-icons/agent-bricks-icon-full-color-container.svg` |
| Lakebridge, migration | Lakebridge | `general-icons/lakebridge-icon-full-color-container.svg` |
| Databricks One, platform | Databricks One | `general-icons/databricks-one-icon-full-color-container.svg` |
| Databricks logo, main logo, symbol | Databricks Symbol | `databricks-symbol-color.svg` |

### Step 3: Generate Full CDN URL

Combine the base URL with the icon path:

```
https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/{path}
```

**URL Encoding**: Spaces in folder names must be URL-encoded as `%20`:
- `Unity Catalog Icon Full Color` → `Unity%20Catalog%20Icon%20Full%20Color`

## Quick Reference: Most Used Icons

### Product Icons (Container Style - Recommended for Diagrams)

| Product | Full CDN URL |
|---------|--------------|
| Unity Catalog | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/unity-catalog-icon-full-color-container.svg` |
| Databricks SQL | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/databricks-sql-icon-full-color-container.svg` |
| Mosaic AI | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/mosaic-ai-icon-full-color-container.svg` |
| Lakeflow | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakeflow-icon-full-color-container.svg` |
| Lakeflow Jobs | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakeflow-jobs-icon-full-color-container.svg` |
| Lakeflow Pipelines | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakeflow-declarative-pipelines-icon-full-color-container.svg` |
| Lakeflow Connect | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakeflow-connect-icon-full-color-container.svg` |
| Lakeflow Designer | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakeflow-designer-icon-full-color-container.svg` |
| Notebooks | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/notebooks-icon-full-color-container.svg` |
| Delta Sharing | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/delta-sharing-icon-full-color-container.svg` |
| AI/BI Genie | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/ai-bi-genie-icon-full-color-container.svg` |
| AI/BI Dashboards | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/ai-bi-dashboards-icon-full-color-container.svg` |
| AI/BI | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/ai-bi-icon-full-color-container.svg` |
| Apps | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/apps-icon-full-color-container.svg` |
| Lakehouse | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakehouse-icon-full-color-container.svg` |
| Data Streaming | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/data-streaming-icon-full-color-container.svg` |
| Marketplace | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/marketplace-icon-full-color-container.svg` |
| Photon | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/photon-icon-full-color-container.svg` |
| Lakebase | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakebase-icon-full-color-container.svg` |
| Clean Rooms | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/clean-rooms-icon-full-color-container.svg` |
| Agent Bricks | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/agent-bricks-icon-full-color-container.svg` |
| Lakebridge | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/lakebridge-icon-full-color-container.svg` |
| Databricks One | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Databricks%20One%20Icon%20Full%20Color%20Container/databricks-one-icon-full-color-container.svg` |

### Databricks Logos

| Logo | Full CDN URL |
|------|--------------|
| Databricks Symbol (Color) | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/databricks-symbol-color.svg` |
| Databricks Favicon | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/databricks-logos/db-favicon-full-color.png` |

## Searching for Primary Icons

Primary icons are feature-specific icons available in three color variants:
- **Navy** (`primary-icon-navy-{feature}.svg`) - Dark blue, for light backgrounds
- **Orange** (`primary-icon-orange-{feature}.svg`) - Databricks orange accent
- **White** (`primary-icon-white-{feature}.svg`) - For dark backgrounds

### Primary Icon Examples

| Feature | Navy CDN URL |
|---------|--------------|
| Delta Lake | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Delta%20Lake/primary-icon-navy-delta-lake-1.svg` |
| Data Lake | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Data%20Lake/primary-icon-navy-data-lake.svg` |
| Machine Learning | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Machine%20Learning/primary-icon-navy-machine-learning.svg` |
| MLOps | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20MLOps/primary-icon-navy-mlops.svg` |
| Feature Store | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Feature%20Store/primary-icon-navy-feature-store-1.svg` |
| Model Registry | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Model%20Registry/primary-icon-navy-model-registry.svg` |
| Streaming | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Streaming/primary-icon-navy-streaming.svg` |
| Data Pipelines | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Data%20Pipelines/primary-icon-navy-data-pipelines.svg` |
| Data Lineage | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Data%20Lineage/primary-icon-navy-data-lineage.svg` |
| Auto Loader | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Auto%20Loader/primary-icon-navy-auto-loader.svg` |
| Governance | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Governance/primary-icon-navy-governance.svg` |
| Spark Cluster | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Spark%20Cluster/primary-icon-navy-spark-cluster.svg` |
| Data Warehouse | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Data%20Warehouse/primary-icon-navy-data-warehouse-1.svg` |
| Analytics | `https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/Primary%20Icon%20Analytics/primary-icon-navy-analytics.svg` |

## Advanced: Live Search from Repository

When an icon is not in the quick reference, search the repository directly:

```bash
# List all icons matching a keyword
gh api "repos/robkisk/databricks-icons/git/trees/main?recursive=1" \
  --jq '.tree[] | select(.path | test("general-icons/.*\\.svg$")) | .path' \
  | grep -i "{keyword}"
```

Replace `{keyword}` with the search term (e.g., "catalog", "streaming", "ml").

## Usage in D2 Diagrams

```d2
unity_catalog: Unity Catalog {
  icon: https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/unity-catalog-icon-full-color-container.svg
  shape: image
}

sql_warehouse: Databricks SQL {
  icon: https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/databricks-sql-icon-full-color-container.svg
  shape: image
}

unity_catalog -> sql_warehouse: Query
```

## Usage in Markdown/Slides

```markdown
![Unity Catalog](https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/unity-catalog-icon-full-color-container.svg)
```

## Usage in HTML

```html
<img src="https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/general-icons/unity-catalog-icon-full-color-container.svg" alt="Unity Catalog" width="64" height="64">
```

## CDN Versioning

For production stability, pin to a specific version:

```
# Latest (development)
https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@main/...

# Pinned to commit (most stable)
https://cdn.jsdelivr.net/gh/robkisk/databricks-icons@{commit-sha}/...
```

## Tips

1. **Use container icons** for diagrams and presentations - they have consistent sizing
2. **Use shape: image** in D2 to render icons without borders
3. **URL-encode spaces** as `%20` in folder paths
4. **Navy icons** work best on light backgrounds
5. **White icons** work best on dark backgrounds
6. **Orange icons** provide accent/highlight

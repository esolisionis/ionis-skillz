---
name: databricks-python
description: Scaffolds modern Python projects for Databricks development using uv, ruff, ty, and Databricks Connect. Use when the user asks to "create a new python project," "scaffold a databricks project," "start a new python app," "set up a python project," or needs a production-ready Python project structure with Databricks tooling.
disable-model-invocation: false
---

# Databricks Python Project Scaffold

Generate production-ready Python project structures optimized for Databricks development with the Astral.sh toolchain.

## Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Package manager | **uv** | Dependency resolution, virtual environments, script execution |
| Linter + Formatter | **ruff** | Replaces flake8, black, isort in a single tool |
| Type checker | **ty** | Astral.sh type checker (replaces mypy/pyright) |
| Runtime | **Python 3.12** | Target version for all projects |
| Connectivity | **Databricks Connect** | Remote Spark execution via serverless compute |
| DataFrames | **Polars** | High-performance local DataFrame processing |

## Scaffold Workflow

### Step 1: Gather Requirements

Ask the user for:

1. **Project name** (kebab-case, e.g. `my-data-pipeline`)
2. **Brief description** (one sentence)
3. **Target directory** (default: current working directory)

### Step 2: Run the Scaffold Script

Execute the scaffold script with the project name:

```bash
bash ~/.claude/skills/databricks-python/scripts/scaffold-project.sh <project-name>
```

The script creates:

```
<project-name>/
├── pyproject.toml          # Dependencies, ruff, pytest config
├── src/
│   └── connect_session.py  # Databricks Connect starter
├── tests/
│   └── __init__.py
└── .python-version         # Pins Python 3.12
```

### Step 3: Post-Scaffold Setup

After the script completes:

1. **Replace the placeholder description** in `pyproject.toml` with the user's description
2. **Replace `project_name`** in `[tool.ruff.lint.isort] known-first-party` with the actual module name (underscore version of project name)
3. **Initialize the environment**:

```bash
cd <project-name> && uv sync
```

4. **Verify the setup**:

```bash
uv run python src/connect_session.py
```

### Step 4: Validate Tooling

Run the full lint + format + type check pipeline:

```bash
uv run ruff check .
uv run ruff format --check .
uv run ty check
uv run pytest
```

## Template: pyproject.toml

The scaffold uses [this template](assets/templates/pyproject.toml) with these defaults:

### Dependencies (Production)

| Package | Min Version | Purpose |
|---------|-------------|---------|
| `databricks-connect` | `>=17.2,<18` | Serverless Spark connectivity (v18+ does not yet support serverless) |
| `databricks-sdk[notebook]` | `>=0.90.0` | Workspace, jobs, DBFS, notebooks |
| `fastapi` | `>=0.115` | REST API framework |
| `polars` | `>=1.38` | Local DataFrame processing |
| `uvicorn` | `>=0.34` | ASGI server for FastAPI |
| `nbformat` | `>=5.10` | Jupyter notebook manipulation |
| `ipykernel` | `>=7.2` | Jupyter kernel support |
| `psycopg` | `>=3.2` | PostgreSQL async driver |

### Dependencies (Dev)

| Package | Min Version | Purpose |
|---------|-------------|---------|
| `pytest` | `>=9.0` | Test framework |
| `pytest-xdist` | `>=3.8` | Parallel test execution |
| `ruff` | `>=0.15` | Linting + formatting |
| `ty` | `>=0.0.1` | Type checking |

### Ruff Configuration

```toml
[tool.ruff]
target-version = "py312"
line-length = 100

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP", "ARG", "SIM"]
ignore = ["E501"]
```

**Rule sets explained:**

| Code | Plugin | What It Catches |
|------|--------|-----------------|
| `E/W` | pycodestyle | Style violations, whitespace issues |
| `F` | pyflakes | Unused imports, undefined names |
| `I` | isort | Import ordering |
| `B` | flake8-bugbear | Common Python gotchas |
| `C4` | flake8-comprehensions | Unnecessary list/dict/set calls |
| `UP` | pyupgrade | Outdated Python syntax |
| `ARG` | flake8-unused-arguments | Dead function parameters |
| `SIM` | flake8-simplify | Simplifiable expressions |

## Quick Command Reference

### uv

```bash
uv sync                        # Install all dependencies
uv add <pkg>                   # Add a dependency
uv remove <pkg>                # Remove a dependency
uv run <script.py>             # Run with project deps
uv run --with <pkg> <script>   # Run with ephemeral dep
uv run pytest                  # Run tests
uv run ruff check .            # Lint
uv run ruff format .           # Format
uv run ty check                # Type check
uv build                       # Build wheel + sdist
```

### Databricks Connect

```bash
# Verify connectivity
uv run python src/connect_session.py

# Interactive REPL with project deps
uv run python
>>> from databricks.connect import DatabricksSession
>>> spark = DatabricksSession.builder.profile("dev").serverless().getOrCreate()
```

## Databricks Connect Starter

The scaffold includes `src/connect_session.py` — a ready-to-run connectivity check that:

1. Creates a `DatabricksSession` using the `dev` profile with serverless compute
2. Prints the workspace URL and cluster ID
3. Prints the Python version info
4. Queries `samples.nyctaxi.trips` to verify catalog access

This file requires a Databricks CLI profile named `dev` configured via `databricks auth login --profile dev`.

## References

| Topic | File |
|-------|------|
| uv workflows | [uv-workflow.md](reference/uv-workflow.md) |
| Ruff + ty config | [ruff-ty-config.md](reference/ruff-ty-config.md) |
| Databricks Connect | [databricks-connect.md](reference/databricks-connect.md) |

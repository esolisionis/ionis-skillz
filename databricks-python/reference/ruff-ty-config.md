# Ruff + ty Configuration Reference

## Ruff: Linting and Formatting

Ruff replaces flake8, black, isort, pyupgrade, and several flake8 plugins in a single Rust-powered tool.

### Commands

```bash
uv run ruff check .                  # Lint — report violations
uv run ruff check --fix .            # Lint — auto-fix safe violations
uv run ruff format .                 # Format — apply formatting
uv run ruff format --check .         # Format — check without modifying
uv run ruff rule <code>              # Explain a specific rule (e.g. B006)
```

### Configuration Explained

```toml
[tool.ruff]
target-version = "py312"    # Enables Python 3.12 syntax in pyupgrade rules
line-length = 100           # Max line width (black default is 88)

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors — basic style violations
    "W",      # pycodestyle warnings — whitespace, line issues
    "F",      # pyflakes — unused imports, undefined names, dead code
    "I",      # isort — import ordering and grouping
    "B",      # flake8-bugbear — common Python footguns
    "C4",     # flake8-comprehensions — unnecessary list()/dict() wrappers
    "UP",     # pyupgrade — modernize syntax to 3.12 idioms
    "ARG",    # flake8-unused-arguments — dead function parameters
    "SIM",    # flake8-simplify — ternaries, context managers, comparisons
]
ignore = ["E501"]           # Line length handled by formatter, not linter
```

### Why These Rules

| Rule Set | Rationale |
|----------|-----------|
| **E/W** | Baseline Python style — catches obvious formatting issues |
| **F** | Eliminates dead imports and undefined references early |
| **I** | Deterministic import ordering — eliminates merge conflicts in imports |
| **B** | Catches mutable default arguments (B006), abstract methods (B024), etc. |
| **C4** | `list(x for x in y)` → `[x for x in y]` — cleaner comprehensions |
| **UP** | Auto-modernizes `Optional[X]` → `X \| None`, `Dict` → `dict`, etc. |
| **ARG** | Flags unused function args — keeps signatures honest |
| **SIM** | Simplifies `if x == True` → `if x`, nested ifs → compound, etc. |

### Extending Rules

Additional rule sets worth enabling for specific use cases:

```toml
# For projects with docstrings
"D",       # pydocstyle — docstring conventions

# For async code
"ASYNC",   # flake8-async — async anti-patterns

# For security-sensitive code
"S",       # bandit — security vulnerabilities

# For type annotation quality
"ANN",     # flake8-annotations — missing type annotations
"TCH",     # flake8-type-checking — TYPE_CHECKING block imports
```

### Per-File Ignores

```toml
[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = ["ARG"]    # Test fixtures often have unused args
"__init__.py" = ["F401"]     # Re-exports are intentional in __init__
```

---

## ty: Type Checking

ty is Astral.sh's type checker — a fast Rust-based alternative to mypy and pyright.

### Commands

```bash
uv run ty check                      # Type check entire project
uv run ty check src/                 # Type check specific directory
uv run ty check src/module.py        # Type check single file
```

### Configuration

ty is configured in `pyproject.toml`:

```toml
[tool.ty]
python-version = "3.12"

[tool.ty.rules]
# Override specific diagnostics:
# "possibly-unbound-attribute" = "warn"
```

### Common Patterns for Databricks

Databricks Connect and SDK types may not have complete stubs. Suppress specific errors inline:

```python
spark = DatabricksSession.builder.profile("dev").serverless().getOrCreate()  # type: ignore[attr-defined]
```

Or configure ty to treat specific rules as warnings rather than errors in `pyproject.toml`.

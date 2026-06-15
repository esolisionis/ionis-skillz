# uv Workflow Reference

## Project Lifecycle

### Initialize and Sync

```bash
uv sync                              # Install all deps + create venv
uv sync --extra <name>               # Include optional extra group
```

`uv sync` reads `pyproject.toml`, resolves dependencies, creates `.venv/`, and writes `uv.lock`.

### Dependency Management

```bash
uv add <package>                     # Add to [project.dependencies]
uv add --dev <package>               # Add to [dependency-groups] dev
uv add "<package>>=1.0,<2.0"         # Add with version constraint
uv remove <package>                  # Remove dependency
uv lock --upgrade-package <pkg>      # Upgrade a single package
uv lock --upgrade                    # Upgrade all packages
```

### Running Code

```bash
uv run python <script.py>            # Run script with project deps
uv run --with <pkg> <script.py>      # Run with ephemeral dependency
uv run pytest                        # Run pytest
uv run ruff check .                  # Run ruff linter
uv run ty check                      # Run ty type checker
uv run python -m <module>            # Run module
```

`uv run` automatically activates the project's virtual environment. Never use `pip install` or activate venvs manually.

### Building and Publishing

```bash
uv build                             # Build wheel + sdist to dist/
uv publish                           # Publish to PyPI
uv publish --index <url>             # Publish to private index
```

## Dependency Groups (PEP 735)

The template uses `[dependency-groups]` instead of `[project.optional-dependencies]` for dev tools:

```toml
[dependency-groups]
dev = [
    "pytest>=9.0",
    "pytest-xdist>=3.8",
    "ruff>=0.15",
    "ty>=0.0.1",
]
```

Install with: `uv sync` (dev group is included by default).

## Lock File

`uv.lock` is auto-generated and should be committed to version control. It ensures reproducible installs across environments.

## Python Version Pinning

The `.python-version` file pins the project to Python 3.12. uv will automatically download and use this version:

```
3.12
```

If Python 3.12 is not installed, `uv sync` downloads it automatically via the standalone Python builds.

## Converting from pip/poetry

```bash
# From requirements.txt
uv add $(cat requirements.txt | tr '\n' ' ')

# From poetry — uv reads pyproject.toml natively
uv sync
```

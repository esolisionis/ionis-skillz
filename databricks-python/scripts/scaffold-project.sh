#!/bin/bash
# Scaffold a new Python project for Databricks development
# Usage: scaffold-project.sh <project-name>

set -e

PROJECT_NAME="${1:?Usage: scaffold-project.sh <project-name>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../assets"

# Derive module name (kebab to underscore)
PROJECT_MODULE="${PROJECT_NAME//-/_}"

# Validate project name (kebab-case)
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: Project name must be kebab-case (start with letter, lowercase + numbers + hyphens)"
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists"
    exit 1
fi

echo "Scaffolding Databricks Python project: $PROJECT_NAME"

# Create directory structure
mkdir -p "$PROJECT_NAME"/{src,tests}

# Copy template files
cp "$ASSETS_DIR/templates/pyproject.toml" "$PROJECT_NAME/"
cp "$ASSETS_DIR/templates/src/connect_session.py" "$PROJECT_NAME/src/"

# Create empty test init
touch "$PROJECT_NAME/tests/__init__.py"

# Pin Python version
echo "3.12" > "$PROJECT_NAME/.python-version"

# Replace placeholders
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$PROJECT_NAME/pyproject.toml"
    sed -i '' "s/{{PROJECT_MODULE}}/$PROJECT_MODULE/g" "$PROJECT_NAME/pyproject.toml"
    sed -i '' "s/{{PROJECT_DESCRIPTION}}/Databricks Python project/g" "$PROJECT_NAME/pyproject.toml"
else
    sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$PROJECT_NAME/pyproject.toml"
    sed -i "s/{{PROJECT_MODULE}}/$PROJECT_MODULE/g" "$PROJECT_NAME/pyproject.toml"
    sed -i "s/{{PROJECT_DESCRIPTION}}/Databricks Python project/g" "$PROJECT_NAME/pyproject.toml"
fi

echo ""
echo "Project created at: $PROJECT_NAME/"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  uv sync"
echo "  uv run python src/connect_session.py"
echo ""
echo "Tooling:"
echo "  uv run ruff check .          # Lint"
echo "  uv run ruff format .         # Format"
echo "  uv run ty check              # Type check"
echo "  uv run pytest                # Test"

# 80-languages.bashrc - Modern Language Tooling & Workflows
# Comprehensive support for Python, TypeScript, Rust, OCaml, and more

## ============================================================================
## Python - Modern Tooling with uv, ruff, pre-commit
## ============================================================================

# Python environment detection
export PYTHONIOENCODING=utf-8

# uv - Ultra-fast Python package installer (replacement for pip/pip-tools/virtualenv)
if command -v uv &>/dev/null; then
    # uv shortcuts
    alias uvs="uv sync"                    # Sync dependencies
    alias uva="uv add"                     # Add package
    alias uvr="uv remove"                  # Remove package
    alias uvrun="uv run"                   # Run command in venv
    alias uvpy="uv run python"             # Run python in venv

    # Create new project with uv
    uvnew() {
        local project_name="$1"
        if [ -z "$project_name" ]; then
            echo "Usage: uvnew <project-name>"
            return 1
        fi
        uv init "$project_name"
        cd "$project_name"
        uv venv
        uv add ruff pytest pre-commit
        echo "✓ Created $project_name with uv, ruff, pytest, pre-commit"
    }

    # Quick virtual environment activation
    alias uact="source .venv/bin/activate"
fi

# ruff - Fast Python linter & formatter (replacement for flake8, black, isort)
if command -v ruff &>/dev/null; then
    alias rf="ruff check"                  # Check code
    alias rff="ruff check --fix"           # Check and fix
    alias rffmt="ruff format"              # Format code
    alias rfwatch="ruff check --watch"     # Watch mode

    # Check and format in one go
    rfa() {
        ruff check --fix "$@" && ruff format "$@"
    }
fi

# mypy - Type checking
if command -v mypy &>/dev/null; then
    alias mpy="mypy ."
    alias mpystrict="mypy --strict ."
fi

# pytest - Testing
if command -v pytest &>/dev/null; then
    alias pt="pytest"
    alias ptv="pytest -v"
    alias ptw="pytest --watch"             # Requires pytest-watch
    alias ptc="pytest --cov"               # Coverage
    alias ptx="pytest -x"                  # Stop on first failure
    alias ptlf="pytest --lf"               # Run last failed
fi

# pre-commit - Git hooks
if command -v pre-commit &>/dev/null; then
    alias pc="pre-commit run --all-files"
    alias pcu="pre-commit autoupdate"
    alias pci="pre-commit install"

    # Quick setup pre-commit in a project
    pcsetup() {
        if [ ! -f ".pre-commit-config.yaml" ]; then
            cat > .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.11.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
EOF
            pre-commit install
            echo "✓ Created .pre-commit-config.yaml and installed hooks"
        else
            echo "⚠ .pre-commit-config.yaml already exists"
        fi
    }
fi

# Poetry (alternative to uv)
if command -v poetry &>/dev/null; then
    alias po="poetry"
    alias por="poetry run"
    alias poi="poetry install"
    alias poa="poetry add"
    alias posh="poetry shell"
fi

## ============================================================================
## TypeScript / JavaScript - Node, pnpm, bun
## ============================================================================

# Node version manager (nvm is loaded in 99-local.bashrc)

# pnpm - Fast, disk space efficient package manager
if command -v pnpm &>/dev/null; then
    alias pn="pnpm"
    alias pni="pnpm install"
    alias pna="pnpm add"
    alias pnad="pnpm add -D"
    alias pnr="pnpm run"
    alias pnx="pnpm dlx"                   # Run package without installing
    alias pndev="pnpm run dev"
    alias pnbuild="pnpm run build"
    alias pntest="pnpm test"
fi

# bun - Fast JavaScript runtime & package manager
if command -v bun &>/dev/null; then
    alias b="bun"
    alias bi="bun install"
    alias ba="bun add"
    alias bad="bun add -d"
    alias br="bun run"
    alias bdev="bun run dev"
    alias bbuild="bun run build"
    alias btest="bun test"
fi

# TypeScript
if command -v tsc &>/dev/null; then
    alias tsc="tsc --pretty"
    alias tscw="tsc --watch"
fi

# ESLint
if command -v eslint &>/dev/null; then
    alias lint="eslint ."
    alias lintfix="eslint . --fix"
fi

# Prettier
if command -v prettier &>/dev/null; then
    alias fmt="prettier --write ."
    alias fmtcheck="prettier --check ."
fi

## ============================================================================
## Rust - Cargo, Clippy, Rustfmt
## ============================================================================

if command -v cargo &>/dev/null; then
    # Cargo shortcuts
    alias c="cargo"
    alias cb="cargo build"
    alias cbr="cargo build --release"
    alias cr="cargo run"
    alias crr="cargo run --release"
    alias ct="cargo test"
    alias ccheck="cargo check"
    alias cclippy="cargo clippy"
    alias cfmt="cargo fmt"
    alias cdoc="cargo doc --open"
    alias cclean="cargo clean"
    alias cupdate="cargo update"

    # cargo-watch - Auto-rebuild
    if command -v cargo-watch &>/dev/null; then
        alias cw="cargo watch -x check"
        alias cwr="cargo watch -x run"
        alias cwt="cargo watch -x test"
    fi

    # cargo-nextest - Better test runner
    if command -v cargo-nextest &>/dev/null; then
        alias ctn="cargo nextest run"
    fi

    # Quick Rust project setup
    cnew() {
        local project_name="$1"
        if [ -z "$project_name" ]; then
            echo "Usage: cnew <project-name>"
            return 1
        fi
        cargo new "$project_name"
        cd "$project_name"
        echo "✓ Created Rust project: $project_name"
    }

    # Rust all-in-one check: format, clippy, test
    ccheck-all() {
        echo "→ Formatting..."
        cargo fmt || return 1
        echo "→ Running clippy..."
        cargo clippy -- -D warnings || return 1
        echo "→ Running tests..."
        cargo test || return 1
        echo "✓ All checks passed!"
    }
fi

# rustup
if command -v rustup &>/dev/null; then
    alias rsup="rustup update"
    alias rsshow="rustup show"
fi

## ============================================================================
## OCaml - Dune, opam
## ============================================================================

if command -v opam &>/dev/null; then
    # opam shortcuts
    alias oi="opam install"
    alias ou="opam update"
    alias oupgrade="opam upgrade"
    alias os="opam search"
    alias olist="opam list"

    # Initialize opam environment
    if [ -f "$HOME/.opam/opam-init/init.sh" ]; then
        source "$HOME/.opam/opam-init/init.sh" > /dev/null 2>&1 || true
    fi
fi

if command -v dune &>/dev/null; then
    # Dune shortcuts
    alias d="dune"
    alias db="dune build"
    alias dt="dune test"
    alias dw="dune build --watch"
    alias dclean="dune clean"
    alias dexec="dune exec"

    # OCaml project setup
    ocnew() {
        local project_name="$1"
        if [ -z "$project_name" ]; then
            echo "Usage: ocnew <project-name>"
            return 1
        fi
        dune init project "$project_name"
        cd "$project_name"
        echo "✓ Created OCaml project: $project_name"
    }
fi

# utop - Enhanced OCaml REPL
if command -v utop &>/dev/null; then
    alias ocaml="utop"
fi

# ocamlformat
if command -v ocamlformat &>/dev/null; then
    alias ofmt="ocamlformat --inplace"
fi

## ============================================================================
## Web Development - HTML, CSS, Markdown
## ============================================================================

# Markdown linting
if command -v markdownlint &>/dev/null; then
    alias mdlint="markdownlint '**/*.md' --ignore node_modules"
    alias mdfix="markdownlint '**/*.md' --ignore node_modules --fix"
fi

# Markdown preview (if glow is installed)
if command -v glow &>/dev/null; then
    alias mdp="glow"
    alias mdpager="glow -p"
fi

# Serve current directory (for testing static sites)
serve() {
    local port="${1:-8000}"
    if command -v python3 &>/dev/null; then
        echo "Serving at http://localhost:$port"
        python3 -m http.server "$port"
    elif command -v python &>/dev/null; then
        echo "Serving at http://localhost:$port"
        python -m SimpleHTTPServer "$port"
    else
        echo "Error: Python not found"
        return 1
    fi
}

## ============================================================================
## React / Next.js
## ============================================================================

# Create React App (if using)
if command -v npx &>/dev/null; then
    cra() {
        npx create-react-app "$@"
    }

    # Create Next.js app
    next-new() {
        npx create-next-app@latest "$@"
    }

    # Create Vite app (modern alternative)
    vite-new() {
        npm create vite@latest "$@"
    }
fi

## ============================================================================
## Language Version Managers
## ============================================================================

# asdf - Universal version manager
if command -v asdf &>/dev/null; then
    alias av="asdf"
    alias avi="asdf install"
    alias avl="asdf list"
    alias avg="asdf global"
    alias avlocal="asdf local"
    alias avp="asdf plugin"
fi

## ============================================================================
## General Development Utilities
## ============================================================================

# Quick project initialization
devnew() {
    local project_type="$1"
    local project_name="$2"

    case "$project_type" in
        py|python)
            uvnew "$project_name"
            ;;
        rs|rust)
            cnew "$project_name"
            ;;
        oc|ocaml)
            ocnew "$project_name"
            ;;
        ts|typescript)
            if command -v pnpm &>/dev/null; then
                pnpm create vite "$project_name" --template react-ts
            else
                npm create vite@latest "$project_name" -- --template react-ts
            fi
            ;;
        react)
            next-new "$project_name"
            ;;
        *)
            echo "Usage: devnew <type> <name>"
            echo "Types: py, rust, ocaml, ts, react"
            return 1
            ;;
    esac
}

# Run formatters for all files in project
fmt-all() {
    # Python
    if [ -f "pyproject.toml" ] && command -v ruff &>/dev/null; then
        echo "→ Formatting Python..."
        ruff format .
    fi

    # Rust
    if [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
        echo "→ Formatting Rust..."
        cargo fmt
    fi

    # TypeScript/JavaScript
    if [ -f "package.json" ]; then
        if command -v prettier &>/dev/null; then
            echo "→ Formatting JS/TS..."
            prettier --write .
        fi
    fi

    # OCaml
    if [ -f "dune-project" ] && command -v ocamlformat &>/dev/null; then
        echo "→ Formatting OCaml..."
        dune build @fmt --auto-promote
    fi

    echo "✓ Formatting complete"
}

# Run all linters
lint-all() {
    local failed=0

    # Python
    if [ -f "pyproject.toml" ] && command -v ruff &>/dev/null; then
        echo "→ Linting Python..."
        ruff check . || failed=1
    fi

    # Rust
    if [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
        echo "→ Linting Rust..."
        cargo clippy || failed=1
    fi

    # TypeScript/JavaScript
    if [ -f "package.json" ] && command -v eslint &>/dev/null; then
        echo "→ Linting JS/TS..."
        eslint . || failed=1
    fi

    if [ $failed -eq 0 ]; then
        echo "✓ All linters passed"
        return 0
    else
        echo "✗ Some linters failed"
        return 1
    fi
}

# Run all tests
test-all() {
    # Python
    if [ -f "pyproject.toml" ] && command -v pytest &>/dev/null; then
        echo "→ Running Python tests..."
        pytest || return 1
    fi

    # Rust
    if [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
        echo "→ Running Rust tests..."
        cargo test || return 1
    fi

    # TypeScript/JavaScript
    if [ -f "package.json" ]; then
        echo "→ Running JS/TS tests..."
        if command -v pnpm &>/dev/null; then
            pnpm test || return 1
        elif command -v bun &>/dev/null; then
            bun test || return 1
        else
            npm test || return 1
        fi
    fi

    # OCaml
    if [ -f "dune-project" ] && command -v dune &>/dev/null; then
        echo "→ Running OCaml tests..."
        dune test || return 1
    fi

    echo "✓ All tests passed"
}

# Quick CI check (format, lint, test)
ci-check() {
    echo "Running full CI check..."
    fmt-all && lint-all && test-all
    if [ $? -eq 0 ]; then
        echo "✓✓✓ Ready to commit!"
    else
        echo "✗✗✗ Please fix issues before committing"
        return 1
    fi
}

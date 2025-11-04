# 80-languages.fish - Modern Language Tooling & Workflows
# Comprehensive support for Python, TypeScript, Rust, OCaml, and more

## ============================================================================
## Python - Modern Tooling with uv, ruff, pre-commit
## ============================================================================

# Python environment detection
set -x PYTHONIOENCODING utf-8

# uv - Ultra-fast Python package installer
if command -v uv &>/dev/null
    # uv shortcuts
    alias uvs="uv sync"
    alias uva="uv add"
    alias uvr="uv remove"
    alias uvrun="uv run"
    alias uvpy="uv run python"

    # Create new project with uv
    function uvnew
        set -l project_name $argv[1]
        if test -z "$project_name"
            echo "Usage: uvnew <project-name>"
            return 1
        end

        uv init $project_name
        cd $project_name
        uv venv
        uv add ruff pytest pre-commit
        echo "✓ Created $project_name with uv, ruff, pytest, pre-commit"
    end

    # Quick virtual environment activation
    alias uact="source .venv/bin/activate.fish"
end

# ruff - Fast Python linter & formatter
if command -v ruff &>/dev/null
    alias rf="ruff check"
    alias rff="ruff check --fix"
    alias rffmt="ruff format"
    alias rfwatch="ruff check --watch"

    # Check and format in one go
    function rfa
        ruff check --fix $argv; and ruff format $argv
    end
end

# mypy - Type checking
if command -v mypy &>/dev/null
    alias mpy="mypy ."
    alias mpystrict="mypy --strict ."
end

# pytest - Testing
if command -v pytest &>/dev/null
    alias pt="pytest"
    alias ptv="pytest -v"
    alias ptw="pytest --watch"
    alias ptc="pytest --cov"
    alias ptx="pytest -x"
    alias ptlf="pytest --lf"
end

# pre-commit - Git hooks
if command -v pre-commit &>/dev/null
    alias pc="pre-commit run --all-files"
    alias pcu="pre-commit autoupdate"
    alias pci="pre-commit install"

    # Quick setup pre-commit in a project
    function pcsetup
        if not test -f .pre-commit-config.yaml
            echo 'repos:
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
        additional_dependencies: [types-all]' > .pre-commit-config.yaml

            pre-commit install
            echo "✓ Created .pre-commit-config.yaml and installed hooks"
        else
            echo "⚠ .pre-commit-config.yaml already exists"
        end
    end
end

# Poetry (alternative to uv)
if command -v poetry &>/dev/null
    alias po="poetry"
    alias por="poetry run"
    alias poi="poetry install"
    alias poa="poetry add"
    alias posh="poetry shell"
end

## ============================================================================
## TypeScript / JavaScript - Node, pnpm, bun
## ============================================================================

# pnpm - Fast, disk space efficient package manager
if command -v pnpm &>/dev/null
    alias pn="pnpm"
    alias pni="pnpm install"
    alias pna="pnpm add"
    alias pnad="pnpm add -D"
    alias pnr="pnpm run"
    alias pnx="pnpm dlx"
    alias pndev="pnpm run dev"
    alias pnbuild="pnpm run build"
    alias pntest="pnpm test"
end

# bun - Fast JavaScript runtime & package manager
if command -v bun &>/dev/null
    alias b="bun"
    alias bi="bun install"
    alias ba="bun add"
    alias bad="bun add -d"
    alias br="bun run"
    alias bdev="bun run dev"
    alias bbuild="bun run build"
    alias btest="bun test"
end

# TypeScript
if command -v tsc &>/dev/null
    alias tsc="tsc --pretty"
    alias tscw="tsc --watch"
end

# ESLint
if command -v eslint &>/dev/null
    alias lint="eslint ."
    alias lintfix="eslint . --fix"
end

# Prettier
if command -v prettier &>/dev/null
    alias fmt="prettier --write ."
    alias fmtcheck="prettier --check ."
end

## ============================================================================
## Rust - Cargo, Clippy, Rustfmt
## ============================================================================

if command -v cargo &>/dev/null
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
    if command -v cargo-watch &>/dev/null
        alias cw="cargo watch -x check"
        alias cwr="cargo watch -x run"
        alias cwt="cargo watch -x test"
    end

    # cargo-nextest - Better test runner
    if command -v cargo-nextest &>/dev/null
        alias ctn="cargo nextest run"
    end

    # Quick Rust project setup
    function cnew
        set -l project_name $argv[1]
        if test -z "$project_name"
            echo "Usage: cnew <project-name>"
            return 1
        end

        cargo new $project_name
        cd $project_name
        echo "✓ Created Rust project: $project_name"
    end

    # Rust all-in-one check: format, clippy, test
    function ccheck-all
        echo "→ Formatting..."
        cargo fmt; or return 1
        echo "→ Running clippy..."
        cargo clippy -- -D warnings; or return 1
        echo "→ Running tests..."
        cargo test; or return 1
        echo "✓ All checks passed!"
    end
end

# rustup
if command -v rustup &>/dev/null
    alias rsup="rustup update"
    alias rsshow="rustup show"
end

## ============================================================================
## OCaml - Dune, opam
## ============================================================================

if command -v opam &>/dev/null
    # opam shortcuts
    alias oi="opam install"
    alias ou="opam update"
    alias oupgrade="opam upgrade"
    alias os="opam search"
    alias olist="opam list"

    # Initialize opam environment
    if test -f $HOME/.opam/opam-init/init.fish
        source $HOME/.opam/opam-init/init.fish > /dev/null 2>&1; or true
    end
end

if command -v dune &>/dev/null
    # Dune shortcuts
    alias d="dune"
    alias db="dune build"
    alias dt="dune test"
    alias dw="dune build --watch"
    alias dclean="dune clean"
    alias dexec="dune exec"

    # OCaml project setup
    function ocnew
        set -l project_name $argv[1]
        if test -z "$project_name"
            echo "Usage: ocnew <project-name>"
            return 1
        end

        dune init project $project_name
        cd $project_name
        echo "✓ Created OCaml project: $project_name"
    end
end

# utop - Enhanced OCaml REPL
if command -v utop &>/dev/null
    alias ocaml="utop"
end

# ocamlformat
if command -v ocamlformat &>/dev/null
    alias ofmt="ocamlformat --inplace"
end

## ============================================================================
## Web Development - HTML, CSS, Markdown
## ============================================================================

# Markdown linting
if command -v markdownlint &>/dev/null
    alias mdlint="markdownlint '**/*.md' --ignore node_modules"
    alias mdfix="markdownlint '**/*.md' --ignore node_modules --fix"
end

# Markdown preview (if glow is installed)
if command -v glow &>/dev/null
    alias mdp="glow"
    alias mdpager="glow -p"
end

# Serve current directory
function serve
    set -l port $argv[1]
    if test -z "$port"
        set port 8000
    end

    if command -v python3 &>/dev/null
        echo "Serving at http://localhost:$port"
        python3 -m http.server $port
    else if command -v python &>/dev/null
        echo "Serving at http://localhost:$port"
        python -m SimpleHTTPServer $port
    else
        echo "Error: Python not found"
        return 1
    end
end

## ============================================================================
## React / Next.js
## ============================================================================

if command -v npx &>/dev/null
    # Create React App
    function cra
        npx create-react-app $argv
    end

    # Create Next.js app
    function next-new
        npx create-next-app@latest $argv
    end

    # Create Vite app
    function vite-new
        npm create vite@latest $argv
    end
end

## ============================================================================
## Language Version Managers
## ============================================================================

# asdf - Universal version manager
if command -v asdf &>/dev/null
    alias av="asdf"
    alias avi="asdf install"
    alias avl="asdf list"
    alias avg="asdf global"
    alias avlocal="asdf local"
    alias avp="asdf plugin"
end

## ============================================================================
## General Development Utilities
## ============================================================================

# Quick project initialization
function devnew
    set -l project_type $argv[1]
    set -l project_name $argv[2]

    switch $project_type
        case py python
            uvnew $project_name
        case rs rust
            cnew $project_name
        case oc ocaml
            ocnew $project_name
        case ts typescript
            if command -v pnpm &>/dev/null
                pnpm create vite $project_name --template react-ts
            else
                npm create vite@latest $project_name -- --template react-ts
            end
        case react
            next-new $project_name
        case '*'
            echo "Usage: devnew <type> <name>"
            echo "Types: py, rust, ocaml, ts, react"
            return 1
    end
end

# Run formatters for all files in project
function fmt-all
    # Python
    if test -f pyproject.toml; and command -v ruff &>/dev/null
        echo "→ Formatting Python..."
        ruff format .
    end

    # Rust
    if test -f Cargo.toml; and command -v cargo &>/dev/null
        echo "→ Formatting Rust..."
        cargo fmt
    end

    # TypeScript/JavaScript
    if test -f package.json
        if command -v prettier &>/dev/null
            echo "→ Formatting JS/TS..."
            prettier --write .
        end
    end

    # OCaml
    if test -f dune-project; and command -v ocamlformat &>/dev/null
        echo "→ Formatting OCaml..."
        dune build @fmt --auto-promote
    end

    echo "✓ Formatting complete"
end

# Run all linters
function lint-all
    set -l failed 0

    # Python
    if test -f pyproject.toml; and command -v ruff &>/dev/null
        echo "→ Linting Python..."
        ruff check .; or set failed 1
    end

    # Rust
    if test -f Cargo.toml; and command -v cargo &>/dev/null
        echo "→ Linting Rust..."
        cargo clippy; or set failed 1
    end

    # TypeScript/JavaScript
    if test -f package.json; and command -v eslint &>/dev/null
        echo "→ Linting JS/TS..."
        eslint .; or set failed 1
    end

    if test $failed -eq 0
        echo "✓ All linters passed"
        return 0
    else
        echo "✗ Some linters failed"
        return 1
    end
end

# Run all tests
function test-all
    # Python
    if test -f pyproject.toml; and command -v pytest &>/dev/null
        echo "→ Running Python tests..."
        pytest; or return 1
    end

    # Rust
    if test -f Cargo.toml; and command -v cargo &>/dev/null
        echo "→ Running Rust tests..."
        cargo test; or return 1
    end

    # TypeScript/JavaScript
    if test -f package.json
        echo "→ Running JS/TS tests..."
        if command -v pnpm &>/dev/null
            pnpm test; or return 1
        else if command -v bun &>/dev/null
            bun test; or return 1
        else
            npm test; or return 1
        end
    end

    # OCaml
    if test -f dune-project; and command -v dune &>/dev/null
        echo "→ Running OCaml tests..."
        dune test; or return 1
    end

    echo "✓ All tests passed"
end

# Quick CI check (format, lint, test)
function ci-check
    echo "Running full CI check..."
    fmt-all; and lint-all; and test-all
    if test $status -eq 0
        echo "✓✓✓ Ready to commit!"
    else
        echo "✗✗✗ Please fix issues before committing"
        return 1
    end
end

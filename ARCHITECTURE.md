# Dotfiles Architecture

## Overview

This is a next-generation dotfiles setup designed for:
- **Cross-platform support**: Linux, macOS, Windows WSL
- **Modular management**: Using GNU Stow for symlink management
- **AI-first workflows**: Built-in harness for parallelized AI coding sessions
- **Powerful navigation system**: Advanced directory navigation and aliasing
- **Easy adoption**: Interactive installer with sensible defaults

---

## Directory Structure

```
dotfiles/
├── install.sh                    # Interactive installer
├── README.md                     # User-facing documentation
├── ARCHITECTURE.md               # This file
├── AGENT_GUIDE.md               # Guide for using the AI agent harness
├── .gitignore
│
├── bin/                          # Executable scripts (added to PATH)
│   ├── agent                     # Multi-agent session manager
│   ├── worktree-clean            # Cleanup stale worktrees
│   └── context-sync              # Sync context between sessions
│
├── common/                       # Cross-platform configs (GNU Stow modules)
│   ├── bash/
│   │   ├── .bashrc
│   │   └── .bashrc.d/
│   │       ├── 00-init.bashrc           # Initialization
│   │       ├── 10-navigation.bashrc     # Your legendary navigation system
│   │       ├── 20-aliases.bashrc        # Handy aliases
│   │       ├── 30-git.bashrc            # Git shortcuts
│   │       ├── 40-agents.bashrc         # AI agent workflow helpers
│   │       ├── 50-prompt.bashrc         # Prompt configuration
│   │       ├── 60-history.bashrc        # History settings
│   │       ├── 70-aesthetics.bashrc     # Colors and styling
│   │       └── 99-local.bashrc          # Local overrides (sources ~/.bash_profile)
│   │
│   ├── fish/
│   │   └── .config/fish/
│   │       ├── config.fish
│   │       ├── conf.d/
│   │       │   ├── 00-init.fish
│   │       │   ├── 10-navigation.fish
│   │       │   ├── 20-aliases.fish
│   │       │   ├── 30-git.fish
│   │       │   ├── 40-agents.fish
│   │       │   └── 99-local.fish
│   │       └── functions/             # Fish functions
│   │
│   ├── git/
│   │   ├── .gitconfig                 # Main git config
│   │   └── .gitignore_global          # Global gitignore
│   │
│   ├── vim/
│   │   ├── .vimrc
│   │   └── .vimrc.d/                  # Modular vim configs
│   │
│   ├── nvim/
│   │   └── .config/nvim/
│   │       ├── init.lua               # Neovim config (Lua-based)
│   │       └── lua/
│   │           ├── config/
│   │           └── plugins/
│   │
│   ├── tmux/
│   │   └── .tmux.conf
│   │
│   ├── starship/
│   │   └── .config/starship.toml      # Cross-shell prompt
│   │
│   └── agents/                        # AI Agent Harness
│       └── .config/agents/
│           ├── config.yaml            # Agent configuration
│           ├── sessions/              # Active session metadata
│           ├── contexts/              # Shared context files
│           └── templates/             # Session templates
│
├── macos/                            # macOS-specific configs
│   ├── Brewfile                      # Homebrew packages
│   ├── defaults/                     # macOS system defaults scripts
│   │   ├── dock.sh
│   │   ├── finder.sh
│   │   └── system.sh
│   ├── yabai/
│   │   └── .config/yabai/yabairc
│   ├── skhd/
│   │   └── .config/skhd/skhdrc
│   └── zed/
│       └── .config/zed/settings.json
│
├── linux/                            # Linux-specific configs
│   ├── packages-apt.txt              # Debian/Ubuntu packages
│   ├── packages-pacman.txt           # Arch packages
│   ├── packages-dnf.txt              # Fedora packages
│   ├── i3/
│   │   └── .config/i3/config
│   ├── sway/
│   │   └── .config/sway/config
│   └── alacritty/
│       └── .config/alacritty/alacritty.toml
│
├── windows/                          # Windows WSL configs
│   ├── packages-choco.txt            # Chocolatey packages
│   ├── powershell/
│   │   └── Microsoft.PowerShell_profile.ps1
│   └── wsl/
│       └── .wslconfig
│
└── docs/                             # Extended documentation
    ├── INSTALLATION.md
    ├── CUSTOMIZATION.md
    ├── AGENT_WORKFLOWS.md
    ├── MIGRATION.md                  # Migrating from old dotfiles
    └── TROUBLESHOOTING.md
```

---

## Core Components

### 1. Interactive Installer (`install.sh`)

A comprehensive bash script that:
- **Detects OS** (Linux distro, macOS, Windows WSL)
- **Asks user preferences** interactively
- **Installs dependencies** (stow, git, etc.)
- **Offers module selection** (bash, fish, vim, nvim, tmux, etc.)
- **Handles OS-specific configs** (macOS defaults, Linux packages)
- **Sets up the AI agent harness**
- **Creates personal override files** (.bash_profile, .gitprofile, etc.)
- **Validates installation**

### 2. Modular Configuration System

Uses **GNU Stow** for symlink management:
- Each directory under `common/`, `macos/`, `linux/`, `windows/` is a stow "package"
- Running `stow -t ~ bash` from `common/` creates `~/.bashrc` → `dotfiles/common/bash/.bashrc`
- Easy to adopt individual modules without all-or-nothing approach
- Safe to version control (no private data in repo)

### 3. AI Agent Parallelization Harness

**Purpose**: Enable multiple AI coding agents (Claude, Codex, etc.) to work on the same repo in parallel using git worktrees with shared context.

**Architecture**:

```
Main Repo: ~/projects/myproject/
├── .git/
└── (main branch files)

Worktrees (created by harness):
├── ~/projects/myproject-wt-feature-a/    # Claude session 1
├── ~/projects/myproject-wt-bugfix-b/     # Claude session 2
└── ~/projects/myproject-wt-refactor-c/   # Codex session

Shared Context (managed by harness):
~/.config/agents/contexts/myproject/
├── session-feature-a/
│   ├── context.md                 # What this session is working on
│   ├── notes.md                   # Agent's notes/progress
│   ├── shared-tempfiles/          # Files shared across sessions
│   └── .lock                      # Prevent concurrent writes
├── session-bugfix-b/
│   └── ...
└── global/                        # Context shared by ALL sessions
    ├── architecture.md            # Repo architecture notes
    ├── conventions.md             # Code conventions
    └── todos.md                   # Master todo list
```

**CLI Tool: `agent`**

```bash
# Create a new agent session with worktree
agent new feature-auth --branch=feature/auth --template=feature
  ├── Creates git worktree in ~/projects/myproject-wt-feature-auth/
  ├── Creates context dir ~/.config/agents/contexts/myproject/session-feature-auth/
  ├── Opens session in $EDITOR
  └── Prints instructions for launching AI agent

# List active sessions
agent list
  ├── Shows all worktrees and their status
  └── Displays context summaries

# Switch to a session
agent switch feature-auth
  ├── cd into the worktree
  └── Sources session-specific environment

# Share context between sessions
agent share-context feature-auth bugfix-login --file=auth-utils.md
  ├── Copies context from one session to another
  └── Logs the share event

# Sync changes from main
agent sync feature-auth
  ├── Fetches latest from origin
  ├── Rebases/merges into worktree
  └── Updates context

# Clean up completed session
agent close feature-auth --delete-branch
  ├── Removes worktree
  ├── Archives context
  └── Optionally deletes git branch

# View session context
agent context feature-auth
  ├── Shows context.md
  └── Opens in pager or $EDITOR

# Lock/unlock for safe concurrent operations
agent lock feature-auth "Editing shared API spec"
agent unlock feature-auth
```

**Session Templates**:

Templates in `~/.config/agents/templates/` pre-populate context:

```yaml
# feature.yaml
name: Feature Development
files:
  context.md: |
    # Feature: {{FEATURE_NAME}}

    ## Objective
    {{OBJECTIVE}}

    ## Approach
    {{APPROACH}}

    ## Progress
    - [ ] Task 1

  notes.md: |
    # Development Notes

  shared-tempfiles/.gitkeep: ""
```

**Integration with dotfiles**:

Add to `.bashrc.d/40-agents.bashrc`:

```bash
# Quick aliases for agent workflow
alias anew="agent new"
alias asw="agent switch"
alias alist="agent list"
alias async="agent sync"

# Enhanced cd that recognizes session names
acd() {
  if agent list | grep -q "$1"; then
    agent switch "$1"
  else
    cd "$1"
  fi
}

# Show current agent session in prompt
export AGENT_SESSION=$(agent current 2>/dev/null)
```

### 4. Navigation System

**Powerful directory navigation and aliasing**:
- `al`, `fal`, `xal`, `lal` - symlink aliasing system
- `pcd` - smart cd with backoff
- `vcd` - cd into files → vim
- `mkcd`, `up`, `dn`, `bk` - navigation helpers
- `pushloc`, `gotoloc`, `poploc` - location stack
- `xn`, `fk` - expanded navigation
- Cross-shell support (bash + fish versions)
- Integration with agent sessions
- Tab completion support

### 5. Cross-Platform Package Management

**Package Lists**:
- `linux/packages-apt.txt` - Debian/Ubuntu
- `linux/packages-pacman.txt` - Arch
- `linux/packages-dnf.txt` - Fedora
- `macos/Brewfile` - macOS (Homebrew Bundle)
- `windows/packages-choco.txt` - Windows (Chocolatey)

**Installer handles**:
- Detecting package manager
- Installing from appropriate list
- Handling missing packages gracefully
- Optional packages vs. required

---

## Installation Flow

```
┌─────────────────────────────────────┐
│ User runs: ./install.sh             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Detect OS and package manager       │
│ (Linux: apt/pacman/dnf)              │
│ (macOS: brew)                        │
│ (Windows: WSL detection)             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Ask: Install packages? [y/n]        │
│ → If yes: Install stow, git, etc.   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Ask which shells to configure:      │
│ □ Bash                               │
│ □ Fish                               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Ask which modules to install:       │
│ ☑ Git (recommended)                 │
│ ☑ Vim                                │
│ □ Neovim                             │
│ ☑ Tmux                               │
│ □ Starship prompt                    │
│ ☑ AI Agent Harness                  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ For each selected module:           │
│   stow -R -t ~ -d common [module]   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ OS-specific configs:                │
│ • macOS: Brewfile, yabai, skhd      │
│ • Linux: i3/sway, alacritty         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Create personal override files:     │
│ • ~/.bash_profile (if not exists)   │
│ • ~/.gitprofile (with name/email)   │
│ • ~/.config/agents/config.yaml      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Ask: Set default shell? [bash/fish] │
│ → Change shell with chsh            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ ✅ Installation complete!            │
│ → Source ~/.bashrc to activate      │
│ → Run 'agent new' to start          │
└─────────────────────────────────────┘
```

---

## Configuration Philosophy

### Public vs. Private

**In the repo** (public, version-controlled):
- Shell configurations
- Aliases and functions
- Editor settings
- General git config (aliases, defaults)

**Local only** (private, not version-controlled):
- Git user name/email (`~/.gitprofile`)
- SSH keys
- API tokens/credentials
- Machine-specific paths (`~/.bash_profile`)
- Custom aliases (`~/.bash_aliases`)

### Loading Order (Bash Example)

```
1. .bashrc (main file)
   ├── Sources vars.sh (env variables)
   ├── Sources .bashrc.d/*.bashrc (numbered order)
   │   ├── 00-init.bashrc
   │   ├── 10-navigation.bashrc
   │   ├── 20-aliases.bashrc
   │   ├── ...
   │   └── 99-local.bashrc
   └── Sources ~/.bash_profile (user overrides)
```

---

## Agent Harness Implementation Details

### Storage Structure

```
~/.config/agents/
├── config.yaml                    # Global config
│   ├── default_template: feature
│   ├── worktree_prefix: wt-
│   ├── auto_sync: true
│   └── contexts_path: ~/.config/agents/contexts
│
├── sessions/                      # Active session registry
│   ├── myproject-feature-auth.yaml
│   ├── myproject-bugfix-login.yaml
│   └── ...
│
├── contexts/                      # Shared context storage
│   └── myproject/
│       ├── session-feature-auth/
│       │   ├── context.md
│       │   ├── notes.md
│       │   ├── .lock
│       │   └── shared-tempfiles/
│       ├── session-bugfix-login/
│       │   └── ...
│       └── global/
│           ├── architecture.md
│           └── conventions.md
│
└── templates/                     # Session templates
    ├── feature.yaml
    ├── bugfix.yaml
    ├── refactor.yaml
    └── exploration.yaml
```

### Session Metadata (YAML)

```yaml
# ~/.config/agents/sessions/myproject-feature-auth.yaml
name: feature-auth
repo: /home/user/projects/myproject
worktree: /home/user/projects/myproject-wt-feature-auth
branch: feature/auth
created: 2025-11-04T10:30:00Z
last_active: 2025-11-04T14:22:00Z
template: feature
context_dir: ~/.config/agents/contexts/myproject/session-feature-auth
status: active  # active | paused | completed
tags:
  - authentication
  - backend
notes: "Implementing OAuth2 flow"
```

### Locking Mechanism

Simple file-based locks for preventing concurrent edits to shared context:

```bash
# agent lock <session> <reason>
acquire_lock() {
  local session=$1
  local reason=$2
  local lockfile="$CONTEXT_DIR/.lock"

  if [ -f "$lockfile" ]; then
    echo "Session locked by: $(cat $lockfile)"
    return 1
  fi

  echo "$USER @ $(hostname) - $reason - $(date)" > "$lockfile"
}

# agent unlock <session>
release_lock() {
  local session=$1
  local lockfile="$CONTEXT_DIR/.lock"
  rm -f "$lockfile"
}
```

### Context Syncing

`context-sync` script runs periodically (or manually) to:
- Detect changes in shared context files
- Notify other sessions of updates
- Merge non-conflicting changes
- Flag conflicts for manual resolution

---

## Future Enhancements

- **Web UI**: Dashboard for managing agent sessions
- **LLM Integration**: Direct API to provide context to AI agents
- **Metrics**: Track session productivity, commits, etc.
- **Team Mode**: Share context across multiple developers
- **Conflict Resolution**: Smart merging of parallel changes
- **Session Replay**: Reproduce agent workflows
- **Templates Marketplace**: Community-shared session templates

---

## Design Principles

1. **Modularity**: Everything is a stow package
2. **Interactivity**: Installer asks, never assumes
3. **Functionality**: Rich feature set including advanced navigation
4. **Extensibility**: Easy to add new modules/features
5. **Safety**: Backups, validation, dry-run modes
6. **Documentation**: Extensive inline comments and guides
7. **Cross-platform**: Works everywhere developers work
8. **AI-first**: Built for modern AI-assisted workflows

---

This architecture provides a solid foundation for a truly modern, powerful, and future-proof dotfiles system. Let's build it! 🚀

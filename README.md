# Dotfiles

[![License](https://img.shields.io/github/license/rajatscode/dotfiles)](./LICENSE)

---

*These are my dotfiles. There are many like them, but these ones are mine.*

My dotfiles are my best friends. They are my life. I must master them as I must master my life.

Without me, my dotfiles are abandoned. Without my dotfiles, I am unproductive. I must maintain my dotfiles faithfully. I must maintain harder than technical debt that is trying to destroy me. I must build my productivity before tech debt tanks it. I will!

My dotfiles and I know that what counts in development are not the lines we write, the coverage of our tests, nor the lack of linter errors. We know that it is the sanity that counts. We will stay sane!

My dotfiles are human, even as I, because they are my life. Thus, I will learn them as a brother. I will learn their weaknesses, their strength, their parts, their accessories, their directories and their scripts. I will keep my dotfiles clean and useful, even as I am clean and useful. We will become part of each other. We will!

Before root, I swear this creed. My dotfiles and I are the defenders of civilization. We are the masters of technical debt. We are the saviors of my life.

So be it, until victory is GNU's and there is no technical debt, but maintainability!

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rajatscode/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the interactive installer
./install.sh
```

## Features

### 🤖 AI Agent Parallelization Harness

Because every day that passes makes me less convinced I can write code myself.

```bash
# Create a new feature session
agent new auth-feature --branch=feature/oauth

# List all sessions
agent list

# Switch to a session
agent switch auth-feature

# Share context between sessions
agent share-context auth-feature bugfix-login --file=api-spec.md

# Close when done
agent close auth-feature --archive --delete-branch
```

Each session gets:
- Its own git worktree
- Shared context directory
- Lock files to prevent conflicts
- Pre-configured templates (feature, bugfix, refactor, exploration)

### 🧭 Navigation System

I'm gonna be honest with you, this just exists because I kept trying to `cd` files and `vim` dirs.

Directory aliasing and navigation helpers:

```bash
# Symlink-based directory aliasing
al myproject              # Alias current directory
fal myproject             # Jump to aliased directory
lal                       # List all aliases

# Smart cd with backoff
pcd /path/that/might/not/exist  # Goes to deepest valid path

# Location stack
pl                        # Push location
gl                        # Go to last pushed
ol                        # Pop and go

# Create and cd
mkcd new/deep/path        # Creates all parents

# cd into file? Opens vim instead!
vcd ~/project/file.js     # cd to dir, opens file in vim
```

### 🛠️ Aliases & Tools

```bash
# Cross-platform system updates
updoot                    # Updates packages on any OS

# Sudo helper
plz                       # Re-run last command as root

# Network utilities
myip                      # Show public IP
weather NYC               # Check weather
freeport 8080             # Kill process on port

# Git shortcuts
gpom                      # git push origin main
push-please               # git push --force-with-lease
gwip / gunwip             # Quick WIP commits

# And 50+ more...
```

## Installation

The installer will guide you through:

1. **OS Detection** - Automatically detects Linux/macOS/Windows WSL
2. **Backup** - Backs up existing dotfiles
3. **Package Installation** - Installs tools (with permission)
4. **Module Selection** - Choose which configs to install
5. **Personal Setup** - Creates personal override files
6. **Agent Tools** - Sets up multi-agent harness

### What Gets Installed

**Shells** (choose one or more):
- Bash - traditional Unix shell
- Zsh - feature-rich shell with better defaults
- Fish - user-friendly shell with autosuggestions

**Version Control**:
- Git - distributed version control
- Mercurial (hg) - alternative distributed VCS
- Jujutsu (jj) - next-gen VCS with powerful workflows

**Editors**:
- Vim - classic modal editor
- Neovim - modern vim with LSP support
- Zed - fast, collaborative AI-first editor

**Other Tools**:
- Tmux - terminal multiplexer
- Starship - cross-shell prompt
- Agent tools - AI parallelization harness

**OS-Specific**:
- **macOS**: Homebrew packages, yabai/skhd window management
- **Linux**: apt/pacman packages, i3/sway, Alacritty
- **Windows**: WSL-optimized configs

## Using the AI Agent Harness

### Basic Workflow

1. **Create a session**:
   ```bash
   agent new feature-auth --template=feature
   ```

2. **Edit context**:
   ```bash
   agent context feature-auth --edit
   ```

3. **Launch AI agent** in the worktree

4. **Work in parallel** with multiple sessions:
   ```bash
   agent new bugfix-login --template=bugfix
   agent new refactor-api --template=refactor
   ```

5. **Share context**:
   ```bash
   agent share-context feature-auth bugfix-login --file=api-spec.md
   ```

See [docs/AGENT_WORKFLOWS.md](./docs/AGENT_WORKFLOWS.md) for detailed examples.

## Configuration

### Personal Overrides (Not Tracked in Git)

- **`~/.bash_profile`** - Personal bash configuration
- **`~/.gitprofile`** - Git name, email, personal settings
- **`~/.tmux.profile`** - Personal tmux configuration
- **`~/.config/nvim/personal.lua`** - Personal neovim config

### Directory Structure

```
dotfiles/
├── install.sh              # Interactive installer
├── ARCHITECTURE.md         # System design
│
├── bin/                    # Executable tools
│   ├── agent               # Multi-agent manager
│   ├── worktree-clean      # Clean stale worktrees
│   └── context-sync        # Sync context
│
├── common/                 # Cross-platform configs
│   ├── bash/               # Bash (modular .bashrc.d/)
│   ├── git/                # Git configuration
│   ├── vim/                # Vim configuration
│   ├── nvim/               # Neovim (Lua-based)
│   ├── tmux/               # Tmux configuration
│   └── agents/             # Agent templates
│
├── macos/                  # macOS-specific
│   ├── Brewfile            # Homebrew packages
│   └── ...
│
└── linux/                  # Linux-specific
    ├── packages-*.txt      # Package lists
    └── ...
```

## Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System design and architecture
- **[docs/AGENT_WORKFLOWS.md](./docs/AGENT_WORKFLOWS.md)** - AI agent workflow examples
- **[docs/CUSTOMIZATION.md](./docs/CUSTOMIZATION.md)** - Customization guide

## Advanced Features

### Git Worktree Integration

```bash
# Manual worktree management
git worktree add ../myproject-feature feature/new-thing

# Or use agent tool (recommended)
agent new new-feature --branch=feature/new-thing

# Clean up stale worktrees
worktree-clean
```

### Context Syncing

```bash
# Sync once
context-sync --once

# Watch and sync continuously
context-sync --watch

# Check status
context-sync --status
```

## Updating

Since configs are symlinked via stow, updating is simple:

```bash
# Update dotfiles from git
dotfiles-update

# Or manually
cd ~/dotfiles
git pull
```

Changes take effect immediately for new shell sessions (existing sessions need `source ~/.bashrc`).

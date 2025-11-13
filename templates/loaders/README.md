# Dotfiles Loader Templates

This directory contains loader templates that implement the **inverted customization pattern** for dotfiles.

## The Problem

Traditional dotfiles setups symlink config files from the repo to your home directory:
```
~/.bashrc → ~/dotfiles/common/bash/.bashrc
~/.vimrc → ~/dotfiles/common/vim/.vimrc
```

This breaks when external tools (like `pnpm install`, `nvm`, `rvm`, etc.) try to modify your configs:
- They modify the files in your git repo
- This creates unwanted changes in git
- Or worse, they try to replace symlinks and break your setup

## The Solution: Inverted Pattern

Instead of symlinking, we use **loader files** that source the dotfiles:

```bash
# Your actual ~/.bashrc (not a symlink)
source ~/.dotfiles/common/bash/.bashrc
# Your local customizations go here
```

Now:
- ✅ External tools can modify `~/.bashrc` without breaking dotfiles
- ✅ Your dotfiles remain clean and version-controlled
- ✅ Local customizations are easy and obvious
- ✅ Updates to dotfiles don't conflict with local changes

## Loader Files

Each loader template follows this pattern:

1. **Find dotfiles directory** - Auto-detect standard locations
2. **Source dotfiles config** - Load the versioned configuration
3. **Local customizations** - Space for user additions

## Installation

The install script will:

1. Copy loaders to your home directory (NOT symlink)
2. Backup any existing configs
3. Allow you to add customizations after the source line

## Supported Configs

- **Bash**: `~/.bashrc` → sources `dotfiles/common/bash/.bashrc`
- **Zsh**: `~/.zshrc` → sources `dotfiles/common/zsh/.zshrc`
- **Fish**: `~/.config/fish/config.fish` → sources `dotfiles/common/fish/.config/fish/config.fish`
- **Vim**: `~/.vimrc` → sources `dotfiles/common/vim/.vimrc`
- **Git**: `~/.gitconfig` → includes `dotfiles/common/git/.gitconfig`
- **Tmux**: `~/.tmux.conf` → sources `dotfiles/common/tmux/.tmux.conf`
- **Neovim**: `~/.config/nvim/init.lua` → dofile `dotfiles/common/nvim/.config/nvim/init.lua`

## Example: Bash Loader

```bash
# ~/.bashrc - User bash configuration

# Source dotfiles
if [ -z "${DOTFILES_DIR}" ]; then
    export DOTFILES_DIR="$HOME/.dotfiles"
fi

if [ -f "$DOTFILES_DIR/common/bash/.bashrc" ]; then
    source "$DOTFILES_DIR/common/bash/.bashrc"
fi

# Local customizations below
export MY_VAR="value"
alias myalias="cd ~/projects"
```

## Architecture: Decoupled Installation

The loader pattern maintains decoupling between your git repo and live configs:

```
~/dotfiles/              ← Your git repo (work here, experiment freely)
    ↓ install.sh
~/.dotfiles/            ← Installed copy (stable, sourced by your configs)
    ↓ sourced by
~/.bashrc, ~/.vimrc     ← Your actual configs (modified by external tools)
```

**Key Points:**
- Work on `~/dotfiles` without affecting your shell
- Run `dotfiles-update` when ready to sync changes to `~/.dotfiles`
- External tools (npm, pnpm) can modify your configs safely
- Best of both worlds: decoupling + resilience

## Migration from Symlink-based Setup

If you're migrating from an old symlink-based setup:

1. Backup any local customizations
2. Run the installer: `./install.sh`

The installer will automatically detect and remove old symlinks, backup existing configs, and install the loader-based pattern.

## Benefits

1. **Resilient**: External tools can't break your dotfiles
2. **Clean**: Git repo stays pristine
3. **Flexible**: Easy to add local overrides
4. **Simple**: One-liner sourcing, easy to understand
5. **Compatible**: Works with all existing dotfiles

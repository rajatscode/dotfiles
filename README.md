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

From repo root, run `./tutorial.sh` for a tour.

## Configuration

### How It Works: Loader Pattern

This dotfiles setup uses a **loader pattern** instead of symlinking:

- Your actual config files (`~/.bashrc`, `~/.vimrc`, etc.) source the dotfiles
- External tools can safely modify your configs without breaking the dotfiles
- Local customizations go directly in your config files, after the source line

Example (`~/.bashrc`):
```bash
# Source dotfiles
source ~/.dotfiles/common/bash/.bashrc

# Your local customizations below
export MY_VAR="value"
alias myalias="cd ~/projects"
```

### Personal Overrides (Not Tracked in Git)

- **`~/.gitprofile`** - Git name, email, personal settings
- **Local customizations** - Added directly to config files (see above)

## Updating

Updating is simple since dotfiles are sourced, not symlinked:

```bash
# Update dotfiles from git
cd ~/dotfiles
git pull

# Or use the update command if available
dotfiles-update
```

Changes take effect immediately for new shell sessions.

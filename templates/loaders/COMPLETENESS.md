# Dotfiles Loader Completeness

## Overview Capabilities

All supported dotfiles are customizable with the loader pattern:

| Config | Loader Method | Override Support | Notes |
|--------|---------------|------------------|-------|
| **bash** | ✅ Source | ✅ Yes | Local configs come after dotfiles source |
| **zsh** | ✅ Source | ✅ Yes | Local configs come after dotfiles source |
| **fish** | ✅ Source | ✅ Yes | Local configs come after dotfiles source |
| **vim** | ✅ Source | ✅ Yes | Local configs come after dotfiles source |
| **nvim** | ✅ Dofile (Lua) | ✅ Yes | Local configs come after dotfiles source |
| **git** | ✅ Include | ✅ Yes | Git merges includes; later settings override |
| **tmux** | ✅ Source | ✅ Yes | Local configs come after dotfiles source |
| **hg** | ✅ %include | ✅ Yes | Mercurial supports %include directive |
| **starship** | ⚠️ Copy | ⚠️ Manual | TOML has no include; copy and edit directly |
| **jj** | ⚠️ Copy | ⚠️ Manual | TOML has no include; copy and edit directly |
| **zed** | ⚠️ Copy | ⚠️ Manual | JSON has no include; copy and edit directly |

## Override Mechanism

For configs that use source/include:

```
1. Dotfiles config loaded FIRST
   ↓
2. Local customizations loaded AFTER
   ↓
3. Later settings override earlier ones
```

This works automatically in all shells and editors.

### Example: Bash

```bash
# ~/.bashrc
source ~/.dotfiles/common/bash/.bashrc  # ← Dotfiles first

# Your overrides
export EDITOR="nano"     # ← Overrides dotfiles EDITOR
alias ls="ls -lah"       # ← Overrides dotfiles ls alias
```

### Example: Git

```gitconfig
# ~/.gitconfig
[include]
    path = ~/.dotfiles/common/git/.gitconfig  # ← Dotfiles first

# Your overrides
[user]
    name = Your Name      # ← Overrides/adds user config
[alias]
    st = status --short   # ← Overrides dotfiles st alias
```

### Example: Vim

```vim
" ~/.vimrc
source ~/.dotfiles/common/vim/.vimrc  " ← Dotfiles first

" Your overrides
set number relativenumber  " ← Overrides dotfiles settings
nnoremap <leader>p :echo "Local"<CR>  " ← Overrides dotfiles mappings
```

## Special Cases

### Starship, Jujutsu, Zed (Copy-Based)

These configs don't support file inclusion, so they are copied:

1. **Initial install**: Template is copied to home directory
2. **Customization**: Edit the copied file directly
3. **Updates**: Run `dotfiles-update` and manually merge changes

To update these manually:
```bash
# After dotfiles-update, compare and merge:
diff ~/.config/starship.toml ~/.dotfiles/common/starship/.config/starship.toml
diff ~/.config/jj/config.toml ~/.dotfiles/common/jj/.jjconfig.toml
diff ~/.config/zed/settings.json ~/.dotfiles/templates/loaders/settings.json
```

## Verification

To verify override capability, add a test setting in your local config:

**Bash:**
```bash
# In ~/.bashrc after the source line:
alias test-override="echo 'Local config works!'"
```

Then open a new shell and run:
```bash
test-override
# Should output: Local config works!
```

**Vim:**
```vim
" In ~/.vimrc after the source line:
nnoremap <leader>t :echo "Local vim config works!"<CR>
```

Open vim and press `<leader>t` - should show the message.

## Summary

✅ **11/11 configs are customizable**
- 7 use true source/include (full override support)
- 1 uses %include (mercurial)
- 3 use copy (manual merge required)

All configs support local customizations without breaking the dotfiles pattern.

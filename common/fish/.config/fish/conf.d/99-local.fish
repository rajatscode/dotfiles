# 99-local.fish - Local overrides and machine-specific configs
# This file sources user's personal profile and provides extension points

## ============================================================================
## Personal Profile
## ============================================================================

# Source personal fish config if it exists
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

## ============================================================================
## Local Bin Directories
## ============================================================================

# Add local bin directories to PATH if they exist
for bindir in $HOME/.local/bin $HOME/bin
    if test -d $bindir; and not contains $bindir $PATH
        set -gx PATH $bindir $PATH
    end
end

## ============================================================================
## Development Environment Managers (Optional)
## ============================================================================

# Node Version Manager (nvm) - Fish has its own nvm wrapper
# Install with: fisher install jorgebucaran/nvm.fish

# Python Virtual Environment (pyenv)
if command -v pyenv &>/dev/null
    status is-login; and pyenv init --path | source
    pyenv init - | source
end

# Rust (cargo)
if test -f $HOME/.cargo/env
    source $HOME/.cargo/env
end

## ============================================================================
## Platform-Specific Configs
## ============================================================================

# macOS-specific
if test "$OS_TYPE" = "macos"
    # Homebrew
    if test -f /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    end
end

# WSL-specific
if set -q WSL_DISTRO_NAME
    # WSL-specific configs can go here
end

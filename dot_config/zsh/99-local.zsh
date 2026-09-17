# 99-local.zsh - Local overrides and machine-specific configs
# This file sources user's personal profile and provides extension points

## ============================================================================
## Personal Profile
## ============================================================================

# Source personal zsh profile if it exists
# This is where users should put machine-specific configs
if [ -f ~/.zprofile ]; then
    source ~/.zprofile
fi

## ============================================================================
## SSH Agent (Optional)
## ============================================================================

# Auto-start SSH agent if not running (optional, enable in ~/.zprofile)
if [ "${AUTO_START_SSH_AGENT:-false}" = "true" ]; then
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" &>/dev/null
    fi
fi

## ============================================================================
## Local Bin Directories
## ============================================================================

# Add local bin directories to PATH if they exist
for bindir in "$HOME/.local/bin" "$HOME/bin"; do
    if [ -d "$bindir" ] && [[ ":$PATH:" != *":$bindir:"* ]]; then
        export PATH="$bindir:$PATH"
    fi
done

## ============================================================================
## Development Environment Managers (Optional)
## ============================================================================

# Node Version Manager (nvm)
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Ruby Version Manager (rvm)
if [ -d "$HOME/.rvm" ]; then
    export PATH="$PATH:$HOME/.rvm/bin"
    [ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"
fi

# Python Virtual Environment (pyenv)
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi

# Rust (cargo)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

## ============================================================================
## Platform-Specific Configs
## ============================================================================

# macOS-specific
if [ "$OS_TYPE" = "macos" ]; then
    # Homebrew
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# WSL-specific
if [ -n "$WSL_DISTRO_NAME" ]; then
    # WSL-specific configs can go here
    :
fi

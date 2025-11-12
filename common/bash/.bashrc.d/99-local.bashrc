# 99-local.bashrc - Local overrides and machine-specific configs
# This file provides extension points for development environment managers

## ============================================================================
## Personal Profile
## ============================================================================

# Personal configs should be added to your ~/.bashrc file after the line
# that sources the dotfiles. The ~/.bash_profile file is no longer used by default.
# If you have an existing ~/.bash_profile, you can source it here for backward compatibility.
if [ -f ~/.bash_profile ]; then
    # Uncomment the next line if you want to preserve backward compatibility
    # source ~/.bash_profile
    :
fi

## ============================================================================
## SSH Agent (Optional)
## ============================================================================

# Auto-start SSH agent if not running (optional, enable in ~/.bash_profile)
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
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
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

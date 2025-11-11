# 99-local.fish - Local overrides and machine-specific configs
# This file provides extension points for development environment managers

## ============================================================================
## Personal Profile
## ============================================================================

# Set personal profile paths (for bash compatibility)
set -gx VIM_PERSONAL_PROFILE "$HOME/.vim_profile"
set -gx GIT_PERSONAL_PROFILE "$HOME/.gitprofile"
set -gx TMUX_PERSONAL_PROFILE "$HOME/.tmux.profile"

# NOTE: With the new loader pattern, personal configs should be added to
# your ~/.config/fish/config.fish file after the line that sources the dotfiles.
# The ~/.config/fish/personal.fish file is no longer used by default.
# If you have an existing personal.fish, you can source it here for backward compatibility.
# Uncomment the next lines if you want to preserve backward compatibility:
# if test -f ~/.config/fish/personal.fish
#     source ~/.config/fish/personal.fish
# else if test -f ~/.config/fish/local.fish
#     source ~/.config/fish/local.fish
# end

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
if test -d $HOME/.cargo/bin; and not contains $HOME/.cargo/bin $PATH
    set -gx PATH $HOME/.cargo/bin $PATH
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

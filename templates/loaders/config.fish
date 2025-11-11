# ~/.config/fish/config.fish - User fish configuration
#
# This file sources the dotfiles fish configuration and allows for local customization.
# The dotfiles are managed separately and can be updated without affecting your local changes.

# ============================================================================
# Source Dotfiles Configuration
# ============================================================================

# Determine dotfiles directory
if not set -q DOTFILES_HOME_DIR
    # Try standard locations
    for dotfiles_candidate in "$HOME/.dotfiles" "$HOME/dotfiles" "$HOME/.config/dotfiles"
        if test -f "$dotfiles_candidate/common/fish/.config/fish/config.fish"
            set -gx DOTFILES_HOME_DIR $dotfiles_candidate
            break
        end
    end

    # If still not found, warn user
    if not set -q DOTFILES_HOME_DIR
        echo "Warning: Dotfiles not found. Please set DOTFILES_HOME_DIR environment variable."
        echo "Expected location: ~/.dotfiles/common/fish/.config/fish/config.fish"
        return
    end
end

# Source the main dotfiles fish configuration
if test -f "$DOTFILES_HOME_DIR/common/fish/.config/fish/config.fish"
    source "$DOTFILES_HOME_DIR/common/fish/.config/fish/config.fish"
else
    echo "Warning: Dotfiles config.fish not found at $DOTFILES_HOME_DIR/common/fish/.config/fish/config.fish"
end

# ============================================================================
# Local Customizations
# ============================================================================

# Add your local customizations below this line
# This section will not be modified by dotfiles updates

# Example: Local aliases
# alias myproject="cd ~/projects/myproject"

# Example: Local environment variables
# set -gx MY_CUSTOM_VAR "value"

# Example: Local PATH additions
# set -gx PATH $HOME/my-local-bin $PATH

# Source additional local configs if they exist
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

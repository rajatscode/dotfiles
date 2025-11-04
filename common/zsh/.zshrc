# ~/.zshrc
# Cross-platform, modular, AI-first zsh configuration
#
# For personal customizations, use ~/.zsh_profile (auto-sourced at the end)

# If not running interactively, do nothing
[[ $- != *i* ]] && return

# ============================================================================
# Core Setup
# ============================================================================

# Determine dotfiles directory
if [[ -z "${DOTFILES_HOME_DIR}" ]]; then
    if [[ -f "${HOME}/.config/dotfiles/.zshrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/.config/dotfiles"
    elif [[ -f "${HOME}/.dotfiles/.zshrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/.dotfiles"
    elif [[ -f "${HOME}/dotfiles/.zshrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/dotfiles"
    else
        export DOTFILES_HOME_DIR="${HOME}/.configs/dotfiles"
    fi
fi

export ZSHRC_HOME_DIR="$DOTFILES_HOME_DIR/common/zsh"

# Environment variables
export ZSHRC_STORED_VARS="${HOME}/.zsh_stored_vars"
export ZSH_PERSONAL_PROFILE="${HOME}/.zsh_profile"
export GIT_PERSONAL_PROFILE="${HOME}/.gitprofile"
export ALIAS_SYMLINK_DIR="${HOME}/.aliased_symlinks"

# Add bin directory to PATH (for agent tools)
if [[ -d "$DOTFILES_HOME_DIR/bin" ]]; then
    export PATH="$DOTFILES_HOME_DIR/bin:$PATH"
fi

# Create stored vars file if it doesn't exist, and source it
mkdir -p $(dirname -- "$ZSHRC_STORED_VARS")
touch "$ZSHRC_STORED_VARS"

alias read_dotfile_vars="source $ZSHRC_STORED_VARS"
read_dotfile_vars

# Create symlink directory if it doesn't exist
mkdir -p "$ALIAS_SYMLINK_DIR"

# ============================================================================
# Persistent Variable Management
# ============================================================================

# Method for removing a variable from the stored vars file
delete_dotfile_var() {
    local VARNAME=$1
    sed -i "/typeset.*"$VARNAME"=.*/d" "$ZSHRC_STORED_VARS"
}

# Method for storing a variable (with its _current_ value) in stored vars file
store_dotfile_var() {
    local VARNAME=$1
    # to avoid cluttering the stored vars file, delete existing declarations
    delete_dotfile_var "$VARNAME"
    # then append the new declaration to the end of the file
    typeset -p $VARNAME >> "$ZSHRC_STORED_VARS"
}

# ============================================================================
# Import Modular Configurations
# ============================================================================

# Load all .zsh files from .config/zsh/ directory in numbered order
# Numbering scheme:
#   00-09: Initialization and core setup
#   10-19: Navigation and file operations
#   20-29: Aliases and shortcuts
#   30-39: Git and version control
#   40-49: AI/Agent workflow tools
#   50-59: Prompt and aesthetics
#   60-69: History and convenience
#   70-79: OS-specific tweaks
#   80-89: Development tools
#   90-99: Local overrides

if [[ -d "$ZSHRC_HOME_DIR/.config/zsh" ]]; then
    for zsh_file in $(ls "$ZSHRC_HOME_DIR/.config/zsh/"*.zsh 2>/dev/null | sort); do
        source "${zsh_file}"
    done
fi

# ============================================================================
# Personal Profile (User Customizations)
# ============================================================================

# Respect user configs in $ZSH_PERSONAL_PROFILE
[ -f "$ZSH_PERSONAL_PROFILE" ] && source "$ZSH_PERSONAL_PROFILE"

# ============================================================================
# Git Personal Config
# ============================================================================

# Include $GIT_PERSONAL_PROFILE here since .gitconfig doesn't support env vars
if [ -f "$GIT_PERSONAL_PROFILE" ]; then
    git config --global include.path "$GIT_PERSONAL_PROFILE"
fi

# ============================================================================
# Welcome Message (Optional)
# ============================================================================

if [ -n "${DOTFILES_SHOW_WELCOME:-}" ]; then
    echo -e "\033[0;36mDotfiles loaded successfully!\033[0m"
    if command -v agent &>/dev/null; then
        echo -e "\033[0;32m✓ Agent tools available\033[0m"
        if [ -n "${AGENT_SESSION:-}" ]; then
            echo -e "\033[1;35m► Active session: $AGENT_SESSION\033[0m"
        fi
    fi
fi

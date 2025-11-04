# ~/.bashrc
# Cross-platform, modular, AI-first bash configuration
#
# For personal customizations, use ~/.bash_profile (auto-sourced at the end)
# For additional aliases, use ~/.bash_aliases (auto-sourced)

# If not running interactively, do nothing
case $- in
    *i*) ;;
    *) return ;;
esac

# ============================================================================
# Core Setup
# ============================================================================

# Determine dotfiles directory
if [[ -z "${DOTFILES_HOME_DIR}" ]]; then
    # Try to find dotfiles directory
    if [[ -f "${HOME}/.config/dotfiles/.bashrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/.config/dotfiles"
    elif [[ -f "${HOME}/.dotfiles/.bashrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/.dotfiles"
    elif [[ -f "${HOME}/dotfiles/.bashrc" ]]; then
        export DOTFILES_HOME_DIR="${HOME}/dotfiles"
    else
        # Fallback to default
        export DOTFILES_HOME_DIR="${HOME}/.configs/dotfiles"
    fi
fi

export BASHRC_HOME_DIR="$DOTFILES_HOME_DIR/common/bash"

# Environment variables (for backward compatibility and new features)
export BASHRC_STORED_VARS="${HOME}/.bash_stored_vars"
export BASH_PERSONAL_PROFILE="${HOME}/.bash_profile"
export GIT_PERSONAL_PROFILE="${HOME}/.gitprofile"
export TMUX_PERSONAL_PROFILE="${HOME}/.tmux.profile"
export VIM_PERSONAL_PROFILE="${HOME}/.vim_profile"
export ALIAS_SYMLINK_DIR="${HOME}/.aliased_symlinks"

# Add bin directory to PATH (for agent tools)
if [[ -d "$DOTFILES_HOME_DIR/bin" ]]; then
    export PATH="$DOTFILES_HOME_DIR/bin:$PATH"
fi

# Create stored vars file if it doesn't exist, and source it
mkdir -p $(dirname -- "$BASHRC_STORED_VARS")
touch "$BASHRC_STORED_VARS"

alias read_dotfile_vars="source $BASHRC_STORED_VARS "
read_dotfile_vars

# Create symlink directory if it doesn't exist
mkdir -p "$ALIAS_SYMLINK_DIR"

# ============================================================================
# Persistent Variable Management
# ============================================================================

# Method for removing a variable from the stored vars file
delete_dotfile_var() {
    local VARNAME=$1
    sed -i "/declare.*"$VARNAME"=.*/d" "$BASHRC_STORED_VARS"
}

# Method for storing a variable (with its _current_ value) in stored vars file
store_dotfile_var() {
    local VARNAME=$1
    # to avoid cluttering the stored vars file, delete existing declarations
    delete_dotfile_var "$VARNAME"
    # then append the new declaration to the end of the file
    eval "declare -p $VARNAME" | cut -d ' ' -f 3- >> "$BASHRC_STORED_VARS"
}

# ============================================================================
# Dotfiles Auto-Sync (Optional)
# ============================================================================

# Keep dotfiles in sync (if enabled)
sync_and_adopt_dotfiles() {
    local SCRIPT_LOC="$BASHRC_HOME_DIR/../../sync.sh"
    if [ -e "$SCRIPT_LOC" ]; then
        chmod +x "$SCRIPT_LOC"
        bash "$SCRIPT_LOC"
    fi
}

ensure_dotfile_syncing() {
    local SYNC_PERIOD_IN_HOURS=$1
    local SYNC_CUTOFF=$(date -d 'now - '$SYNC_PERIOD_IN_HOURS' hours' +%s 2>/dev/null || \
                        date -v-${SYNC_PERIOD_IN_HOURS}H +%s 2>/dev/null)

    if [ -z "$LAST_DOTFILE_SYNC" ] || [ "$SYNC_CUTOFF" -ge "$LAST_DOTFILE_SYNC" ]; then
        LAST_DOTFILE_SYNC=$(date +%s)
        # check for internet connection first so syncing doesn't hang
        wget -q --spider 1.1.1.1 2>/dev/null &&
            sync_and_adopt_dotfiles &&
            store_dotfile_var LAST_DOTFILE_SYNC &&
            # source afterwards to avoid need for restarting shell
            source ~/.bashrc
    fi
}

# ============================================================================
# Import Modular Configurations
# ============================================================================

# Load all .bashrc files from .bashrc.d directory in numbered order
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

if [[ -d "$BASHRC_HOME_DIR/.bashrc.d" ]]; then
    for bashrc_file in $(ls "$BASHRC_HOME_DIR/.bashrc.d/"*.bashrc 2>/dev/null | sort); do
        source "${bashrc_file}"
    done
fi

# ============================================================================
# Personal Profile (User Customizations)
# ============================================================================

# Respect user configs in $BASH_PERSONAL_PROFILE
[ -f "$BASH_PERSONAL_PROFILE" ] && source "$BASH_PERSONAL_PROFILE"

# ============================================================================
# Auto-Sync (Run Last)
# ============================================================================

# Don't sync more than once a day, to avoid spawning a bunch of child shells
# Do this after loading $BASH_PERSONAL_PROFILE so DOTFILES_AUTOSYNC can be set
# in that file
if [ "$DOTFILES_AUTOSYNC" = true ]; then
    ensure_dotfile_syncing ${DOTFILES_AUTOSYNC_PERIOD_IN_HOURS:-24}
fi

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

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
if [[ -z "${DOTFILES_DIR}" ]]; then
    # Try to find dotfiles directory
    # First, check if this bashrc is symlinked and get the source directory
    if [[ -L "${HOME}/.bashrc" ]]; then
        # Get the real path of the symlink and extract dotfiles directory
        bashrc_real_path="$(readlink -f "${HOME}/.bashrc" 2>/dev/null || readlink "${HOME}/.bashrc")"
        if [[ -n "$bashrc_real_path" ]]; then
            # Extract dotfiles dir from path like /path/to/dotfiles/common/bash/.bashrc
            export DOTFILES_DIR="$(dirname "$(dirname "$(dirname "$bashrc_real_path")")")"
        fi
    fi

    # If still not found, try standard locations
    if [[ -z "${DOTFILES_DIR}" ]] || [[ ! -d "${DOTFILES_DIR}/common/bash" ]]; then
        if [[ -f "${HOME}/.config/dotfiles/.bashrc" ]] || [[ -d "${HOME}/.config/dotfiles/common/bash" ]]; then
            export DOTFILES_DIR="${HOME}/.config/dotfiles"
        elif [[ -f "${HOME}/.dotfiles/.bashrc" ]] || [[ -d "${HOME}/.dotfiles/common/bash" ]]; then
            export DOTFILES_DIR="${HOME}/.dotfiles"
        elif [[ -f "${HOME}/dotfiles/.bashrc" ]] || [[ -d "${HOME}/dotfiles/common/bash" ]]; then
            export DOTFILES_DIR="${HOME}/dotfiles"
        else
            # Fallback to default
            export DOTFILES_DIR="${HOME}/.configs/dotfiles"
        fi
    fi
fi

export BASHRC_HOME_DIR="$DOTFILES_DIR/common/bash"

# Environment variables
export BASHRC_STORED_VARS="${HOME}/.bash_stored_vars"
export BASH_PERSONAL_PROFILE="${HOME}/.bash_profile"
export GIT_PERSONAL_PROFILE="${HOME}/.gitprofile"
export TMUX_PERSONAL_PROFILE="${HOME}/.tmux.profile"
export VIM_PERSONAL_PROFILE="${HOME}/.vim_profile"
export ALIAS_SYMLINK_DIR="${HOME}/.aliased_symlinks"

# Add bin directory to PATH (for agent tools)
if [[ -d "$DOTFILES_DIR/bin" ]]; then
    export PATH="$DOTFILES_DIR/bin:$PATH"
fi

# ============================================================================
# Auto-sync Dotfiles
# ============================================================================

# Sync dotfiles from remote once per day
_dotfiles_auto_sync() {
    local dotfiles_dir="${HOME}/.dotfiles"
    local last_sync_file="${HOME}/.dotfiles_last_sync"
    local current_time=$(date +%s)
    local sync_interval=86400  # 24 hours in seconds

    # Only sync if dotfiles installation exists
    if [[ ! -d "$dotfiles_dir/.git" ]]; then
        return
    fi

    # Check if we need to sync
    local should_sync=false
    if [[ ! -f "$last_sync_file" ]]; then
        should_sync=true
    else
        local last_sync=$(cat "$last_sync_file" 2>/dev/null || echo "0")
        local time_since_sync=$((current_time - last_sync))
        if [[ $time_since_sync -ge $sync_interval ]]; then
            should_sync=true
        fi
    fi

    if [[ "$should_sync" == "true" ]]; then
        # All checks inside background process to avoid TOCTOU race conditions
        (
            cd "$dotfiles_dir" || exit 0

            # Check for uncommitted changes
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                # Dirty working tree, skip sync
                exit 0
            fi

            # Fetch to get latest remote info
            git fetch origin >/dev/null 2>&1 || exit 0

            # Check if local is ahead of remote (has local commits)
            local local_commit=$(git rev-parse HEAD 2>/dev/null)
            local remote_commit=$(git rev-parse @{u} 2>/dev/null || git rev-parse origin/main 2>/dev/null)

            if [[ -n "$local_commit" ]] && [[ -n "$remote_commit" ]] && [[ "$local_commit" != "$remote_commit" ]]; then
                # Check if local is ahead (has commits not in remote)
                if git merge-base --is-ancestor "$remote_commit" "$local_commit" 2>/dev/null; then
                    # Local is ahead, skip sync to preserve local work
                    exit 0
                fi
            fi

            # Safe to pull: local is behind or equal to remote, working tree is clean
            # Use --ff-only to prevent merge commits
            if git pull --ff-only origin main >/dev/null 2>&1; then
                echo "$current_time" > "$last_sync_file"
            fi
        ) &
    fi
}

# Run auto-sync
_dotfiles_auto_sync

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
# Git Personal Config
# ============================================================================

# Include $GIT_PERSONAL_PROFILE here since .gitconfig doesn't support env vars
if [ -f "$GIT_PERSONAL_PROFILE" ]; then
    git config --global include.path "$GIT_PERSONAL_PROFILE"
fi

# Local customizations should be added to your ~/.bashrc file after the line
# that sources this dotfile, not in ~/.bash_profile. This ensures external tools
# can modify your ~/.bashrc without breaking dotfiles.

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

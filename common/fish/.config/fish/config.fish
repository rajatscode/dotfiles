# config.fish - Main Fish Shell Configuration
# This file sources all configuration modules

## Set DOTFILES_HOME_DIR if not already set
if not set -q DOTFILES_HOME_DIR
    set -gx DOTFILES_HOME_DIR (dirname (dirname (dirname (dirname (status --current-filename)))))
end

## Create alias symlink directory
if not set -q ALIAS_SYMLINK_DIR
    set -gx ALIAS_SYMLINK_DIR $HOME/.dotfiles_aliases
    mkdir -p $ALIAS_SYMLINK_DIR
end

## Helper functions for dotfile variable persistence
function read_dotfile_vars
    # Fish stores variables differently - this is a placeholder
    # for compatibility with bash config
end

function store_dotfile_var
    # Fish stores variables differently - this is a placeholder
    # for compatibility with bash config
end

## Source all configuration files from conf.d/
## Fish automatically sources files in conf.d/ directory
## Files are sourced in lexicographic order (00-*, 10-*, etc.)

## Interactive shell only configurations
if status is-interactive
    # Commands to run in interactive sessions can go here

    # Auto-sync dotfiles once per day
    function _dotfiles_auto_sync
        set dotfiles_dir "$HOME/.dotfiles"
        set last_sync_file "$HOME/.dotfiles_last_sync"
        set current_time (date +%s)
        set sync_interval 86400  # 24 hours in seconds

        # Only sync if dotfiles installation exists
        if not test -d "$dotfiles_dir/.git"
            return
        end

        # Check if we need to sync
        set should_sync false
        if not test -f "$last_sync_file"
            set should_sync true
        else
            set last_sync (cat "$last_sync_file" 2>/dev/null; or echo "0")
            set time_since_sync (math $current_time - $last_sync)
            if test $time_since_sync -ge $sync_interval
                set should_sync true
            end
        end

        if test "$should_sync" = "true"
            # Sync silently in background
            fish -c "cd $dotfiles_dir && git fetch origin >/dev/null 2>&1 && git pull origin main >/dev/null 2>&1 && echo $current_time > $last_sync_file" &
        end
    end

    # Run auto-sync
    _dotfiles_auto_sync

    # Disable greeting
    set -g fish_greeting

    # Enable VI mode (optional - uncomment if desired)
    # fish_vi_key_bindings
end

## Non-interactive shell configurations
if not status is-interactive
    # Commands for non-interactive sessions
end

## Welcome message (optional)
# Uncomment to show a welcome message on new shells
# if status is-interactive
#     echo "🐟 Fish shell initialized with dotfiles config"
# end

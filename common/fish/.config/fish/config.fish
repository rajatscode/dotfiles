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

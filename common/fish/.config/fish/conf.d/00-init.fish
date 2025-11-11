# 00-init.fish - Initialization and core setup
# This file runs first and sets up the foundation

## Set DOTFILES_DIR if not already set
## Note: conf.d files are sourced BEFORE config.fish, so we must set this here
if not set -q DOTFILES_DIR
    # Get the directory containing this conf.d file
    set -l conf_file (status --current-filename)

    # Resolve symlink to get real path (readlink -f handles nested symlinks)
    if test -L "$conf_file"
        # Use realpath or readlink to resolve the symlink
        if command -v realpath &>/dev/null
            set conf_file (realpath "$conf_file")
        else if command -v readlink &>/dev/null
            # readlink -f is more portable (works on Linux and macOS with GNU coreutils)
            set conf_file (readlink -f "$conf_file" 2>/dev/null; or readlink "$conf_file")
        end
    end

    # Go up from .../dotfiles/common/fish/.config/fish/conf.d/00-init.fish to dotfiles root
    # That's 5 levels up: conf.d -> fish -> .config -> fish -> common -> dotfiles
    set -gx DOTFILES_DIR (dirname (dirname (dirname (dirname (dirname "$conf_file")))))

    # Validate that we found the right directory
    if not test -d "$DOTFILES_DIR/common/fish"
        # Fallback to standard locations if resolution failed
        if test -d "$HOME/.dotfiles/common/fish"
            set -gx DOTFILES_DIR "$HOME/.dotfiles"
        else if test -d "$HOME/dotfiles/common/fish"
            set -gx DOTFILES_DIR "$HOME/dotfiles"
        else
            # Last resort fallback
            set -gx DOTFILES_DIR "$HOME/.dotfiles"
        end
    end
end

## Add bin directory to PATH early (for agent and other tools)
if test -d "$DOTFILES_DIR/bin"
    # Only add if not already in PATH
    if not contains "$DOTFILES_DIR/bin" $PATH
        set -gx PATH "$DOTFILES_DIR/bin" $PATH
    end
end

## Create installs directory for downloaded tools
set -x DOTFILES_INSTALLS_DIR "$DOTFILES_DIR/.installs"
mkdir -p $DOTFILES_INSTALLS_DIR 2>/dev/null

## Set default editor (respect user's EDITOR if set)
if test -z "$EDITOR"
    if command -v vim &>/dev/null
        set -x EDITOR vim
    else if command -v nvim &>/dev/null
        set -x EDITOR nvim
    else
        set -x EDITOR vi
    end
end

## Detect OS
set -x OS_TYPE ""
switch (uname -s)
    case Linux
        set -x OS_TYPE linux
    case Darwin
        set -x OS_TYPE macos
    case 'CYGWIN*' 'MINGW*' 'MSYS*'
        set -x OS_TYPE windows
end

# 00-init.bashrc - Initialization and core setup
# This file runs first and sets up the foundation

## explicitly enable alias expansion (even in non-interactive shell)
shopt -s expand_aliases

## Create installs directory for downloaded tools
export DOTFILES_INSTALLS_DIR="$DOTFILES_DIR/.installs"
mkdir -p "$DOTFILES_INSTALLS_DIR"

## Set default editor (respect user's EDITOR if set)
if [ -z "$EDITOR" ]; then
    if command -v vim &>/dev/null; then
        export EDITOR="vim"
    elif command -v nvim &>/dev/null; then
        export EDITOR="nvim"
    else
        export EDITOR="vi"
    fi
fi

## Enable bash completion (if available)
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    # macOS bash completion (via Homebrew)
    if [ -f /opt/homebrew/etc/bash_completion ]; then
        . /opt/homebrew/etc/bash_completion
    elif [ -f /usr/local/etc/bash_completion ]; then
        . /usr/local/etc/bash_completion
    fi
fi

## Detect OS
export OS_TYPE=""
case "$(uname -s)" in
    Linux)
        export OS_TYPE="linux"
        ;;
    Darwin)
        export OS_TYPE="macos"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        export OS_TYPE="windows"
        ;;
esac

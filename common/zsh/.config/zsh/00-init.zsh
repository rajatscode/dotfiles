# 00-init.zsh - Initialization and core setup
# This file runs first and sets up the foundation

## Explicitly enable alias expansion (enabled by default in zsh)
setopt ALIASES

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

## Enable zsh completion system
autoload -Uz compinit
compinit

# Additional completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive completion

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

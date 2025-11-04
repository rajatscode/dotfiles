# 00-init.fish - Initialization and core setup
# This file runs first and sets up the foundation

## Create installs directory for downloaded tools
set -x DOTFILES_INSTALLS_DIR "$DOTFILES_HOME_DIR/.installs"
mkdir -p $DOTFILES_INSTALLS_DIR

## Set default editor (respect user's EDITOR if set)
if test -z "$EDITOR"
    if command -v nvim &>/dev/null
        set -x EDITOR nvim
    else if command -v vim &>/dev/null
        set -x EDITOR vim
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

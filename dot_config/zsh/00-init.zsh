# Basic shell initialization.

setopt ALIASES

export DOTFILES_INSTALLS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/installs"
mkdir -p "$DOTFILES_INSTALLS_DIR"

if [[ -z "${EDITOR:-}" ]]; then
    if command -v nvim &>/dev/null; then
        export EDITOR=nvim
    elif command -v vim &>/dev/null; then
        export EDITOR=vim
    else
        export EDITOR=vi
    fi
fi

case "$(uname -s)" in
    Darwin) export OS_TYPE=macos ;;
    Linux) export OS_TYPE=linux ;;
    *) export OS_TYPE=unknown ;;
esac

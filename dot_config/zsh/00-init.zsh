# Basic shell initialization.

setopt ALIASES

for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [[ -d "$brew_prefix/bin" && ":$PATH:" != *":$brew_prefix/bin:"* ]]; then
        export PATH="$brew_prefix/bin:$PATH"
    fi
done

export DOTFILES_INSTALLS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/installs"
mkdir -p "$DOTFILES_INSTALLS_DIR"

dotfiles_realpath() {
    local path="$1"
    if command -v realpath &>/dev/null; then
        command realpath "$path"
    elif [[ -d "$path" ]]; then
        (cd -P -- "$path" && pwd -P)
    else
        local directory="${path%/*}"
        local name="${path##*/}"
        [[ "$directory" == "$path" ]] && directory="."
        (cd -P -- "$directory" && printf '%s/%s\n' "$PWD" "$name")
    fi
}

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

# Basic shell initialization.

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

if test (uname) = Darwin
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
    fish_add_path /usr/local/bin
end

if not set -q EDITOR
    if command -q nvim
        set -gx EDITOR nvim
    else if command -q vim
        set -gx EDITOR vim
    else
        set -gx EDITOR vi
    end
end

set -gx OS_TYPE (uname -s | string lower)
set -l data_home $XDG_DATA_HOME
if test -z "$data_home"
    set data_home $HOME/.local/share
end
set -gx DOTFILES_INSTALLS_DIR "$data_home/dotfiles/installs"
mkdir -p $DOTFILES_INSTALLS_DIR 2>/dev/null

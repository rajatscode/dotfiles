# Basic shell initialization.

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

function dotfiles_realpath
    set -l path $argv[1]
    if command -q realpath
        command realpath $path
    else if command -q python3
        command python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' $path
    else
        set -l directory (dirname $path)
        set -l name (basename $path)
        set -l physical_directory (builtin cd $directory; and command pwd -P)
        printf '%s/%s\n' $physical_directory $name
    end
end

if test (uname) = Darwin
    for brew_dir in /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin
        test -d $brew_dir; and fish_add_path $brew_dir
    end
else if test -d /home/linuxbrew/.linuxbrew/bin
    fish_add_path /home/linuxbrew/.linuxbrew/bin
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

switch (uname -s)
    case Darwin
        set -gx OS_TYPE macos
    case Linux
        set -gx OS_TYPE linux
    case '*'
        set -gx OS_TYPE (uname -s | string lower)
end
set -l data_home $XDG_DATA_HOME
if test -z "$data_home"
    set data_home $HOME/.local/share
end
set -gx DOTFILES_INSTALLS_DIR "$data_home/dotfiles/installs"
mkdir -p $DOTFILES_INSTALLS_DIR 2>/dev/null

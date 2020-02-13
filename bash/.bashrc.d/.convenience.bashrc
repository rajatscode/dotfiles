# config to make the shell more convenient to use

## set up globbing
### stay interested in filenames starting with '.'
shopt -s dotglob ;
### enable '**' to match deep search within directory structure
shopt -s globstar ;
### use case-sensitive matching
shopt -u nocaseglob ;
### enable nullglob-esque '*' but don't back-off to empty matches
shopt -s failglob ;
shopt -u nullglob ;

## lesspipe - make less work for binary/non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## enable programmable completion features (if not already enabled)
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

## print previous command's return value if non-zero
export PROMPT_COMMAND="
__=\$?; history -a; if [[ \$__ != 0 ]]; then echo \$'\033p01;31mReturn value = ' \$__ ; fi"

## mkdir + cd
function mkcd() {
    mkdir -p -- "$@" && command cd -P "$@"
}

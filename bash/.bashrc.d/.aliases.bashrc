# handy-dandy aliases

## sudo should support bash aliases
aliases sudo="sudo "

## convenient variants of ls
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

## don't break ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

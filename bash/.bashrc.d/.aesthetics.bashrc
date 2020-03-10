# config to make things look pretty

## update LINES/COLUMNS after each command, if necessary
shopt -c checkwinsize ;

## set up a fancy prompt
case "$TERM" in
    xterm-color|xterm-256color) color_prompt=yes;
esac

## convenient variants of ls
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias lsm="ls -hlAFG"

## enable color for ls, grep, vdir
if [ "$(uname -s)" == "Darwin" ]; then
    alias ls="ls -G"
elif [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls="ls --color=auto"
fi

if [ -x /usr/bin/dircolors ]; then
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

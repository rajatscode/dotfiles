# config to make things look pretty

## update LINES/COLUMNS after each command, if necessary
shopt -c checkwinsize ;

## set up a fancy prompt
case "$TERM" in
    xterm-color|xterm-256color) color_prompt=yes;
esac

## enable color support for ls, grep, dir
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# configs to set up and improve history

## basic history configuration
HISTSIZE=10000
HISTFILESIZE=20000

## don't put duplicate lines or lines starting with space in history
HISTCONTROL=ignoreboth

## append to the history file, rather than overwriting it
shopt -s histappend

## disable the XON/XOFF feature to free up Ctrl+S for history navigation (fwd)
stty -ixon

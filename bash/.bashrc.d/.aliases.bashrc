# handy-dandy aliases

## explicitly enable alias expansion (even in non-interactive shell)
shopt -s expand_aliases

## sudo should support bash aliases
alias sudo="sudo "

## plz: re-run the last command as root.
alias plz="fc -l -1 | cut -d' ' -f2- | xargs sudo"

## convenient variants of ls
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias lsm="ls -hlAFG"

## `dir` is wasted on `ls -C -b` - use it for ls'ing only directories
dir() {
    ls -F -- $1 | grep /
}

## cls: clear, with listed directories
alias cls="clear;ls -hlAFG"

## updoot: aggressively update _everything_ (platform-dependent)
if [ ! -z "$(which brew)" ]; then
    alias updoot="brew update && brew upgrade"
elif [ ! -z "$(which pacman)" ]; then
    alias updoot="sudo pacman -Syyu"
elif [ ! -z "$(which apt)" ]; then
    alias updoot="sudo apt update && sudo apt upgrade && sudo apt full-upgrade"
elif [ ! -z "$(which apt-get)" ]; then
    alias updoot ="sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade"
elif [ ! -z "$(which dnf)" ]; then
    alias updoot="sudo dnf upgrade"
elif [ ! -z "$(which yum)" ]; then
    alias updoot="su -c 'yum update'"
elif [ ! -z "$(which zypper)" ]; then
    alias updoot="sudo zypper update"
fi

## quick curls
### weather: fetch weather for city/zip code
weather() { curl wttr.in/"$1"; }
### myip: print IP address
alias myip="curl icanhazip.com"

## ports: lists all ports open and which programs are using them
alias ports="netstat -tulpn"

## space: gets space left on disk
alias space="df -h"
## used: recursively gets how much space is used in the current (or given) directory
alias used="du -ch -d 1"

## incognito: stop saving command history
incognito() {
  case $1 in
    start)
    set +o history;;
    stop)
    set -o history;;
    *)
    echo -e "USAGE: incognito start - disable command history.
       incognito stop  - enable command history.";;
  esac
}

## download: download any and every item linked from that page.
### USAGE - download https://data.gov
alias download="wget --random-wait -r -p --no-parent -e robots=off -U mozilla"

## pman: render the given manpage in Preview.app
if [ "$(uname -s)" == "Darwin" ]; then
  pman() { ps=`mktemp -t manpageXXXX`.ps ; man -t $@ > "$ps" ; open "$ps" ; }
fi

## reveal: what folder am I in?
if [ "$(uname -s)" == "Darwin" ]; then
  alias reveal="open ."
else
  alias reveal="pwd "
fi

## alert: alert for long-running commands; e.g., `sleep 10; alert`
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## restart: refresh the shell
alias restart="source ~/.bashrc"

## bye: clear before exiting to avoid leaking information
alias bye="clear; exit"

## freeport: kill process running on specified port
freeport() {
  kill -9 $(lsof -t -i:$1) 2>>/dev/null && echo "Killed process on port $1" || echo "No process on port $1" ;
}

## source ~/.bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

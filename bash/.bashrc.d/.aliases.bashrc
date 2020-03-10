# handy-dandy aliases

## sudo should support bash aliases
aliases sudo="sudo "

## plz: re-run the last command as root.
alias plz="fc -l -1 | cut -d' ' -f2- | xargs sudo"

## convenient variants of ls
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias lsm="ls -hlAFG"

## `dir` is wasted - use it for ls'ing only directories
dir() {
    ls -F -- $1 | grep /
}

## enable color for ls
if [ "$(uname -s)" == "Darwin" ]; then
    alias ls="ls -G"
else
    alias ls="ls --color=auto"
fi

## enable autocd (in lieu of "<target> is a directory")
if [ "$(uname -s)" != "Darwin" ]; then
    shopt -s autocd
fi

## go `up` or down (`dn`) a directory
alias up="cd .."
function dn() {
    # pick first directory; fail if no directories
    # suppress stderr for `ls` and just go back to `pwd`
    cd `(ls -d */ 2> /dev/null || echo ".") | head -1` ;
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
fi

## git aliases
### gpom: git push origin master
alias gpom="git push origin master"
alias add="git add"
alias commit="git commit"
alias push="git push"
alias status="git status"
alias stash="git stash"

### restart: refresh the shell
alias restart="source ~/.bashrc"

### push-please: force push with lease (don't overwrite remote branch commits)
alias push-please="git push --force-with-lease"

## source ~/.bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

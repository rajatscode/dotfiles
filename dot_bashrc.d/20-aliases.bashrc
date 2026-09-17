# 20-aliases.bashrc - Handy-Dandy Aliases and Utility Functions

## ============================================================================
## Sudo Helpers
## ============================================================================

## sudo should support bash aliases
alias sudo="sudo "

## plz: re-run the last command as root.
alias plz="fc -l -1 | cut -d' ' -f2- | xargs sudo"

## ============================================================================
## File Listing Variants
## ============================================================================

## convenient variants of ls
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias lsm="ls -hlAFG"

## `dir` is wasted on `ls -C -b` - use it for ls'ing only directories
dir() {
    ls -F "$@" | grep /
}

## cls: clear, with listed directories
alias cls="clear;ls -hlAFG"

## ============================================================================
## System Updates (Cross-Platform)
## ============================================================================

## updoot: aggressively update _everything_ (platform-dependent)
if command -v brew &>/dev/null; then
    alias updoot="brew update && brew upgrade && brew cleanup"
elif command -v pacman &>/dev/null; then
    alias updoot="sudo pacman -Syu"
elif command -v apt &>/dev/null; then
    alias updoot="sudo apt update && sudo apt upgrade && sudo apt full-upgrade && sudo apt autoremove"
elif command -v apt-get &>/dev/null; then
    alias updoot="sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove"
elif command -v dnf &>/dev/null; then
    alias updoot="sudo dnf upgrade"
elif command -v yum &>/dev/null; then
    alias updoot="su -c 'yum update'"
elif command -v zypper &>/dev/null; then
    alias updoot="sudo zypper update"
fi

## ============================================================================
## Network & Internet Utilities
## ============================================================================

## quick curls
weather() { curl "wttr.in/""$1""?u"; }  # fetch weather for city/zip code
alias myip="curl icanhazip.com"        # print IP address

## connected: whether internet access is working
alias connected="wget -q --spider 1.1.1.1"
alias internet="connected && echo 👍 || echo 👎"

## ports: lists all ports open and which programs are using them
alias ports="lsof -nP -iTCP -sTCP:LISTEN"

## freeport: kill process running on specified port
freeport() {
    kill -9 $(lsof -t -i:$1) 2>> /dev/null && echo "Killed process on port $1" || echo "No process on port $1"
}

## ============================================================================
## Financial / Fun Utilities
## ============================================================================

## stonks: query Yahoo Finance API for a given ticker
stonks() {
    local ticker=$1
    python3 -c "import yfinance; stonk = yfinance.Ticker('$ticker'); print(stonk.info.get('longName'), stonk.ticker, '\n', stonk.history(period='5d'));" 2>/dev/null || echo "yfinance not installed. Run: pip3 install yfinance"
}

## ============================================================================
## Disk Space
## ============================================================================

## space: gets space left on disk
alias space="df -h"

## used: recursively gets how much space is used in the current (or given) directory
alias used="du -ch -d 1"

## ============================================================================
## Privacy / Security
## ============================================================================

## incognito: stop saving command history
incognito() {
    case $1 in
        start)
            set +o history
            echo "Command history disabled"
            ;;
        stop)
            set -o history
            echo "Command history enabled"
            ;;
        *)
            echo -e "USAGE: incognito start - disable command history.\n       incognito stop  - enable command history."
            ;;
    esac
}

## ============================================================================
## Archive Utilities
## ============================================================================

## untar: for when you forget the flags to extract a tar archive
alias untar="tar -zxvf "

## download: download any and every item linked from that page.
### USAGE - download https://data.gov
alias download="wget --random-wait -r -p --no-parent -e robots=off -U mozilla"

## ============================================================================
## macOS-Specific Aliases
## ============================================================================

if [ "$OS_TYPE" = "macos" ]; then
    ## pman: render the given manpage in Preview.app
    pman() {
        ps=$(mktemp -t manpageXXXX).ps
        man -t $@ > "$ps"
        open "$ps"
    }

    ## reveal: what folder am I in?
    alias reveal="open ."
else
    alias reveal="pwd "
fi

## ============================================================================
## Shell Management
## ============================================================================

## alert: notify when a long-running command finishes; e.g. `sleep 10; alert`
alert() {
    if [ "$OS_TYPE" = "macos" ] && command -v osascript &>/dev/null; then
        osascript -e 'display notification "Command finished" with title "Shell"' >/dev/null 2>&1
    elif command -v notify-send &>/dev/null; then
        notify-send --urgency=low "Shell" "Command finished" >/dev/null 2>&1
    else
        printf '\a'
    fi
}

## restart: refresh the shell
alias restart="source ~/.bashrc"

## bye: clear before exiting to avoid leaking information
alias bye="clear; exit"

## refresh: go to home dir, clear
alias refresh="cd; clear"

## ============================================================================
## Source User Aliases
## ============================================================================

## source ~/.bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

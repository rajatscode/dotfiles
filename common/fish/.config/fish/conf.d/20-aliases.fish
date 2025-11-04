# 20-aliases.fish - Handy-Dandy Aliases and Utility Functions

## ============================================================================
## Sudo Helpers
## ============================================================================

## plz: re-run the last command as root
function plz
    eval sudo (history --max=1 | string trim)
end

## ============================================================================
## File Listing Variants
## ============================================================================

## convenient variants of ls
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias lsm="ls -hlAFG"

## dir - ls only directories
function dir
    ls -F -- $argv | grep /
end

## cls: clear, with listed directories
alias cls="clear; ls -hlAFG"

## ============================================================================
## System Updates (Cross-Platform)
## ============================================================================

## updoot: aggressively update everything (platform-dependent)
if command -v brew &>/dev/null
    alias updoot="brew update; and brew upgrade; and brew cleanup"
else if command -v pacman &>/dev/null
    alias updoot="sudo pacman -Syu"
else if command -v apt &>/dev/null
    alias updoot="sudo apt update; and sudo apt upgrade; and sudo apt full-upgrade; and sudo apt autoremove"
else if command -v apt-get &>/dev/null
    alias updoot="sudo apt-get update; and sudo apt-get upgrade; and sudo apt-get dist-upgrade; and sudo apt-get autoremove"
else if command -v dnf &>/dev/null
    alias updoot="sudo dnf upgrade"
else if command -v yum &>/dev/null
    alias updoot="su -c 'yum update'"
else if command -v zypper &>/dev/null
    alias updoot="sudo zypper update"
end

## ============================================================================
## Network & Internet Utilities
## ============================================================================

## quick curls
function weather
    curl "wttr.in/$argv[1]?u"
end

alias myip="curl icanhazip.com"

## connected: whether internet access is working
alias connected="wget -q --spider 1.1.1.1"

function internet
    if connected
        echo 👍
    else
        echo 👎
    end
end

## ports: lists all ports open and which programs are using them
alias ports="netstat -tulpn 2>/dev/null; or lsof -iTCP -sTCP:LISTEN -n -P"

## freeport: kill process running on specified port
function freeport
    kill -9 (lsof -t -i:$argv[1]) 2>/dev/null; and echo "Killed process on port $argv[1]"; or echo "No process on port $argv[1]"
end

## ============================================================================
## Financial / Fun Utilities
## ============================================================================

## stonks: query Yahoo Finance API for a given ticker
function stonks
    set -l ticker $argv[1]
    python3 -c "import yfinance; stonk = yfinance.Ticker('$ticker'); print(stonk.info.get('longName'), stonk.ticker, '\n', stonk.history(period='5d'));" 2>/dev/null; or echo "yfinance not installed. Run: pip3 install yfinance"
end

## ============================================================================
## Disk Space
## ============================================================================

alias space="df -h"
alias used="du -ch -d 1"

## ============================================================================
## Privacy / Security
## ============================================================================

## incognito: stop saving command history
function incognito
    switch $argv[1]
        case start
            set -g fish_history ""
            echo "Command history disabled"
        case stop
            set -e fish_history
            echo "Command history enabled"
        case '*'
            echo "USAGE: incognito start - disable command history."
            echo "       incognito stop  - enable command history."
    end
end

## ============================================================================
## Archive Utilities
## ============================================================================

alias untar="tar -zxvf"
alias download="wget --random-wait -r -p --no-parent -e robots=off -U mozilla"

## ============================================================================
## macOS-Specific Aliases
## ============================================================================

if test "$OS_TYPE" = "macos"
    ## pman: render the given manpage in Preview.app
    function pman
        set ps (mktemp -t manpageXXXX).ps
        man -t $argv > $ps
        open $ps
    end

    alias reveal="open ."
else
    alias reveal="pwd"
end

## ============================================================================
## Shell Management
## ============================================================================

## restart: refresh the shell
alias restart="source ~/.config/fish/config.fish"

## bye: clear before exiting to avoid leaking information
alias bye="clear; exit"

## refresh: go to home dir, clear
alias refresh="cd; clear"

## ============================================================================
## Source User Aliases
## ============================================================================

# Source user's custom aliases if they exist
if test -f ~/.config/fish/aliases.fish
    source ~/.config/fish/aliases.fish
end

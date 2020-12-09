# config to make things look pretty

## update LINES/COLUMNS after each command, if necessary
shopt -s checkwinsize

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

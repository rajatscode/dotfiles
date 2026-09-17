# 60-history.bashrc - History configuration

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# History size
HISTSIZE=10000
HISTFILESIZE=20000

# Add timestamp to history
HISTTIMEFORMAT="%F %T "

# Ignore common commands
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Save multi-line commands as one command
shopt -s cmdhist

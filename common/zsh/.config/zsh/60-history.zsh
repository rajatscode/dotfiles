# 60-history.zsh - History configuration

# History file location
HISTFILE=~/.zsh_history

# History size
HISTSIZE=10000
SAVEHIST=20000

# Add timestamp to history
setopt EXTENDED_HISTORY

# Don't put duplicate lines in the history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Don't record lines starting with space
setopt HIST_IGNORE_SPACE

# Append to the history file, don't overwrite it
setopt APPEND_HISTORY

# Share history between sessions
setopt SHARE_HISTORY

# Incrementally append to history (write after each command)
setopt INC_APPEND_HISTORY

# Save multi-line commands as one command
setopt HIST_REDUCE_BLANKS

# Remove superfluous blanks from history
setopt HIST_REDUCE_BLANKS

# Don't execute immediately upon history expansion
setopt HIST_VERIFY

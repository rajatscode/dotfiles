# 60-history.fish - History configuration

# History size
set -x fish_history_max_size 10000

# Add timestamp to history (Fish does this by default)

# Save history immediately (Fish does this by default)

# Enable history search with up/down arrows
bind \e\[A history-search-backward
bind \e\[B history-search-forward

# Don't save commands that start with space
set -x HISTCONTROL ignorespace

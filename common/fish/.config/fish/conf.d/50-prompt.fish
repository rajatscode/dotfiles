# 50-prompt.fish - Prompt configuration with git and agent integration

# If starship is installed, use it instead of custom prompt
if command -v starship &>/dev/null
    starship init fish | source
    exit
end

# Fish has excellent built-in git prompt support
# Configure git prompt
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_showstashstate 1

# Prompt colors
set -g __fish_git_prompt_color_branch yellow
set -g __fish_git_prompt_color_upstream_ahead green
set -g __fish_git_prompt_color_upstream_behind red
set -g __fish_git_prompt_color_dirtystate purple
set -g __fish_git_prompt_color_untrackedfiles cyan

# Prompt characters
set -g __fish_git_prompt_char_dirtystate '*'
set -g __fish_git_prompt_char_untrackedfiles '+'
set -g __fish_git_prompt_char_stashstate '$'
set -g __fish_git_prompt_char_upstream_ahead '↑'
set -g __fish_git_prompt_char_upstream_behind '↓'

# Custom prompt function
function fish_prompt
    set -l last_status $status

    # Show exit status if non-zero
    if test $last_status -ne 0
        set_color red
        echo -n "[$last_status] "
    end

    # Show current directory
    set_color blue --bold
    echo -n (prompt_pwd)

    # Show git info
    set_color normal
    echo -n (fish_git_prompt)

    # Show agent session if active
    if test -n "$AGENT_SESSION"
        set_color magenta
        echo -n " [agent:$AGENT_SESSION]"
    end

    # Prompt character
    set_color normal
    echo -n ' $ '
end

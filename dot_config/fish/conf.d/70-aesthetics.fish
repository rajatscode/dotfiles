# 70-aesthetics.fish - Color support and visual enhancements

## ============================================================================
## Color Support
## ============================================================================

# Enable color support for ls and grep (Fish does this by default)
if test (uname -s) = "Darwin"
    # macOS color support
    set -x CLICOLOR 1
    set -x LSCOLORS ExGxBxDxCxEgEdxbxgxcxd
end

# Set ls colors
if command -v dircolors &>/dev/null
    if test -r ~/.dircolors
        eval (dircolors -c ~/.dircolors)
    else
        eval (dircolors -c)
    end
end

## ============================================================================
## Less Colors (Man Pages)
## ============================================================================

set -x LESS_TERMCAP_mb (printf '\e[1;31m')     # begin bold
set -x LESS_TERMCAP_md (printf '\e[1;36m')     # begin blink
set -x LESS_TERMCAP_me (printf '\e[0m')        # reset bold/blink
set -x LESS_TERMCAP_so (printf '\e[01;44;33m') # begin reverse video
set -x LESS_TERMCAP_se (printf '\e[0m')        # reset reverse video
set -x LESS_TERMCAP_us (printf '\e[1;32m')     # begin underline
set -x LESS_TERMCAP_ue (printf '\e[0m')        # reset underline

## ============================================================================
## Fish-Specific Colors
## ============================================================================

# Set syntax highlighting colors
set -g fish_color_command blue --bold
set -g fish_color_param cyan
set -g fish_color_error red --bold
set -g fish_color_comment brblack
set -g fish_color_quote yellow
set -g fish_color_redirection bryellow
set -g fish_color_end green
set -g fish_color_operator magenta
set -g fish_color_escape brcyan
set -g fish_color_autosuggestion brblack

# Set completion colors
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix cyan --bold
set -g fish_pager_color_progress brwhite --background=cyan

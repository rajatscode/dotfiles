# 50-prompt.zsh - Prompt configuration with git and agent integration

# If starship is installed, use it instead of custom prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
    return
fi

# Otherwise, use custom git-aware prompt

# Enable prompt substitution
setopt PROMPT_SUBST

# Colors (zsh uses %F{color} syntax for colors)
# But we can also use ANSI escape codes for consistency

# Regular Colors
Color_Off="%f%k%b"
Black="%F{black}"
Red="%F{red}"
Green="%F{green}"
Yellow="%F{yellow}"
Blue="%F{blue}"
Purple="%F{magenta}"
Cyan="%F{cyan}"
White="%F{white}"

# Bold
BBlack="%B%F{black}"
BRed="%B%F{red}"
BGreen="%B%F{green}"
BYellow="%B%F{yellow}"
BBlue="%B%F{blue}"
BPurple="%B%F{magenta}"
BCyan="%B%F{cyan}"
BWhite="%B%F{white}"

# High Intensity (Bright colors)
IBlack="%F{8}"     # bright black (gray)
IRed="%F{9}"       # bright red
IGreen="%F{10}"    # bright green
IYellow="%F{11}"   # bright yellow
IBlue="%F{12}"     # bright blue
IPurple="%F{13}"   # bright magenta
ICyan="%F{14}"     # bright cyan
IWhite="%F{15}"    # bright white

# Git-aware prompt with agent session integration
__zsh_git_prompt() {
    # Check if we're in a git repo
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch="${vcs_info_msg_0_}"

        # Check if we're in .git directory
        if [[ $(basename $PWD) == ".git" ]]; then
            echo "${IWhite}(${branch}) ${BYellow}git "
        else
            # Check if there are uncommitted changes
            if git diff-index --quiet HEAD -- 2>/dev/null; then
                # Clean repo
                echo "${IGreen}(${branch}) ${BYellow}git "
            else
                # Dirty repo
                echo "${IPurple}⁅${branch}⁆ ${BYellow}git "
            fi
        fi
    fi
}

# Build the prompt
PROMPT='$(__zsh_git_prompt)${BBlue}%~$(__agent_ps1)${Color_Off}$ '

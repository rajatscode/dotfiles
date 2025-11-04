# 50-prompt.bashrc - Prompt configuration with git and agent integration

# If starship is installed, use it instead of custom prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
    return
fi

# Otherwise, use custom git-aware prompt

# Reset
Color_Off="\[\033[0m\]"

# Regular Colors
Black="\[\033[0;30m\]"
Red="\[\033[0;31m\]"
Green="\[\033[0;32m\]"
Yellow="\[\033[0;33m\]"
Blue="\[\033[0;34m\]"
Purple="\[\033[0;35m\]"
Cyan="\[\033[0;36m\]"
White="\[\033[0;37m\]"

# Bold
BBlack="\[\033[1;30m\]"
BRed="\[\033[1;31m\]"
BGreen="\[\033[1;32m\]"
BYellow="\[\033[1;33m\]"
BBlue="\[\033[1;34m\]"
BPurple="\[\033[1;35m\]"
BCyan="\[\033[1;36m\]"
BWhite="\[\033[1;37m\]"

# High Intensity
IBlack="\[\033[0;90m\]"
IRed="\[\033[0;91m\]"
IGreen="\[\033[0;92m\]"
IYellow="\[\033[0;93m\]"
IBlue="\[\033[0;94m\]"
IPurple="\[\033[0;95m\]"
ICyan="\[\033[0;96m\]"
IWhite="\[\033[0;97m\]"

# Path variables
PathShort="\W"
PathFull="\w"

# Trim path down to bottom-most 3 directories
PROMPT_DIRTRIM=3

# Git-aware prompt with agent session integration
if type -t __git_ps1 &>/dev/null; then
    export PS1=$Color_Off'$([[ $(basename $PWD) == ".git" ]] &> /dev/null;\
if [ $? -eq 0 ]; then \
  echo "'$IWhite'"$(__git_ps1 "(%s)")" '$BYellow' git '$BBlue$PathFull$(__agent_ps1)$Color_Off'\$ "; \
else \
  git branch &>/dev/null;\
  if [ $? -eq 0 ]; then \
    echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
    if [ "$?" -eq "0" ]; then \
      echo "'$IGreen'"$(__git_ps1 "(%s)"); \
    else \
      echo "'$IPurple'"$(__git_ps1 "⁅%s⁆"); \
    fi) '$BYellow'git '$BBlue$PathFull$(__agent_ps1)$Color_Off'\$ "; \
  else \
    echo "'$BGreen$PathFull$(__agent_ps1)$Color_Off'\$ "; \
  fi \
fi)'
else
    # Simple prompt without git integration
    export PS1="${BGreen}\w${BPurple}\$(__agent_ps1)${Color_Off}\$ "
fi

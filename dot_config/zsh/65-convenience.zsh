# 65-convenience.zsh - Shell convenience features

## ============================================================================
## Globbing Options
## ============================================================================

## stay interested in filenames starting with '.'
setopt GLOB_DOTS

## enable '**' to match deep search within directory structure
setopt GLOB_STAR_SHORT

## disable case-sensitive matching (use case-insensitive)
# unsetopt CASE_GLOB  # Commented out to keep case-sensitive by default

## enable nullglob-esque '*' behavior
# setopt NULL_GLOB  # Different from bash - using NOMATCH instead
setopt NOMATCH  # Print error if no matches (like bash's failglob)

## catch spelling errors when using cd
setopt CORRECT
setopt CORRECT_ALL

## enable autocd (typing directory name changes to it)
setopt AUTO_CD

## ============================================================================
## Enhanced Tools
## ============================================================================

## lesspipe - make less work for binary/non-text input files
if [ -x /usr/bin/lesspipe ]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

## ============================================================================
## Precmd Hook
## ============================================================================

## print previous command's return value if non-zero
__prompt_command() {
    local exit_code=$?
    if [[ $exit_code != 0 ]]; then
        print -P "%F{red}%BReturn value = $exit_code%b%f"
    fi
}

# Add to precmd_functions if not already present
if [[ ! "${precmd_functions[(r)__prompt_command]}" == "__prompt_command" ]]; then
    precmd_functions+=(__prompt_command)
fi

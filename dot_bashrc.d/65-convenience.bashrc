# 65-convenience.bashrc - Shell convenience features

## ============================================================================
## Globbing Options
## ============================================================================

## stay interested in filenames starting with '.'
shopt -s dotglob

## enable '**' to match deep search within directory structure
if [ "$(uname -s)" != "Darwin" ]; then
    shopt -s globstar
fi

## use case-sensitive matching
shopt -u nocaseglob

## enable nullglob-esque '*' but don't back-off to empty matches
shopt -s failglob
shopt -u nullglob

## catch spelling errors when using cd and in directory names
shopt -s cdspell
if [ "$(uname -s)" != "Darwin" ]; then
    shopt -s dirspell
fi

## ============================================================================
## Enhanced Tools
## ============================================================================

## lesspipe - make less work for binary/non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## enable autocd (in lieu of "<target> is a directory")
if [ "$(uname -s)" != "Darwin" ]; then
    shopt -s autocd
fi

## ============================================================================
## Prompt Command
## ============================================================================

## print previous command's return value if non-zero
__prompt_command() {
    local exit_code=$?
    history -a
    if [[ $exit_code != 0 ]]; then
        echo -e "\033[01;31mReturn value = $exit_code\033[0m"
    fi
}

# Add to PROMPT_COMMAND (preserve existing if any)
if [ -z "$PROMPT_COMMAND" ]; then
    export PROMPT_COMMAND="__prompt_command"
else
    export PROMPT_COMMAND="__prompt_command; $PROMPT_COMMAND"
fi

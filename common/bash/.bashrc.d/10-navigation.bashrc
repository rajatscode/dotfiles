# 10-navigation.bashrc - Navigation System
# Enhanced directory navigation with aliasing, backoff, and location stacks

## ============================================================================
## Directory Creation & Navigation
## ============================================================================

## mkcd - create the directory if it doesn't exist, then cd into it
mkcd() {
    mkdir -p -- "$@" && command cd -P -- "$@"
}

## pcd (overrides cd) - cd with backoff (i.e., if the whole path doesn't work,
## go to the deepest subpath that still does); this handles cd'ing into files
## or cd'ing into invalid directories + is compatible with spelling autofix
pcd() {
    command cd "$@" 2>> /dev/null
    if [[ "$?" == '0' ]]; then
        :
    else
        local laststep=$(echo "$@" | sed 's|.*/||')
        local mainpath=${@%%$laststep}
        local mainpath=${mainpath%%/}
        ## edge case - don't backoff into root or empty dir
        if [[ -n "$mainpath" ]]; then
            pcd "$mainpath"
        fi
        if [[ "$?" == '0' && -n "$laststep" ]]; then
            command cd "$laststep"
        else
            return 1
        fi
    fi
}
alias sd="pcd "

## vcd - tried cd'ing into a file? whoops, should vim
## if file/directory doesn't exist, then use pcd
vcd() {
    if [[ -d "$@" ]]; then
        cd "$@"
    else
        if [[ -f "$@" ]]; then
            cd $(dirname "$@")
            ${EDITOR:-vim} $(basename "$@")
        else
            pcd "$@"
        fi
    fi
}

## ============================================================================
## Quick Directory Movement
## ============================================================================

## go `up` or down (`dn`) a directory
alias up="cd .."
dn() {
    # pick first directory; fail if no directories
    # suppress stderr for `ls` and just go back to `pwd`
    cd "$( ( (command ls -d -- */ 2> /dev/null) || echo "." ) | head -1 )"
}

## go `bk` between directories
alias bk="cd -"

## ============================================================================
## Symlink-Based Aliasing System
## ============================================================================

## `al` - convenient aliasing for directory names (or files)
## arguments: alias name (defaults to dirname), alias path (optional)
## newer aliases quietly replace older ones
##
## Note: aliases with /'s in their names cannot be correctly followed by `fal`,
## so creating aliases with /'s is unsupported
al() {
    local alias_name="${1:-${PWD##*/}}"
    local alias_target="${2:-$PWD}"
    # delete the alias, if it already exists, to avoid wonky behavior
    xal $alias_name 2>>/dev/null
    ln -sf "$(realpath "$alias_target")" "$ALIAS_SYMLINK_DIR""/""$alias_name"
}

## `fal` - follow alias; use aliases created by al
## reads path from symlink so we go to the real directory/file
fal() {
    local target_alias=$( echo "$@" | cut -d/ -f1 )
    local target_subpath=$( echo "$@/" | cut -d/ -f2- | sed 's/\/$//' )
    local full_symlink="$ALIAS_SYMLINK_DIR"/"$target_alias"
    if [[ ! -L $full_symlink ]]; then
        return 1
    fi

    local alias_target=$(readlink -f "$full_symlink")
    local actual_target="$alias_target"/"$target_subpath"
    touch -h $full_symlink
    vcd "$actual_target"
}
alias fa="fal "

_alias_completions() {
    local _stored_aliases=$(ls -1 "$ALIAS_SYMLINK_DIR" 2>/dev/null)
    local cur=${COMP_WORDS[COMP_CWORD]}

    COMPREPLY=( $(compgen -W "${_stored_aliases}" -- $cur) )
}
complete -F _alias_completions fal

## `xal` - removes aliases
## if no arguments are given, clears all aliases
xal() {
    if [ "$#" -eq 0 ]; then
        read -p "You're about to delete all symlink aliases. Are you sure? [y/N]" yn
        case $yn in
            [Yy]* ) rm $ALIAS_SYMLINK_DIR/* 2>/dev/null ;;
            [Nn]* ) ;;
            * ) echo "Assuming that's a no. Not deleting any aliases.";;
        esac
    else
        rm "$ALIAS_SYMLINK_DIR/$@" 2> /dev/null
    fi
}

complete -F _alias_completions xal

## `lal` - lists aliases
if [ "$OS_TYPE" = "macos" ]; then
    # macOS stat has different syntax
    alias lal="(stat -f'%N %m' $ALIAS_SYMLINK_DIR/* 2>/dev/null | sed 's~'\"$ALIAS_SYMLINK_DIR\"'/~~' | sort -nrk 2 | rev | cut -d ' ' -f 2- | rev) 2>> /dev/null"
else
    alias lal="(stat -c\"%N %Y\" $ALIAS_SYMLINK_DIR/* 2>/dev/null | sed 's~'\"$ALIAS_SYMLINK_DIR\"'/~~' | sort -nrk 4 | rev | cut -d \" \" -f 2- | rev) 2>> /dev/null"
fi

## `fk` - a convenience alias for `lal` and `fal`, but with a `vcd` fallback
## if the alias doesn't exist, tries to open it (creating if needed)
fk() {
    case $1 in
        "-l")
            lal
            ;;
        *)
            fal "$@" || vcd "$@"
            ;;
    esac
}

## ============================================================================
## eXpanded Navigation (xn) - Unified Navigation Interface
## ============================================================================

## `xn` - eXpanded Navigation, combining vcd, al, and fal
xn() {
    if [ "$#" -eq 0 ]; then
        command ls -A
    else
        case $1 in
            "-a")
                shift
                al "$@"
                ;;
            "-l")
                lal
                ;;
            *)
                if [[ "$1" == @* ]]; then
                    # cut out the leading "@" and call `fal`
                    local input_args="${@:(1)}"
                    fal "${input_args:(1)}"
                else
                    vcd "$@"
                fi
            ;;
        esac
    fi
}
alias fj="xn "

## ============================================================================
## Location Stack (Push/Pop Locations)
## ============================================================================

## `pushloc` - push a location (default $PWD) onto a stack to visit later
## NOTE: this is not integrated with pushd/popd and has different behavior
pushloc() {
    local path_to_push=$(readlink -f "${1:-$PWD}")
    read_dotfile_vars # keep SAVED_PATHS_STACK consistent
    SAVED_PATHS_STACK=("$path_to_push" "${SAVED_PATHS_STACK[@]}")
    store_dotfile_var SAVED_PATHS_STACK
}
alias pl="pushloc "

## `gotoloc` - go to the last location saved onto the stack, without deletion
gotoloc() {
    read_dotfile_vars # keep SAVED_PATHS_STACK consistent
    test -n "$SAVED_PATHS_STACK" && vcd "$SAVED_PATHS_STACK"
}
alias gl="gotoloc "

## `poploc` - go back to the last location you saved onto the stack
## removes the location from the stack as well
## NOTE: this is not integrated with pushd/popd and has different behavior
poploc() {
    gotoloc
    SAVED_PATHS_STACK=("${SAVED_PATHS_STACK[@]:1}")
    store_dotfile_var SAVED_PATHS_STACK
}
alias ol="poploc "

## ============================================================================
## Directory Deletion
## ============================================================================

## `deldir` - remove current directory (can do multiple levels, prompts if non-empty)
deldir() {
    local confirmdel=0
    if [ $(ls -a | wc -l) -le 2 ]; then
        confirmdel=1
    else
        read -p "You're about to delete non-empty dir ${PWD##*/}. Are you sure? [y/N]" yn
        case $yn in
            [Yy]* ) confirmdel=1 ;;
            [Nn]* ) confirmdel=0 ;;
            * )
                echo "Assuming that's a no. Not deleting any directory."
                confirmdel=0 ;;
        esac
    fi

    if [ $confirmdel -eq 1 ]; then
        local dirtodel=$PWD
        command cd ..
        rm -r "$dirtodel"
    fi
}
alias rd="deldir "

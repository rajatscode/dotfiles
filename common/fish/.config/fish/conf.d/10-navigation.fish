# 10-navigation.fish - Navigation System
# Enhanced directory navigation with aliasing, backoff, and location stacks

## ============================================================================
## Directory Creation & Navigation
## ============================================================================

## mkcd - create the directory if it doesn't exist, then cd into it
function mkcd
    mkdir -p $argv
    and cd $argv
end

## pcd (overrides cd) - cd with backoff (i.e., if the whole path doesn't work,
## go to the deepest subpath that still does)
function pcd
    if command cd $argv 2>/dev/null
        return 0
    else
        set laststep (basename $argv)
        set mainpath (dirname $argv)

        # edge case - don't backoff into root or empty dir
        if test -n "$mainpath"
            pcd $mainpath
        end

        if test $status -eq 0; and test -n "$laststep"
            command cd $laststep
        else
            return 1
        end
    end
end

alias sd="pcd"

## vcd - tried cd'ing into a file? whoops, should vim
## if file/directory doesn't exist, then use pcd
function vcd
    if test -d $argv
        cd $argv
    else if test -f $argv
        cd (dirname $argv)
        eval $EDITOR (basename $argv)
    else
        pcd $argv
    end
end

## ============================================================================
## Quick Directory Movement
## ============================================================================

## go up or down a directory
alias up="cd .."

function dn
    # pick first directory; fail if no directories
    cd (command ls -d -- */ 2>/dev/null; or echo ".") | head -1
end

## go to a sibling directory
function sib
    cd "../$argv[1]"
end

## go back between directories
alias bk="cd -"

## ============================================================================
## Symlink-Based Aliasing System
## ============================================================================

## al - convenient aliasing for directory names (or files)
function al
    set -l alias_name $argv[1]
    if test -z "$alias_name"
        set alias_name (basename $PWD)
    end

    set -l alias_target $argv[2]
    if test -z "$alias_target"
        set alias_target $PWD
    end

    # delete the alias, if it already exists
    xal $alias_name 2>/dev/null
    ln -sf (realpath $alias_target) $ALIAS_SYMLINK_DIR/$alias_name
end

## fal - follow alias; use aliases created by al
function fal
    set -l target_alias (echo $argv | cut -d/ -f1)
    set -l target_subpath (echo $argv/ | cut -d/ -f2- | sed 's/\/$//')
    set -l full_symlink $ALIAS_SYMLINK_DIR/$target_alias

    if not test -L $full_symlink
        return 1
    end

    set -l alias_target (readlink -f $full_symlink)
    set -l actual_target $alias_target/$target_subpath
    touch -h $full_symlink
    vcd $actual_target
end

alias fa="fal"

## Completion for fal
complete -c fal -a "(ls -1 $ALIAS_SYMLINK_DIR 2>/dev/null)"

## xal - removes aliases
function xal
    if test (count $argv) -eq 0
        read -P "You're about to delete all symlink aliases. Are you sure? [y/N] " yn
        switch $yn
            case Y y
                rm $ALIAS_SYMLINK_DIR/* 2>/dev/null
            case '*'
                echo "Not deleting any aliases."
        end
    else
        rm $ALIAS_SYMLINK_DIR/$argv 2>/dev/null
    end
end

complete -c xal -a "(ls -1 $ALIAS_SYMLINK_DIR 2>/dev/null)"

## lal - lists aliases with their targets
if test "$OS_TYPE" = "macos"
    # macOS: use stat to get mtime for sorting, then readlink to show targets
    function lal
        # Use ls to check if directory is empty (avoid Fish glob expansion errors)
        if test (count (ls -A $ALIAS_SYMLINK_DIR 2>/dev/null)) -gt 0
            for f in $ALIAS_SYMLINK_DIR/*
                if test -e "$f"
                    set fname (basename "$f")
                    set mtime (stat -f'%m' "$f" 2>/dev/null)
                    set target (readlink "$f" 2>/dev/null)
                    echo "$mtime $fname -> $target"
                end
            end | sort -nrk1 | cut -d' ' -f2-
        else
            echo "No aliases found. Use 'al' to create one."
        end
    end
else
    function lal
        # Linux: use stat to get mtime for sorting, then readlink to show targets
        if test (count (ls -A $ALIAS_SYMLINK_DIR 2>/dev/null)) -gt 0
            for f in $ALIAS_SYMLINK_DIR/*
                if test -e "$f"
                    set fname (basename "$f")
                    set mtime (stat -c'%Y' "$f" 2>/dev/null)
                    set target (readlink "$f" 2>/dev/null)
                    echo "$mtime $fname -> $target"
                end
            end | sort -nrk1 | cut -d' ' -f2-
        else
            echo "No aliases found. Use 'al' to create one."
        end
    end
end

## fk - convenience alias for lal and fal with vcd fallback
function fk
    switch $argv[1]
        case "-l"
            lal
        case '*'
            fal $argv; or vcd $argv
    end
end

## ============================================================================
## eXpanded Navigation (xn) - Unified Navigation Interface
## ============================================================================

function xn
    if test (count $argv) -eq 0
        command ls -A
    else
        switch $argv[1]
            case "-a"
                set -e argv[1]
                al $argv
            case "-l"
                lal
            case '@*'
                # cut out the leading "@" and call fal
                set -l input_args (string sub -s 2 $argv[1])
                fal $input_args
            case '*'
                vcd $argv
        end
    end
end

alias fj="xn"

## ============================================================================
## Location Stack (Push/Pop Locations)
## ============================================================================

## pushloc - push a location onto a stack
function pushloc
    set -l path_to_push (readlink -f $argv[1])
    if test -z "$path_to_push"
        set path_to_push (readlink -f $PWD)
    end

    read_dotfile_vars # keep SAVED_PATHS_STACK consistent
    set -g SAVED_PATHS_STACK $path_to_push $SAVED_PATHS_STACK
    store_dotfile_var SAVED_PATHS_STACK
end

alias pl="pushloc"

## gotoloc - go to the last location saved onto the stack
function gotoloc
    read_dotfile_vars
    if test -n "$SAVED_PATHS_STACK[1]"
        vcd $SAVED_PATHS_STACK[1]
    end
end

alias gl="gotoloc"

## poploc - go back to the last location and remove from stack
function poploc
    gotoloc
    set -e SAVED_PATHS_STACK[1]
    store_dotfile_var SAVED_PATHS_STACK
end

alias ol="poploc"

## ============================================================================
## Directory Deletion
## ============================================================================

## deldir - remove current directory
function deldir
    set -l confirmdel 0

    if test (ls -a | wc -l) -le 2
        set confirmdel 1
    else
        read -P "You're about to delete non-empty dir "(basename $PWD)". Are you sure? [y/N] " yn
        switch $yn
            case Y y
                set confirmdel 1
            case '*'
                echo "Not deleting any directory."
                set confirmdel 0
        end
    end

    if test $confirmdel -eq 1
        set -l dirtodel $PWD
        command cd ..
        rm -r $dirtodel
    end
end

alias rd="deldir"

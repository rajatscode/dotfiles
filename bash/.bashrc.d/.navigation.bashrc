# configs to improve navigation

## mkcd - create the directory if it doesn't exist
function mkcd() {
    mkdir -p -- "$@" && command cd -P "$@"
}

## vcd - tried cd'ing into a file? whoops, should vim
## if file/directory doesn't exist, use mkcd
function vcd() {
    if [[ -d "$@" ]]
    then
        cd "$@";
    else
        if [[ -f "$@" ]]
        then
            vim "$@";
        else
            mkcd "$@";
        fi
    fi
}

## go `up` or down (`dn`) a directory
alias up="cd .."
function dn() {
    # pick first directory; fail if no directories
    # suppress stderr for `ls` and just go back to `pwd`
    cd `(ls -d */ 2> /dev/null || echo ".") | head -1`;
}

## `al` - convenient aliasing for directory names (or files)
## arguments: alias name (defaults to dirname), alias path (optional)
## newer aliases quietly replace older ones
function al() {
    local alias_name="${1:-${PWD##*/}}";
    local alias_target="${2:-$PWD}";
    ln -sf "$(realpath $alias_target)" "$ALIAS_SYMLINK_DIR"/"$alias_name";
}

## `fal` - follow alias; use aliases created by al
## reads path from symlink so we go to the real directory/file
function fal() {
    local full_symlink="$ALIAS_SYMLINK_DIR"/"$@";
    if [[ ! -L $full_symlink ]]
    then
        return 1;
    fi

    local actual_target=$(readlink -f "$full_symlink");
    if [[ -d "$actual_target" ]]
    then
        cd "$actual_target";
    else
        vim "$actual_target";
    fi
}

## `xal` - removes aliases
## if no arguments are given, clears all aliases
function xal() {
    if [ "$#" -eq 0 ];
    then
        rm $ALIAS_SYMLINK_DIR/* ;
    else
        rm "$ALIAS_SYMLINK_DIR/$@" 2> /dev/null ;
    fi
}

## `xn` - eXpanded Navigation, combining vcd, al, and fal
function xn() {
    if [ "$#" -ne 0 ]
    then
        case $1 in
            "-a")
                shift;
                al "$@" ;
                ;;
    
            *)
                if [[ "$1" == @* ]];
                then
                    # cut out the leading "@" and call `fal`
                    local input_args="${@:(1)}";
                    fal "${input_args:(1)}" ;
                else
                    vcd "$@" ;
                fi
            ;;
        esac
    fi
}
alias fj="xn "

## `pushloc` - push a location (default $PWD) onto a stack to visit later
function pushloc() {
    local path_to_push=$(readlink -f "${1:-$PWD}");
    read_dotfile_vars; # keep SAVED_PATHS_STACK consistent
    SAVED_PATHS_STACK=("$path_to_push" "${SAVED_PATHS_STACK[@]}");
    store_dotfile_var SAVED_PATHS_STACK;
}
alias pl="pushloc "

## `gotoloc` - go to the last location saved onto the stack, without deletion
function gotoloc() {
    read_dotfile_vars; # keep SAVED_PATHS_STACK consistent
    test -n "$SAVED_PATHS_STACK" && vcd "$SAVED_PATHS_STACK";
}
alias gl="gotoloc "

## `poploc` - go back to the last location you saved onto the stack
## removes the location from the stack as well
function poploc() {
    gotoloc;
    SAVED_PATHS_STACK=("${SAVED_PATHS_STACK[@]:1}");
    store_dotfile_var SAVED_PATHS_STACK;
}
alias ol="poploc "

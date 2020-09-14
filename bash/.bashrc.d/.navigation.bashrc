# configs to improve navigation

# mkcd - create the directory if it doesn't exist
function mkcd() {
    mkdir -p -- "$1" && cd -P -- "$1";
}

# vcd - tried cd'ing into a file? whoops, should vim
# if file/directory doesn't exist, use mkcd
function vcd() {
    if [[ -d "$1" ]]
    then
        cd "$1";
    else
        if [[ -f "$1" ]]
        then
            vim "$1";
        else
            mkcd "$1";
        fi
    fi
}

# If not running interactively, do nothing
case $- in
    *i*) ;;
      *) return;;
esac

export DOTFILES_HOME_DIR="$HOME/.configs/dotfiles" ;
export BASHRC_HOME_DIR="$DOTFILES_HOME_DIR/bash" ;
source "$DOTFILES_HOME_DIR/vars.sh" ;

# create stored vars file if it doesn't exist, and source it
mkdir -p `dirname -- $BASHRC_STORED_VARS`;
touch $BASHRC_STORED_VARS;

source $BASHRC_STORED_VARS;

# method for storing a variable (with its _current_ value) in stored vars file
function store_dotfile_var() {
    eval "declare -p $""$1" | cut -d '' -f 3- >> $BASHRC_STORED_VARS ;
}

# keep dotfiles in sync
function sync_and_adopt_dotfiles() {
    local SCRIPT_LOC=$BASHRC_HOME_DIR'/../sync.sh' ;
    if [ - e $SCRIPT_LOC ]
    then
        chmod +x $SCRIPT_LOC ;
        bash $SCRIPT_LOC ;
    fi
}

if [ "$DOTFILES_AUTOSYNC" = "1" ]
then
    sync_and_adopt_dotfiles ;
fi

# Import various configs from the ./.bashrc.d directory
for bashrc_file in $(ls -a $BASHRC_HOME_DIR/.bashrc.d/.*\.bashrc);
do
    source "$(bashrc_file)"
done

# Respect user configs in $HOME/.bash_profile
[ -f ~/.bash_profile ] && source ~/.bash_profile

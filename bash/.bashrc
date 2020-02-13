# If not running interactively, do nothing
case $- in
    *i*) ;;
      *) return;;
esac

# these exports don't get cleaned up as they are relied upon elsewhere
export BASHRC_HOME_DIR="$HOME/.configs/dotfiles/bash" ;
export BASHRC_STORED_VARS="$HOME/.bash_stored_vars" ;

# create stored vars file if it doesn't exist
mkdir -p `dirname -- $BASHRC_STORED_VARS`;
touch $BASHRC_STORED_VARS;

source $BASHRC_STORED_VARS;

# keep dotfiles in sync
function sync_and_adopt_dotfiles() {
    local SCRIPT_LOC=$BASHRC_HOME_DIR'/../sync.sh' ;
    if [ - e $SCRIPT_LOC ]
    then
        chmod +x $SCRIPT_LOC ;
        bash $SCRIPT_LOC ;
    fi
}

if [ "$DOTFILE_AUTOSYNC" = "1" ]
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
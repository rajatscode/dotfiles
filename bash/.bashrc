# If not running interactively, do nothing
case $- in
    *i*) ;;
      *) return;;
esac

export DOTFILES_HOME_DIR="$HOME/.configs/dotfiles" ;
export BASHRC_HOME_DIR="$DOTFILES_HOME_DIR/bash" ;
source "$DOTFILES_HOME_DIR/vars.sh" ;

# Create stored vars file if it doesn't exist, and source it
mkdir -p `dirname -- $BASHRC_STORED_VARS`;
touch $BASHRC_STORED_VARS;

source $BASHRC_STORED_VARS;

# Create symlink directory if it doesn't exist
mkdir -p $ALIAS_SYMLINK_DIR;

# Method for storing a variable (with its _current_ value) in stored vars file
function store_dotfile_var() {
    eval "declare -p $""$1" | cut -d '' -f 3- >> $BASHRC_STORED_VARS ;
}

# Keep dotfiles in sync (if enabled)
function sync_and_adopt_dotfiles() {
    local SCRIPT_LOC=$BASHRC_HOME_DIR'/../sync.sh' ;
    if [ - e $SCRIPT_LOC ]
    then
        chmod +x $SCRIPT_LOC ;
        bash $SCRIPT_LOC ;
    fi
}

if [ "$DOTFILES_AUTOSYNC" = true ]
then
    sync_and_adopt_dotfiles ;
fi

# Import various configs from the ./.bashrc.d directory
for bashrc_file in $(ls -a $BASHRC_HOME_DIR/.bashrc.d/.*\.bashrc);
do
    source "$(bashrc_file)"
done

# Respect user configs in $BASH_PERSONAL_PROFILE
[ -f $BASH_PERSONAL_PROFILE ] &&
    source $BASH_PERSONAL_PROFILE

# Include $GIT_PERSONAL_PROFILE here since .gitconfig doesn't support env vars
git config --global include.path $GIT_PERSONAL_PROFILE

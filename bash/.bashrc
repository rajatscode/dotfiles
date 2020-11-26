# If not running interactively, do nothing
case $- in
    *i*) ;;
      *) return;;
esac

if [[ -z "${DOTFILES_HOME_DIR}" ]]
    then export DOTFILES_HOME_DIR="$HOME/.configs/dotfiles";
fi

export BASHRC_HOME_DIR="$DOTFILES_HOME_DIR/bash" ;
source "$DOTFILES_HOME_DIR/vars.sh" ;

# Create stored vars file if it doesn't exist, and source it
mkdir -p `dirname -- $BASHRC_STORED_VARS`;
touch $BASHRC_STORED_VARS;

alias read_dotfile_vars="source $BASHRC_STORED_VARS " ;
read_dotfile_vars ;

# Create symlink directory if it doesn't exist
mkdir -p $ALIAS_SYMLINK_DIR;

# Method for removing a variable from the stored vars file
function delete_dotfile_var() {
    local VARNAME=$1 ;
    sed -i "/declare.*"$VARNAME"=.*/d" $BASHRC_STORED_VARS ;
}

# Method for storing a variable (with its _current_ value) in stored vars file
function store_dotfile_var() {
    local VARNAME=$1 ;
    # to avoid cluttering the stored vars file, delete existing declarations
    delete_dotfile_var $VARNAME ;
    # then append the new declaration to the end of the file
    eval "declare -p "$VARNAME | cut -d '' -f 3- >> $BASHRC_STORED_VARS ;
}

# Keep dotfiles in sync (if enabled)
function sync_and_adopt_dotfiles() {
    local SCRIPT_LOC=$BASHRC_HOME_DIR'/../sync.sh' ;
    if [ -e $SCRIPT_LOC ]
    then
        chmod +x $SCRIPT_LOC ;
        bash $SCRIPT_LOC ;
    fi
}

function ensure_dotfile_syncing() {
    local SYNC_PERIOD_IN_HOURS=$1 ;
    local SYNC_CUTOFF=`date -d 'now - '$SYNC_PERIOD_IN_HOURS' hours' +%s` ;

    if [ -z $LAST_DOTFILE_SYNC ] || [ $SYNC_CUTOFF -ge $LAST_DOTFILE_SYNC ];
    then
        LAST_DOTFILE_SYNC=`date +%s` ;
        store_dotfile_var LAST_DOTFILE_SYNC ;
        (sync_and_adopt_dotfiles)> /dev/null ;
    fi
}

# Import various configs from the ./.bashrc.d directory
for bashrc_file in $(ls -a $BASHRC_HOME_DIR/.bashrc.d/.*\.bashrc);
do
    source "${bashrc_file}"
done

# Respect user configs in $BASH_PERSONAL_PROFILE
[ -f $BASH_PERSONAL_PROFILE ] &&
    source $BASH_PERSONAL_PROFILE

# Don't sync more than once a day, to avoid spawning a bunch of child shells
# Do this after loading $BASH_PERSONAL_PROFILE so DOTFILES_AUTOSYNC can be set
# in that file
if [ "$DOTFILES_AUTOSYNC" = true ]
then
    ensure_dotfile_syncing ${DOTFILES_AUTOSYNC_PERIOD_IN_HOURS:-24} ;
fi

# Include $GIT_PERSONAL_PROFILE here since .gitconfig doesn't support env vars
git config --global include.path $GIT_PERSONAL_PROFILE

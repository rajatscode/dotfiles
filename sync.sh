#!/bin/bash
# script to sync dotfiles from GitHub; runs on bash startup if environment
# variable DOTFILE_AUTOSYNC is set to 1; otherwise may be run manually
# NOTE: the first sync _has_ to be done manually, just cloning this repo will
# not affect your dotfiles

## convenience function to sync dotfiles from git
function sync_dotfiles() {
    local DOTFILE_SRC_REPO="https://github.com/rajatscode/dotfiles"
    local DOTFILE_SYNC_DIR=$1;

    git clone $DOTFILE_SRC_REPO "$DOTFILE_SYNC_DIR" &> /dev/null ||
	(git -C $DOTFILE_SYNC_DIR fetch --all &> /dev/null &&
	 git -C $DOTFILE_SYNC_DIR reset --hard origin/main &> /dev/null) ;
}

## convenience function to adopt the dotfiles in a directory
## WARNING: this will override existing dotfiles and replace them with symlinks
## to use these dotfiles alongside personal configurations:
## * for Bash, store/source your personal configs in ~/.bash_profile
## * for Vim, store/source your personal configs in ~/.vim_profile
## * for Git, store/source your personal configs in ~/.gitprofile
## * for Tmux, store/source your personal configs in ~/.tmux.profile
function adopt_dotfiles() {
    local DOTFILE_SYNC_DIR=$1;

    ln -sf "$DOTFILE_SYNC_DIR/bash/.bashrc" $HOME/.bashrc ;
    ln -sf "$DOTFILE_SYNC_DIR/git/.gitconfig" $HOME/.gitconfig ;
    ln -sf "$DOTFILE_SYNC_DIR/tmux/.tmux.conf" $HOME/.tmux.conf ;
    ln -sf "$DOTFILE_SYNC_DIR/vim/.vimrc" $HOME/.vimrc ;
}

if [[ -z "${DOTFILES_HOME_DIR}" ]]
    then DOTFILE_SYNC_DIR="${HOME}/.configs/dotfiles" ;
    else DOTFILE_SYNC_DIR="${DOTFILES_HOME_DIR}" ;
fi
sync_dotfiles $DOTFILE_SYNC_DIR ;
adopt_dotfiles $DOTFILE_SYNC_DIR ;
unset DOTFILE_SYNC_DIR ;

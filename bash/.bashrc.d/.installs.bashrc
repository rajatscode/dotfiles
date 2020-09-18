# configs to install dependencies (and track where they are)
export DOTFILES_INSTALLS_DIR="$DOTFILES_HOME_DIR/.installs" ;

read_dotfile_vars; # make sure dotfile-stored-vars are consistent
## install google-java-format, which is useful for vim-codefmt

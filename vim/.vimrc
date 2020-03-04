set nocompatible
syntax on

filetype off " for Vundle purposes
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" autoshare yank registers across _all_ vim instances
Plugin 'ardagnir/united-front'

" use TabNine for autocompletion
Plugin 'zxqfl/tabnine-vim'

call vundle#end()
filetype plugin indent on " re-enable after final Vundle plugin installation

for fpath in split(glob('$DOTFILES_HOME_DIR/vim/.vimrc.d/*.vim'), '\n')
  exe 'source' fpath
endfor

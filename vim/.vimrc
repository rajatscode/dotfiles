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

" install peaksea colorscheme
Plugin 'calincru/peaksea.vim'

call vundle#end()
filetype plugin indent on " re-enable after final Vundle plugin installation

for fpath in split(glob('$DOTFILES_HOME_DIR/vim/.vimrc.d/*.vim'), '\n')
  exe 'source' fpath
endfor

" Respect user configs in $VIM_PERSONAL_PROFILE
function! SourceFileIfExists(filepath)
    if filereadable(expand(a:filepath))
        exe 'source' a:filepath
    endif
endfunction
call SourceFileIfExists($VIM_PERSONAL_PROFILE)

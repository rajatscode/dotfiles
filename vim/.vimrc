set nocompatible
syntax on

filetype off " for Vundle purposes
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" required by Vundle
Plugin 'VundleVim/Vundle.vim'

" Plugins
" autoshare yank registers across _all_ vim instances
Plugin 'ardagnir/united-front'
" install peaksea colorscheme
Plugin 'calincru/peaksea.vim'
" required for vim-codefmt
Plugin 'google/vim-maktaba'
" autoformat code
Plugin 'google/vim-codefmt'
" used to configure codefmt's maktaba flags
Plugin 'google/vim-glaive'
" day/night color shifts in vim
Plugin 'jonstoler/werewolf.vim'
" TypeScript support
Plugin 'leafgarland/typescript-vim'
" write HTML faster
Plugin 'rstacruz/sparkup'
" comment/uncomment via gcc/gc
Plugin 'tpope/vim-commentary'
" git inside vim
Plugin 'tpope/vim-fugitive'
" smart indentation
Plugin 'tpope/vim-sleuth'
" linting, inline
Plugin 'w0rp/ale'
" fast file navigation
Plugin 'wincent/command-t'
" use TabNine for autocompletion
Plugin 'zxqfl/tabnine-vim'

call vundle#end()
call glaive#Install()

" Enable codefmt's default mappings on the <Leader>= prefix
Glaive codefmt plugin[mappings]
Glaive codefmt google_java_executable="java -jar $GOOGLE_JAVA_FMT_PATH"

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

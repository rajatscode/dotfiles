set nocompatible
syntax on

filetype off " for Vundle purposes
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" access to bash aliases & bash settings
let $BASH_ENV = "~/.bashrc"

" for Vundle help, see :h vundle
" required by Vundle
Plugin 'VundleVim/Vundle.vim'

" Vim grep
" Nerd Tree
" vim-multiple-cursors
" surround.vim
" lightline
" Vimroom
" Vim-go
" Syntastic
" Git gutter

" Plugins - see .vimrc.d/plugins.vim for config/shortcuts
" required for vim-codefmt
Plugin 'google/vim-maktaba'
" required for vim-snipmate
Plugin 'MarcWeber/vim-addon-mw-utils'
" required for vim-snipmate
Plugin 'tomtom/tlib_vim'

" show git diff in the sign column
Plugin 'airblade/vim-gitgutter'
" autoshare yank registers across _all_ vim instances
Plugin 'ardagnir/united-front'
" install peaksea colorscheme
Plugin 'calincru/peaksea.vim'
" install dracula colorscheme
Plugin 'dracula/vim', { 'name': 'dracula' }
" Ctrl-P - fuzzy finder
Plugin 'ctrlpvim/ctrlp.vim'
" Golang support for vim
Plugin 'fatih/vim-go'
" isort (Python imports sort) inside vim (unlike ALE, supports config)
Plugin 'fisadev/vim-isort'
" support for textual snippets
Plugin 'garbas/vim-snipmate'
" autoformat code
Plugin 'google/vim-codefmt'
" used to configure codefmt's maktaba flags
Plugin 'google/vim-glaive'
" default snippets for vim-snipmate
Plugin 'honza/vim-snippets'
" make the status line beautiful
Plugin 'itchyny/lightline.vim'
" quickly and easily switch between buffers
Plugin 'jlanzarotta/bufexplorer'
" day/night color shifts in vim
Plugin 'jonstoler/werewolf.vim'
" TypeScript support
Plugin 'leafgarland/typescript-vim'
" expanding abbreviations
Plugin 'mattn/emmet-vim'
" emacs 'kill ring' (yank/delete w/o losing previous yanks)
Plugin 'maxbrunsfeld/vim-yankstack'
" support for a distraction free WriteRoom
Plugin 'mikewest/vimroom'
" highlight all trailing whitespace characters
Plugin 'ntpeters/vim-better-whitespace'
" file system explorer
Plugin 'preservim/nerdtree'
" write HTML faster
Plugin 'rstacruz/sparkup'
" MRU for vim (shared + clean navigation)
Plugin 'tandrewnichols/vim-rumrunner'
" multiple selection, like Sublime Text
Plugin 'terryma/vim-multiple-cursors'
" comment/uncomment via gcc
Plugin 'tpope/vim-commentary'
" git inside vim
Plugin 'tpope/vim-fugitive'
" smart indentation
Plugin 'tpope/vim-sleuth'
" simplify parentheses, brackets, and the like
Plugin 'tpope/vim-surround'
" syntax-checking
Plugin 'vim-syntastic/syntastic'
" linting, inline
Plugin 'w0rp/ale'
" fast file navigation
Plugin 'wincent/command-t'
" integrate grep like search within vim
Plugin 'yegappan/grep'
" local AI code completion via Ollama
Plugin 'gergap/vim-ollama'

call vundle#end()

filetype plugin indent on " re-enable after final Vundle plugin installation

try
  call glaive#Install()

  " Enable codefmt's default mappings on the <Leader>= prefix
  Glaive codefmt plugin[mappings]
  if (!empty($GOOGLE_JAVA_FMT_PATH))
    Glaive codefmt google_java_executable=`expand("java -jar $GOOGLE_JAVA_FMT_PATH")`
  endif
catch
endtry

" vim-ollama configuration is in ~/.vim/config/ollama.vim
" Run :Ollama config to edit settings

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

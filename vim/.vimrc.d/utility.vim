" general configurations to make life easier
set autochdir
set colorcolumn=80
set hlsearch
set ignorecase
set incsearch
set mouse=a
set number
set shiftround
set showmatch
set smartcase
set smarttab

" persistent undo functionality
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

if has('persistent_undo')
  let myUndoDir = expand(vimDir . '/undodir')
  call system('mkdir ' . vimDir)
  call system('mkdir ' . myUndoDir)
  let &undodir = myUndoDir
  set undofile
endif

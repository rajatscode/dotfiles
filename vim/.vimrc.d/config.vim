" configurations and basic settings (non-aesthetic)

" Auto-indent (default)
set ai
" Smart indent (adapt to file)
set si

" Update home directory to match open file
set autochdir

" Automatically read when a file is changed from outside
set autoread

" Make backspace work like it would be expected to
set backspace=eol,start,indent

" Turn off backups (use version control instead :-) )
set nobackup
set nowb
" Turn off swap files, too!
set noswapfile

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8
" Use Unix as the standard file type
set ffs=unix,dos,mac

" Use spaces rather than inserting tab
set expandtab
" Infer how to interpret <TAB> based on position of cursor
set smarttab

" Get rid of error sounds
set noerrorbells
set novisualbell
set t_vb=
if has("gui_macvim")
    autocmd GUIEnter * set vb t_vb=
endif

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Have vim remember 500 lines of history (default 20)
set history=500 "

" Hide (rather than close) abandoned buffers
set hid

" Options for search
" Highlight search results
set hlsearch
" If search term is all lowercase, assume case-insensitive
set ignorecase
" Enable incremental searches (as you type)
set incsearch
" Infer case-sensitivity for search (if uppercase)
set smartcase

" Performance optimization - don't redraw while executing macros
set lazyredraw

" Linebreak on textwidth
set lbr

" Turn on grep-like behavior for regex
set magic

" Make mouse useful inside vim too
set mouse=a

" When shifting, round to nearest indent
set shiftround

" Default to 4 spaces per tab
set shiftwidth=4
set tabstop=4

" Briefly jump to matching bracket when inserting bracket
set showmatch
set mat=2 " Blink for 0.2s when showing matching brackets

" Spend 500ms waiting for completion
set tm=500
set ttm=10 " For key code delays

" Enable wrapping (across lines) when navigating using h, l, or cursor keys
set whichwrap+=<,>,[,],h,l

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Turn on Wild menu (command line completion)
set wildmenu

" Wrap lines
set wrap

" Settings for buffer-switching behavior
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always show the status line
set laststatus=2

" Format the status line
" HasPaste() is true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
"
" Delete trailing white space on save
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

" aesthetic vim configurations

" Set command bar height
set cmdheight=2

" Extra margin to the left
set foldcolumn=1

" Set colorcolumn to match textwidth (default 80)
set textwidth=0
function! s:SetColorColumn()
  if &textwidth == 0
    setlocal colorcolumn=80
  else
    setlocal colorcolumn=+0
  endif
endfunction

augroup colorcolumn
    autocmd!
    autocmd OptionSet textwidth call s:SetColorColumn()
    autocmd BufEnter * call s:SetColorColumn()
augroup end

" Show line numbers
set number
" Show current position
set ruler

" Buffer of 7 lines for autoscroll
set scrolloff=7

" Enable 256 color palette in GNOME Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" Set colorscheme to dark peaksea
set background=dark
colorscheme peaksea

" Turn on syntax highlighting
syntax enable

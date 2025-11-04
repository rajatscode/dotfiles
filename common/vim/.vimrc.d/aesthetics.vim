" aesthetic vim configurations

" Set GUI font, preferring Hack & IBM Plex Mono
if has("mac") || has("macunix")
    set gfn=IBM\ Plex\ Mono:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
elseif has("win16") || has("win32")
    set gfn=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h12,Bitstream\ Vera\ Sans\ Mono:h11
elseif has("gui_gtk2")
    set gfn=IBM\ Plex\ Mono:h14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("linux")
    set gfn=IBM\ Plex\ Mono:h14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("unix")
    set gfn=Monospace\ 11
endif

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

" Set colorscheme to dark peaksea (zellner as backup)
" Note: vim-werewolf settings (in plugins.vim) should override these
silent! colorscheme zellner
silent! colorscheme peaksea
set background=dark

" Turn on syntax highlighting
syntax enable

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

" Disable scrollbars for GUI
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

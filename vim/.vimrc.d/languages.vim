" configurations to adapt to languages
augroup c
  au! " clear when reloading
  autocmd FileType c setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=80 textwidth=80
augroup END

augroup cpp
  au! " clear when reloading
  autocmd FileType cpp setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=80 textwidth=80
augroup END

augroup java
  au! " clear when reloading
  autocmd FileType java setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=120 textwidth=120
augroup END

augroup python
  au! " clear when reloading
  autocmd FileType python setlocal
    \ shiftwidth=4 softtabstop=4 expandtab
    \ colorcolumn=80 textwidth=80
    \ ai si et sta
    \ backspace=indent,eol,start fo=croql
augroup END

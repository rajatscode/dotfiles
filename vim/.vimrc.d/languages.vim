" configurations to adapt to languages
augroup c
  au!
  autocmd FileType c setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=80 textwidth=80
augroup END

augroup cpp
  au!
  autocmd FileType cpp setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=80 textwidth=80
augroup END

augroup java
  au!
  autocmd FileType java setlocal
    \ shiftwidth=2 softtabstop=2 expandtab
    \ colorcolumn=120 textwidth=120
  autocmd FileType java AutoFormatBuffer google-java-format
augroup END

let python_highlight_all = 1

" isort config for Python, with opinionated Black-compatible config
let g:vim_isort_map = '<C-i>'
let g:vim_isort_python_version = 'python3'
let g:vim_isort_config_overrides = {
  \ 'multi_line_output': 3, 'include_trailing_comma': 1,
  \ 'force_grid_wrap': 0, 'use_parentheses': 1,
  \ 'ensure_newline_before_comments': 1, 'line_length': 88,
  \ 'force_sort_within_sections': 1, 'lexicographical': 1,
  \ 'group_by_package': 1, 'combine_as_imports': 1}

" syntastic config for Python, with Black-compatible config
let g:syntastic_python_flake8_post_args = "--max-line-length 88 --extend-ignore=E203"
" ALE config for Python, with Black-compatible config
let g:ale_python_flake8_options = "--max-line-length 88 --extend-ignore=E203"

augroup python
  au!
  autocmd BufNewFile,BufRead *.jinja set syntax=htmljinja
  autocmd BufNewFile,BufRead *.mako set ft=mako

  autocmd FileType python :autocmd! BufWritePost * Isort
  autocmd FileType python AutoFormatBuffer black

  autocmd FileType python syn keyword pythonDecorator True None False self
  autocmd FileType python map <buffer> F :set foldmethod=indent<cr>
  autocmd FileType python setlocal
    \ shiftwidth=4 softtabstop=4 expandtab
    \ colorcolumn=88 textwidth=88
    \ ai si et sta
    \ backspace=indent,eol,start fo=croql

  " convenient expansions
  autocmd FileType python inoremap <buffer> $r return 
  autocmd FileType python inoremap <buffer> $i import 
  autocmd FileType python inoremap <buffer> $p print 
  autocmd FileType python inoremap <buffer> $f # --- <esc>a
  autocmd FileType python map <buffer> <leader>1 /class 
  autocmd FileType python map <buffer> <leader>2 /def 
  autocmd FileType python map <buffer> <leader>C ?class 
  autocmd FileType python map <buffer> <leader>D ?def 

  " convenient settings
  autocmd FileType python set cindent
  autocmd FileType python set cinkeys-=0#
  autocmd FileType python set indentkeys-=0#
augroup END

augroup css
  au!
  autocmd FileType css set omnifunc=csscomplete#CompleteCSS
augroup end

function! JavaScriptFold() 
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '')
    endfunction
    setl foldtext=FoldText()
endfunction

augroup javascript
  au!
  autocmd FileType javascript call JavaScriptFold()
  autocmd FileType javascript setl fen
  autocmd FileType javascript setl nocindent

  autocmd FileType javascript imap <c-t> $log();<esc>hi
  autocmd FileType javascript imap <c-a> alert();<esc>hi

  autocmd FileType javascript inoremap <buffer> $r return 
  autocmd FileType javascript inoremap <buffer> $f // --- PH<esc>FP2xi
augroup end

function! CoffeeScriptFold()
    setl foldmethod=indent
    setl foldlevelstart=1
endfunction

augroup coffeescript
  au!
  au FileType coffee call CoffeeScriptFold()
augroup end

au FileType gitcommit call setpos('.', [0, 1, 1, 0])

au FileType markdown setlocal textwidth=80

" Shell (set colors)
if exists('$TMUX') 
    if has('nvim')
        set termguicolors
    else
        set term=screen-256color 
    endif
endif

" Twig
autocmd BufRead *.twig set syntax=html filetype=html

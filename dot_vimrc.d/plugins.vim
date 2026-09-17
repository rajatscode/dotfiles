" settings for plugins (see .vimrc for list of plugins)

" bufExplorer
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

" ruMRUnner plugin
map <leader>f :RumList<CR>

" YankStack
let g:yankstack_yank_keys = ['y', 'd']

nmap <c-p> <Plug>yankstack_substitute_older_paste
nmap <c-n> <Plug>yankstack_substitute_newer_paste

" CTRL-P
let g:ctrlp_working_path_mode = 0

let g:ctrlp_map = '<c-f>'
map <leader>j :CtrlP<cr>
map <c-b> :CtrlPBuffer<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

" Emmet
" Enable all functions in all modes
let g:user_emmet_mode='a'

" snipMate
let g:snipMate = { 'snippet_version' : 1 }
" support Ctrl+J
ino <c-j> <c-r>=snipMate#TriggerSnippet()<cr>
snor <c-j> <esc>i<right><c-r>=snipMate#TriggerSnippet()<cr>

" Vim grep
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH

" NERD Tree
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

" vim-multiple-cursors
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-s>'
let g:multi_cursor_select_all_word_key = '<A-s>'
let g:multi_cursor_start_key           = 'g<C-s>'
let g:multi_cursor_select_all_key      = 'g<A-s>'
let g:multi_cursor_next_key            = '<C-s>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" surround.vim - annotate strings
vmap Si S(i_<esc>f)
au FileType mako vmap Si S"i${ _(<esc>2f"a) }<esc>

" lightline
let g:lightline = {
                  \ 'colorscheme': 'wombat',
                  \ 'active': {
                  \   'left': [ ['mode', 'paste'],
                  \             ['fugitive', 'readonly', 'filename', 'modified'] ],
                  \   'right': [ [ 'lineinfo' ], ['percent'] ]
                  \ },
                  \ 'component': {
                  \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
                  \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
                  \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
                  \ },
                  \ 'component_visible_condition': {
                  \   'readonly': '(&filetype!="help"&& &readonly)',
                  \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
                  \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
                  \ },
                  \ 'separator': { 'left': ' ', 'right': ' ' },
                  \ 'subseparator': { 'left': ' ', 'right': ' ' }
                  \ }

" Vimroom
let g:goyo_width=100
let g:goyo_margin_top = 2
let g:goyo_margin_bottom = 2
nnoremap <silent> <leader>z :Goyo<cr>

" Vim-go
let g:go_fmt_command = "goimports"

" Syntastic
let g:ale_linters = {
                  \   'javascript': ['jshint'],
                  \   'python': ['flake8'],
                  \   'go': ['go', 'golint', 'errcheck']
                  \}

nmap <silent> <leader>a <Plug>(ale_next_wrap)

" Disabling highlighting
let g:ale_set_highlights = 0

" Only run linting when saving the file
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0

" Git gutter
let g:gitgutter_enabled=0
nnoremap <silent> <leader>d :GitGutterToggle<cr>

" vim-werewolf config: DISABLED in favor of custom hourly rotation
let g:werewolf_change_automatically = 0

" Custom hourly colorscheme rotation
" Rotates through 6 colorschemes, one per hour in a 6-hour cycle
let g:hourly_colorschemes = ['tokyonight', 'jellybeans', 'dracula', 'gruvbox', 'monokai', 'ayu']

function! SetHourlyColorscheme()
    let current_hour = strftime('%H')
    let scheme_index = current_hour % len(g:hourly_colorschemes)
    let chosen_scheme = g:hourly_colorschemes[scheme_index]

    " Only change if different from current
    if !exists('g:colors_name') || g:colors_name != chosen_scheme
        try
            execute 'colorscheme ' . chosen_scheme
        catch
            " If colorscheme not found, fall back to dracula
            colorscheme dracula
        endtry
    endif
endfunction

" Set colorscheme on startup and when focus is gained
augroup HourlyColorscheme
    autocmd!
    autocmd VimEnter * call SetHourlyColorscheme()
    autocmd FocusGained * call SetHourlyColorscheme()
augroup END

" Manual command to force update
command! ColorschemeUpdate call SetHourlyColorscheme()

" YouCompleteMe - fast LSP-based completion
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']
" Disable YCM diagnostics (we have ALE for that)
let g:ycm_show_diagnostics_ui = 0
" Don't ask about loading config files
let g:ycm_confirm_extra_conf = 0

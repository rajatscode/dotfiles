" configurations providing custom handy commands

" Set "," to mapleader for additional commands
let mapleader = ","

" Saving
" Fast saving (,w)
nmap <leader>w :w!<cr>
" Sudo saving (:W)
command W w !sudo tee % > /dev/null

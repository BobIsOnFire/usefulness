syntax on
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set number relativenumber
set mouse=a
set ruler
colorscheme pablo

set number

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

syntax on
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set number relativenumber
set mouse=a
set ruler
set formatoptions-=t
set whichwrap+=<,>,[,]
colorscheme pablo-legacy

set number

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

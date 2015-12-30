set textwidth=72
set number
syntax on
set tabstop=4
set softtabstop=4
set shiftwidth=4 
set expandtab " tabs become spaces
set showcmd " show input of incomplete command
set showmatch " parenthesis/bracket matching
set incsearch " search as you enter characters
set foldenable
set foldlevelstart=3
set ruler

" autocmd BufWritePre *.pm :%s/\s\+$//e
" autocmd BufWritePre *.pl :%s/\s\+$//e
" autocmd BufWritePre *.t :%s/\s\+$//e
" autocmd BufWritePre *.sql :%s/\s\+$//e

autocmd BufWritePre * :%s/\s+$//e

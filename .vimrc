set textwidth=72
set number
syntax on
set tabstop=4 shiftwidth=4 expandtab

" autocmd BufWritePre *.pm :%s/\s\+$//e
" autocmd BufWritePre *.pl :%s/\s\+$//e
" autocmd BufWritePre *.t :%s/\s\+$//e
" autocmd BufWritePre *.sql :%s/\s\+$//e

autocmd BufWritePre * :%s/\s+$//e

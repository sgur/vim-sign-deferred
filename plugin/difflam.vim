" difflam
" Version: 0.0.1
" Author: 
" License: 

if exists('g:loaded_difflam')
  finish
endif
let g:loaded_difflam = 1

let s:save_cpo = &cpo
set cpo&vim


augroup plugin-difflam
  autocmd!
  autocmd BufRead,BufWritePost * call difflam#start(expand('<afile>', 1))
augroup END


if empty(maparg(']c', 'n'))
  nmap ]c <plug>(difflam-next-hunk)
endif
if empty(maparg('[c', 'n'))
  nmap [c <plug>(difflam-prev-hunk)
endif


nnoremap <silent> <expr> <plug>(difflam-next-hunk)
      \ &diff ? ']c' : ":\<C-u>call difflam#next_hunk(v:count1)\<CR>"
nnoremap <silent> <expr> <plug>(difflam-prev-hunk)
      \ &diff ? '[c' : ":\<C-u>call difflam#prev_hunk(v:count1)\<CR>"


nnoremap <silent> <Plug>(difflam-next-hunk)  :<C-u>call difflam#next_hunk(v:count1)<CR>
nnoremap <silent> <Plug>(difflam-prev-hunk)  :<C-u>call difflam#prev_hunk(v:count1)<CR>


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:

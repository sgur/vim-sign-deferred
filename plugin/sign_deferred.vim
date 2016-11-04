" SignDeferred
" Version: 0.1.0
" Author: sgur
" License: MIT License

if exists('g:loaded_sign_deferred')
  finish
endif
let g:loaded_sign_deferred= 1

let s:save_cpo = &cpo
set cpo&vim


augroup plugin-sign-deferred
  autocmd!
  autocmd BufReadPre,BufWritePost * call sign_deferred#start(expand('<abuf>', 1))
augroup END


command! SignDeferredEnable  call sign_deferred#enable()
command! SignDeferredDisable  call sign_deferred#disable()


" nnoremap <silent> <Plug>(sign-deferred-next-hunk)  :<C-u>call sign_deferred#next_hunk(v:count1)<CR>
" nnoremap <silent> <Plug>(sign-deferred-prev-hunk)  :<C-u>call sign_deferred#prev_hunk(v:count1)<CR>


nnoremap <silent> <expr> <plug>(sign-deferred-next-hunk)
      \ &diff ? ']c' : ":\<C-u>call sign_deferred#next_hunk(v:count1)\<CR>"
nnoremap <silent> <expr> <plug>(sign-deferred-prev-hunk)
      \ &diff ? '[c' : ":\<C-u>call sign_deferred#prev_hunk(v:count1)\<CR>"


if empty(maparg(']c', 'n'))
  nmap ]c <plug>(sign-deferred-next-hunk)
endif
if empty(maparg('[c', 'n'))
  nmap [c <plug>(sign-deferred-prev-hunk)
endif


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:

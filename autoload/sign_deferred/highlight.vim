scriptencoding utf-8



" Interface {{{1

function! sign_deferred#highlight#map() abort
  if has('vim_starting') ? hlexists('GitGutterAdd') : !empty(synIDattr(synIDtrans(hlID('GitGutterAdd')), 'fg'))
    highlight link SignDeferredInserted GitGutterAdd
    highlight link SignDeferredDelete GitGutterDelete
    highlight link SignDeferredModify GitGutterChange
  else
    highlight link SignDeferredInserted DiffAdd
    highlight link SignDeferredDelete DiffDelete
    highlight link SignDeferredModify DiffChange
  endif
endfunction


" Internal {{{1


" Initialization {{{1




" 1}}}

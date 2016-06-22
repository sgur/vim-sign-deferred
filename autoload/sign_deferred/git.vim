scriptencoding utf-8



" Internal {{{1


" Interface {{{1

function! sign_deferred#git#diff() abort
  let work_tree = fnamemodify(b:sign_deferred.dir, ':h')
  return printf('git --git-dir="%s" --work-tree="%s" diff --no-color --no-ext-diff -U0 -- %s'
        \ , b:sign_deferred.dir
        \ , work_tree
        \ , b:sign_deferred.path[len(work_tree)+1:])
endfunction


" Initialization {{{1



" 1}}}

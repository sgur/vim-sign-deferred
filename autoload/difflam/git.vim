scriptencoding utf-8



" Internal {{{1


" Interface {{{1

function! difflam#git#diff() abort
  let work_tree = fnamemodify(b:difflam.dir, ':h')
  return printf('git --git-dir="%s" --work-tree="%s" diff --no-color --no-ext-diff -U0 -- %s'
        \ , b:difflam.dir
        \ , work_tree
        \ , b:difflam.path[len(work_tree)+1:])
endfunction


" Initialization {{{1



" 1}}}

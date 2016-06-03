scriptencoding utf-8



" Internal {{{1


" Interface {{{1

function! difflam#git#diff_buffer() abort
  let work_tree = fnamemodify(b:difflam.dir, ':h')
  let fname = b:difflam.path[len(work_tree)+1:]

  let tempname1 = tempname()
  let lines = getline(1, '$')
  call writefile(lines, tempname1)
  let tempname2 = tempname()
  call writefile(systemlist(printf('git --git-dir="%s" --work-tree="%s" show HEAD:%s', b:difflam.dir, work_tree, fname)), tempname2)

  return printf('git diff --no-index --no-color --no-ext-diff -U0 -- %s %s'
        \ , tempname2, tempname1)
endfunction

function! difflam#git#diff() abort
  let work_tree = fnamemodify(b:difflam.dir, ':h')
  return printf('git --git-dir="%s" --work-tree="%s" diff --no-color --no-ext-diff -U0 -- %s'
        \ , b:difflam.dir
        \ , work_tree
        \ , b:difflam.path[len(work_tree)+1:])
endfunction


" Initialization {{{1



" 1}}}

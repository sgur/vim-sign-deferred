scriptencoding utf-8



" Internal {{{1

function! s:detect(path) abort "{{{
  return s:find_repotype(fnamemodify(a:path, ':h'))
endfunction "}}}

function! s:find_repotype(dir) "{{{
  let parent = fnamemodify(a:dir, ':h')
  if a:dir == parent
    return ['', '']
  endif
  let type = filter(map(['git'], '[v:val, printf("%s/.%s", a:dir, v:val)]'), 'isdirectory(v:val[1])')
  if !empty(type)
    return type[0]
  endif
  return s:find_repotype(parent)
endfunction "}}}

function! s:sign_diff(diff) abort "{{{
  if b:difflam.bufnr != bufnr('%') || b:difflam.path != expand('%:p:gs?\\?/?')
    echoerr 'Diff mismatch occurred:' expand('%')
    return
  endif
  let per_diff_stats = s:process_diff(a:diff)
  let [b:difflam.hunks, b:difflam.stats] = difflam#sign#sign_diff(b:difflam.bufnr, per_diff_stats)
endfunction "}}}

function! s:process_diff(diff) abort "{{{
  let stats = []
  let hunk_re = '^@@ -\(\d\+\),\?\(\d*\) +\(\d\+\),\?\(\d*\) @@'
  for line in filter(a:diff, 'v:val =~ "^@@ "')
    let inserted = []
    let modified = []
    let deleted = []
    let matches = matchlist(line, hunk_re)

    let start = str2nr(matches[3])
    let old_size = empty(matches[2]) ? 1 : str2nr(matches[2])
    let new_size = empty(matches[4]) ? 1 : str2nr(matches[4])
    if !old_size
      let inserted += range(start, start + new_size -1)
    elseif !new_size
      let deleted += [!start ? 1 : start]
    else
      let modified += range(start, start + new_size -1)
    endif
    let stats += [{
          \   'inserted': inserted
          \ , 'modified': modified
          \ , 'deleted': deleted
          \ }]
  endfor
  return stats
endfunction "}}}


" Interface {{{1

function! difflam#get_stats() abort
  if !exists('b:difflam') || !has_key(b:difflam, 'stats')
    return [-1, -1, -1]
  endif
  return b:difflam.stats
endfunction

function! difflam#start(path) abort
  let path = fnamemodify(a:path, ':p')

  if exists('b:difflam') && !b:difflam.active
    return
  endif
  let [type, dir] = s:detect(path)
  if empty(type)
    let b:difflam = {'active': 0}
    return
  endif

  let b:difflam = {
        \   'active': 1
        \ , 'type': type
        \ , 'bufnr': bufnr('%')
        \ , 'path': fnamemodify(path, ':p:gs?\\?/?')
        \ , 'dir': fnamemodify(dir, ':p:h:gs?\\?/?')
        \ , 'stats': [0, 0, 0]
        \ }
  if has('job') && has('patch-7.4.1828')
    if exists('s:job') && job_status(s:job) == 'run'
      call job_stop(s:job)
    endif
    let s:job = job_start(difflam#{type}#diff(), {'close_cb': 'difflam#callback'})
  else
    let stmp = &shelltemp
    try
      let &shelltemp = !(has('win32') && has("filterpipe")) && &shelltemp
      let diff = systemlist(difflam#{type}#diff())
      call s:sign_diff(diff)
    finally
      let &shelltemp = stmp
    endtry
  endif
endfunction

function! difflam#callback(channel) abort
  let diff = []
  while ch_status(a:channel) is# 'buffered'
    let diff += [ch_read(a:channel)]
  endwhile
  call s:sign_diff(diff)
endfunction

function! difflam#next_hunk(count) abort
  if !exists('b:difflam')
    return
  endif

  call difflam#sign#next_hunk(b:difflam.bufnr, b:difflam.hunks, a:count)
endfunction

function! difflam#prev_hunk(count) abort
  if !exists('b:difflam')
    return
  endif

  call difflam#sign#prev_hunk(b:difflam.bufnr, b:difflam.hunks, a:count)
endfunction

" Initialization {{{1

let s:sign_cache = {}


" 1}}}

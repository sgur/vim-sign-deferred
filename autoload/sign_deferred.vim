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
  if !exists('b:sign_deferred') || !get(b:sign_deferred, 'active', 0) | return | endif
  if b:sign_deferred.bufnr != bufnr('%') || b:sign_deferred.path != expand('%:p:gs?\\?/?')
    echoerr 'vim-sign-deferred: Diff mismatch occurred:' expand('%')
    return
  endif
  let per_diff_stats = s:process_diff(a:diff)
  let b:sign_deferred.hunks = sign_deferred#sign#sign_diff(b:sign_deferred.bufnr, per_diff_stats)
  let b:sign_deferred.stats = [0, 0, 0]
  for diff_stat in per_diff_stats
    let [b:sign_deferred.stats[0], b:sign_deferred.stats[1], b:sign_deferred.stats[2]] += [len(diff_stat.inserted), len(diff_stat.modified), len(diff_stat.deleted)]
  endfor
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

function! s:callback_on_error(channel, message) abort "{{{
  echoerr 'vim-sign-deferred: Job error callback invoked'
  echohl ErrorMsg
  echomsg a:message
  for [k, v] in items(ch_info(a:channel))
    echomsg k ':' v
  endfor
  echohl NONE
endfunction "}}}

function! s:callback_on_close(channel) abort "{{{
  let diff = []
  while ch_status(a:channel) is# 'buffered'
    let diff += [ch_read(a:channel)]
  endwhile
  if !empty(diff)
    call s:sign_diff(diff)
  endif

  let job = ch_getjob(a:channel)
  call filter(s:diff_jobs, 'v:val != job')
endfunction "}}}


" Interface {{{1

function! sign_deferred#get_stats() abort
  if !exists('b:sign_deferred') || !has_key(b:sign_deferred, 'stats')
    return [-1, -1, -1]
  endif
  return b:sign_deferred.stats
endfunction

function! sign_deferred#start(bufnr) abort
  if exists('b:sign_deferred') && !b:sign_deferred.active
    return
  endif

  let path = expand('#' . a:bufnr . ':p')
  let [type, dir] = s:detect(path)
  if empty(type)
    let b:sign_deferred = {'active': 0}
    return
  endif

  let b:sign_deferred = {
        \   'active': 1
        \ , 'type': type
        \ , 'bufnr': a:bufnr
        \ , 'path': fnamemodify(path, ':p:gs?\\?/?')
        \ , 'dir': fnamemodify(dir, ':p:h:gs?\\?/?')
        \ , 'stats': [0, 0, 0]
        \ }

  if has('job') && has('patch-7.4.1828')
    if has_key(s:diff_jobs, a:bufnr) && job_status(s:diff_jobs[a:bufnr]) == 'run'
      call job_stop(s:diff_jobs[a:bufnr])
    endif
    let s:diff_jobs[a:bufnr] = job_start(sign_deferred#{type}#diff(), {'close_cb': function('s:callback_on_close'), 'err_cb': function('s:callback_on_error')})
  else
    let stmp = &shelltemp
    try
      let &shelltemp = !(has('win32') && has("filterpipe")) && &shelltemp
      let diff = systemlist(sign_deferred#{type}#diff())
      call s:sign_diff(diff)
    finally
      let &shelltemp = stmp
    endtry
  endif
endfunction

function! sign_deferred#next_hunk(count) abort
  if !exists('b:sign_deferred')
    return
  endif
  call sign_deferred#sign#next_hunk(b:sign_deferred.bufnr, get(b:sign_deferred, 'hunks', []), a:count)
endfunction

function! sign_deferred#prev_hunk(count) abort
  if !exists('b:sign_deferred')
    return
  endif
  call sign_deferred#sign#prev_hunk(b:sign_deferred.bufnr, get(b:sign_deferred, 'hunks' []), a:count)
endfunction

" Initialization {{{1

let s:sign_cache = {}
let s:diff_jobs = {}

" 1}}}

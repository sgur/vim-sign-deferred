scriptencoding utf-8



" Internal {{{1
function! s:unplace_sign(stats, lnum) abort "{{{
  if has_key(a:stats, a:lnum)
    execute 'sign unplace' a:stats[a:lnum].id
  endif
endfunction "}}}

function! s:sign_id() abort "{{{
  try
    return s:sign_id_top
  finally
    let s:sign_id_top += 1
  endtry
endfunction "}}}

function! s:place_sign(bufnr, signs, line, name) abort "{{{
  if has_key(a:signs, a:line)
    if a:name == a:signs[a:line].name " already placed
      return a:signs[a:line].id
    endif
    let id = a:signs[a:line].id
  else
    let id = s:sign_id()
  endif

  execute printf('sign place %d line=%d name=%s buffer=%s',
        \ id, a:line, a:name, a:bufnr)
  return id
endfunction "}}}

function! s:raw_sign_list(bufnr) abort "{{{
  let lang = v:lang
  try
    language message C
    redir => raw_signs
    silent! execute 'sign place buffer='. a:bufnr
    redir END
    return split(raw_signs, "\n")[2:]
  finally
    silent! execute 'language message' lang
  endtry
  return []
endfunction "}}}

function! s:extract_signs(bufnr) abort "{{{
  let stats = {}

  for raw_line in s:raw_sign_list(a:bufnr)
    let lnum = str2nr(matchstr(raw_line, 'line=\zs\d\+\ze'))
    let id = str2nr(matchstr(raw_line, 'id=\zs\d\+\ze'))
    let name = matchstr(raw_line, 'name=\zs\w\+\ze')

    if name =~# '^Difflam'
      let stats[lnum] = {'name': name, 'id': id}
    endif
  endfor
  return stats
endfunction "}}}

function! s:define_sign_text() abort "{{{
  for [name, hlgroup, text] in [
        \   ['DifflamInserted', 'DifflamSignInserted', get(g:, 'difflam_sign_insert_symbol', '+')]
        \ , ['DifflamDeleteFirstLine', 'DifflamSignDelete', get(g:, 'difflam_sign_delete_first_line_symbol', '‾')]
        \ , ['DifflamDelete', 'DifflamSignDelete', get(g:, 'difflam_sign_delete_symbol', '_')]
        \ , ['DifflamModify', 'DifflamSignModify', get(g:, 'difflam_sign_modify_symbol', '!')]
        \ ]
    execute printf('sign define %s text=%s texthl=%s', name, text, hlgroup)
  endfor
endfunction "}}}


" Interface {{{1

function! difflam#sign#sign_diff(bufnr, stats) abort
  let placed_signs = s:extract_signs(a:bufnr)
  let used_signs = {}
  let hunks = []

  for stat in a:stats
    let ids = []
    for lnum in stat.inserted
      let ids += [s:place_sign(a:bufnr, placed_signs, lnum, 'DifflamInserted')]
      let used_signs[lnum] = 1
    endfor
    for lnum in stat.deleted
      let ids += [s:place_sign(a:bufnr, placed_signs, lnum, (lnum == 1 ? 'DifflamDeleteFirstLine' : 'DifflamDelete'))]
      let used_signs[lnum] = 1
    endfor
    for lnum in stat.modified
      let ids += [s:place_sign(a:bufnr, placed_signs, lnum, 'DifflamModify')]
      let used_signs[lnum] = 1
    endfor
    if !empty(ids)
      let lnums = stat.inserted + stat.deleted + stat.modified
      let hunks += [{
            \   'sign_id'  : ids[0]
            \ , 'start': min(lnums)
            \ , 'end'  : max(lnums)}]
    endif
  endfor

  call map(filter(keys(placed_signs), '!has_key(used_signs, v:val)'), 's:unplace_sign(placed_signs, v:val)')
  return hunks
endfunction

function! difflam#sign#next_hunk(bufnr, hunks, count) abort
  let lnum = line('.')
  let hunks = filter(copy(a:hunks), 'v:val.start > lnum')

  if empty(hunks)
    return
  endif

  let hunk = hunks[len(hunks) >= a:count ? a:count - 1 : -1]
  execute 'sign jump' hunk.sign_id 'buffer=' . a:bufnr
endfunction

function! difflam#sign#prev_hunk(bufnr, hunks, count) abort
  let lnum = line('.')
  let hunks = filter(copy(a:hunks), 'v:val.start < lnum')

  if empty(hunks)
    return
  endif

  let hunk = hunks[len(hunks) >= a:count ? 0 - a:count : 0]
  execute 'sign jump' hunk.sign_id 'buffer=' . a:bufnr
endfunction

" Initialization {{{1

let s:sign_id_top = 0xBEEF

highlight default link DifflamSignInserted DiffAdd
highlight default link DifflamSignDelete DiffDelete
highlight default link DifflamSignModify DiffChange

call s:define_sign_text()


" 1}}}

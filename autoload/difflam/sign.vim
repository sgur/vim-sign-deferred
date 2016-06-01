scriptencoding utf-8



" Internal {{{1
function! s:unplace_sign(stats, line) abort "{{{
  if has_key(a:stats, a:line)
    execute 'sign unplace' a:stats[a:line].id
  endif
endfunction "}}}

function! s:next_id() abort "{{{
  try
    return s:sign_id_top
  finally
    let s:sign_id_top += 1
  endtry
endfunction "}}}

function! s:place_sign(signs, line, name) abort "{{{
  if has_key(a:signs, a:line)
    if a:name == a:signs[a:line].name " already placed
      return a:signs[a:line].id
    endif
    let id = a:signs[a:line].id
  else
    let id = s:next_id()
  endif

  execute printf('sign place %d line=%d name=%s buffer=%s',
        \ id, a:line, a:name, b:difflam.bufnr)
  return id
endfunction "}}}

function! s:raw_sign_list() abort "{{{
  let lang = v:lang
  try
    language message C
    redir => raw_signs
    silent! execute 'sign place buffer='. b:difflam.bufnr
    redir END
    return split(raw_signs, "\n")[2:]
  finally
    silent! execute 'language message' lang
  endtry
  return []
endfunction "}}}

function! s:extract_signs() abort "{{{
  let stats = {}

  for raw_line in s:raw_sign_list()
    let lnum = str2nr(matchstr(raw_line, 'line=\zs\d\+\ze'))
    let id = str2nr(matchstr(raw_line, 'id=\zs\d\+\ze'))
    let name = matchstr(raw_line, 'name=\zs\w\+\ze')

    if name =~# '^Difflam'
      if has_key(stats, lnum)
        execute 'sign unplace' stats[lnum].id
      endif
      let stats[lnum] = {'name': name, 'id': id}
    endif
  endfor
  return stats
endfunction "}}}

function! s:highlight_group_init() abort "{{{
  highlight default link DifflamSignInserted  DiffAdd
  highlight default link DifflamSignDelete  DiffDelete
  highlight default link DifflamSignModify  DiffChange
  highlight default link DifflamSignModifyDelete  DifflamSignModify

  execute 'sign define DifflamInserted text=' . s:sign_insert 'texthl=DifflamSignInserted'
  execute 'sign define DifflamModify text=' . s:sign_modify 'texthl=DifflamSignModify'
  execute 'sign define DifflamDelete text=' . s:sign_delete 'texthl=DifflamSignDelete'
  execute 'sign define DifflamDeleteFirstLine text=' . s:sign_delete_first_line 'texthl=DifflamSignDelete'
endfunction "}}}


" Interface {{{1

function! difflam#sign#sign_diff(stats) abort
  let used_signs = {}
  let [inserted, modified, deleted] = [0, 0, 0]
  let hunks = []

  let stats = s:extract_signs()

  for stat in a:stats
    let ids = []
    for lnum in stat.inserted
      let ids += [s:place_sign(stats, lnum, 'DifflamInserted')]
      let used_signs[lnum] = 1
    endfor
    for lnum in stat.deleted
      let ids += [s:place_sign(stats, lnum, (lnum == 1 ? 'DifflamDeleteFirstLine' : 'DifflamDelete'))]
      let used_signs[lnum] = 1
    endfor
    for lnum in stat.modified
      let ids += [s:place_sign(stats, lnum, 'DifflamModify')]
      let used_signs[lnum] = 1
    endfor

    if !empty(ids)
      let [inserted, modified, deleted] += [len(stat.inserted), len(stat.modified), len(stat.deleted)]
      let lnums = stat.inserted + stat.deleted + stat.modified
      let hunks += [{
            \   'id'  : ids[0]
            \ , 'start': min(lnums)
            \ , 'end'  : max(lnums)}]
    endif
  endfor
  let b:difflam.hunks = hunks
  let b:difflam.stats = [inserted, modified, deleted]

  call map(filter(keys(stats), '!has_key(used_signs, v:val)'), 's:unplace_sign(stats, v:val)')
endfunction

function! difflam#sign#jump(id) abort
  execute 'sign jump' a:id 'buffer=' . b:difflam.bufnr
endfunction

" Initialization {{{1

let s:sign_id_top = 0xBEEF

let s:sign_insert = get(g:, 'difflam_sign_insert_symbol', '+')
let s:sign_delete_first_line = get(g:, 'difflam_sign_delete_first_line_symbol', '‾')
let s:sign_delete = get(g:, 'difflam_sign_delete_symbol', '_')
let s:sign_modify = get(g:, 'difflam_sign_modify_symbol', '!')

call s:highlight_group_init()

" 1}}}

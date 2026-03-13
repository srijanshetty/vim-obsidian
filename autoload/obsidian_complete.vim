" autoload/obsidian_complete.vim - Core logic for Obsidian wiki-link completion

let s:cache = []
let s:cache_time = 0
let s:vault_path = ''

" --- Vault Detection ---

function! s:FindVaultRoot() abort
  if exists('g:obsidian_vault_path') && g:obsidian_vault_path !=# ''
    return fnamemodify(g:obsidian_vault_path, ':p')
  endif

  return ''
endfunction

" --- Note Listing: Filesystem Backend ---

function! s:ListNotesFS(vault) abort
  let l:notes = []
  " Prefer ag for speed, fall back to find
  if executable('ag')
    let l:cmd = 'ag -g "\.md$" ' . shellescape(a:vault)
  else
    let l:cmd = 'find ' . shellescape(a:vault) . ' -name "*.md" -not -path "*/.obsidian/*" -not -path "*/.trash/*"'
  endif

  let l:files = systemlist(l:cmd)
  if v:shell_error
    return []
  endif

  let l:vault_prefix = a:vault
  if l:vault_prefix[-1:] !=# '/'
    let l:vault_prefix .= '/'
  endif

  for l:f in l:files
    " Skip .obsidian/ and .trash/ internal dirs
    if l:f =~# '/\.obsidian/' || l:f =~# '/\.trash/'
      continue
    endif

    " Strip vault prefix and .md extension
    let l:rel = substitute(l:f, '^' . escape(l:vault_prefix, '/\'), '', '')
    let l:rel = substitute(l:rel, '\.md$', '', '')

    " Get just the filename (without path) for the link text
    let l:name = fnamemodify(l:rel, ':t')

    call add(l:notes, {'name': l:name, 'path': l:rel})
  endfor

  return l:notes
endfunction

" --- Note Listing: Obsidian CLI Backend ---

function! s:ListNotesCLI(vault) abort
  if !executable('obsidian')
    return []
  endif

  " Use `obsidian files` to list notes; parse output
  let l:output = systemlist('obsidian files --vault ' . shellescape(a:vault) . ' 2>/dev/null')
  if v:shell_error
    return []
  endif

  let l:notes = []
  for l:line in l:output
    let l:line = substitute(l:line, '\.md$', '', '')
    let l:name = fnamemodify(l:line, ':t')
    call add(l:notes, {'name': l:name, 'path': l:line})
  endfor

  return l:notes
endfunction

" --- Note Listing: Dispatcher ---

function! s:ListNotes() abort
  let l:vault = s:FindVaultRoot()
  if l:vault ==# ''
    echohl WarningMsg | echo 'obsidian-complete: Set g:obsidian_vault_path to enable completion' | echohl None
    return []
  endif
  let s:vault_path = l:vault

  " Check cache
  if g:obsidian_cache_ttl > 0 && !empty(s:cache) && (localtime() - s:cache_time) < g:obsidian_cache_ttl
    return s:cache
  endif

  let l:backend = g:obsidian_backend

  if l:backend ==# 'auto'
    let l:notes = s:ListNotesCLI(l:vault)
    if empty(l:notes)
      let l:notes = s:ListNotesFS(l:vault)
    endif
  elseif l:backend ==# 'cli'
    let l:notes = s:ListNotesCLI(l:vault)
  else
    let l:notes = s:ListNotesFS(l:vault)
  endif

  " Sort alphabetically by name
  call sort(l:notes, {a, b -> a.name < b.name ? -1 : a.name > b.name ? 1 : 0})

  " Update cache
  let s:cache = l:notes
  let s:cache_time = localtime()

  return l:notes
endfunction

" --- Completion Function ---

function! obsidian_complete#Complete(findstart, base) abort
  if a:findstart
    " Locate the start of the [[ link
    let l:line = getline('.')
    let l:col = col('.') - 1

    " Walk back to find [[
    let l:start = l:col
    while l:start > 0
      if l:line[l:start - 2 : l:start - 1] ==# '[['
        return l:start
      endif
      let l:start -= 1
    endwhile

    " No [[ found
    return -3
  endif

  " Second pass: find matches
  let l:notes = s:ListNotes()
  let l:matches = []
  let l:query = tolower(a:base)

  for l:note in l:notes
    let l:match_name = tolower(l:note.name)
    let l:match_path = tolower(l:note.path)

    " Fuzzy-ish match: all query chars must appear in order
    if s:FuzzyMatch(l:query, l:match_name) || s:FuzzyMatch(l:query, l:match_path)
      let l:word = g:obsidian_show_path && l:note.path !=# l:note.name
            \ ? l:note.path
            \ : l:note.name

      call add(l:matches, {
            \ 'word': l:word,
            \ 'abbr': l:note.name,
            \ 'menu': l:note.path !=# l:note.name ? '[' . fnamemodify(l:note.path, ':h') . ']' : '',
            \ 'dup': 1,
            \ })

      if len(l:matches) >= g:obsidian_max_results
        break
      endif
    endif
  endfor

  return l:matches
endfunction

" --- Fuzzy Matching ---

function! s:FuzzyMatch(query, target) abort
  if a:query ==# ''
    return 1
  endif

  let l:qi = 0
  let l:ti = 0
  let l:qlen = len(a:query)
  let l:tlen = len(a:target)

  while l:qi < l:qlen && l:ti < l:tlen
    if a:query[l:qi] ==# a:target[l:ti]
      let l:qi += 1
    endif
    let l:ti += 1
  endwhile

  return l:qi >= l:qlen
endfunction

" --- Public API ---

function! obsidian_complete#ClearCache() abort
  let s:cache = []
  let s:cache_time = 0
  echo 'obsidian-complete: Cache cleared'
endfunction

function! obsidian_complete#Refresh() abort
  call obsidian_complete#ClearCache()
  let l:notes = s:ListNotes()
  echo 'obsidian-complete: Loaded ' . len(l:notes) . ' notes from ' . s:vault_path
endfunction

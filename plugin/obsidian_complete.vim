" obsidian_complete.vim - Autocomplete [[wiki-links]] from Obsidian vault
" Maintainer: Generated for srijan
" License: MIT

if exists('g:loaded_obsidian_complete')
  finish
endif
let g:loaded_obsidian_complete = 1

" --- Configuration ---
" Path to vault (required)
" let g:obsidian_vault_path = '/path/to/vault'

" Backend: 'auto', 'cli', or 'fs'
"   auto - try CLI first, fall back to filesystem
"   cli  - use `obsidian` CLI (requires desktop app running)
"   fs   - scan .md files directly (fast, no dependencies)
let g:obsidian_backend = get(g:, 'obsidian_backend', 'fs')

" Include relative path from vault root in completion (0 = filename only)
let g:obsidian_show_path = get(g:, 'obsidian_show_path', 1)

" Cache duration in seconds (0 = no cache)
let g:obsidian_cache_ttl = get(g:, 'obsidian_cache_ttl', 30)

" Max results to show
let g:obsidian_max_results = get(g:, 'obsidian_max_results', 50)

" --- Auto-commands ---
augroup ObsidianComplete
  autocmd!
  autocmd FileType markdown setlocal completefunc=obsidian_complete#Complete
  autocmd FileType markdown inoremap <buffer> [[ [[<C-x><C-u>
augroup END

" --- Commands ---
command! ObsidianClearCache call obsidian_complete#ClearCache()
command! ObsidianRefresh call obsidian_complete#Refresh()

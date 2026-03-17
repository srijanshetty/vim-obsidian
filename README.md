*obsidian_complete.txt*  Autocomplete [[wiki-links]] from Obsidian vault

==============================================================================
CONTENTS                                          *obsidian-complete-contents*

    1. Overview .......................... |obsidian-complete-overview|
    2. Installation ...................... |obsidian-complete-install|
    3. Configuration ..................... |obsidian-complete-config|
    4. Usage ............................. |obsidian-complete-usage|
    5. Commands .......................... |obsidian-complete-commands|

==============================================================================
1. OVERVIEW                                       *obsidian-complete-overview*

Provides insert-mode autocompletion for Obsidian-style [[wiki-links]] in
markdown files. Typing `[[` triggers a completion popup with note names from
your Obsidian vault.

Supports two backends:
- Filesystem scanning (fast, default) using ag/find
- Obsidian CLI (requires desktop app running)

==============================================================================
2. INSTALLATION                                   *obsidian-complete-install*

With vim-plug: >
    Plug 'srijanshetty/vim-obsidian'

With lazy.nvim: >
    { 'srijanshetty/vim-obsidian', ft = 'markdown' }

Manual: copy plugin/ and autoload/ dirs into ~/.vim/

==============================================================================
3. CONFIGURATION                                  *obsidian-complete-config*

                                                  *g:obsidian_vault_path*
g:obsidian_vault_path ~
    Explicit vault path. This is required. If unset, the plugin does not
    scan the filesystem and completion stays disabled.

                                                  *g:obsidian_backend*
g:obsidian_backend ~
    Backend for listing notes. Values: 'fs' (default), 'cli', 'auto'.
    'auto' tries CLI first, falls back to filesystem.

                                                  *g:obsidian_show_path*
g:obsidian_show_path ~
    Include the relative path from vault root in the completion word.
    Set to 0 to insert only the filename. Default: 1.

                                                  *g:obsidian_cache_ttl*
g:obsidian_cache_ttl ~
    Seconds to cache the note list. Default: 30. Set to 0 to disable.

                                                  *g:obsidian_max_results*
g:obsidian_max_results ~
    Maximum completion results shown. Default: 50.

==============================================================================
4. USAGE                                          *obsidian-complete-usage*

In insert mode in a markdown file, type `[[` to trigger completion.
Start typing to fuzzy-filter results. Select with <C-n>/<C-p>, confirm
with <CR> or <C-y>, then type `]]` to close the link.

You can also manually trigger with <C-x><C-u> after `[[`.

==============================================================================
5. COMMANDS                                       *obsidian-complete-commands*

:ObsidianClearCache                               *:ObsidianClearCache*
    Clear the cached note list.

:ObsidianRefresh                                  *:ObsidianRefresh*
    Clear cache and reload all notes. Reports count.

==============================================================================
vim:tw=78:ts=8:ft=help:norl:

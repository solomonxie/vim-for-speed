" DESC: SHOWS A GIT DIFF IN THE SIGN COLUMN. IT SHOWS WHICH LINES HAVE BEEN ADDED, MODIFIED, OR REMOVED.
"
" {{{{{{SUPER SLOW FOR BIG JSON FILES!!!!!!}}}}}}
"
" if executable('git')
" endif

"Feature: Shwo diff inline
"REF: https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter', {'commit': '90b7520'}

set updatetime=1000
let g:gitgutter_enabled = 1
let g:gitgutter_diff_base = 'HEAD'
let g:gitgutter_max_signs = 500
let g:gitgutter_realtime = 1
let g:gitgutter_async = 1
let g:gitgutter_use_location_list = 1
let g:gitgutter_highlight_linenrs = 1  "highlight line number only
let g:gitgutter_preview_win_floating = 1  "for vim compatible let g:gitgutter_terminal_reports_focus = 0
" let g:gitgutter_map_keys = 0  "Cancel pre-set mapping
let g:gitgutter_highlight_lines = 0  "GitHub-like line bg, toggle with `:GitGutterLineHighlightsToggle`
" let g:gitgutter_diff_relative_to = 'working_tree'


" UI
let g:gitgutter_sign_added = '▎'  "The char '▎' is shown as a highlight bar
let g:gitgutter_sign_modified = '▎'  "The char '▎' is shown as a highlight bar
let g:gitgutter_sign_removed = '▎'  "The char '▎' is shown as a highlight bar
" let g:gitgutter_sign_added = '+'
" let g:gitgutter_sign_modified = '~'
" let g:gitgutter_sign_removed = '-'
highlight GitGutterAdd guifg=green ctermfg=green
highlight GitGutterChange guifg=yellow ctermfg=yellow
highlight GitGutterDelete guifg=red ctermfg=red
" Line bg for added/changed lines. Removed lines no longer exist in the buffer,
" so gitgutter would paint the line *below* them; keep that one blank and rely
" on the red sign instead. Re-applied on ColorScheme since `colorscheme` runs
" later in nvimrc and clears highlights.
function! s:GitGutterLineColors() abort
    highlight GitGutterAddLine          ctermbg=22 guibg=#1a3a24
    highlight GitGutterChangeLine       ctermbg=58 guibg=#3a3a1a
    highlight GitGutterDeleteLine       ctermbg=NONE guibg=NONE
    highlight GitGutterChangeDeleteLine ctermbg=58 guibg=#3a3a1a
endfunction
call s:GitGutterLineColors()
autocmd ColorScheme * call s:GitGutterLineColors()


" >> KEY MAPPINGS
nnoremap gz :GitGutterFold<CR>
nnoremap gp :GitGutterPrevHunk<CR>
nnoremap gn :GitGutterNextHunk<CR>
nnoremap gP :GitGutterPreviewHunk<CR>
" nnoremap gn :GitGutterNextHunk<CR>
" nnoremap gp :GitGutterPrevHunk<CR>
" nnoremap gP :GitGutterPreviewHunk<CR>

" Diff base comes from g:git_diff_base (see GitDiffBase() in vimrc-functions.vim, loaded later)
autocmd User GitDiffBaseChanged let g:gitgutter_diff_base = GitDiffBase() | silent! GitGutterAll

" Aoivd hanging when loading big files
autocmd BufEnter * call Disable_plugins()

" Fixes an error on lost focus, but also clears signs on every leave -- annoying
" autocmd FocusLost * GitGutterDisable
" autocmd FocusGained * GitGutterEnable

" Only this buffer: GitGutterDisable turned it off in every buffer until vim restarted
function! Disable_plugins()
    if line('$') > 2000
        execute "GitGutterBufferDisable"
    elseif strlen(getline('.')) > 2000
        execute "GitGutterBufferDisable"
    endif
endfunction


" ============= End of File ==================
echom 'Loaded ' . expand('<sfile>:t') |redraw

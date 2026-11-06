" --- Any Jump - Reference/Usage search ---
"
"IDE madness without overhead for 40+ languages
"Vim plugin for jumping to defitinitions and references/usages through nice ui.
"nvim 0.4+ or vim 8.2+ required
"Based on syntax rules for 40 languages and fast regexp engines like ripgrep and ag.
"Required rg or ag to be installed.

"REF: https://github.com/pechorin/any-jump.vim
Plug 'pechorin/any-jump.vim', {'commit': 'f95674d'}

" KEY MAPPINGS
nnoremap fu :AnyJump<CR>

"Disable preset key mappings
let g:any_jump_disable_default_keybindings = 1
let g:any_jump_disable_vcs_ignore = 1

let g:any_jump_list_numbers = 1
let g:any_jump_references_enabled = 1
let g:any_jump_grouping_enabled = 0  "Press T to toggle
let g:any_jump_preview_lines_count = 5
let g:any_jump_max_search_results = 7
let g:any_jump_search_prefered_engine = 'ag'  "rg|ag
let g:any_jump_results_ui_style = 'filename_first'  "filename_fist|filename_last
let g:any_jump_remove_comments_from_results = 1

" Important
let g:any_jump_references_only_for_current_filetype = 0
let g:any_jump_ignored_files = ['*.tmp', '*.temp', '*.log', '*.json', '*.yaml']

" Hide test files from the results (on by default; X in the results window toggles)
let s:any_jump_test_globs = ['tests/**', 'test/**', '__tests__/**', 'test_*.py', '*_test.py', '*_test.go', '*.test.*', '*.spec.*', 'conftest.py']
let s:any_jump_base_ignores = copy(g:any_jump_ignored_files)
let g:any_jump_hide_tests = get(g:, 'any_jump_hide_tests', 1)

function! s:AnyJumpApplyTestFilter() abort
    let g:any_jump_ignored_files = s:any_jump_base_ignores + (g:any_jump_hide_tests ? s:any_jump_test_globs : [])
endfunction
call s:AnyJumpApplyTestFilter()

" Results window: flip the filter and rerun the keyword from the source window
function! s:AnyJumpToggleTests() abort
    let g:any_jump_hide_tests = !g:any_jump_hide_tests
    call s:AnyJumpApplyTestFilter()
    let l:keyword = exists('t:any_jump') ? t:any_jump.keyword : ''
    call g:AnyJumpHandleClose()
    if !empty(l:keyword)
        execute 'AnyJumpArg ' . l:keyword
    endif
    echo 'AnyJump: test files ' . (g:any_jump_hide_tests ? 'hidden' : 'shown')
endfunction

augroup AnyJumpTests
    autocmd!
    autocmd FileType any-jump nnoremap <buffer> <silent> X :call <SID>AnyJumpToggleTests()<CR>
augroup END


" Any-jump window size & position options
let g:any_jump_window_width_ratio  = 0.7
let g:any_jump_window_height_ratio = 0.6
let g:any_jump_window_top_offset   = 4

" let g:any_jump_keyword_match_cursor_mode', 'word'


" ============= End of File ==================
echom 'Loaded ' . expand('<sfile>:t') |redraw

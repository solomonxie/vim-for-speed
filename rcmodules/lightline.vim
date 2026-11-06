"REF: https://github.com/itchyny/lightline.vim
"REF: https://github.com/itchyny/lightline.vim/blob/master/colorscheme.md
Plug 'itchyny/lightline.vim', {'commit': 'e358557'}

set noshowmode  "hide --INSERT--
set laststatus=2 " startup the lightline.vim

" let g:lightline = {'colorscheme': 'one'}  "wombat|one|solarized|papercolor|deus
let g:lightline = {
  \ 'colorscheme': 'deus',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'gitbranch', 'modified', 'filetype', 'projectpath', 'spell' ],
  \   ],
  \   'right': [ [ 'lineinfo' ],
  \              [ 'percent' ],
  \              [ 'mycustom1', 'modified' ],
  \   ]
  \ },
  \ 'component': {
  \   'mycustom1': 'me',
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead',
  \   'readonly': 'FuncLightlineReadonly',
  \   'lineinfo': 'LightlineLineinfo',
  \   'projectpath': 'LightlineProjectPath',
  \ },
\}

" components: 'fileformat', 'fileencoding', 'filetype'

let g:lightline.separator = { 'left': '', 'right': '' }
let g:lightline.subseparator = { 'left': '|', 'right': '|' }

function! FuncLightlineReadonly()
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction

" Path relative to the git root of cwd, else full; independent of how the buffer was opened
let s:project_roots = {}  "Cache: cwd -> project root
function! s:ProjectRoot() abort
    let l:cwd = getcwd()
    if !has_key(s:project_roots, l:cwd)
        let l:root = trim(system('git -C ' . shellescape(l:cwd) . ' rev-parse --show-toplevel 2>/dev/null'))
        let s:project_roots[l:cwd] = resolve(v:shell_error == 0 && isdirectory(l:root) ? l:root : l:cwd)
    endif
    return s:project_roots[l:cwd]
endfunction

function! LightlineProjectPath() abort
    if &buftype !=# '' | return expand('%:t') | endif
    if expand('%') ==# '' | return '[No Name]' | endif
    let l:path = resolve(expand('%:p'))
    let l:root = s:ProjectRoot() . '/'
    if stridx(l:path, l:root) == 0
        return l:path[len(l:root):]
    endif
    return fnamemodify(expand('%:p'), ':~')
endfunction

"REF: https://yeripratama.com/blog/customizing-vim-lightline/
function! LightlineLineinfo() abort  "abort: stop function as soon as error occurs
    if winwidth(0) < 86
        return ''
    endif

    "Lines
    let l:cur_line = printf('%-2s', line('.'))
    let l:max_line = printf('%-2s', line('$'))
    let l:line_display = 'L:' . l:cur_line . '/' . l:max_line

    "Columns
    let l:cur_col = printf('%-2s', col('.'))
    let l:max_col = printf('%-2s', col('$'))
    let l:col_display = 'C:' . l:cur_col . '/' . l:max_col

    "Word Count
    let l:wc = 'W:' . printf('%-2s', wordcount().words)

    let l:lineinfo = l:col_display . ' ' . l:line_display . ' ' . l:wc
    return l:lineinfo
endfunction


function! LightLineSelectionInfo() abort
    let l:line_count = line("'>") - line("'<") + 1
    let l:select_info = 'S:' . l:line_count
    return l:select_info
endfunction


" ============= End of File ==================
echom 'Loaded ' . expand('<sfile>:t') |redraw

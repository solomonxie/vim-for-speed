"------Vim (not Neovim) config: standalone replica of nvimrc.vim minus Neovim-only parts---------
" No Lua, LSP, Treesitter or nvim-cmp. Install: install.sh vim (links ~/.vimrc here)

" DEFINE AT TOP BEFORE PLUGINS REGISTER
let mapleader = ","

" --- VIM-PLUG MANAGER FOR PLUGINS ---
" https://github.com/junegunn/vim-plug
if !filereadable(expand('~/.vim/autoload/plug.vim'))
    echo 'Downloading vim-plug manager...'
    call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
endif

call plug#begin('~/.vim/plugged')
Plug 'solomonxie/badwolf'


" ==================== PLUGIN: perf_profiling ====================
" TIPS:
" - :StartupTime ~/foo.vim 100
" - :StartupTime 100 -- -u ~/foo.vim -i NONE -- ~/foo.vim
" - $ time vim +q
" - $ vim +StartupTime
" - $ vim --startuptime startup.txt startup.txt
" - $ vim -D  # Step debugging mode

"REF: https://codeinthehole.com/tips/debugging-vim-by-example/#why-is-vim-slow-to-start-up


" REF: https://github.com/tweekmonster/startuptime.vim
Plug 'tweekmonster/startuptime.vim', {'commit': 'dfa57f5'}   "VIM loading analysis


"REF: https://thoughtbot.com/blog/profiling-vim
" :profile start profile.log
" :profile func *
" :profile file *
" " At this point do slow actions
" :profile pause
" :qall!


" ========== HOW TO PROFILE ANY ACTION =========
" :profile start /tmp/vim_profile.log
" :profile func *
" :profile file *
" do something...
" :profile pause
" do something else...
" :profile stop

" " PUT THESE LINES AT THE BOTTOM OF VIMRC
" " :profile pause
" " :qall!
" augroup PauseProfiling
"     autocmd!
"     autocmd VimEnter * profile pause
"     " autocmd VimEnter * qall!
" augroup end


" ==================== PLUGIN: misc ====================
" https://github.com/mbbill/undotree
Plug 'mbbill/undotree', {'commit': '178d19e'}
nnoremap <LocalLeader>d :UndotreeToggle<CR>:UndotreeFocus<CR>

"REF: https://github.com/machakann/vim-highlightedyank
Plug 'machakann/vim-highlightedyank', {'commit': '285a614'}
let g:highlightedyank_highlight_duration = 1000

Plug 'bronson/vim-visual-star-search', {'commit': '7c32edb'}

"REF: https://github.com/kassio/neoterm
" Plug 'kassio/neoterm'  "For Terminal

" Plug 'tomtom/tcomment_vim'  "2ms

"REF: https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary', {'commit': '64a654e'}  "Blazing fast!!
" On ,c instead of gc, same as the Neovim config.
" The plugin adds its own gc/gcc/gcu maps unless gc is taken, so gc is held by a <Nop>
" (it also replaces nvim's built-in gc).
nnoremap gc <Nop>
xmap <leader>c  <Plug>Commentary
nmap <leader>c  <Plug>Commentary
omap <leader>c  <Plug>Commentary
nmap <leader>cc <Plug>CommentaryLine
nmap <leader>cu <Plug>Commentary<Plug>Commentary
autocmd FileType sql setlocal commentstring=--\ %s

"REF: https://github.com/bronson/vim-trailing-whitespace
Plug 'bronson/vim-trailing-whitespace', {'commit': '5540b3f'}

"REF: https://github.com/wsdjeg/vim-fetch
" Plug 'wsdjeg/vim-fetch'  "Open/Edit file from reference: /path/to/file:190:3

"REF: https://github.com/rbgrouleff/bclose.vim
Plug 'rbgrouleff/bclose.vim', {'commit': '99018b4'}  "CLOSE BUF WITHOUT CLOSING WINDOW


"REF: https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround', {'commit': '3d188ed'}  "Add brackets/quotesAdd brackets/quotes



"REF: https://github.com/andymass/vim-matchup
" Plug 'andymass/vim-matchup'

"REF: https://github.com/mechatroner/rainbow_csv
"Plug 'mechatroner/rainbow_csv'

"REF: https://github.com/chrisbra/csv.vim
" Plug 'chrisbra/csv.vim'

"REF: https://github.com/airblade/vim-rooter
"Plug 'airblade/vim-rooter'
"" autocmd BufEnter * :Rooter
"let g:rooter_patterns = ['.git', 'Makefile', 'envfile*']
"let g:rooter_change_directory_for_non_project_files = 'current'
"let g:rooter_silent_chdir = 0
"let g:rooter_resolve_links = 1

"REF: https://github.com/mattn/emmet-vim
" Plug 'mattn/emmet-vim'  "Not working


"REF: https://github.com/Shatur/neovim-session-manager
"Plug 'Shatur/neovim-session-manager'

"REF: https://github.com/mhinz/vim-signify
" Plug 'mhinz/vim-signify'  "Git Diff

"REF: https://github.com/machakann/vim-swap
" Plug 'machakann/vim-swap'  "SWAP FUNCTION ARGUMENTS

"REF: https://github.com/svermeulen/vim-yoink
" Plug 'svermeulen/vim-yoink'  "Keep yank history
" let g:yoinkMaxItems = 100

" Plug 'mhinz/vim-startify'  " Welcome screen -> SLOW

" Plug 'yegappan/mru'

" Plug 'dhruvasagar/vim-zoom'  "Zoom window

" Plug 'justinmk/vim-sneak'
" let g:sneak#label = 1


"REF: https://github.com/lifepillar/pgsql.vim
" Plug 'lifepillar/pgsql.vim'

"REF: https://github.com/mg979/vim-visual-multi
" Plug 'mg979/vim-visual-multi'


"REF: https://github.com/rstacruz/vim-closer
" Plug 'rstacruz/vim-closer'

"REF: https://github.com/mg979/vim-visual-multi
"Note: Will mess up with many key mappings
"Plug 'mg979/vim-visual-multi'

"REF: https://github.com/kshenoy/vim-signature
" Plug 'kshenoy/vim-signature', {'commit': '6bc3dd1'}
" nnoremap fm :SignatureListBufferMarks<CR>

" Plug 'tpope/vim-obsession'  "Messing up the buffer behaviors





"REF: https://github.com/hashivim/vim-terraform
" Syntax highlighting for Terraform
Plug 'hashivim/vim-terraform', {'commit': '520498f'}


" ==================== PLUGIN: buftabline ====================
"REF: https://github.com/ap/vim-buftabline
Plug 'ap/vim-buftabline', {'commit': '6cdb6ae'}

let g:buftabline_show = 1  "only if there are at least two buffers
let g:buftabline_numbers = 2
let g:buftabline_indicators = v:true
let g:buftabline_separators = v:false
"let g:buftabline_plug_max = 10
let g:buftabline_indicators = v:true

" REF: CTERM COLOR PICKER ==> https://jonasjacek.github.io/colors/
"highlight XXX cterm=NONE ctermbg=15 ctermfg=8 gui=NONE guibg=#ffffff guifg=#d70000

" ==> airline-theme: 'wombat'
" REF: https://gist.github.com/iboard/5853434
" REF: https://jonasjacek.github.io/colors/
highlight BufTabLineCurrent ctermbg=192 ctermfg=0
highlight BufTabLineHidden ctermbg=235 ctermfg=191
highlight BufTabLineModifiedCurrent ctermfg=0 ctermbg=168
highlight BufTabLineModifiedActive ctermfg=0 ctermbg=214
highlight BufTabLineModifiedHidden ctermfg=0 ctermbg=222
" highlight BufTabLineCurrent ctermbg=192 ctermfg=0 cterm=none guibg=blue guifg=0
" highlight BufTabLineHidden ctermbg=235 ctermfg=191 cterm=none guibg=red guifg=191
" highlight BufTabLineModifiedCurrent ctermfg=0 ctermbg=168 cterm=none guibg=green guifg=0
" highlight BufTabLineModifiedActive ctermfg=0 ctermbg=214 cterm=none guibg=blue guifg=0
" highlight BufTabLineModifiedHidden ctermfg=0 ctermbg=222 cterm=none guibg=yellow guifg=0

" DEFAULT
"hi default link BufTabLineCurrent TabLineSel
"hi default link BufTabLineActive PmenuSel
"hi default link BufTabLineHidden TabLine
"hi default link BufTabLineFill TabLineFill
"hi default link BufTabLineModifiedCurrent BufTabLineCurrent
"hi default link BufTabLineModifiedActive BufTabLineActive
"hi default link BufTabLineModifiedHidden BufTabLineHidden


" ==================== PLUGIN: lightline ====================
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

" Path relative to the project (git root of cwd) if the file is inside it,
" otherwise the full path. Unlike %f, this doesn't depend on how the buffer was opened.
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


" ==================== PLUGIN: nerdtree ====================
" --- NERDTREE - FILE BROWSER ---

"LOAD SIGNIFICANTLY FASTER
"REF: https://github.com/preservim/nerdtree/issues/276
Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind', 'NERDTree'], 'commit': '690d061'}

" Plug 'scrooloose/nerdtree'  ", {'on': ['NERDTree', 'NERDTreeFind', 'NERDTreeToggle']}
" Plug 'jistr/vim-nerdtree-tabs'      " enhance nerdtree's tabs
" Plug 'ryanoasis/vim-devicons'       " add beautiful icons besides files
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  "Slow down vim significantly

">> Key Mappings
nnoremap <Leader>f :<C-U>call NerdTreeAtProjectRoot()<CR>
" nnoremap <Leader>F :NERDTreeFind<CR>zz
" nnoremap FF :NERDTree<CR>
nnoremap ff :<C-U>call NerdTreeFindOrRoot()<CR>zz

" Git root of the current file (symlinks resolved, so a symlinked checkout
" still matches the path NERDTreeFind resolves), else the cwd.
function! s:NerdTreeProjectRoot() abort
    let l:dir = empty(expand('%')) ? getcwd() : fnamemodify(resolve(expand('%:p')), ':h')
    let l:root = trim(system('git -C ' . shellescape(l:dir) . ' rev-parse --show-toplevel'))
    return v:shell_error == 0 && isdirectory(l:root) ? resolve(l:root) : resolve(getcwd())
endfunction

function! NerdTreeAtProjectRoot() abort
    exec 'NERDTree ' . fnameescape(s:NerdTreeProjectRoot())
endfunction

" Always rooted at the project root, then reveal the current file in it
function! NerdTreeFindOrRoot() abort
    let l:root = s:NerdTreeProjectRoot()
    " g:NERDTree is undefined until the lazy-loaded plugin's first command runs
    if !exists('g:NERDTree') || !g:NERDTree.ExistsForTab()
                \ || g:NERDTree.ForCurrentTab().root.path.str() !=# l:root
        let l:file = expand('%:p')
        exec 'NERDTree ' . fnameescape(l:root)
        if empty(l:file)
            return
        endif
        wincmd p
    elseif empty(expand('%'))
        NERDTreeFocus
        return
    endif
    NERDTreeFind
endfunction
" nnoremap <Leader>F :NERDTree %:p:h<CR>
" Add '%' for changing root accordingly
"nnoremap <Leader>f :NERDTree %:p:h<CR>
" nnoremap gd :NERDTreeFind<CR>zz
" nnoremap gD :NERDTree<CR>

">> UI settings
let NERDTreeQuitOnOpen=0   " Keep NERDTree open after opening a file
let NERDTreeMinimalUI=1    " Start NERDTree in minimal UI mode (No help lines)
let NERDTreeDirArrows=1    " Display arrows instead of ascii art in NERDTree
let NERDTreeHighlightCursorline = 1  "Conflict with other addon-plugins for nerdtree
"let NERDTreeChDirMode=2    " Change current working directory based on root directory in NERDTree
let g:NERDTreeHidden=1     " Don't show hidden files
let NERDTreeWinSize=50     " Initial NERDTree width
let NERDTreeAutoDeleteBuffer = 1  " Auto delete buffer deleted with NerdTree
"let NERDTreeShowBookmarks=0   " Show NERDTree bookmarks
let NERDTreeIgnore = ['\.pyc$', '\.swp', '\.swo', '__pycache__', 'node_modules']   " Hide temp files in NERDTree
"let g:NERDTreeShowLineNumbers=1  " Show Line Number

"let NERDTreeAutoCenter = 1  "Not working

" Open Nerdtree when there's no file opened
"autocmd vimenter * if !argc()|NERDTree|endif
" Or, auto-open Nerdtree
"autocmd vimenter * NERDTree
function NerdTreeCustom()
    echom "nerd"
    " Close NERDTree when there's no other windows
    if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree())
        q
    endif
    " Manually turn on syntax
    " syntax manual
    " set syntax=on
endfunction

autocmd FileType nerdtree call NerdTreeCustom()

" NERDTree caches its "previous buffer" number at open time and jumps back to
" it on quit. Netrw's own buffer wiping (bufhidden=wipe, CloseNetrw) can free
" that number out from under it, throwing E86. Guard with bufexists() first.
function! SafeNERDTreeQuit() abort
    if exists('b:NERDTree') && b:NERDTree.isWinTree()
                \ && b:NERDTree.previousBuf() !=# -1 && bufexists(b:NERDTree.previousBuf())
        exec 'buffer ' . b:NERDTree.previousBuf()
    elseif winnr('$') > 1
        call g:NERDTree.Close()
    else
        call nerdtree#echo('Cannot close last window')
    endif
endfunction
autocmd FileType nerdtree nnoremap <buffer> q :call SafeNERDTreeQuit()<CR>

" Pin the side tree to its window: = - :bn :bp would swap a file into it.
" Only for the side (tab) tree -- a window tree replaces itself by design.
function! s:PinNerdTreeWindow() abort
    if exists('b:NERDTree') && b:NERDTree.isTabTree()
        if exists('+winfixbuf') | setlocal winfixbuf | endif
        nnoremap <buffer> = <Nop>
        nnoremap <buffer> - <Nop>
    endif
endfunction
autocmd User NERDTreeInit call s:PinNerdTreeWindow()
" winfixbuf is window-local: reopening the tree (toggle, ,f) puts the existing
" buffer in a new window without NERDTreeInit, so re-pin it. Otherwise quickfix
" <CR> may pick the tree as the previous window and open the file there.
autocmd BufWinEnter NERD_tree_tab_* call s:PinNerdTreeWindow()

" Auto-refresh NERDTree root every second, replacing manual R press.
" Timer only runs while the NERDTree buffer is open.
let s:nerdtree_refresh_timer = -1

" A refresh re-reads the whole tree from disk (~600ms with ~1000 lines open),
" blocking j/k -- so hold it off while the cursor is moving in the tree.
let s:nerdtree_last_move = 0.0
autocmd CursorMoved NERD_tree_* let s:nerdtree_last_move = reltimefloat(reltime())

function! s:NerdTreeAutoRefresh(timer) abort
    if reltimefloat(reltime()) - s:nerdtree_last_move < 2
        return
    endif
    silent! NERDTreeRefreshRoot
    silent! call s:NerdTreeGitHighlight()
endfunction

" Highlight dirty files/folders in NERDTree. Base is GitDiffBase()
" (FUNCTIONS section), default HEAD. Git is re-queried at most every 3s.
" Own colors rather than Diff* links: badwolf's DiffChange is a near-invisible bg
function! s:NerdTreeGitHighlightColors() abort
    highlight default NERDTreeGitDirtyFile cterm=bold ctermfg=154 gui=bold guifg=#aeee00
    highlight default NERDTreeGitDirtyDir ctermfg=154 guifg=#aeee00
endfunction
call s:NerdTreeGitHighlightColors()
autocmd ColorScheme * call s:NerdTreeGitHighlightColors()
let s:git_dirty = {}
let s:git_dirty_key = ''
let s:git_dirty_at = 0.0

function! s:NerdTreeGitDirtySet(root) abort
    let l:base = exists('*GitDiffBase') ? GitDiffBase() : 'HEAD'
    let l:key = a:root . '@' . l:base
    if l:key ==# s:git_dirty_key && reltimefloat(reltime()) - s:git_dirty_at < 3
        return s:git_dirty
    endif
    let s:git_dirty_key = l:key
    let s:git_dirty_at = reltimefloat(reltime())
    let s:git_dirty = {}
    " Paths relative to the tree root (not the git toplevel) so symlinked roots match
    let l:git = 'git -C ' . shellescape(a:root) . ' '
    call system(l:git . 'rev-parse --git-dir')
    if v:shell_error != 0
        return s:git_dirty
    endif
    let l:files = systemlist(l:git . 'diff --name-only --relative ' . shellescape(l:base))
                \ + systemlist(l:git . 'ls-files --others --exclude-standard')
    for l:rel in l:files
        let l:path = a:root . '/' . l:rel
        let s:git_dirty[l:path] = 'NERDTreeGitDirtyFile'
        let l:dir = fnamemodify(l:path, ':h')
        while len(l:dir) > len(a:root) && !has_key(s:git_dirty, l:dir)
            let s:git_dirty[l:dir] = 'NERDTreeGitDirtyDir'
            let l:dir = fnamemodify(l:dir, ':h')
        endwhile
    endfor
    return s:git_dirty
endfunction

function! s:NerdTreeGitHighlight() abort
    if !g:NERDTree.IsOpen()
        return
    endif
    let l:curWin = win_getid()
    noautocmd call win_gotoid(win_getid(g:NERDTree.GetWinNum()))
    let l:dirty = s:NerdTreeGitDirtySet(b:NERDTree.root.path.str())
    let l:positions = {'NERDTreeGitDirtyFile': [], 'NERDTreeGitDirtyDir': []}
    " Skip when neither the tree nor the git set changed since last time
    let l:sig = b:changedtick . '@' . s:git_dirty_at
    if get(b:, 'nerdtree_git_hl_sig', '') ==# l:sig
        noautocmd call win_gotoid(l:curWin)
        return
    endif
    let b:nerdtree_git_hl_sig = l:sig
    " One top-down pass tracking the dir at each indent level. ui.getPath()
    " walks upward per line, which is O(n^2) and froze big trees for seconds.
    let l:ui = b:NERDTree.ui
    let l:dirs = {}
    let l:root = substitute(b:NERDTree.root.path.str(), '/$', '', '')
    let l:rootLine = l:ui.getRootLineNum()
    for l:lnum in empty(l:dirty) ? [] : range(l:rootLine + 1, line('$'))
        let l:line = getline(l:lnum)
        let l:name = l:ui._stripMarkup(l:line)
        if empty(l:name)
            continue
        endif
        let l:indent = l:ui._indentLevelFor(l:line)
        let l:isDir = l:name =~# '/$'
        let l:name = substitute(l:name, '/$', '', '')
        let l:path = get(l:dirs, l:indent - 1, l:root) . '/' . l:name
        if l:isDir
            let l:dirs[l:indent] = l:path
        endif
        let l:group = get(l:dirty, l:path, '')
        if empty(l:group)
            continue
        endif
        " Highlight just the name, not the indent/arrow/icon
        let l:col = stridx(l:line, l:name)
        if l:col >= 0
            call add(l:positions[l:group], [l:lnum, l:col + 1, strlen(l:name)])
        endif
    endfor
    for l:m in getmatches()
        if l:m.group =~# '^NERDTreeGitDirty'
            call matchdelete(l:m.id)
        endif
    endfor
    for [l:group, l:pos] in items(l:positions)
        " Older vims accept at most 8 positions per matchaddpos() call
        for l:i in range(0, len(l:pos) - 1, 8)
            call matchaddpos(l:group, l:pos[l:i : l:i + 7])
        endfor
    endfor
    noautocmd call win_gotoid(l:curWin)
endfunction

function! s:StartNerdTreeAutoRefresh() abort
    if s:nerdtree_refresh_timer ==# -1
        let s:nerdtree_refresh_timer = timer_start(1000, function('s:NerdTreeAutoRefresh'), {'repeat': -1})
    endif
endfunction

function! s:StopNerdTreeAutoRefresh() abort
    if s:nerdtree_refresh_timer !=# -1
        call timer_stop(s:nerdtree_refresh_timer)
        let s:nerdtree_refresh_timer = -1
    endif
endfunction

if has('timers')
    autocmd FileType nerdtree call s:StartNerdTreeAutoRefresh()
    " BufWinLeave stops the timer, but reshowing the buffer doesn't re-fire FileType
    autocmd BufWinEnter NERD_tree_* call s:StartNerdTreeAutoRefresh()
    autocmd BufWinLeave NERD_tree_* call s:StopNerdTreeAutoRefresh()
endif
" Open/close re-renders the buffer and shifts lines; re-highlight right away
" instead of waiting for the next timer tick (git set is cached, so this is cheap)
autocmd TextChanged NERD_tree_* silent! call s:NerdTreeGitHighlight()
" :ChangeGitDiffBase (FUNCTIONS section) -- drop the cached git set and repaint now
autocmd User GitDiffBaseChanged let s:git_dirty_key = '' | silent! call s:NerdTreeGitHighlight()


" Customize icons on Nerdtree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" Git related
" Special characters
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
\ }


" --- Customized Abilities on Nerdtree ---
" call NERDTreeAddKeyMap({
"         \ 'key': 'E',
"         \ 'callback': 'MyNerdtreeFunc',
"         \ 'quickhelpText': 'put full path of current node into the default register' })
"
" function! MyNerdtreeFunc()
"     let n = g:NERDTreeFileNode.GetSelected()
"     if n != {}
"         call setreg('"', n.path.str())
"     endif
" endfunction



" --- Vim-Devicons - Icons for Nerdtree ---
"https://github.com/ryanoasis/vim-devicons/wiki/Extra-Configuration
if &runtimepath =~ 'vim-devicons'
    let g:webdevicons_enable = 1  "Enable plugin
    let g:webdevicons_enable_nerdtree = 1
    let g:webdevicons_enable_airline_tabline = 0
    let g:webdevicons_enable_airline_statusline = 0
    set guifont=DroidSansMono_Nerd_Font:h11
endif


" --- Nerdtree Syntax Highlight ---
"https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
if &runtimepath =~ 'nerdtree-syntax-highlight'
    let g:NERDTreeFileExtensionHighlightFullName = 1
    let g:NERDTreeExactMatchHighlightFullName = 1
    let g:NERDTreePatternMatchHighlightFullName = 1
    let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
    let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
    let g:NERDTreeExtensionHighlightColor = {} " this line is needed to avoid error
    let g:NERDTreeLimitedSyntax = 1  "Disable uncommon file extensions highlighting
    " Disable
    " let g:NERDTreeDisableFileExtensionHighlight = 1
    " let g:NERDTreeDisableExactMatchHighlight = 1
    " let g:NERDTreeDisablePatternMatchHighlight = 1
endif


" Follow the current buffer: reveal it in the open tree without taking focus.
" Only for files under the tree root, so the root never jumps. Opening from the
" tree itself runs under eventignore=all and is already highlighted anyway.
let s:nerdtree_revealing = 0
function! s:NerdTreeRevealCurrent() abort
    if s:nerdtree_revealing || !exists('g:NERDTree') || !g:NERDTree.IsOpen()
                \ || exists('b:NERDTree') || &buftype !=# '' || empty(expand('%'))
        return
    endif
    " Tree may still be initializing (BufEnter mid-creation): no root yet
    let l:tree = g:NERDTree.ForCurrentTab()
    if type(l:tree) != v:t_dict
        return
    endif
    let l:file = resolve(expand('%:p'))
    let l:root = substitute(resolve(l:tree.root.path.str()), '/$', '', '')
    if !filereadable(l:file) || stridx(l:file, l:root . '/') != 0
        return
    endif
    let s:nerdtree_revealing = 1
    let l:win = win_getid()
    try
        silent NERDTreeFind
    finally
        noautocmd call win_gotoid(l:win)
        let s:nerdtree_revealing = 0
    endtry
endfunction
autocmd BufEnter * call s:NerdTreeRevealCurrent()

" Only NERDTree left in the tab:
" - after :q/:wq/ZZ (QuitPre) -> quit nvim, as before the tree stayed open.
"   Unsaved hidden buffers block the quit; show one of them instead.
" - after :bdelete (,q), which closes every window showing the buffer -> keep
"   the tree and open an empty window beside it.
" Deferred because layout changes are not allowed mid-:quit/:bdelete.
let s:nerdtree_quit_requested = 0
autocmd QuitPre * let s:nerdtree_quit_requested = 1
" QuitPre also fires for :q on a split with other windows left; drop it once idle
if exists('##SafeState')
    autocmd SafeState * let s:nerdtree_quit_requested = 0
endif

function! s:NerdTreeKeepEditWindow(quit, ...) abort
    if winnr('$') != 1 || !exists('b:NERDTree') || !b:NERDTree.isTabTree()
        return
    endif
    if a:quit
        let l:modified = filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&modified")')
        if empty(l:modified)
            quit
            return
        endif
    endif
    rightbelow vnew
    wincmd p
    exec 'vertical resize ' . g:NERDTreeWinSize
    wincmd p
    if a:quit
        exec 'buffer ' . l:modified[0]
        echohl ErrorMsg | echo 'No write since last change' | echohl None
    endif
endfunction
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree')
            \ | call timer_start(0, function('s:NerdTreeKeepEditWindow', [s:nerdtree_quit_requested]))
            \ | let s:nerdtree_quit_requested = 0 | endif


" ==================== PLUGIN: netrw ====================
"<NetRW File Tree>
" ============================================================================
" Netrw Directory Listing                                        (netrw v170)
"   ~/.config
"   Sorted by      name
"   Sort sequence: [\/]$,\<core\%(\.\d\+\)\=\>,\.h$,\.c$,\.cpp$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$
"   Hiding:        \(^\|\s\s\)\zs\.\S\+
"   Quick Help: <F1>:help  -:go up dir  D:delete  R:rename  s:sort-by  x:special
" ==============================================================================
" HELP LINKS ===>
" :help netrw-quickmap

let g:netrw_banner=1
let g:netrw_hide=1
let g:netrw_browse_split=0  " 0 = open files in netrw's own window (single-window `:e folder/` use)
let g:netrw_liststyle=0  " flat listing -- tree (3) uses a shadow "NetrwTreeListing" buffer that lingers
let g:netrw_altv = 2
let g:netrw_winsize=30
let g:netrw_list_hide = '.*\.swp$,.DS_Store,*/tmp/*,*.so,*.swp,*.zip,*.git,^\.\.\=/\=$'
" let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'


let g:netrw_fastbrowse = 0

let g:netrw_winsize = 25  " Window size 25%

function! CloseNetrw() abort
    " Sweep every netrw buffer (by filetype, name, or b:netrw_curdir) -- netrw
    " juggles multiple buffers per listing, and wiping only the current one
    " leaves the directory-named buffer behind to reseed a fresh display.
    for bufn in range(1, bufnr('$'))
        if !bufexists(bufn) | continue | endif
        if getbufvar(bufn, '&filetype') ==# 'netrw'
                    \ || bufname(bufn) =~# 'NetrwTreeListing'
                    \ || !empty(getbufvar(bufn, 'netrw_curdir'))
            silent! execute 'bwipeout! ' . bufn
        endif
    endfor
endfunction

augroup closeOnOpen
    autocmd!
    autocmd BufWinEnter * if getbufvar(winbufnr(winnr()), "&filetype") != "netrw"|call CloseNetrw()|endif
aug END

" All netrw buffer-local mappings/settings, kept in one place
augroup netrwLocal
    autocmd!
    autocmd FileType netrw setl bufhidden=wipe
    autocmd FileType netrw nmap <buffer> o <CR>
    autocmd FileType netrw nmap <buffer> p -
    " <nowait>: netrw's own qb/qf/qF/qL mappings make bare "q" an ambiguous
    " prefix otherwise (this also makes those four unreachable -- q always wins)
    autocmd FileType netrw nnoremap <buffer> <nowait> q :call CloseNetrw()<CR>
    autocmd FileType netrw if exists('b:netrw_bannercnt') | execute b:netrw_bannercnt | endif
augroup END

" nnoremap ff :silent execute "let @/=expand('%:t')<Bar>silent execute 'Lexplore' expand('%:h')<Bar>normal n"<CR>
" nnoremap <Leader>f :Lexplore .<CR>


" ==================== PLUGIN: fzf ====================
"REF: https://github.com/junegunn/fzf.vim
"
" let g:fzf_layout = { 'down': '~40%' }  " down | up | left | right

let g:fzf_preview_window = ['right:40%', 'ctrl-/']  " up|down|left|right

let $FZF_DEFAULT_OPTS='--layout=reverse --info=inline'
" --no-ignore-vcs: skip .gitignore (so .env etc. are findable); junk stays excluded via ~/.config/fd/ignore (etc/fd/ignore)
let $FZF_DEFAULT_COMMAND="fd --type f --type l --hidden --follow --no-ignore-vcs"
" command! -bang -nargs=? -complete=dir Files
"         \ call fzf#vim#files(<q-args>, { 'options': "--prompt '>' $FZF_DEFAULT_OPTS"}, <bang>0)

" let g:fzf_buffers_jump = 1  " [Buffers] Jump to the existing window if possible

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'

"let g:fzf_history_dir = '~/.vim/fzf-history'  "[History] -> will block Ctrl-n & Ctrl-p keys

"- enew / -tabnew / 10split enew
"let g:fzf_layout = { 'window': 'enew' }
"let g:fzf_layout = { 'window': '-tabnew' }
"let g:fzf_layout = { 'window': '10split enew' }


function! SpecifyFileFinderFolder(cmd)
    let s:dir = expand("%:h")
    let s:dir = input("", s:dir)
    let s:dir = substitute(s:dir, '/$', '', 'g')
    let s:full_dir = fnamemodify(s:dir, ':p')
    " echo "\nSearch scoope: ". s:dir ."\n"
    if a:cmd == 'Files'
        execute "Files " . s:dir . "/"
    elseif a:cmd == 'FZFRg'
        " RigGrep special:
        command! -bang -nargs=* FZFRg call fzf#vim#grep(
            \ "rg --hidden --column --line-number --no-heading --color=always --smart-case ". shellescape(<q-args>) . " ". s:dir,
            \ 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
        execute 'FZFRg'
    endif
endfunction

command! -bang -nargs=* FzfQuickfix call s:FzfQuickfix(<q-args>)
function! s:FzfQuickfix(query) abort
    let command = 'rg --vimgrep --no-heading --smart-case ' . shellescape(a:query)
    let result = system(command)
    let lines = split(result, "\n")
    call setqflist(map(lines, '{"filename": v:val, "lnum": str2nr(split(v:val, ":")[1]), "col": str2nr(split(v:val, ":")[2]), "text": join(split(v:val, ":")[3:], ":")}'))
    copen
endfunction

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
  copen
endfunction

"">> KEY MAPPINGS
nnoremap fd :Files<CR>
nnoremap fa :Ag<CR>
nnoremap fb :Buffers<CR>
" nnoremap fl :BLines<CR>
" nnoremap ft :BTags<CR>
nnoremap fh :History:<CR>
nnoremap fc :Commands<CR>
nnoremap fm :Marks<CR>
" nnoremap tc :History:<CR>
" nnoremap th :History<CR>
" nnoremap tm :Marks<CR>
" nnoremap ts :Snippets<CR>

nnoremap FD :call SpecifyFileFinderFolder("Files")<CR>
nnoremap FA :call SpecifyFileFinderFolder("FZFRg")<CR>
" nnoremap FC :Commands<CR>
" nnoremap gC :<C-f>

" This is the default extra key bindings
let g:fzf_action = {
    \ 'ctrl-x': function('s:build_quickfix_list'),
\}
" let g:fzf_action = {
"     \ 'ctrl-t': 'tab split',
"     \ 'ctrl-x': 'split',
"     \ 'ctrl-v': 'vsplit' ,
"     \ 'ctrl-e': 'edit' ,
" \}


">> Alter options
" let g:x_fzf_opts = {'options': [
"     \      '--layout=reverse', '--info=inline',
"     \      '--preview', '~/vim_plugged/fzf.vim/bin/preview.sh {}'
"     \ ]}
" command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir Ag call fzf#vim#ag(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir Buffers call fzf#vim#buffers(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir BTags call fzf#vim#buffer_tags(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir Marks call fzf#vim#marks(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir Snippets call fzf#vim#snippets(<q-args>, g:x_fzf_opts, <bang>0)
" command! -bang -nargs=? -complete=dir History call fzf#vim#files(<q-args>, g:x_fzf_opts, <bang>0)

" nnoremap fg :GFiles<CR>
" nnoremap fb :call fzf#vim#buffers(fzf#vim#with_preview('right:0%'))<CR>
" nnoremap fa :call fzf#vim#ag('', fzf#vim#with_preview('right'))<CR>
""nnoremap <localleader>f :Files %:p:h<CR>
"" nnoremap <M-f> :Files<CR>
"" nnoremap <LocalLeader>f :Files<CR>
"" nnoremap <localleader>H :Helptags<CR>
"" nnoremap <localleader>h :History<CR>
"" nnoremap <localleader>c :History:<CR>
"" nnoremap <localleader>/ :History/<CR>
"" nnoremap <localleader>p :Snippets<CR>
"" nnoremap <localleader>C :BCommits<CR>
"" nnoremap <localleader>b :Buffers<CR>
"" nnoremap <localleader>t :Tags<CR>
"" nnoremap <LocalLeader>a :Ag<CR>
"" nnoremap <localleader>m :Marks<CR>
""nnoremap <localleader>p/ :Files ..
""nnoremap <localleader>color/ :Colors
""nnoremap <localleader>k/ :Maps<CR>
"nnoremap fd :Files<CR>
"" nnoremap fg :GFiles<CR>
"nnoremap fb :call fzf#vim#buffers(fzf#vim#with_preview('right:0%'))<CR>
"nnoremap ft :Tags<CR>
"nnoremap fc :History:<CR>
"nnoremap fC :Commands<CR>
"nnoremap fh :History<CR>
"nnoremap fa :Rg<CR>
"nnoremap fm :Marks<CR>
"" nnoremap fa :call fzf#vim#ag('', fzf#vim#with_preview('right'))<CR>
"nnoremap fs :Snippets<CR>
"" nnoremap fS :History/<CR>
"" nnoremap fm :Marks<CR>


" [Rg] Set preview window
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep(
"   \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
"   \   fzf#vim#with_preview(), <bang>0)

" " [Rg] disable matching file path
" command! -bang -nargs=* Rg
"     \ call fzf#vim#grep(
"     \   "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
"     \   {'options': '--delimiter : --nth 4..'}, <bang>0)

" [Ag] disable matching file path
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)


" MUST BE PLACED AFTER SETTINGS
"REF: https://github.com/junegunn/fzf.vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all', 'commit': '3f94bcb'}
Plug 'junegunn/fzf.vim', {'commit': 'ddc14a6'}
" Plug 'chengzeyi/fzf-preview.vim'


" ==================== PLUGIN: anyjump ====================
" --- Any Jump - Reference/Usage search ---
"
"IDE madness without overhead for 40+ languages
"Vim plugin for jumping to defitinitions and references/usages through nice ui.
"vim 8.2+ required
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


" Any-jump window size & position options
let g:any_jump_window_width_ratio  = 0.7
let g:any_jump_window_height_ratio = 0.6
let g:any_jump_window_top_offset   = 4

" let g:any_jump_keyword_match_cursor_mode', 'word'


" ==================== PLUGIN: autopairs ====================
"REF: https://github.com/jiangmiao/auto-pairs
Plug 'jiangmiao/auto-pairs', {'commit': '39f06b8'} "Smartest (bug:)

" KEY MAPPINGS
"imap <C-d> <Meta>
"imap <C-d>e <M-e>

let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', "`":"`", '```':'```', '"""':'"""', "'''":"'''",'<!--': '-->', '<%': '%>'}
"Fly mode
let g:AutoPairsFlyMode = 0
"Options
let g:AutoPairsMultilineClose = 0 "Solve bug of deleting pair
let g:AutoPairsMapBS = 0  "Disable deleting pairs (inconvenient)
let g:AutoPairsMapCh = 0
let g:AutoPairsMapCR = 0  "Insert a new indented line (buggy for deeper level)
let g:AutoPairsCenterLine = 0
let g:AutoPairsMapSpace = 0
" let g:AutoPairsShortcutToggle = '<M-i>'  " Default to <M-p>


" ==================== PLUGIN: tig ====================
" Setup:
"   $ brew install tig
"   $ ln -sf $PWD/etc/tigrc ~/.tigrc

" if executable('git') && executable('tig')
" endif

"REF: https://github.com/iberianpig/tig-explorer.vim
Plug 'iberianpig/tig-explorer.vim', {'commit': 'ac49ff1'}  "faster/prettier (tig required)

nnoremap tt :TigStatus<CR>


" ==================== PLUGIN: gitgutter ====================
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
let g:gitgutter_highlight_lines = 1  "GitHub-like line bg, toggle with :GitGutterLineHighlightsToggle
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

" Diff base comes from g:git_diff_base (see GitDiffBase() in the FUNCTIONS section)
autocmd User GitDiffBaseChanged let g:gitgutter_diff_base = GitDiffBase() | silent! GitGutterAll

" Aoivd hanging when loading big files
autocmd BufEnter * call Disable_plugins()

" Fixes an error on lost focus, but also clears signs on every leave -- annoying
" autocmd FocusLost * GitGutterDisable
" autocmd FocusGained * GitGutterEnable

function! Disable_plugins()
    if line('$') > 2000
        execute "GitGutterDisable"
    elseif strlen(getline('.')) > 2000
        execute "GitGutterDisable"
    endif
endfunction

call plug#end()


" Some plugins require env variables (vim does not take env from shell)
silent! source ~/.vimrc-env.vim


" ==================== FUNCTIONS ====================
" --- VIM FUNCTIONS ---

function! Hello_word()
    let my_grouped_opts = input ( "1.- Search one\n2.- Search two\n3.- Search three\n" )
    let my_list_opts = split( my_grouped_opts, ".\zs" )
    for selection in my_list_opts
        echo "\nOption number " selection " selected"
    endfor
endfunction


function! JumpToBuffer(...)
    let bufindex = a:1
    let buffer_list = filter(range(1, bufnr("$")), "buflisted(v:val)")
    " echo buffer_list
    exe ":buffer " . buffer_list[bufindex]
endfunction


function! HowManyBuffers()
    let buffer_list = filter(range(1, bufnr("$")), "buflisted(v:val)")
    echo 'There are [' . len(buffer_list) . '] buffers'
endfunction


" Open git changed files
function! EditChangedFiles()
    let fnames = split(system("git diff --name-only"), "\n")
    for fn in fnames
        " execute "argadd " fn
        execute "next " fn
    endfor
endfunction


"{Toggle Relative Line Number}
function! ToggleRelativeNumber()
    if &relativenumber == 0
        set number relativenumber
    else
        set number norelativenumber
    endif
endfunction

"{Flash Relative Line Number -- show just long enough to type a {count}j/k
" jump, then auto-hide on the first cursor move so it doesn't stay on}
function! FlashRelativeNumber() abort
    if &relativenumber
        return  " already on (e.g. via the permanent toggle) -- leave it alone
    endif
    set relativenumber
    augroup FlashRelativeNumberOff
        autocmd!
    augroup END
    " Arm the auto-hide on the next event-loop tick, not immediately: the
    " visual-mode mapping does :<C-u>call FlashRelativeNumber()<CR>gv, and
    " that trailing gv (restoring the selection) is itself a cursor move --
    " arming synchronously would let it self-trigger before the user ever
    " gets to type their real jump.
    call timer_start(0, {-> s:ArmUnflash()})
endfunction

function! s:ArmUnflash() abort
    if !&relativenumber
        return  " toggled off already (e.g. race with another flash)
    endif
    augroup FlashRelativeNumberOff
        autocmd!
        autocmd CursorMoved <buffer> call s:UnflashRelativeNumber()
    augroup END
endfunction

function! s:UnflashRelativeNumber() abort
    set norelativenumber
    autocmd! FlashRelativeNumberOff
endfunction


function! LoadVimrc()
    :tabnew
    :source ~/.vim/workspace.vim
endfunction


function! s:GitRemoteFileUrl(with_line, ...) abort
    let l:file = expand('%:p')
    let l:target = a:0 >= 1 ? a:1 : l:file
    let l:kind = a:0 >= 2 ? a:2 : 'blob'
    if empty(l:target) || (a:0 == 0 && &buftype !=# '')
        echoerr 'Current buffer is not a file'
        return ''
    endif

    let l:file_dir = a:0 >= 1 ? l:target : expand('%:p:h')
    let l:root = trim(system('git -C ' . shellescape(l:file_dir) . ' rev-parse --show-toplevel'))
    if v:shell_error || empty(l:root)
        echoerr 'Current file is not in a Git repository'
        return ''
    endif

    let l:remotes = systemlist('git -C ' . shellescape(l:root) . ' remote')
    let l:remote = get(l:remotes, 0, '')
    if empty(l:remote)
        echoerr 'No Git remote found'
        return ''
    endif

    let l:remote_url = trim(system('git -C ' . shellescape(l:root) . ' remote get-url ' . shellescape(l:remote)))
    if v:shell_error || empty(l:remote_url)
        echoerr 'Could not determine Git remote URL'
        return ''
    endif

    let l:remote_url = substitute(l:remote_url, '^git@\([^:]*\):', 'https://\1/', '')
    let l:remote_url = substitute(l:remote_url, '^ssh://git@', 'https://', '')
    let l:remote_url = substitute(l:remote_url, '^git+ssh://git@', 'https://', '')
    let l:remote_url = substitute(l:remote_url, '/\?$', '', '')
    let l:remote_url = substitute(l:remote_url, '\.git$', '', '')

    let l:branch = trim(system('git -C ' . shellescape(l:root) . ' symbolic-ref --short HEAD 2>/dev/null'))
    if empty(l:branch)
        let l:branch = trim(system('git -C ' . shellescape(l:root) . ' rev-parse HEAD'))
    endif

    let l:relative = l:target ==# l:root ? '' : strpart(l:target, strlen(l:root) + 1)
    let l:relative = substitute(l:relative, ' ', '%20', 'g')
    let l:branch = substitute(l:branch, ' ', '%20', 'g')
    let l:host = tolower(matchstr(l:remote_url, '^https\?://[^/]*'))
    if l:host =~# 'github\.com'
        let l:url = l:remote_url . '/' . l:kind . '/' . l:branch . '/' . l:relative
    elseif l:host =~# 'gitlab\.'
        let l:url = l:remote_url . '/-/' . l:kind . '/' . l:branch . '/' . l:relative
    elseif l:host =~# 'bitbucket\.'
        let l:url = l:remote_url . '/src/' . l:branch . '/' . l:relative
    else
        let l:url = l:remote_url . '/' . l:kind . '/' . l:branch . '/' . l:relative
    endif

    let l:url = substitute(l:url, '/$', '', '')
    if a:with_line
        let l:url .= '#L' . line('.')
    endif
    return l:url
endfunction

function! GetGithubLink(with_line) abort
    let l:url = s:GitRemoteFileUrl(a:with_line)
    if empty(l:url)
        return
    endif
    let @+ = l:url
    echo 'Copied Git remote link'
endfunction

function! GetGitRemoteCodeReferenceLink()
    call GetGithubLink(1)
endfunction

function! GithubLink()
    call GetGithubLink(0)
endfunction

function! GithubLinkCurrentLine()
    call GetGithubLink(1)
endfunction

function! GitOpen() abort
    if empty(expand('%:p')) || &buftype !=# ''
        " No file (empty buffer, NERDTree...): open the repo root, not cwd
        let l:root = trim(system('git -C ' . shellescape(getcwd()) . ' rev-parse --show-toplevel'))
        let l:url = s:GitRemoteFileUrl(0, v:shell_error ? getcwd() : l:root, 'tree')
    else
        let l:url = s:GitRemoteFileUrl(0)
    endif
    if empty(l:url)
        return
    endif

    if executable('open')
        let l:browser = 'open'
    elseif executable('xdg-open')
        let l:browser = 'xdg-open'
    elseif executable('cmd.exe')
        let l:browser = 'cmd.exe'
    else
        echo l:url
        return
    endif

    call job_start([l:browser, l:url], {'stoponexit': ''})
    echo 'Opened ' . l:url
endfunction


" One session per project, named by its slugified full path, e.g.
" ~/do.not.move/vim-sessions/Users-me-workspace-myproject.vim
" Kept outside the repo: in a git worktree .git is a file, not a dir. Override with g:session_dir.
function! GetSessionPath()
    let g:gitroot = trim(system("git rev-parse --show-toplevel"))
    let project = isdirectory(g:gitroot) ? g:gitroot : getcwd()
    let slug = substitute(substitute(project, '[^A-Za-z0-9._-]\+', '-', 'g'), '^-\+', '', '')
    let session_dir = expand(get(g:, 'session_dir', '~/do.not.move/vim-sessions'))
    call mkdir(session_dir, 'p')
    return session_dir . '/' . slug . '.vim'
endfunction


" function! SaveSessionBuiltIn()
function! SaveSession()
    let session_path = GetSessionPath()
    execute "mksession! " . session_path
    echo "Saved session to: " . session_path
endfunction


function! SaveSessionSimple()
    echom "SAVING SESSION BY FILES..."
    let buffer_list = filter(range(1, bufnr("$")), "buflisted(v:val)")
    " echom 'Buffers: ' . string(buffer_list)
    let session_path = GetSessionPath()
    let steps = []
    call add(steps, 'cd '. fnameescape(getcwd()))
    call add(steps, 'let g:gitroot = "'. g:gitroot . '"')
    call add(steps, 'let s:wipebuf = bufnr("%")')  "Mark initial/empty buffer
    " Record buffers
    let l:files = []
    for bufnr in buffer_list
        let l:bufname = expand('#' .. bufnr .. ':p')
        if bufexists(bufnr) && buflisted(bufnr) && getbufvar(bufnr, '&buftype') ==# '' && !empty(bufname(bufnr)) && !isdirectory(l:bufname)
            call add(l:files, l:bufname)
            call add(steps, '$argadd ' . fnameescape(l:bufname))
        endif
    endfor
    " Record others. Focus may be on NERDTree or an unnamed buffer, where a bare
    " `edit` fails with E32, so fall back to the first recorded file.
    let l:focused = expand('%:p')
    if index(l:files, l:focused) >= 0
        call add(steps, 'edit ' . fnameescape(l:focused))  "Set focused file
        call add(steps, 'call cursor(' . line('.') . ', ' . col('.') . ')')  "Restore cursor in focused file
        call add(steps, 'normal! zz')  "Center view on restored cursor line
    elseif !empty(l:files)
        call add(steps, 'edit ' . fnameescape(l:files[0]))
    endif
    call add(steps, 'silent exe "bwipe " . s:wipebuf')  "Remove initial/empty buffer
    " echom 'Steps: ' . string(steps)
    if len(steps) > 0
        call writefile(steps, session_path, 'b')
    endif
    echom "SAVED SESSION TO: " . session_path
endfunction


function! SaveSessionByObsession()
    echom "SAVING SESSION BY FILES..."
    let session_path = GetSessionPath()
    execute "Obsession! " . session_path
    echom "SAVED SESSION TO: " . session_path
endfunction


function! LoadSession()
    let session_path = GetSessionPath()
    execute "source " . session_path
    echom "LOADED SESSION FROM: " . session_path
endfunction


"Search/grep pattern and open files
function! GrepOpen(...)
    let keywords = a:1
    let path = "."
    echo "searching [" . keywords . "]..."
    if executable("ag")
        let cmd = "ag -l '" . keywords . "' ". path
    else
        let cmd = "grep -l -r -E '" . keywords . "' " . path
    endif
    let result = trim(system(cmd))
    echo "Search result:\n" . result . "\n\n"
    let target_files = split(result, "\n")
    let choice = input("Open above [". len(target_files) ."] files? (Y/N):")
    if choice == 'y' || choice == 'Y'
        for fname in target_files
            execute "edit " . fname
        endfor
    endif
endfunction


function! DebugCurrentFile()
    " https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-debug-launcher
    " - https://github.com/fabiospampinato/vscode-debug-launcher/blob/master/docs/terminal.md
    " REQUIRES:
    " 1. MACOS
    " 2. VSCODE + DEBUG LAUNCHER (EXTENSION)
    let file_path = expand('%:p')
    let cmd = "open 'vscode://fabiospampinato.vscode-debug-launcher/file?args=". file_path ."'"
    echo system(cmd)
endfunction

" REF: https://gist.github.com/JoshuaJWilborn/e8c14b8fabaca3e18178c69f556d30cf
let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " . a:height
        try
            exec "buffer " . g:term_buf
        catch
            call term_start($SHELL, {'curwin': 1})
            let g:term_buf = bufnr("")
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction


function! OpenLink(...)
    let link = a:1
    let url = substitute(link, '\#', '\\#', 'g')
    let cmd = "open " . url
    echo system(cmd)
endfunction


" gx: open the URL under the cursor up to the next space. <cfile> stops at '=', '&', '"' etc. and cut long URLs.
" Runs `open` without a shell, so '#', '&', '|' in the URL need no escaping.
function! OpenUrlUnderCursor() abort
    let url = substitute(expand('<cWORD>'), '^.\{-}\ze\a\+://', '', '')
    if has('nvim')
        call jobstart(['open', url], {'detach': v:true})
    else
        call job_start(['open', url])
    endif
    echo url
endfunction


function! EscapeString(...)
    let text = a:1
    let text = substitute(text, '\\', '\\\\', 'g')
    let text = substitute(text, '\/', '\\/', 'g')
    let text = substitute(text, '\~', '\\~', 'g')
    let text = substitute(text, '\[', '\\[', 'g')
    let text = substitute(text, '\]', '\\]', 'g')
    " let text = substitute(text, '\#', '\\#', 'g')
    " let text = substitute(text, '\@', '\\@', 'g')
    return text
endfunction

function! GetVisualSelection()
    "REF: https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! ReplaceSelection()
    "Test: /path/to/abc/def/hah
    "Test: abc~!@#$%%^&&**()
    let l:src = GetVisualSelection()
    let l:src2 = EscapeString(l:src)
    let l:dest = input("Alternative ----> ", l:src)
    let l:dest2 = EscapeString(l:dest)
    if index(['y', 'Y'], input('All buffers? [Yy/Nn]: ', 'n')) >= 0
        let l:bufs = ' bufdo '
    else
        let l:bufs = ''
    endif
    let l:cmd = 'silent! '. l:bufs .' %s#' . l:src2 . '#' . l:dest2 . '#gc'
    if index(['y', 'Y'], input(l:cmd . ' ----> [Yy/Nn]: ', 'y')) >= 0
        let l:buf = bufnr('%')  "Remember current buffer
        " Add to command history
        call histadd("cmd", l:cmd)
        " execute l:cmd
        call feedkeys(':'. l:cmd, 'i')
        " Return to the remembered buffer:
        execute 'buffer ' . l:buf
    else
        echo "\n^Canceled"
    endif
endfunction


function! ToggleVerbose()
    " $ tail -f /tmp/vim-runtime.log
    " $ less +F /tmp/vim-runtime.log
    " When bigger than zero, Vim will give messages about what it is doing. Currently, these messages are given:
    " >= 1 When the viminfo file is read or written.
    " >= 2 When a file is ":source"'ed.
    " >= 5 Every searched tags file and include file.
    " >= 8 Files for which a group of autocommands is executed.
    " >= 9 Every executed autocommand.
    " >= 12 Every executed function.
    " >= 13 When an exception is thrown, caught, finished, or discarded.
    " >= 14 Anything pending in a ":finally" clause.
    " >= 15 Every executed Ex command (truncated at 200 characters).
    if !&verbose
        set verbosefile=/tmp/vim-runtime.log
        set verbose=9
    else
        set verbose=0
        set verbosefile=
    endif
endfunction


function! ShowHighlightGroupUnderCursor ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction


function! ChangeCwdToProjectRoot ()
    let s:cwd = expand('%:p')
    echo s:cwd
    " TBD
    " ...
endfunction


function! BuildCurrentFile ()
    write
    if &filetype ==# 'python'
        execute '!python3 ' . shellescape(expand('%:p'))
    elseif &filetype ==# 'c'
        execute '!gcc ' . shellescape(expand('%')) . ' -o /tmp/a.out && /tmp/a.out'
    elseif &filetype ==# 'cpp' || &filetype ==# 'c++' || &filetype ==# 'cc'
        execute '!clang++ ' . shellescape(expand('%')) . ' -Wall -Wextra -std=c++17 -o /tmp/a.out && /tmp/a.out'
    elseif &filetype ==# 'javascript'
        " Call your custom JS debug function
        call DebugCurrentFile()
    elseif &filetype ==# 'sh'
        execute '!bash ' . shellescape(expand('%'))
    elseif expand('%') =~# 'Makefile'
        execute '!make'
    elseif expand('%:t') =~# '\v(\.vim|\.vimrc|vimrc.*)'
        execute 'source ~/.vim/init.vim'
    elseif expand('%:t') =~# '\v(\.zshrc|zshrc.*)'
        execute '!source ' . shellescape(expand('%:p'))
    else
        echo "No build command defined for this filetype."
    endif
endfunction


function! PreviewMarkdown()
    " Render current markdown buffer to HTML (dark theme, mermaid diagrams, KaTeX math)
    " via pandoc and open it in the browser.
    if &filetype !=# 'markdown'
        echo 'Not a markdown file.'
        return
    endif
    echo 'Generating preview page for ' . expand('%:t') . '...'
    let l:css_dark = expand('<script>:p:h') . '/scripts/markdown-preview-dark.css'
    let l:css_light = expand('<script>:p:h') . '/scripts/markdown-preview-light.css'
    let l:mermaid = expand('<script>:p:h') . '/scripts/markdown-preview-mermaid.html'
    let l:toggle = expand('<script>:p:h') . '/scripts/markdown-preview-theme-toggle.html'
    let l:slug = substitute(expand('%:p:r'), '[/.]', '-', 'g')
    let l:out = '/tmp/' . l:slug . '.html'
    let l:cmd = 'pandoc ' . shellescape(expand('%:p'))
        \ . ' -s --katex --embed-resources'
        \ . ' --css=' . shellescape(l:css_dark)
        \ . ' --css=' . shellescape(l:css_light)
        \ . ' --include-after-body=' . shellescape(l:mermaid)
        \ . ' --include-after-body=' . shellescape(l:toggle)
        \ . ' -o ' . shellescape(l:out) . ' && open ' . shellescape(l:out)
    call job_start(['sh', '-c', l:cmd])
endfunction


function! SearchInFile(pattern)
    " Good for searching text with special characters
    let oldpat=@/
    let @/=a:pattern
    let old_a=@a
    normal! gg"aygn
    let result=@a
    let @a=old_a
    let @/=oldpat
    return result
endfunction

function! ToggleVerbose()
    let s:path = "/tmp/vim_verbose_". strftime('%Y%m%d') .".log"
    if !&verbose
        echo 'Turnning on verbose mode and saving runtime log into: '. s:path
        let &verbosefile = s:path
        set verbose=15
    else
        echo 'Turnning off verbose mode'
        let &verbose=0  "set verbose=0
        set verbosefile=
    endif
endfunction


function! SendContextToAI(...) range
    " Send current file path + line (or visual line range), plus an optional
    " trailing message, to the tmux pane on the right.
    if a:firstline == a:lastline
        let l:loc = expand('%') . ':L' . a:firstline
    else
        let l:loc = expand('%') . ':L' . a:firstline . '-' . a:lastline
    endif
    let l:msg = 'Context: ' . l:loc
    let l:has_question = a:0 > 0 && a:1 !=# ''
    if l:has_question
        let l:msg .= "\n" . a:1
    else
        let l:msg .= "\n"
    endif
    call system('tmux send-keys -t "{right-of}" -l ' . shellescape(l:msg))
    if l:has_question
        " A pasted "\n" just inserts a line break in the prompt box, it
        " doesn't submit — send a real Enter keystroke to ask right away.
        call system('tmux send-keys -t "{right-of}" Enter')
    endif
    call system('tmux select-pane -t "{right-of}"')
endfunction


" --- GIT DIFF BASE (shared by gitgutter, NERDTree, lsptagbar) ---
" g:git_diff_base: the commit every git view diffs against. Plugins read GitDiffBase()
" (or the variable) and listen for `User GitDiffBaseChanged` to repaint.
" Default: where this branch forked from main (fallback: master), so views show the
" whole branch like a PR. Re-picked per repo/worktree on BufEnter until a ref is set by hand.
" :ChangeGitDiffBase          -> back to the default (branch fork point, auto per repo)
" :ChangeGitDiffBase <ref>    -> diff against any branch/tag/commit, e.g. HEAD~3, origin/develop
" :ChangeGitDiffBase HEAD     -> uncommitted changes only
let g:git_diff_base = get(g:, 'git_diff_base', 'HEAD')
let s:git_diff_base_auto = 1
autocmd BufEnter * if s:git_diff_base_auto | call s:AutoGitDiffBase() | endif

function! GitDiffBase() abort
    return empty(get(g:, 'git_diff_base', '')) ? 'HEAD' : g:git_diff_base
endfunction

function! s:AutoGitDiffBase() abort
    if &buftype !=# ''
        return
    endif
    if !exists('b:git_toplevel')
        let b:git_toplevel = trim(system('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel 2>/dev/null'))
    endif
    if empty(b:git_toplevel) || b:git_toplevel ==# get(s:, 'git_diff_base_repo', '')
        return
    endif
    let s:git_diff_base_repo = b:git_toplevel
    let g:git_diff_base = 'HEAD'  " if no main/master here, don't keep another repo's base
    call SetGitDiffBase('', 1)
endfunction

" ref '' = branch fork point from main/master; optional 2nd arg: quiet (no messages)
function! SetGitDiffBase(ref, ...) abort
    let l:quiet = a:0 && a:1
    let s:git_diff_base_auto = empty(a:ref)
    let l:git = 'git -C ' . shellescape(expand('%:p:h')) . ' '
    let l:ref = a:ref
    if empty(l:ref)
        for l:candidate in ['main', 'master', 'origin/main', 'origin/master']
            call system(l:git . 'rev-parse --verify --quiet ' . shellescape(l:candidate))
            if v:shell_error == 0
                let l:ref = l:candidate
                break
            endif
        endfor
        if empty(l:ref)
            if !l:quiet | echohl ErrorMsg | echo 'ChangeGitDiffBase: no main/master branch found' | echohl None | endif
            return
        endif
        let l:base = trim(system(l:git . 'merge-base HEAD ' . shellescape(l:ref)))
        let l:label = 'merge-base with ' . l:ref
    else
        let l:base = trim(system(l:git . 'rev-parse --verify --quiet ' . shellescape(l:ref)))
        let l:label = l:ref
    endif
    if v:shell_error != 0 || empty(l:base)
        if !l:quiet | echohl ErrorMsg | echo 'ChangeGitDiffBase: invalid ref: ' . l:ref | echohl None | endif
        return
    endif
    let g:git_diff_base = l:base
    if exists('#User#GitDiffBaseChanged')
        doautocmd <nomodeline> User GitDiffBaseChanged
    endif
    if !l:quiet
        echo 'Git diff base: ' . l:label . ' (' . l:base[:7] . ')'
    endif
endfunction

function! GitRefComplete(arglead, cmdline, cursorpos) abort
    let l:refs = systemlist('git -C ' . shellescape(expand('%:p:h')) . ' for-each-ref --format="%(refname:short)" refs/heads refs/remotes refs/tags')
    return filter(['HEAD'] + l:refs, 'v:val =~# "^" . escape(a:arglead, "\\.^$~[]*")')
endfunction


" ==================== COMMANDS ====================
"----------------------------------------------------------------------------------------"
"|       __     ___              ____                                          _        |"
"|       \ \   / (_)_ __ ___    / ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |___    |"
"|        \ \ / /| | '_ ` _ \  | |   / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|   |"
"|         \ V / | | | | | | | | |__| (_) | | | | | | | | | | | (_| | | | | (_| \__ \   |"
"|          \_/  |_|_| |_| |_|  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/   |"
"|                                                                                      |"
"----------------------------------------------------------------------------------------"


"<Files>----------------------------------------------------{
    command! OpenThisOnMac :silent exec "!open %"<CR>
    command! OpenAllInThisDir :next *
    "{Change pwd/Current Directory to be same with buffer}
    command! CDToCurrentDir :cd %:p:h
    command! R :source ~/.vimrc
    command! BufferCount :call HowManyBuffers()
    command! Build call BuildCurrentFile()
"}


"<Grep & Open files>-----------------------------------------{
    " command! GrepO :normal :call GrepOpen('haha')
    command! Vimrc :call LoadVimrc()
    command! CloseAllBuffers :normal :bufdo bd<CR>
    "command! CloseAllBuffers :% bd|e#
    command! TerminalOpenAtBottom :bot split \| resize 10 \| terminal<CR>i
"}

"<Path>-------------------------------------------{
    command! Cwd echo expand('%')
    command! CwdCopy let @+ = expand('%') | echo 'Copied: ' @+
    command! C let @+ = expand('%') | echo 'Copied: ' @+
    command! Pwd echo expand('%:p')
    command! PwdCopy let @+ = expand('%:p') | echo 'Copied: ' @+
    command! P let @+ = expand('%:p') | echo 'Copied: ' @+
    command! FilenameCopy let @+ = expand('%:t') | echo 'Copied: ' @+
    command! F let @+ = expand('%:t') | echo 'Copied: ' @+
    "command! CopyFolderRelativePath let @+ = expand('%:h') | echo 'Copied: ' @+
    "command! CopyFolderAbsolutePath let @+ = expand('%:p:h') | echo 'Copied: ' @+
"}


"<Git>------------------------------------------------------------------{
    command! RemoteGitFileReference call GetGitRemoteCodeReferenceLink()
    command! GithubLink call GithubLink()
    command! OpenGithubLink call GitOpen()
    command! GithubLinkCurrentLine call GithubLinkCurrentLine()
    command! GitOpen call GitOpen()
    command! OpenChangedFiles call EditChangedFiles()
    command! -nargs=? -complete=customlist,GitRefComplete ChangeGitDiffBase call SetGitDiffBase(<q-args>)
"}


"<Claude>-----------------------------------------------------------------{
    command! -range -nargs=* AskAI <line1>,<line2>call SendContextToAI(<q-args>)
"}


"<Spelling>---------------------------------------------------------{
    command! SpellCheck01On  setlocal spell spelllang=en,en_us,cjk
    command! SpellCheck02Off setlocal nospell
"}


"[Session]----------------------------------{
    "{Load session}
    augroup AutoSaveSession
        autocmd!
        " autocmd VimLeave,FocusLost * if len(getbufinfo({'buflisted':1}))>=2 | call SaveSession() | endif
        autocmd VimLeave,FocusLost * if len(getbufinfo({'buflisted':1}))>=2 | call SaveSessionSimple() | endif
        " autocmd VimLeave,FocusLost * if len(getbufinfo({'buflisted':1}))>=2 | silent! call SaveSessionByObsession() | endif
    augroup end

    " augroup persistent_folds "Will messup with cwd and jump history!!!
    "     autocmd!
    "     autocmd BufWinLeave * silent! mkview
    "     autocmd BufWinEnter * silent! loadview
    " augroup END
"}


"[Prettify/Formatting]--------------------------{
    command! JsonPrettify :% !python -m json.tool
    command! SqlPrettify :% !python -m sqlparse.format --reindent --keywords upper --identifiers lower

    command! RemoveTrailingWhitespace %s/\s\+$//e
"}


"[Reload Vimrc]--------------------------{
    command! SO :source $MYVIMRC
"}


" ==================== KEY MAPPINGS ====================
"-----------------------------------------------------------------
"           __     ___             _  __                         -
"           \ \   / (_)_ __ ___   | |/ /___ _   _ ___            -
"            \ \ / /| | '_ ` _ \  | ' // _ \ | | / __|           -
"             \ V / | | | | | | | | . \  __/ |_| \__ \           -
"              \_/  |_|_| |_| |_| |_|\_\___|\__, |___/           -
"                                           |___/                -
"----------------------------GENERATED-BY-FIGLET------------------
" Cheatsheet: https://vim.rtorr.com

" DEBUG:
" > :verbose imap or nmap

" Get Full path of ~, e.g., /home/ubuntu
let $HOME = expand('~')

" --- GENERAL GLOBAL MAPPINGS ---
" let maplocalleader = "\\"

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not found' messages
set shortmess+=c

" When menu comes out, can use ctrl-n to select
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" --- ALPHABET ---
vnoremap br "1y:bufdo %s/<C-r>1/<C-r>1/ge \| update
" nnoremap fw /<C-r>+<CR>
" nnoremap fw :call SearchInFile('<C-r>+')<CR>
" Search clipboard text literally (\V: no regex; special chars and multi-line OK)
nnoremap <silent> fp :let @/ = '\V' . substitute(escape(trim(getreg('+'), "\n", 2), '\/'), '\n', '\\n', 'g') \| call histadd('/', @/) \| set hlsearch<CR>n

" Centralize
" nnoremap n nzzzv
" nnoremap N Nzzzv
" nnoremap J mzJ`z

" nnoremap <Leader>p [m
" nnoremap <Leader>n ]m

" nnoremap gx :silent execute "!open <c-r><c-a>"<CR>
" nnoremap gx :call OpenLink("<C-r><C-a>")<CR>
nnoremap gx :call OpenUrlUnderCursor()<CR>
vnoremap g* "1y:%s/<C-r>1//n<CR>
" Refer: https://vim.fandom.com/wiki/Count_number_of_matches_of_a_pattern
nnoremap g* #<C-O>:%s///gn<CR>

vnoremap r "1y:%s#<C-r>1#<C-r>1#gc<Left><Left><Left>*<BS>
vnoremap R :call ReplaceSelection()<CR>
" vnoremap f "1y :Rg <C-r>1<CR>

nnoremap Y y$


" --- SPECIAL CHARACTERS ---
" No Use of ";" in Normal mode
" nnoremap ; :

" Break undo sequence:
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ! !<C-g>u
inoremap ? ?<C-g>u
" inoremap <Space> <Space><C-g>u

" Buffer Movement
nnoremap - :bprev<CR>
nnoremap = :bnext<CR>

" ESC replacement
inoremap ,. <Esc>:nohl<CR><ESC>
vnoremap ,. <Esc>:nohl<CR><ESC>
nnoremap ,. <Esc>:nohl<CR><ESC>
cnoremap ,. <ESC>

" Word Selection
nnoremap <Space> viw
nnoremap g<Space> viW
nnoremap <leader><Space> 0vg_

" Highlight
nnoremap  / :set hlsearch<cr>/
nnoremap  ? :set hlsearch<cr>?
nnoremap  * #:set hlsearch<cr>
nnoremap  # *:set hlsearch<cr>
nnoremap  !! /<C-r>+<CR>

vnoremap <CR> "+y

nnoremap <Del> <ESC>:nohl<CR><ESC>
vnoremap <Del> <ESC>:nohl<CR><ESC>
inoremap <Del> <ESC>
onoremap <Del> <ESC>
cnoremap <Del> <ESC>
tnoremap <Del> <ESC>

" Ctrl-z in Terminal-mode goes to the embedded job (e.g. tig suspends itself)
" instead of vim; exit terminal-mode and suspend vim like Normal-mode does
tnoremap <C-z> <C-\><C-n>:suspend<CR>


" --- LEADER KEY MAPPINGS ---
" vnoremap <leader>r "1y:1,10 s/<C-r>1/<C-r>1/gc<Left><Left><Left>*<BS>
" vnoremap <leader>r :call ReplaceSelection()<CR>
nnoremap <Leader>v v$h
nnoremap <Leader>0 v^

vnoremap <Leader>y "+y
nnoremap <Leader>p "+p
vnoremap <Leader>p "+p

nnoremap <Leader>L :source $MYVIMRC<CR>

nnoremap <leader>R :call LoadSession()<CR><ESC>


"Git blame current line
" nnoremap gb :execute "!git blame -L " . line(".") . ",+1 % "<CR>


" --- CTRL + ALPHABET MAPPINGS ---
inoremap <C-v> <C-r>0
noremap  <C-c> <Esc>:nohl<CR><ESC>
nnoremap <ESC> <Esc>:nohl<CR><ESC>


" --- ALT + ALPHABET MAPPINGS ---



nnoremap t1 :call JumpToBuffer(0)<CR>
nnoremap t2 :call JumpToBuffer(1)<CR>
nnoremap t3 :call JumpToBuffer(2)<CR>
nnoremap t4 :call JumpToBuffer(3)<CR>
nnoremap t5 :call JumpToBuffer(4)<CR>
nnoremap t6 :call JumpToBuffer(5)<CR>
nnoremap t7 :call JumpToBuffer(6)<CR>
nnoremap t8 :call JumpToBuffer(7)<CR>
nnoremap t9 :call JumpToBuffer(8)<CR>
nnoremap t0 :call JumpToBuffer(-1)<CR>

nnoremap ]b :call searchpair('\[','','\]')<cr>
nnoremap [b :call searchpair('\[','','\]','b')<cr>
nnoremap ]B :call searchpair('{','','}')<cr>
nnoremap [B :call searchpair('{','','}','b')<cr>


nnoremap \ `
" nnoremap <leader>l :call ToggleRelativeNumber()<CR>
nnoremap <silent> <leader>l :call FlashRelativeNumber()<CR>
vnoremap <silent> <leader>l :<C-u>call FlashRelativeNumber()<CR>gv
" nnoremap <silent> fw :call FlashRelativeNumber()<CR>

" vnoremap <Leader>f "1y:call GrepOpen("<C-r>1")<CR>
nnoremap <Leader>aa :ggVG<CR>
nnoremap <Leader>ay :%y+<CR>
nnoremap <Leader>ad :%d+<CR>

noremap <Leader>s :vsplit<CR><C-w>l
" Show the next listed buffer in this window before deleting, so the window
" (and the layout next to NERDTree) survives. Last buffer falls back to :bdelete.
" Close a side window (quickfix, help...) and return to the window it was opened
" from. Plain :close focuses whichever window takes over the space, often NERDTree.
function! CloseWindowGoBack() abort
    let l:prev = win_getid(winnr('#'))
    close
    if l:prev != 0
        call win_gotoid(l:prev)
    endif
endfunction

function! s:CloseBuffer() abort
    let l:buf = bufnr('%')
    " Quickfix/location list, help, etc.: just close the window
    if &buftype !=# '' && winnr('$') > 1
        call CloseWindowGoBack()
        return
    endif
    if &modified
        echohl ErrorMsg | echo 'No write since last change' | echohl None
        return
    endif
    let l:others = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != l:buf')
    if buflisted(l:buf) && !empty(l:others)
        execute 'buffer ' . get(filter(copy(l:others), 'v:val > l:buf'), 0, l:others[-1])
    endif
    execute 'bdelete ' . l:buf
endfunction
nnoremap <silent> <Leader>q :call <SID>CloseBuffer()<CR>
nnoremap <Leader>tc :tabnew<CR>
nnoremap <Leader>tq :windo bdelete<CR>

noremap <A-c> <C-w>c

" Send current line (normal) or selection (visual) as context to AI pane,
" no trailing message so it doesn't auto-submit.
nnoremap <Leader>i :call SendContextToAI()<CR>
vnoremap <Leader>i :call SendContextToAI()<CR>

nnoremap \\ :echo expand('%')<CR>
" nnoremap tf :Cwd<CR>
" nnoremap tc :CwdCopy<CR>
" nnoremap tp :PwdCopy<CR>
" nnoremap tn :FilenameCopy<CR>

nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k

"Build/compile current file: (use command :Build instead)
" augroup FileCompile
"     autocmd!
"     autocmd BufReadPre *.py noremap <buffer> <leader>B :w<CR>:!python "%:p" <CR>
"     autocmd BufReadPre *.c noremap <buffer> <leader>B :w<CR>:!gcc % -o /tmp/a.out && /tmp/a.out <CR>
"     autocmd BufReadPre *.cpp,*.cc noremap <buffer> <leader>B :w<CR>:!g++ % -Wall -o /tmp/a.out && /tmp/a.out <CR>
"     autocmd BufReadPre *.js noremap <buffer> <leader>B :w<CR>:call DebugCurrentFile()<CR>
"     " autocmd BufReadPre *.js nnoremap <buffer> [[ []
"     " autocmd BufReadPre *.js nnoremap <buffer> ]] ][
"     autocmd BufReadPre *.sh noremap <buffer> <leader>B :w<CR>:!bash % <CR>
"     autocmd BufReadPre Makefile noremap <buffer> <leader>B :w<CR>:!make <CR>
"     autocmd BufReadPre .vim,.vimrc,vimrc* noremap <buffer> <leader>B :w<CR>:source ~/.vim/init.vim <CR>
"     autocmd BufReadPre .zshrc,zshrc* noremap <buffer> <leader>B :w<CR>:!source % <CR>
" augroup end

if &diff
    map <leader>1 :diffget LOCAL<CR>
    map <leader>2 :diffget BASE<CR>
    map <leader>3 :diffget REMOTE<CR>
endif


" --- AUTO COMPLETE ---
" inoremap ( ()<left>
" inoremap [ []<left>
" inoremap { {}<left>
" inoremap ' ''<left>
" inoremap " ""<left>
" inoremap ` ``<left>
" inoremap <expr> ) strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
" inoremap <expr> } strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
" inoremap <expr> ] strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
" inoremap <expr> ' strpart(getline('.'), col('.')-1, 1) == "\'" ? "\<Right>" : "\'\'\<Left>"
" inoremap <expr> " strpart(getline('.'), col('.')-1, 1) == "\"" ? "\<Right>" : "\"\"\<Left>"


" --- QUICKFIX ---
" nnoremap <leader>co :copen<CR>
" nnoremap <leader>cc :cclose<CR>
" nnoremap <leader>cn :cnext<CR>
" nnoremap <leader>cp :cprev<CR>
" nnoremap <leader>c1 :cc 1<CR>
" nnoremap <leader>c2 :cc 2<CR>
" nnoremap <leader>c3 :cc 3<CR>
" nnoremap <leader>c4 :cc 4<CR>
" nnoremap <leader>c5 :cc 5<CR>


" --- Command-line Mode ---
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>



" Render to HTML and open in the browser: buffer-local so it only exists in markdown
" (gp/gP are already taken by gitgutter's plugin defaults, see rcmodules/gitgutter.vim notes)
autocmd FileType markdown command! -buffer MarkdownPreview call PreviewMarkdown()
autocmd FileType markdown nnoremap <buffer><silent> <leader>P :MarkdownPreview<CR>


" ==================== UI ====================
"-----------------------------------------------------------------------
"          __     ___             _____ _                              -
"          \ \   / (_)_ __ ___   |_   _| |__   ___ _ __ ___   ___      -
"           \ \ / /| | '_ ` _ \    | | | '_ \ / _ \ '_ ` _ \ / _ \     -
"            \ V / | | | | | | |   | | | | | |  __/ | | | | |  __/     -
"             \_/  |_|_| |_| |_|   |_| |_| |_|\___|_| |_| |_|\___|     -
"                                                                      -
"----------------------------GENERATED-BY-FIGLET------------------------

"REF: http://bytefluent.com/devify/

" --- COLORS SCHEME / THEMES ---

"==========> GRUVBOX ============>>>>
" colorscheme gruvbox ">> grubox is slow for old machine
"let g:gruvbox_contrast_dark='hard' "[hard|medium|soft]

"==========> BADWOLF ============>>>>
let g:enable_badwolf_plugin = 0
let g:enable_badwolf_filetype = 1
let g:enable_badwolf_vim = 0
let g:enable_badwolf_python = 0
let g:enable_badwolf_ctrlp = 0
let g:enable_badwolf_easymotion = 0
let g:enable_badwolf_intersting_words = 0
let g:enable_badwolf_makegreen = 0
let g:enable_badwolf_rainbow_parentheses = 0
let g:enable_badwolf_show_marks = 0
let g:enable_badwolf_clojure = 0
let g:enable_badwolf_common_lisp = 0
let g:enable_badwolf_css = 0
let g:enable_badwolf_diff = 0
let g:enable_badwolf_django_templates = 0
let g:enable_badwolf_html = 0
let g:enable_badwolf_java = 0
let g:enable_badwolf_latex = 0
let g:enable_badwolf_less_css = 0
let g:enable_badwolf_lispyscript = 0
let g:enable_badwolf_repls = 0
let g:enable_badwolf_mail = 0
let g:enable_badwolf_markdown = 0
let g:enable_badwolf_mysql = 0
let g:enable_badwolf_slimv = 0
silent! colorscheme badwolf  "Plug 'solomonxie/badwolf'

" ==========> ALTERNATIVES ===========>
    "colorscheme gruvbox  "20ms
    "colorscheme cobalt2 "100ms
    "colorscheme monokai "7ms. Fast (sickill/vim-monokai)
    "colorscheme shades_of_purple ">> Require the plugin

" ==========> Colorscheme based on filetype ===========>
    "autocmd FileType python colorscheme gruvbox
    "autocmd FileType vim,tmux,sh,txt,dockerfile colorscheme badwolf


" --- GENERAL UI / COLOR SCHEME ---
function SetSyntax()
    let b:max_line = 5000
    if line('$') <= b:max_line "&& &syntax != 'manual'
        syntax manual
        set syntax=on
        filetype plugin on    " [essential]
        filetype plugin indent on
    else
        set syntax=off
        filetype plugin off    " [essential]
        filetype plugin indent off
    endif
endfunction

" <Syntax Highlighting>  Better to be in the front
    syntax on  "Speed: off > manual > on > enable

    ""ULTIMATE PERFORMANCE STRATEGY: disable syntax at start, then lazy load on buffer level
    "syntax off  "Speed: off > manual > on > enable
    " autocmd BufEnter *.py,*.js,*.md,*.sql,*.json,*.json.gz,*.yaml,*.yml,*.csv,*.csv.gz,*.vim,*.sh,*.zsh,zshrc*,Makefile*,*.snippets call SetSyntax()
    " autocmd FileType nerdtree call SetSyntax()
    " autocmd FileType vista call SetSyntax()
    autocmd BufRead *.json.gz set filetype=json
    autocmd BufRead *.sh,envfile*,.bashrc*,.zshrc* set filetype=bash
    autocmd BufRead,BufNewFile *.snippets set filetype=snippets
    autocmd BufRead *.ini,*rc,*.service,*.conf,*.config,*.cfg set syntax=config  "or syntax=config
    autocmd BufRead requirements*.txt set syntax=requirements

    let python_highlight_all = 1  "FOR vim/syntax/python.vim (FROM WEB)
"<FileType>
    " filetype plugin on    " [essential]
    " filetype plugin indent on

" <Basic Settings>
    set t_Co=256   ">> Overwriting Alert !!
    " set termguicolors  "{True Color Support} Vim-specific sequences for RGB colors
    set notermguicolors  "Turn off -> when on, bg-color will affect the whole look
    set background=dark   ">> Overwriting Alert !!

    "[CAREFUL!!!] >> Ugly when working with other themes & syntax highlighting plugins
    set fillchars+=vert:\|  "Bar character for VERTical Split Pane

    "Text wrapping
    " set nowrap
    set wrap linebreak nolist

" =={NUMBER LINE}==
    " turn hybrid line numbers on
    " set number relativenumber
    set number norelativenumber
    " highlight! LineNr ctermfg=gray ctermbg=black cterm=NONE guibg=black guifg=gray
    " highlight! SignColumn ctermfg=gray ctermbg=black cterm=NONE guibg=black guifg=gray
    " Automatic toggling between line number modes
    " augroup AutoToggleRelativeNumber
    "   autocmd!
    "   autocmd FocusGained,InsertLeave * set relativenumber
    "   autocmd FocusLost,InsertEnter   * set norelativenumber
    " augroup END

    "MUST GO BEFORE `colorscheme` and after `autocmd`
    " autocmd ColorScheme * highlight Normal ctermbg=None
    " autocmd ColorScheme * highlight NonText ctermbg=None

" <Spell Check>
    " autocmd BufRead,BufNewFile *.txt,*.md setlocal spell spelllang=en,en_us,cjk
    autocmd FileType gitcommit setlocal spell spelllang=en,en_us,cjk

" <Length Marker>
    " highlight OverLength ctermbg=red ctermfg=white  "> Warning color
    " let &colorcolumn=join(range(120,999),",")  "> Warning Column

    "match OverLength /\%81v.\+/

    "> or
    " let &colorcolumn="120,".join(range(400,999),",")
    "> or
    "set colorcolumn=80
    "highlight ColorColumn guibg=#155460
    "> or
    "highlight ColorColumn ctermbg=grey
    "> or
    "highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

" --- HIGHLIGHTING ---
" >>
    set showmatch
    set matchtime=3
    highlight Search guibg='Purple' guifg='NONE'
    highlight IncSearch gui=underline,bold guifg=White guibg=Red3
    "highlight IncSearch ctermbg=black ctermfg=yellow
"Cancel Highlighting when mouse on idle
    "autocmd cursorhold * set nohlsearch
"Highlight on paired braket
    "highlight MatchParen cterm=underline ctermbg=NONE ctermfg=NONE"

" <Highlight Settings>  --> Overwriting Alert!
    "-----> Has to be after loading colorscheme
    " highlight! Normal ctermbg=NONE
    "highlight! nonText ctermbg=NONE
    "highlight! VertSplit guifg=red guibg=blue term=None
    "highlight! Normal ctermbg=White ctermfg=Black guifg=Black guibg=White
    " highlight! Normal ctermfg=grey ctermbg=black  "Set background color
    " highlight Normal guibg=black

" =={CURSOR LINE}==
    " REF: https://jonasjacek.github.io/colors/
    " REF: https://vi.stackexchange.com/questions/23066/change-cursorline-style
    set cursorline  "Highlighting current line
    " autocmd WinEnter * set cursorline
    " autocmd WinLeave * set nocursorline
    highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=237  "Grey
    highlight! CursorLineNr cterm=NONE ctermfg=11 gui=bold guifg=Yellow
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=214  "Orange
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=161  "Deep Pink
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=8  "Grey
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=88  "Dark Red
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=89  "Pink
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=90  "Dark Magenta
    " highlight! CursorLine cterm=underline ctermfg=NONE ctermbg=236  "Dark Magenta
    " highlight! CursorLineNR cterm=NONE ctermfg=NONE ctermbg=89  "Pink

" =={TRAILING WHITESPACE}==
highlight TrailingWhitespace ctermbg=red guibg=red
autocmd BufRead,BufNewFile * match TrailingWhitespace /\s\+$/

" --- PLUGIN RELATED ---
" THIS IS REQUIRED BY PLUGIN TO LOAD AFTER SETTING COLORSCHEME

highlight HighlightedyankRegion cterm=reverse gui=reverse


" ==================== SETTINGS ====================
" --- GENERAL BUILT-IN SETTINGS ---
set nocompatible
set encoding=utf8
"set spell spelllang=en,en_us,cjk  "Spell check [Ugly]
set nospell
set ignorecase "Case Insensitive
set smartcase  "Case sensitive when there's upper case in search
set hidden "Enable to switch buffer without saving
set number "show line number
set mouse=a  "a -> all, enbles mouse in Tmux (but text selection will trigger visual mode)
set mousemodel=extend  "Right-click extends selection instead of opening a PopUp menu
" Disable mouse selection into visual mode
"set mouse=nicr
"noremap <LeftDrag> <LeftMouse>
"noremap! <LeftDrag> <LeftMouse>

set shell=/bin/sh

" Persistent Session Options
set sessionoptions-=options    " do not store global and local values in a session
set sessionoptions-=folds      " do not store folds
" set sessionoptions-=buffers      " do not store closed buffers with :bd
" set sessionoptions=blank,buffers,curdir,tabpages,winsize,terminal

" Avoid prompt to hit enter for every echo when it's not enough to show full msg
set shortmess+=T
set cmdheight=1

filetype plugin on
set omnifunc=syntaxcomplete#Complete
set completeopt=menu,menuone,noinsert,noselect
" Bugfix for insert mode in SQL file:
" SQLComplete, The dbext plugin must be loaded for dynamic SQL completion -->
let g:omni_sql_default_compl_type = 'syntax'

autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>
" References, quickfix and location lists
autocmd FileType qf nnoremap <buffer><silent><nowait> q :call CloseWindowGoBack()<CR>

set nopaste  "IMPORTANT: If it's on, vim will auto indent (messed up) on your paste
set showcmd " show keypress at right-bottom
set backspace=2 "backspace over everything in insert mode
set tabstop=4 "Set a tab=4spaces
set smartindent "Auto indent after hit RETURN: autoindent, smartindent, cindent
set shiftwidth=4 "Set auto-indent to 4 spaces
set expandtab "Expand tab to spaces
retab "Replace all tabs to spaces on file opened
filetype plugin indent on

"[Key maps timeout]
set timeout
set ttimeout
set timeoutlen=1000
set ttimeoutlen=30
"Word recognizing
"set iskeyword-=_
"[Auto reload current file]
set autoread
au FocusGained,BufEnter * :checktime
" Poll on a real timer, not CursorHold -- CursorHold needs a keystroke to
" re-arm, so it can't catch a change while you're fully idle.
if !exists('g:autoread_timer')
    let g:autoread_timer = timer_start(2000, {-> execute('silent! checktime')}, {'repeat': -1})
endif

" Fix ":" auto-filling a huge range like .,.+2143 -> E16 on :q/:wq after refocus
" Skip terminal buffers (tig/fzf/lazygit etc) so refocus doesn't kick them out of Terminal-mode
au FocusGained * if &buftype !=# 'terminal' | call feedkeys("\<C-\>\<C-n>", 'n') | endif

" Automatically set view in the center when jump to the matches
" https://vim.fandom.com/wiki/Make_search_results_appear_in_the_middle_of_the_screen
set scrolloff=5  "Set 99 to make it center

set isfname-==  "When using 'gf', ignore '=' as part of the file name


" --- Vim / NeoVim Persistent Layer (Shada & VimInfo) ---
" Persistent mechanism will keep session/marks/jumplist/buffers...

" VIMINFO: options - format: set viminfo=FLAGS
"   'N - Required: Save marks for the last N files (0 = disable marks)
"   !  - Save/restore global variables that start with uppercase and contain lowercase
"   <N - Save up to N lines for each register
"   @N - Save the last N registers
"   :N - Save the last N command-line history entries
"   /N - Save the last N search history entries
"   %N - Save/restore buffer list (N = number of buffers, 0 = disable)
"   sN - Only save items smaller than N KB
"   c  - Save encoding of the file
"   n  - Name of the viminfo file (default: ~/.viminfo)
"   r  - Removable media (comma-separated list of paths)
"   h  - Disable search highlighting when loading viminfo file
"   f1 - Store file marks (marks set in files)
"
" Example: set viminfo='100,<50,@100,:100,/100,%,s10,h,f1
"          (saves marks for 100 files, registers, history, buffer list, file marks)
set viminfo=

" --- ADVANCED BUILT-IN SETTINGS ---
"set wildmenu
"set wildmode=longest:full,full
"Search Highlighting
set incsearch "Enable instant search Highlighting
set hlsearch " Enable Highlighting all matches

"Disable runtime matchit.vim (SLOW)
let g:loaded_matchit = 1

"Disable new line with comment (FileType, so it wins over ftplugin's `fo+=cro`)
autocmd FileType * setlocal formatoptions-=cro

"<Buffer>
    "Change pwd/current-dir
    " set autochdir " Automatically change current directory
    set noautochdir " Dynamic cwd might messup after navigating to diff subfolders
    "autocmd BufEnter * cd %:p:h  "Auto change 'pwd' to current folder when enter a buffer
    set splitright  "Default split at right
    "set splitbelow  "Default split at right

"<Tag>
    set tags=./tags;,tags;./.git/tags;,../.git/tags


"IMPORTANT: FOR OPENNING LARGE FILE
let g:large_file_size = 10000000  "10MB

" If the file is too large, for performance, need to disable highlighting
autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:large_file_size | set noswapfile | syntax clear | endif
" autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) <= g:large_file_size | syntax clear | endif

" --- PERSISTENT FILE SETTINGS ---
" [  Backup Files  ]--------{
    set nobackup
    " set backup
    " set writebackup
    " " set backupcopy=yes  " Force backups to be copied from original, not renamed
    " " Create folder if not exists
    " set backupdir=~/do.not.move/vim_backup//
    " if !isdirectory(&backupdir)
    "    silent! call mkdir(&backupdir, 'p')
    " endif
" }


" [  Swap files  ]--------{
    set noswapfile  "Disable Swap files
    ""set swapfile  "Enable swap file
    "set directory=/tmp/vim_swap//    "set swp file directory.
    "" Create folder if not exists
    "if !isdirectory(&directory)
    "   silent! call mkdir(&directory, 'p')
    "endif
    "set updatecount=100     "save swp file every amount of characters
    "" ▼ update also check cursor-holds and other functions, bit expensive one.
    "set updatetime=100   "save swap file every amount of ms
" }


" [  Persistent undo  ]--------{
    if has("persistent_undo")
        set undofile "Save UNDO history to local files
        set undodir=~/do.not.move/undo//
        " Create folder if not exists
        if !isdirectory(&undodir)
           silent! call mkdir(&undodir, 'p')
        endif
    endif
" }

set history=1000


" --- Folding ---

" <Avoid any folding>
" set nofoldenable  "Cancel all folds when enter vim (faster)
" set foldmethod=manual  "manual|syntax
" autocmd BufEnter * set foldmethod=manual
" set foldlevelstart=99  "No folding on file open
" set foldlevel=1
" set foldclose=all  "Auto-close folding
" set foldnestmax=1
" set foldcolumn=0

" <Has some folding but start with none>
" set foldmethod=expr  "Don't set this here if it's set in treesitter
set foldlevel=99  "Don't fold anything at start
set foldlevelstart=99  "Don't fold anything at start
set foldcolumn=0      " 0|1 for a thin indicator at left bar

" [Persistent Folding]
" augroup AutoSaveFolds
"   autocmd!
"   autocmd BufWinLeave * mkview 1
"   autocmd BufWinEnter * silent! loadview 1
" augroup END


" --- OTHER SETTINGS ---
" [  Builtin Autocomplete (omnifunc) ] ----{
    "autocmd FileType python set omnifunc=python3complete#Complete
    "autocmd FileType python setl ofu=pythoncomplete#CompletePHP
    "autocmd FileType php setl ofu=phpcomplete#CompletePHP
    "autocmd FileType ruby,eruby setl ofu=rubycomplete#Complete
    "autocmd FileType html,xhtml setl ofu=htmlcomplete#CompleteTags
    "autocmd FileType c setl ofu=ccomplete#CompleteCpp
    "autocmd FileType css setl ofu=csscomplete#CompleteCSS
" }



" --- Open known binary files with macOS default app instead of as text ---
let s:binary_exts = [
    \ 'png', 'jpg', 'jpeg', 'gif', 'bmp', 'tiff', 'webp', 'ico', 'heic',
    \ 'mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv',
    \ 'mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a',
    \ 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    \ 'zip', 'tar', 'gz', '7z', 'rar', 'dmg',
    \ ]
let s:binary_patterns = []
for s:ext in s:binary_exts
    call add(s:binary_patterns, '*.'.s:ext)
    call add(s:binary_patterns, '*.'.toupper(s:ext))
endfor

function! s:OpenWithSystemApp()
    let l:file = expand('<afile>:p')
    let l:buf = expand('<abuf>')
    call job_start(['open', l:file], {'stoponexit': ''})
    call timer_start(0, {-> execute('silent! bwipeout '.l:buf)})
endfunction

augroup BinaryFileOpener
    autocmd!
    execute 'autocmd BufReadCmd '.join(s:binary_patterns, ',').' call s:OpenWithSystemApp()'
augroup END


" --- Local Overrides ---
silent! source ~/.vimrc-local.vim

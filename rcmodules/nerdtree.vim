" --- NERDTREE - FILE BROWSER ---

"LOAD SIGNIFICANTLY FASTER
"REF: https://github.com/preservim/nerdtree/issues/276
Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind', 'NERDTree'], 'commit': '690d061'}

" Plug 'scrooloose/nerdtree'  ", {'on': ['NERDTree', 'NERDTreeFind', 'NERDTreeToggle']}
" Plug 'jistr/vim-nerdtree-tabs'      " enhance nerdtree's tabs
" Plug 'ryanoasis/vim-devicons'       " add beautiful icons besides files
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  "Slow down vim significantly

">> Key Mappings
nnoremap <Leader>f :<C-U>let g:NERDTreeQuitOnOpen = 0 \| call NerdTreeAtProjectRoot()<CR>
" nnoremap <Leader>F :NERDTreeFind<CR>zz
" ff: tree closes after opening a file; FF: stays open (the key used last decides)
nnoremap ff :<C-U>let g:NERDTreeQuitOnOpen = 1 \| call NerdTreeFindOrRoot()<CR>zz
nnoremap FF :<C-U>let g:NERDTreeQuitOnOpen = 0 \| call NerdTreeFindOrRoot()<CR>zz
" NERDTree's buffer-local F/f beat the global FF/ff, so map them in the tree too
autocmd FileType nerdtree nnoremap <buffer><silent> ff :<C-U>let g:NERDTreeQuitOnOpen = 1<CR>
autocmd FileType nerdtree nnoremap <buffer><silent> FF :<C-U>let g:NERDTreeQuitOnOpen = 0<CR>

" Symlinks stay unresolved here; ff/FF and follow-file reveal go through s:NerdTreeReveal

" Full path of the buffer as typed, symlinked folders kept (expand('%:p') resolves them)
function! s:NerdTreeBufPath() abort
    let l:name = bufname('%')
    if empty(l:name)
        return ''
    endif
    " only a leading ~ is expanded; fnamemodify()/expand() resolve links
    let l:name = substitute(l:name, '^\~\ze\(/\|$\)', escape($HOME, '\&'), '')
    let l:full = l:name =~# '^/' ? l:name : getcwd() . '/' . l:name
    " drop ./ and ../ without resolving links
    let l:parts = []
    for l:p in split(l:full, '/')
        if l:p ==# '..'
            call remove(l:parts, -1)
        elseif l:p !=# '.' && l:p !=# ''
            call add(l:parts, l:p)
        endif
    endfor
    let l:full = '/' . join(l:parts, '/')
    " only trust it if it's the same file
    let l:full = resolve(l:full) ==# resolve(expand('%:p')) ? l:full : expand('%:p')
    " work file opened by real path: show it via the cwd checkout's tmp/workfiles link
    if exists('g:loaded_workfiles')
        let l:full = v:lua.require('workfiles').link_path(l:full)
    endif
    return l:full
endfunction

" Git root of the current file by its unresolved path (git rev-parse resolves links), else cwd
function! s:NerdTreeProjectRoot() abort
    let l:dir = empty(expand('%')) ? getcwd() : fnamemodify(s:NerdTreeBufPath(), ':h')
    " inside a git dir (e.g. .git/tmp/workfiles link): use the checkout it belongs to
    let l:wt = matchstr(l:dir, '^.*/\.git/worktrees/[^/]\+')
    if !empty(l:wt) && filereadable(l:wt . '/gitdir')
        return fnamemodify(trim(readfile(l:wt . '/gitdir', '', 1)[0]), ':h')
    endif
    if l:dir =~# '/\.git\(/\|$\)'
        return matchstr(l:dir, '^.\{-}\ze/\.git\(/\|$\)')
    endif
    while l:dir !=# '/'
        if isdirectory(l:dir . '/.git') || filereadable(l:dir . '/.git')
            return l:dir
        endif
        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
    return getcwd()
endfunction

" g:NERDTree and friends exist only once the lazy-loaded plugin is in
function! s:NerdTreeLoad() abort
    if !exists('g:NERDTree')
        call plug#load('nerdtree')
    endif
endfunction

" Open the tree at root without resolving it (NERDTree's :NERDTree <dir> would).
function! s:NerdTreeOpenAt(root) abort
    call g:NERDTreeCreator.CreateTabTree(g:NERDTreePath.New(a:root).str())
endfunction

" Reveal `file` in the tab's tree with the cursor on it; 0 if not under the tree root.
function! s:NerdTreeReveal(file) abort
    let l:path = g:NERDTreePath.New(a:file)
    let l:tree = g:NERDTree.ForCurrentTab()
    if !l:path.isUnder(l:tree.root.path)
        return 0
    endif
    NERDTreeFocus
    if l:path.isHiddenUnder(b:NERDTree.root.path)
        call b:NERDTree.ui.setShowHidden(1)
    endif
    let l:node = b:NERDTree.root.reveal(l:path)
    call b:NERDTree.render()
    call l:node.putCursorHere(1, 0)
    return 1
endfunction

function! NerdTreeAtProjectRoot() abort
    call s:NerdTreeLoad()
    call s:NerdTreeOpenAt(s:NerdTreeProjectRoot())
endfunction

" Always rooted at the project root, then reveal the current file in it
function! NerdTreeFindOrRoot() abort
    let l:root = s:NerdTreeProjectRoot()
    let l:file = s:NerdTreeBufPath()
    call s:NerdTreeLoad()
    if !g:NERDTree.ExistsForTab() || g:NERDTree.ForCurrentTab().root.path.str() !=# l:root
        call s:NerdTreeOpenAt(l:root)
        if empty(l:file)
            return
        endif
        wincmd p
    elseif empty(l:file)
        NERDTreeFocus
        return
    endif
    if !filereadable(l:file) || !s:NerdTreeReveal(l:file)
        NERDTreeFocus
    endif
endfunction
" nnoremap <Leader>F :NERDTree %:p:h<CR>
" Add '%' for changing root accordingly
"nnoremap <Leader>f :NERDTree %:p:h<CR>
" nnoremap gd :NERDTreeFind<CR>zz
" nnoremap gD :NERDTree<CR>

">> UI settings
let NERDTreeQuitOnOpen=0   " Keep NERDTree open after opening a file (ff sets 1, FF/<Leader>f set 0)
let NERDTreeMinimalUI=1    " Start NERDTree in minimal UI mode (No help lines)
let NERDTreeDirArrows=1    " Display arrows instead of ascii art in NERDTree
let NERDTreeHighlightCursorline = 1  "Conflict with other addon-plugins for nerdtree
" Clear the executable flag before NERDTree draws the name (no '*', no green); hooked on User nerdtree
function! s:NerdTreeNotExecutable(event) abort
    let a:event.subject.isExecutable = 0
endfunction
autocmd User nerdtree ++once call g:NERDTreePathNotifier.AddListener('init', function('s:NerdTreeNotExecutable'))
            \ | call g:NERDTreePathNotifier.AddListener('refresh', function('s:NerdTreeNotExecutable'))
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

" Pin the side tree to its window (:bn/:bp would swap a file into it); window trees excluded
function! s:PinNerdTreeWindow() abort
    if exists('b:NERDTree') && b:NERDTree.isTabTree()
        setlocal winfixbuf
        nnoremap <buffer> = <Nop>
        nnoremap <buffer> - <Nop>
    endif
endfunction
autocmd User NERDTreeInit call s:PinNerdTreeWindow()
" winfixbuf is window-local: re-pin on reopen, or quickfix <CR> may open files in the tree
autocmd BufWinEnter NERD_tree_tab_* call s:PinNerdTreeWindow()
" conceallevel is window-local: a new window takes global 0 and shows ^G delimiters
autocmd BufWinEnter,WinEnter NERD_tree_* setlocal conceallevel=2 concealcursor=nvic

" Auto-refresh the root every 10 seconds
" Timer only runs while the NERDTree buffer is open.
let s:nerdtree_refresh_timer = -1

" Refresh blocks j/k (~600ms on big trees): hold off while the cursor is moving
let s:nerdtree_last_move = 0.0
autocmd CursorMoved NERD_tree_* let s:nerdtree_last_move = reltimefloat(reltime())

function! s:NerdTreeAutoRefresh(timer) abort
    if reltimefloat(reltime()) - s:nerdtree_last_move < 2
        return
    endif
    " Normal mode in the tree only: a refresh from another window drops a visual selection
    if &filetype !=# 'nerdtree' || mode(1) !=# 'n'
        return
    endif
    silent! NERDTreeRefreshRoot
    silent! call s:NerdTreeGitHighlight()
endfunction

" Highlight dirty and git-ignored files vs GitDiffBase(), git re-queried every 3s at most
function! s:NerdTreeGitHighlightColors() abort
    highlight default NERDTreeGitDirtyFile cterm=bold ctermfg=154 gui=bold guifg=#aeee00
    highlight default NERDTreeGitDirtyDir ctermfg=154 guifg=#aeee00
    highlight default NERDTreeGitIgnored ctermfg=243 guifg=#767676
    highlight default NERDTreeSymlink ctermfg=81 guifg=#5fd7ff
    highlight default NERDTreeExec ctermfg=141 guifg=#af87ff
endfunction
call s:NerdTreeGitHighlightColors()
autocmd ColorScheme * call s:NerdTreeGitHighlightColors()
let s:git_dirty = {}
" Ignored dir is listed once (git --directory) and covers its contents
let s:git_ignored = {}
let s:git_dirty_key = ''
let s:git_dirty_at = 0.0
" '(ign)' / '(sym)' / '(hard)' / '(exc)' after the name
let s:git_ignored_ns = has('nvim') ? nvim_create_namespace('nerdtree_git_ignored') : -1

function! s:NerdTreeGitDirtySet(root) abort
    let l:base = exists('*GitDiffBase') ? GitDiffBase() : 'HEAD'
    let l:key = a:root . '@' . l:base
    if l:key ==# s:git_dirty_key && reltimefloat(reltime()) - s:git_dirty_at < 3
        return s:git_dirty
    endif
    let s:git_dirty_key = l:key
    let s:git_dirty_at = reltimefloat(reltime())
    let s:git_dirty = {}
    let s:git_ignored = {}
    " Paths relative to the tree root so symlinked roots match
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
    for l:rel in systemlist(l:git . 'ls-files --others --ignored --exclude-standard --directory')
        let s:git_ignored[a:root . '/' . substitute(l:rel, '/$', '', '')] = 1
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
    let l:positions = {'NERDTreeGitDirtyFile': [], 'NERDTreeGitDirtyDir': [], 'NERDTreeGitIgnored': [],
                \ 'NERDTreeSymlink': [], 'NERDTreeExec': []}
    " line number -> [[' (ign)', group], ...] shown after the name
    let l:marks = {}
    " Skip when neither the tree nor the git set changed since last time
    let l:sig = b:changedtick . '@' . s:git_dirty_at
    if get(b:, 'nerdtree_git_hl_sig', '') ==# l:sig
        noautocmd call win_gotoid(l:curWin)
        return
    endif
    let b:nerdtree_git_hl_sig = l:sig
    " One top-down pass tracking the dir per indent level (ui.getPath() per line is O(n^2))
    let l:ui = b:NERDTree.ui
    let l:dirs = {}
    " whether the dir at each indent level is ignored, so its contents are too
    let l:ignoredDirs = {}
    let l:root = substitute(b:NERDTree.root.path.str(), '/$', '', '')
    let l:rootLine = l:ui.getRootLineNum()
    for l:lnum in range(l:rootLine + 1, line('$'))
        let l:line = getline(l:lnum)
        let l:name = l:ui._stripMarkup(l:line)
        if empty(l:name)
            continue
        endif
        let l:indent = l:ui._indentLevelFor(l:line)
        let l:isDir = l:name =~# '/$'
        let l:name = substitute(l:name, '/$', '', '')
        let l:path = get(l:dirs, l:indent - 1, l:root) . '/' . l:name
        let l:ignored = get(l:ignoredDirs, l:indent - 1, 0) || has_key(s:git_ignored, l:path)
        if l:isDir
            let l:dirs[l:indent] = l:path
            let l:ignoredDirs[l:indent] = l:ignored
        endif
        let l:kind = s:NerdTreeLinkKind(l:path)
        if !empty(l:kind)
            let l:marks[l:lnum] = [[' (' . l:kind . ')', l:kind ==# 'exc' ? 'NERDTreeExec' : 'NERDTreeSymlink']]
        endif
        if has_key(s:git_ignored, l:path)
            let l:marks[l:lnum] = get(l:marks, l:lnum, []) + [[' (ign)', 'NERDTreeGitIgnored']]
        endif
        " git state wins the name's color; link/exec color only shows on clean files
        let l:group = get(l:dirty, l:path, l:ignored ? 'NERDTreeGitIgnored'
                    \ : empty(l:kind) ? '' : l:marks[l:lnum][0][1])
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
        if l:m.group =~# '^NERDTree\(GitDirty\|GitIgnored\|Symlink\|Exec\)'
            call matchdelete(l:m.id)
        endif
    endfor
    for [l:group, l:pos] in items(l:positions)
        " Older vims accept at most 8 positions per matchaddpos() call
        for l:i in range(0, len(l:pos) - 1, 8)
            call matchaddpos(l:group, l:pos[l:i : l:i + 7])
        endfor
    endfor
    if s:git_ignored_ns >= 0
        call nvim_buf_clear_namespace(0, s:git_ignored_ns, 0, -1)
        for [l:lnum, l:text] in items(l:marks)
            " eol virt_text already starts one cell after the name, so drop the first leading space
            let l:text[0][0] = l:text[0][0][1:]
            call nvim_buf_set_extmark(0, s:git_ignored_ns, str2nr(l:lnum) - 1, 0,
                        \ {'virt_text': l:text, 'virt_text_pos': 'eol'})
        endfor
    endif
    noautocmd call win_gotoid(l:curWin)
endfunction

" 'sym', 'hard' (other hard links), 'exc' (executable), else ''; getftype() doesn't follow links
function! s:NerdTreeLinkKind(path) abort
    let l:type = getftype(a:path)
    if l:type ==# 'link'
        return 'sym'
    elseif l:type !=# 'file'
        return ''
    elseif has('nvim') && get(luaeval('vim.loop.fs_lstat(_A) or {}', a:path), 'nlink', 1) > 1
        return 'hard'
    endif
    return getfperm(a:path) =~# 'x' ? 'exc' : ''
endfunction

function! s:StartNerdTreeAutoRefresh() abort
    if s:nerdtree_refresh_timer ==# -1
        let s:nerdtree_refresh_timer = timer_start(10000, function('s:NerdTreeAutoRefresh'), {'repeat': -1})
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
    " BufWinLeave stops the timer; reshowing the buffer doesn't re-fire FileType
    autocmd BufWinEnter NERD_tree_* call s:StartNerdTreeAutoRefresh()
    autocmd BufWinLeave NERD_tree_* call s:StopNerdTreeAutoRefresh()
endif
" Re-highlight right away after open/close shifts lines (git set is cached)
autocmd TextChanged NERD_tree_* silent! call s:NerdTreeGitHighlight()
" :ChangeGitDiffBase (vimrc-functions.vim) -- drop the cached git set and repaint now
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
" O on a file opens it like <CR>/o so ff's close-on-open applies; added on NERDTreeInit (lazy-loaded)
function! NerdTreeOpenFileNode(node) abort
    call a:node.activate({'reuse': 'all', 'where': 'p', 'keepopen': !nerdtree#closeTreeOnOpen()})
endfunction
autocmd User NERDTreeInit ++once call NERDTreeAddKeyMap({ 'key': 'O', 'scope': 'FileNode',
            \ 'callback': 'NerdTreeOpenFileNode', 'quickhelpText': 'open file (like o)' })

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


" ============= End of File ==================
" Follow the current buffer: reveal it in the open tree without taking focus, files under root only
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
    let l:file = s:NerdTreeBufPath()
    let l:root = substitute(l:tree.root.path.str(), '/$', '', '')
    if !filereadable(l:file) || stridx(l:file, l:root . '/') != 0
        return
    endif
    let s:nerdtree_revealing = 1
    let l:win = win_getid()
    try
        silent call s:NerdTreeReveal(l:file)
    finally
        noautocmd call win_gotoid(l:win)
        let s:nerdtree_revealing = 0
    endtry
endfunction
autocmd BufEnter * call s:NerdTreeRevealCurrent()

" Only NERDTree left in the tab: :q/ZZ quits nvim (shows an unsaved hidden buffer), :bdelete opens an empty window
let s:nerdtree_quit_requested = 0
autocmd QuitPre * let s:nerdtree_quit_requested = 1
" QuitPre also fires for :q on a split with other windows; drop it once idle
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

echom 'Loaded ' . expand('<sfile>:t') |redraw

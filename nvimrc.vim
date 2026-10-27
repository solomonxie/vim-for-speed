"----------------------------------------------------
"            __     ___           ____   ____       -
"            \ \   / (_)_ __ ___ |  _ \ / ___|      -
"             \ \ / /| | '_ ` _ \| |_) | |          -
"              \ V / | | | | | | |  _ <| |___       -
"               \_/  |_|_| |_| |_|_| \_\\____|      -
"                                                   -
"----------------------------------------------------
"------Modularized Neovim Configuration File---------

" DEFINE AT TOP BEFORE PLUGINS REGISTER
let mapleader = ","
" let maplocalleader = ""

" Enable Byte-compilation for Lua modules (Neovim 0.9.1+)
if has('nvim-0.9.1')
    lua vim.loader.enable()
endif

" --- INSTALL DEPENDENCIES ---
" $ brew install ctags
" $ brew install --HEAD universal-ctags/universal-ctags/universal-ctags
" $ pip install pynvim neovim
" $ pip install python-lsp-server[all] pycodestyle
" $ pip install python-language-server
" $ pip install pyright  # requires npm install neovim typescript
" $ pip install pylint mypy
" $ pip install flake8==3.9.2  # 4.0 no longer respect user config file
" $ npm install -g neovim
" $ npm install -g vim-language-server
" $ npm install -g typescript typescript-language-server
" $ npm install -g bash-language-server
" For more missing dependencies:
" :checkhealth
" On MacOS, grand permission for entire Neovim program:
" $ sudo xattr -r -d com.apple.quarantine ~/nvim-macos-0.11.4/

" --- VIM-PLUG MANAGER FOR PLUGINS ---
" https://github.com/junegunn/vim-plug
" if !filereadable(expand('~/.vim/autoload/plug.vim'))
"     echo 'Downlading vim-plug manager...'
"     let url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"     call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' . url)
"     echo 'Done.'
" endif

let g:lua_configs = []  "Append if a plugin module requires a Lua config after all plugins are loaded

call plug#begin('~/vim_plugged')
    "{Common}
        source ~/.config/nvim/rcmodules/perf_profiling.vim  "Performance Profiling tips
        source ~/.config/nvim/rcmodules/nvim_provider.vim  "Important
        source ~/.config/nvim/rcmodules/misc.vim
        " source ~/.config/nvim/rcmodules/hop.vim  "Textobject hop
    "{UI}
        " source ~/.config/nvim/rcmodules/indent_line.vim  "BUGGY
        source ~/.config/nvim/rcmodules/blankline.vim  "INDENT-LINE
        " source ~/.config/nvim/rcmodules/airline.vim  "681ms+
        source ~/.config/nvim/rcmodules/buftabline.vim  "Blazing fast!
        source ~/.config/nvim/rcmodules/lightline.vim  "Blazing fast!
        " source ~/.config/nvim/rcmodules/statusline.vim
        source ~/.config/nvim/rcmodules/nerdtree.vim
        " source ~/.config/nvim/rcmodules/neotree.vim  "BUGGY!!! HEAVY
        " source ~/.config/nvim/rcmodules/nvim-tree.vim  "fast, simple, but sometimes annoying
        source ~/.config/nvim/rcmodules/netrw.vim
        " source ~/.config/nvim/rcmodules/vinegar.vim
        " source ~/.config/nvim/rcmodules/chadtree.vim
        " source ~/.config/nvim/rcmodules/semshi.vim
        " source ~/.config/nvim/rcmodules/ctags.vim  "300ms+, 99% CPU
        " source ~/.config/nvim/rcmodules/tagbar.vim  "300ms+, ctag based, heavy
        " source ~/.config/nvim/rcmodules/vista.vim  "TAG BAR, ctag based
        " source ~/.config/nvim/rcmodules/markbar.vim
        " source ~/.config/nvim/rcmodules/syntastic.vim
        " source ~/.config/nvim/rcmodules/telescope.vim  "SLOW
        " source ~/.config/nvim/rcmodules/whichkey.vim
    "{Completion | Usages | Definitions}
        " source ~/.config/nvim/rcmodules/replace.vim
        source ~/.config/nvim/rcmodules/fzf.vim
        " source ~/.config/nvim/rcmodules/ale.vim  "Async linting
        " source ~/.config/nvim/rcmodules/deoplete.vim
        " source ~/.config/nvim/rcmodules/ultisnips.vim  "DISABLED for now, see snippets.vim
        source ~/.config/nvim/rcmodules/anyjump.vim
        " source ~/.config/nvim/rcmodules/YCM.vim
        " source ~/.config/nvim/rcmodules/coc.vim
        " source ~/.config/nvim/rcmodules/coq.vim
        " source ~/.config/nvim/rcmodules/ncm2.vim
        source ~/.config/nvim/rcmodules/autopairs.vim  "Brakets/Quotes
        source ~/.config/nvim/rcmodules/treesitter.vim
    "{Language Servers - LSP}
        " LSP
        source ~/.config/nvim/rcmodules/nvim_lspconfig.vim  "Required!
        source ~/.config/nvim/rcmodules/lsp-mason.vim  "LSP Installer, all languages
        source ~/.config/nvim/rcmodules/lsp-makefile.vim  "autotools-language-server, not in Mason
        " source ~/.config/nvim/rcmodules/outline.vim  "Buggy split_command (leaves stray "vs" buffer)
        " source ~/.config/nvim/rcmodules/nvim_lsp_compl.vim
        " source ~/.config/nvim/rcmodules/nvim_compe.vim  "Deprecated
        source ~/.config/nvim/rcmodules/nvim_cmp.vim
        " source ~/.config/nvim/rcmodules/lspsaga.vim  "Buggy
        " source ~/.config/nvim/rcmodules/nvim_dap.vim  "For general debugging
    "{Git}
        source ~/.config/nvim/rcmodules/tig.vim
        source ~/.config/nvim/rcmodules/visidata.vim
        " source ~/.config/nvim/rcmodules/fugitive.vim
        source ~/.config/nvim/rcmodules/gitgutter.vim  "50ms+
        " source ~/.config/nvim/rcmodules/gitsigns.vim  "BLAZING FAST: 0.2262ms
        " source ~/.config/nvim/rcmodules/blame.vim
    "{Python}
        " source ~/.config/nvim/rcmodules/jedi.vim
        " source ~/.config/nvim/rcmodules/ped.vim
    "{NodeJS}
        " source ~/.config/nvim/rcmodules/vimspector.vim
        " source ~/.config/nvim/rcmodules/nvim_dap.vim
    "{AI}
        " source ~/.config/nvim/rcmodules/llm-copilot.vim
        " source ~/.config/nvim/rcmodules/llm-gen.vim  "For local LLMs (Ollama)
        " source ~/.config/nvim/rcmodules/llm-llm_nvim.vim  "Complex settings, buggy UI
        " source ~/.config/nvim/rcmodules/llm-chatgpt.vim  "Failed to setup, too many heavy deps caused many errors
        " source ~/.config/nvim/rcmodules/llm-gp.vim  "Ugly design, not easy to use
        " source ~/.config/nvim/rcmodules/llm-codecompanion.vim  "Not yet knowing how to autocomplete
        " source ~/.config/nvim/rcmodules/llm-yetanotherpilot.vim
    "{Others}
        " source ~/.config/nvim/rcmodules/dadbod.vim  "DB client
call plug#end()
echom 'All plugins loaded.' |redraw


" Some plugins require env variables (vim/neovim does not take env from shell)
silent! source ~/.vimrc-env.vim


" --- NVIM LUA CONFIGS (MUST BE LOADED AFTER PLUGINS) ---
" Load lua configs defined elsewhere
for path in g:lua_configs
    execute 'luafile ' . path
    echom 'Loaded Lua config: ' . path |redraw  "Redraw prevent echo popup message
endfor

" LSPs:
luafile ~/.config/nvim/rcmodules/lua/lsp-python.lua
" luafile ~/.config/nvim/rcmodules/lua/lsp-sql.lua  "not needed, treesitter highlights SQL
luafile ~/.config/nvim/rcmodules/lua/lsp-vim.lua
luafile ~/.config/nvim/rcmodules/lua/lsp-css.lua
luafile ~/.config/nvim/rcmodules/lua/lsp-js.lua
luafile ~/.config/nvim/rcmodules/lua/lsp-html.lua
luafile ~/.config/nvim/rcmodules/lua/lsp-cpp.lua
luafile ~/.config/nvim/rcmodules/lua/lsp-terraform.lua
" luafile ~/.config/nvim/rcmodules/lua/lsp-ruby.lua
luafile ~/.config/nvim/rcmodules/lua/markdown.lua
" Others:
luafile ~/.config/nvim/rcmodules/lua/nvimrc-functions.lua
luafile ~/.config/nvim/rcmodules/lua/misc-plugins.lua
luafile ~/.config/nvim/rcmodules/lua/snippets.lua
luafile ~/.config/nvim/rcmodules/lua/claude_history.lua
luafile ~/.config/nvim/rcmodules/lua/pudb_breakpoints.lua


" --- IMPORT MODULES ---
source ~/.config/nvim/vimrc-functions.vim
source ~/.config/nvim/vimrc-commands.vim
source ~/.config/nvim/vimrc-keymappings.vim
source ~/.config/nvim/vimrc-ui.vim

luafile ~/.config/nvim/rcmodules/lua/nvimrc-ui.lua



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
set mousemodel=extend  "Right-click extends selection instead of opening the nvim PopUp menu
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

" Neovim feature of :%s/a/b/
" if has('nvim')
"     set inccommand=split
" endif

set isfname-==  "When using 'gf', ignore '=' as part of the file name


" --- Vim / NeoVim Persistent Layer (Shada & VimInfo) ---
" Persistent mechanism will keep session/marks/jumplist/buffers...

" SHADA: (Neovim) options - format: set shada=FLAGS
"   'N - Required: Save marks for the last N files (0 = disable marks/jump locations)
"   !  - Save/restore global variables that start with uppercase and contain lowercase (e.g., MyVar)
"        Marks include: file marks ('a, 'b), jump locations (Ctrl-O/Ctrl-I), last position in files
"   <N - Save up to N lines for each register (yank/delete history)
"   @N - Save the last N registers (yank/delete history)
"   :N - Save the last N command-line history entries
"   /N - Save the last N search history entries
"   %N - Save/restore buffer list (N = number of buffers, 0 = disable)
"   sN - Only save items smaller than N KB (prevents saving large text blocks)
"   c  - Save encoding of the file (when 'encoding' differs from 'utf-8')
"   n  - Name of the shada file (default: ~/.local/share/nvim/shada/main.shada)
"   r  - Removable media (comma-separated list of paths, e.g., r/tmp,r/media)
"   h  - Disable search highlighting (hlsearch) when loading shada file
"
" Example: set shada=!,'0,<50,@100,:100,/100,%,s10,h
"          (saves everything except marks/jump locations)
set shada=
"^  super annoying, hence disable it all.

" VIMINFO: (Vim only, not used by Neovim) options - format: set viminfo=FLAGS
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
set foldtext=         " Neovim: setting this to empty keeps syntax highlighting on the fold line

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
    call jobstart(['open', l:file], {'detach': v:true})
    call timer_start(0, {-> execute('silent! bwipeout '.l:buf)})
endfunction

augroup BinaryFileOpener
    autocmd!
    execute 'autocmd BufReadCmd '.join(s:binary_patterns, ',').' call s:OpenWithSystemApp()'
augroup END

" --- Local Overrides ---
silent! source ~/.vimrc-local.vim

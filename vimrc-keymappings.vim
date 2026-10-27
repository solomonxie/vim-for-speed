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
let mapleader = ","
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
" instead of nvim; exit terminal-mode and suspend nvim like Normal-mode does
tnoremap <C-z> <C-\><C-n>:suspend<CR>


" --- LEADER KEY MAPPINGS ---
" vnoremap <leader>r "1y:1,10 s/<C-r>1/<C-r>1/gc<Left><Left><Left>*<BS>
" vnoremap <leader>r :call ReplaceSelection()<CR>
nnoremap <Leader>v v$h
nnoremap <Leader>0 v^

vnoremap <Leader>y "+y
nnoremap <Leader>p "+p
vnoremap <Leader>p "+p

nnoremap <Leader>L :source ~/.config/nvim/nvimrc.vim<CR>

nnoremap <leader>R :call LoadSession()<CR><ESC>


"Git blame current line
" nnoremap gb :execute "!git blame -L " . line(".") . ",+1 % "<CR>
" Toggle blame of the cursor line as virtual text (rcmodules/lua/git_blame.lua)
nnoremap <silent> tb :lua GitBlameToggle()<CR>


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
nnoremap <silent> <Leader>q :call CloseBuffer()<CR>
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



" --- LSP Common Keys ---
" Native gd only understands brace-scoped declarations, not Python's
" indentation-based scoping, so it fails to jump to defs outside the
" current block; use LSP's actual definition lookup instead.
nnoremap gd :lua vim.lsp.buf.definition()<CR>
nnoremap <Leader>d :lua vim.lsp.buf.definition()<CR>
" nnoremap <Leader>D :lua vim.diagnostic.open_float()<CR>
nnoremap <Leader>r :lua vim.lsp.buf.rename('')<LEFT><LEFT>
nnoremap <Leader>u :lua vim.lsp.buf.references()<CR>
" nnoremap <Leader>ca :lua vim.lsp.buf.code_action()<CR>
nnoremap <C-p> :lua vim.diagnostic.goto_prev()<CR>
nnoremap <C-n> :lua vim.diagnostic.goto_next()<CR>
nnoremap K :lua vim.lsp.buf.hover({border = 'rounded'}) <CR>
" nnoremap H :lua vim.lsp.buf.signature_help({border = 'rounded'}) <CR>
nnoremap <Leader>o :lua vim.lsp.diagnostic.set_qflist()<CR>

" :LspInfo is aliased to :checkhealth vim.lsp on nvim 0.11+; make sure `q` closes it
autocmd FileType checkhealth,lspinfo nnoremap <buffer><silent><nowait> q :close<CR>
" References (,u), quickfix and location lists
autocmd FileType qf nnoremap <buffer><silent><nowait> q :call CloseWindowGoBack()<CR>

" Render to HTML and open in the browser: buffer-local so it only exists in markdown
" (gp/gP are already taken by gitgutter's plugin defaults, see rcmodules/gitgutter.vim notes)
autocmd FileType markdown command! -buffer MarkdownPreview call PreviewMarkdown()
autocmd FileType markdown nnoremap <buffer><silent> <leader>P :MarkdownPreview<CR>


" --- Plugin Keys ---
"vim/rcmodules/misc.vim
" map <LocalLeader>d
" plugin defaults, not set by me: m=nvim-marks (overrides built-in set-mark), ds/cs/cS/ys/yS/yss/ySs/ySS=vim-surround, S/gS(visual)/<C-s>(insert)=vim-surround, ,c/,cc/,cu=vim-commentary, */#(visual)=vim-visual-star-search, <Leader>bd=bclose.vim

"vim/rcmodules/hop.vim
" map fw

"vim/rcmodules/nerdtree.vim
" map <Leader>f, map ff (closes after opening a file), map FF (stays open)
" plugin defaults, not set by me (buffer-local inside NERDTree window): o/t/T/i/s/x/X/m/r/R/D/C/u/?/q ... see :help NERDTreeMappings

"vim/after/ftplugin/netrw.vim
" map o, map p, map q, map qq (buffer-local, netrw filetype)

"vim/rcmodules/netrw.vim
" map q (buffer-local, close netrw)
" plugin defaults, not set by me (buffer-local inside netrw window): -/%/d/D/R/mf/mt/mc ... see :help netrw-quickmap

"vim/rcmodules/tagbar.vim (disabled, ctags-based, replaced by Plug 'solomonxie/nvim-lsp-tagbar')
" map ft, map g], map g[
" plugin defaults, not set by me (buffer-local inside Tagbar window): see :help tagbar-keys

"vim/rcmodules/outline.vim (disabled: buggy split_command, flat display for pylsp -- replaced by Plug 'solomonxie/nvim-lsp-tagbar')
" map ft (toggle symbol outline)

"Plug 'solomonxie/nvim-lsp-tagbar'
" map ft (toggle right symbol bar)
" buffer-local inside the bar: j/k preview symbol in the source window, o show/hide callers inline, <CR> jump to symbol + close, p jump to parent symbol, q/<Esc> close

"vim/rcmodules/fzf.vim
" map fd, map fa, map fb, map fh (command history), map fc (commands), map fm, map FD, map FA
" plugin defaults, not set by me (inside fzf popup): Ctrl-t/Ctrl-x/Ctrl-v=tab/split/vsplit, Ctrl-/=toggle preview ... see :help fzf-vim-mappings

"vim/rcmodules/anyjump.vim
" map fu
" (plugin's own default keybindings explicitly disabled via g:any_jump_disable_default_keybindings)

"vim/rcmodules/autopairs.vim
" no maps set directly here (options only)
" plugin defaults, not set by me (insert mode): <M-p>=toggle, <M-e>=fast-wrap, <M-n>=jump, <M-b>=back-insert

"vim/rcmodules/tig.vim
" map tt
" plugin defaults, not set by me (buffer-local inside Tig window): e/<C-o>/<C-t>/<C-s>/<C-v>=open entry, <ESC>o/t/s/v=open commit ... see g:tig_explorer_keymap_*

"vim/rcmodules/visidata.vim
" map tv (:VisiData [file]: data file under the cursor, else the current one)

"vim/rcmodules/gitgutter.vim
" map gz, map gp, map gn, map gP
" plugin defaults, not set by me (buffer-local): [c/]c=prev/next hunk, <Leader>hs=stage hunk, <Leader>hu=undo hunk, <Leader>hp=preview hunk, ic/ac=hunk text-object

"vim/rcmodules/lua/snippets.lua
" map <C-k> (insert/select/visual, expand or wrap), <C-j> (insert/select, jump back)

"vim/rcmodules/lua/nvim_cmp.lua
" map <Tab>, <C-l>, <C-p>, <C-n> (insert mode, completion menu)
" plugin defaults, not set by me (cmp.mapping.preset.insert, insert mode): <C-y>=confirm, <C-e>=abort (commented out in my override table, but preset default still applies)


" ============= End of File ==================
echom 'Loaded ' . expand('<sfile>:t') |redraw

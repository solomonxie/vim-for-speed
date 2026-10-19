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
" On ,c instead of gc (gc opens the Claude history pane). Mapping <Plug>Commentary here,
" before the plugin loads, stops it from adding its own gc maps.
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


"REF: https://github.com/nathom/filetype.nvim (buggy for higher nvim version)
" Plug 'nathom/filetype.nvim'  "Speed-up over filetype.vim for 10ms
" let g:did_load_filetypes = 1

"REF: https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround', {'commit': '3d188ed'}  "Add brackets/quotesAdd brackets/quotes

"REF: https://github.com/kizza/actionmenu.nvim
Plug 'kizza/actionmenu.nvim', {'commit': 'e8d547b'}  "Popup Context Menu


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

"REF: https://github.com/ahmedkhalf/project.nvim
" Plug 'ahmedkhalf/project.nvim'
"^ LUA CONFIGS: vim/rcmodules/lua/misc.lua

"REF: https://github.com/mattn/emmet-vim
" Plug 'mattn/emmet-vim'  "Not working


"REF: https://github.com/luukvbaal/nnn.nvim
" Plug 'luukvbaal/nnn.nvim'  "VERY SLOW
" nnoremap fn :NnnPicker<CR>

"REF: https://github.com/Shatur/neovim-session-manager
"Plug 'Shatur/neovim-session-manager'

"REF: https://github.com/mhinz/vim-signify
" Plug 'mhinz/vim-signify'  "Git Diff

" Plug 'lewis6991/gitsigns.nvim'

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


"REF: https://github.com/solomonxie/nvim-marks
Plug 'solomonxie/nvim-marks', { 'branch': 'master' }
"^ Marks saved to <g:nvim_marks_dir>/<repo>/marks-history.json, set in ~/.vimrc-local.vim

"REF: https://github.com/solomonxie/nvim-workfiles
Plug 'solomonxie/nvim-workfiles', { 'branch': 'master' }
"^ :WorkFiles, :WorkNew, :WorkDir, :WorkGrep. Root is g:workfiles_root, set in ~/.vimrc-local.vim
nnoremap fw :WorkFiles<CR>

"REF: https://github.com/solomonxie/nvim-repo-browser
Plug 'solomonxie/nvim-repo-browser', { 'branch': 'master', 'do': 'npm install && npm run build' }

"REF: https://github.com/solomonxie/nvim-lsp-tagbar
Plug 'solomonxie/nvim-lsp-tagbar', { 'branch': 'master' }

"REF: https://github.com/hashivim/vim-terraform
" Syntax highlighting for Terraform
Plug 'hashivim/vim-terraform', {'commit': '520498f'}


" ============= End of File ==================
echom 'Loaded ' . expand('<sfile>:t') |redraw

" --- TREE SITTER - FOR BUILDING PLUGINS ---

" REF: https://tree-sitter.github.io/tree-sitter/
" REF: https://github.com/nvim-treesitter/nvim-treesitter

" ACTIONS:
" 1. Download Nvim 0.5+ Release
" 2. :PlugInstall
" 3. :TSInstall python javascript bash json

Plug 'nvim-treesitter/nvim-treesitter', {'tag': 'v0.10.0'}
" Plug 'nvim-treesitter/playground'

Plug 'nvim-treesitter/nvim-treesitter-textobjects', {'commit': '5ca4aaa6efdcc59be46b95a3e876300cfead05ef'}

" NOTE: also check settings in `./vim/nvimrc.vim` to avoid conflicts
" Treesitter folding is powerful but can be very slow on large files.
" We only enable it for files smaller than 100KB.
augroup TreesitterFolding
    autocmd!
    autocmd BufReadPost,BufNewFile *
        \ if getfsize(expand("<afile>")) < 100000 && getfsize(expand("<afile>")) != -2 |
        \   setlocal foldmethod=expr |
        \   setlocal foldexpr=v:lua.vim.treesitter.foldexpr() |
        \ else |
        \   setlocal foldmethod=indent |
        \ endif
augroup END


" Autoread reloads (see checktime timer in nvimrc.vim) can leave highlights at
" their old byte offsets, splitting words like t|ry. Re-parse from scratch.
augroup TreesitterReloadFix
    autocmd!
    autocmd FileChangedShellPost * lua
        \ local b = tonumber(vim.fn.expand('<abuf>'))
        \ if vim.treesitter.highlighter.active[b] then
        \     vim.treesitter.stop(b)
        \     vim.treesitter.start(b)
        \ end
augroup END


" Post-Vimplug setup
let g:lua_configs += ['~/.config/nvim/rcmodules/lua/treesitter.lua']

" Claude Code transcripts saved as markdown: Claude's part of each prompt sits between
" <!-- claude {{{ --> and <!-- }}} -->, folded on open; the prompts (# headings) stay visible.
augroup ClaudeTranscriptFolding
    autocmd!
    autocmd BufReadPost,BufNewFile *-claude-*.md setlocal foldmethod=marker foldlevel=0
augroup END

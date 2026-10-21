--REF: https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'go',
        'html',
        'javascript',
        'lua',
        'markdown',
        'python',
        'sql',
        'tsx',
        'typescript',
        'vim',
        -- Configs
        'json',
        'yaml',
        'toml',
        'make',
        'dockerfile',
        -- Frameworkds
        'vue',
        'vimdoc',
        'terraform',
        'svelte',
        'markdown_inline',
    },
    sync_install = false,
    auto_install = true,

    -- UI
    highlight = {
        enable = true,
        -- Disable for large files to improve performance
        disable = function(lang, buf)
            local max_filesize = 200 * 1024 -- 200 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
            -- Also disable if file is too long
            if vim.api.nvim_buf_line_count(buf) > 5000 then
                return true
            end
        end,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Using this option may slow down your editor.
        additional_vim_regex_highlighting = false,
    },

    -- Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            keymaps = {
                ["af"] = "@function.outer",  -- type `vaf` to select whole function
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",  -- type `vac` to select whole class
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            set_jumps = true, -- add jumps to the jumplist (CTRL-O/I)
            goto_next_start = {
                ["]]"] = "@function.outer",
                ["]c"] = "@class.outer",
            },
            goto_next_end = {
                ["]["] = "@function.outer",
                ["]C"] = "@class.outer",
            },
            goto_previous_start = {
                ["[["] = "@function.outer",
                ["[c"] = "@class.outer",
            },
            goto_previous_end = {
                ["[]"] = "@function.outer",
                ["[C"] = "@class.outer",
            },
        }
    },

    -- (Playground removed as it is deprecated)
})

-- .jsonl (one JSON value per line) is highlighted by the json parser
vim.treesitter.language.register('json', 'jsonl')

-- Syntax Highlights are handled in vim/vimrc-ui.vim

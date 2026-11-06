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
            -- markdown parses fast, and its regex fallback loses track after a code fence in a long
            -- file (headings stop highlighting), so it gets a much higher limit: Claude transcripts
            local markdown = lang == 'markdown' or lang == 'markdown_inline'
            local max_bytes = markdown and 3 * 1024 * 1024 or 200 * 1024
            local max_lines = markdown and 50000 or 5000
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_bytes then
                return true
            end
            if vim.api.nvim_buf_line_count(buf) > max_lines then
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
        -- keys set below per buffer, so they don't override a filetype's own ]] / [[
        move = { enable = false, set_jumps = true },
    },

    -- (Playground removed as it is deprecated)
})

-- ]] [[ ][ [] jump between functions, ]c [c ]C [C between classes, only where they don't clobber
-- something: a filetype's own ]] / [[ (markdown headings, vim, sql, python...) are kept, and in diff
-- mode ]c / [c still jump between changes. A buffer whose language has no textobjects query keeps
-- Vim's defaults.
local function textobject_moves(buf)
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    if not lang or not require('nvim-treesitter.query').has_query_files(lang, 'textobjects') then
        return
    end
    local move = require('nvim-treesitter.textobjects.move')
    local function set(lhs, fn, query)
        local mapped = vim.fn.maparg(lhs, 'n', false, true)
        if mapped.buffer == 1 then
            return  -- the filetype's ftplugin (or an after/ftplugin) owns it
        end
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            if vim.wo.diff and (lhs:sub(2) == 'c') then
                vim.cmd('normal! ' .. vim.v.count1 .. lhs)
            else
                fn(query)
            end
        end, { buffer = buf, silent = true, desc = 'Treesitter: ' .. query })
    end
    set(']]', move.goto_next_start, '@function.outer')
    set('][', move.goto_next_end, '@function.outer')
    set('[[', move.goto_previous_start, '@function.outer')
    set('[]', move.goto_previous_end, '@function.outer')
    set(']c', move.goto_next_start, '@class.outer')
    set(']C', move.goto_next_end, '@class.outer')
    set('[c', move.goto_previous_start, '@class.outer')
    set('[C', move.goto_previous_end, '@class.outer')
end
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterMoves', { clear = true }),
    -- after the ftplugins and after/ftplugin files, which run before FileType autocmds finish
    callback = function(ev)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
                textobject_moves(ev.buf)
            end
        end)
    end,
})

-- .jsonl (one JSON value per line) is highlighted by the json parser
vim.treesitter.language.register('json', 'jsonl')

-- Syntax Highlights are handled in vim/vimrc-ui.vim

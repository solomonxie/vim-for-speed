
-- Src: vim/rcmodules/hop.vim
if string.find(vim.o['runtimepath'], 'hop') then
    require('hop').setup()
end


-- Src: vim/rcmodules/blankline.vim
if string.find(vim.o['runtimepath'], 'indent%-blankline') then
    require('ibl').setup({
        -- REF: `:help ibl.config`
        indent = {
            char = "▏",
            -- tab_char = { "a", "b", "c" },
            -- highlight = { "Function", "Label" },
            smart_indent_cap = true,
            priority = 2,
            repeat_linebreak = false,
        },
        whitespace = {
            remove_blankline_trail = false,
        },
        scope = { enabled = false },  -- highlight current scope
        -- show_trailing_blankline_indent = true,
    })
    local hooks = require("ibl.hooks")
    hooks.register(
        hooks.type.WHITESPACE,
        hooks.builtin.hide_first_space_indent_level
    )
end


-- Src: vim/rcmodules/gitsigns.vim
if string.find(vim.o['runtimepath'], 'gitsigns') then
    require('gitsigns').setup({
        signs_staged_enable = true,
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            interval = 100,
            follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 1000,
        status_formatter = nil, -- Use default
        max_file_length = 10000,
        preview_config = {
            -- Options passed to nvim_open_win
            border = 'single',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },
    })
end



-- Src: vim/rcmodules/misc.vim
if string.find(vim.o['runtimepath'], 'nvim%-marks') then
    -- Marks folder: g:nvim_marks_dir in ~/.vimrc-local.vim
    require('nvim-marks').setup()
end

if string.find(vim.o['runtimepath'], 'nvim%-repo%-browser') then
    require('repo-browser').setup()
end

if string.find(vim.o['runtimepath'], 'nvim%-lsp%-tagbar') then
    require('nvim-lsp-tagbar').setup({
        -- right sidebar, as wide as NERDTree; j/k shows each symbol in the source window
        position = 'right',
        width = vim.g.NERDTreeWinSize or 40,
        auto_preview = true,
        -- emmylua_ls emits no symbol for anonymous functions, so command
        -- and autocmd handlers are matched by name here instead.
        queries = {
            lua = {
                { label = '[U]', query = [[
                    ((function_call
                       name: (_) @fn
                       (#eq? @fn "vim.api.nvim_create_user_command")
                       arguments: (arguments (string content: (string_content) @name))) @scope)
                ]] },
                { label = '[A]', query = [[
                    ((function_call
                       name: (_) @fn
                       (#eq? @fn "vim.api.nvim_create_autocmd")
                       arguments: (arguments . (_) @name)) @scope)
                ]] },
            },
        },
    })
end

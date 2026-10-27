-- -- Check environment (Very fast, only check $PATH variable)
-- if vim.fn.executable('pylsp') ~= 1 then
--     print('LSP server not installed, please do $ pip install python-lsp-server[all]')
--     return
-- end

-- REF: https://github.com/python-lsp/python-lsp-server
vim.lsp.enable('pylsp')
vim.lsp.config('pylsp', {
    settings = {
        pylsp = {
            cmd = { "pylsp" },
            filetypes = {"python"},
            debounce = 100,
            single_file_support = true,
            -- skip_token_initialization=true,
            -- -- configurationSources = { "flake8" },  -- CONFLICT WITH pylsp.plugins.flake8.config
            -- init_options = { lint = false },
            plugins = {
                pylint =  { enabled = false, args = { "--rcfile", vim.fn.expand("~/.config/pylintrc") } },
                flake8 = { enabled = false },
                pylsp_flake8 = { enabled = false },
                pylsp_mypy =  { enabled = false },
                mypy =  { enabled = false },
                pycodestyle =  { enabled = true, maxLineLength = 120 },
                pyflakes =  { enabled = true },
                jedi_completion = { enabled = true, include_params = true },  -- Important for completion
            },
            -- ^ Have to specifically everything "enabled=false" otherwise enabled by default
        }
    },
    -- pylsp runs in Mason's own venv, so jedi can't see the project's packages (e.g. google.cloud)
    -- and gd on them finds nothing. Point jedi at the project's .venv, else an activated $VIRTUAL_ENV.
    before_init = function(_, config)
        local venv = config.root_dir and config.root_dir .. '/.venv' or ''
        if vim.fn.executable(venv .. '/bin/python') ~= 1 then
            venv = vim.env.VIRTUAL_ENV or ''
        end
        if vim.fn.executable(venv .. '/bin/python') == 1 then
            config.settings.pylsp.plugins.jedi = { environment = venv .. '/bin/python' }
        end
    end,
})

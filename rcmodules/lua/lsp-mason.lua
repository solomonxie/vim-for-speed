-- REF: https://github.com/mason-org/mason-lspconfig.nvim

local my_lsp_servers = {
    'pylsp',
    'vimls',
    'cssls',
    'sqlls',
    'emmet_ls',  --HTML
    'clangd',  -- C, C++
    'gopls',  -- Go
    'terraformls',  -- Terraform
    -- 'lua_ls',  -- super slow, 18s+ to load (it analyzes whole repo on first load)
    'emmylua_ls',  -- Lua, Rust-based replacement for lua_ls; see vim/.emmyrc.json
    'bashls',  -- Bash, sh, zsh
    'ts_ls',  -- TypeScript, JavaScript
}

require('mason').setup({
    -- log_level = vim.log.levels.DEBUG,
})

require('mason-lspconfig').setup({
  ensure_installed = my_lsp_servers,
  -- v2 defaults this to true, auto-enabling *any* Mason-installed server
  -- (not just ones above) -- e.g. it silently resurrected a leftover
  -- lua-language-server install. The loop below already does enabling
  -- explicitly for the servers we actually want.
  automatic_enable = false,
})
-- ^ IF GOT ERROR, run :MasonInstall <LSP_NAME> or :Mason
-- then manually select lsp serers

-- Init LSP models (we can still override each later)
for _, lsp in ipairs(my_lsp_servers) do
    vim.lsp.enable(lsp)  --New syntax after nvim v0.11
    vim.lsp.config(lsp, {})  --New syntax after nvim v0.11
end

-- bashls ships filetypes {bash, sh}; zsh scripts parse close enough that its
-- document symbols are worth having there too (shell functions and globals).
-- Must follow the loop above, which resets each server's config.
vim.lsp.config('bashls', { filetypes = { 'bash', 'sh', 'zsh' } })

-- basedpyright only for what pylsp lacks: call hierarchy (`o` in the lsp-tagbar). pylsp stays the
-- linter/completer, so basedpyright's diagnostics, hover and completion are switched off.
vim.lsp.enable('basedpyright')
vim.lsp.config('basedpyright', {
    settings = {
        basedpyright = {
            analysis = { typeCheckingMode = 'off', diagnosticSeverityOverrides = {}, autoImportCompletions = false },
            disableOrganizeImports = true,
        },
    },
    handlers = { ['textDocument/publishDiagnostics'] = function() end },
    on_attach = function(client)
        local caps = client.server_capabilities
        for _, k in ipairs({ 'hoverProvider', 'completionProvider', 'signatureHelpProvider', 'renameProvider',
                'documentSymbolProvider', 'definitionProvider', 'referencesProvider', 'documentHighlightProvider',
                'semanticTokensProvider', 'inlayHintProvider', 'codeActionProvider' }) do
            caps[k] = nil
        end
    end,
})

-- TypeScript 7 (the Go port) ships no tsserver.js for ts_ls to load, so a project on it gets its own
-- `tsc --lsp` instead, and ts_ls (with its bundled TypeScript) keeps every other project.
local ts_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock', '.git' }
-- The folder holding the nearest node_modules/typescript (the one ts_ls would load) when it has no tsserver.js
local function ts7_root(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.find('node_modules/typescript', { path = vim.fs.dirname(name), upward = true, type = 'directory' })[1]
    if not found or vim.fn.filereadable(found .. '/lib/tsserver.js') == 1 then return nil end
    local root = vim.fs.dirname(vim.fs.dirname(found))
    if vim.fn.executable(root .. '/node_modules/.bin/tsc') == 1 then return root end
end
vim.lsp.config('ts_ls', {
    root_dir = function(bufnr, on_dir)
        if not ts7_root(bufnr) then on_dir(vim.fs.root(bufnr, ts_markers) or vim.fn.getcwd()) end
    end,
})
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = function(ev)
        local root = ts7_root(ev.buf)
        if not root then return end
        vim.lsp.start({ name = 'tsc', cmd = { root .. '/node_modules/.bin/tsc', '--lsp', '--stdio' }, root_dir = root },
            { bufnr = ev.buf })
    end,
})

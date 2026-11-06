-- REF: https://github.com/mason-org/mason-lspconfig.nvim

local my_lsp_servers = {
    'pylsp',
    'vimls',
    'cssls',
    -- 'sqlls',  -- not needed: SQL highlighting (also ```sql in markdown) comes from treesitter's sql parser
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

-- basedpyright only for call hierarchy (`o` in lsp-tagbar); pylsp stays linter/completer.
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

-- gd / ,d: pylsp first, then basedpyright (jedi misresolves imports shadowed by a tests/ copy).
function _G.LspGotoDefinition()
    local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
    local order = {}
    for _, name in ipairs({ 'pylsp', 'basedpyright' }) do
        local c = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
        if c then table.insert(order, c) end
    end
    if #order == 0 then
        return vim.lsp.buf.definition()
    end
    local function try(i)
        local client = order[i]
        if not client then
            return vim.notify('No definition found', vim.log.levels.INFO)
        end
        local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
        client:request('textDocument/definition', params, function(err, result)
            if err or not result or vim.tbl_isempty(result) then
                return try(i + 1)
            end
            if result.uri or result.targetUri then result = { result } end
            if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_buf() ~= buf then return end
            if #result == 1 then
                vim.cmd("normal! m'")
                vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
            else
                vim.fn.setqflist({}, ' ', { title = 'Definitions', items = vim.lsp.util.locations_to_items(result, client.offset_encoding) })
                vim.cmd('botright copen')
            end
        end, buf)
    end
    try(1)
end

-- TypeScript 7 (Go port) has no tsserver.js: such projects get `tsc --lsp`, others keep ts_ls.
local ts_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock', '.git' }
-- Nearest node_modules/typescript folder (what ts_ls would load) that has no tsserver.js
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

-- Big files (> g:large_file_size): opened as plain text with everything per-buffer switched off,
-- like snacks.nvim's bigfile. Vim still reads the whole file into memory; for ~1GB use `tv`, less or head.
-- Off: filetype (so no syntax, ftplugin, treesitter, LSP, completion), undo history, swap, folds,
-- matchparen, indent lines, gitgutter, cursor-line blame.

vim.g.large_file_size = vim.g.large_file_size or 10 * 1024 * 1024

vim.filetype.add({
    pattern = {
        ['.*'] = {
            function(path, buf)
                local size = vim.fn.getfsize(path)
                if buf and vim.bo[buf].buftype == '' and size > vim.g.large_file_size then
                    return 'bigfile'
                end
            end,
            { priority = math.huge },
        },
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'bigfile',
    callback = function(ev)
        vim.b[ev.buf].bigfile = true
        vim.bo[ev.buf].swapfile = false
        vim.bo[ev.buf].undolevels = -1
        vim.bo[ev.buf].undofile = false
        vim.wo.foldmethod = 'manual'
        vim.wo.spell = false
        vim.bo[ev.buf].matchpairs = ''  -- matchparen has nothing to match; :NoMatchParen would be global
        pcall(vim.cmd, 'GitGutterBufferDisable')
        pcall(require('ibl').setup_buffer, ev.buf, { enabled = false })
        require('cmp').setup.buffer({ enabled = false })
        vim.schedule(function()
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
                vim.lsp.buf_detach_client(ev.buf, client.id)
            end
        end)
        vim.notify(string.format('Big file (%dMB): plain text, plugins off', vim.fn.getfsize(ev.file) / 1048576))
    end,
})

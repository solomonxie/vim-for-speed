function LspRename()
    -- REF: https://hastebin.skyra.pw/butoxuwaci.pgsql
    local curr_name = vim.fn.expand("<cword>")
    local value = vim.fn.input("LSP Rename: ", curr_name)
    local lsp_params = vim.lsp.util.make_position_params()

    if not value or #value == 0 or curr_name == value then return end

    -- request lsp rename
    lsp_params.newName = value
    vim.lsp.buf_request(0, "textDocument/rename", lsp_params, function(_, res, ctx, _)
        if not res then return end

        -- apply renames
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

        -- print renames
        local changed_files_count = 0
        local changed_instances_count = 0

        if (res.documentChanges) then
            for _, changed_file in pairs(res.documentChanges) do
                changed_files_count = changed_files_count + 1
                changed_instances_count = changed_instances_count + #changed_file.edits
            end
        elseif (res.changes) then
            for _, changed_file in pairs(res.changes) do
                changed_instances_count = changed_instances_count + #changed_file
                changed_files_count = changed_files_count + 1
            end
        end

        -- compose the right print message
        print(string.format("renamed %s instance%s in %s file%s. %s",
        changed_instances_count,
        changed_instances_count == 1 and '' or 's',
        changed_files_count,
        changed_files_count == 1 and '' or 's',
        changed_files_count > 1 and "To save them run ':wa'" or ''
        ))
    end)
end


-- gf on path:15, path:15:3, path:L15, path:L12-30; tries as given, file dir, git root; else gF.
local function goto_file_line()
    local line, col = vim.fn.getline('.'), vim.fn.col('.')
    local init = 1
    while true do
        local s, e, path, lnum = line:find('([%w%._/~%-]+):L?(%d+)', init)
        if not s then break end
        if col >= s and col <= e then
            local root = vim.fn.systemlist({ 'git', '-C', vim.fn.expand('%:p:h'), 'rev-parse', '--show-toplevel' })[1]
            for _, dir in ipairs({ '', vim.fn.expand('%:p:h') .. '/', vim.v.shell_error == 0 and root .. '/' or nil }) do
                local f = vim.fn.expand(dir .. path)
                if vim.fn.filereadable(f) == 1 then
                    vim.cmd('edit ' .. vim.fn.fnameescape(f))
                    vim.api.nvim_win_set_cursor(0, { math.min(tonumber(lnum), vim.api.nvim_buf_line_count(0)), 0 })
                    vim.cmd('normal! zz')
                    return
                end
            end
        end
        init = e + 1
    end
    local ok, err = pcall(vim.cmd, 'normal! gF')
    if not ok then vim.notify(err:gsub('^Vim%(normal%):', ''), vim.log.levels.ERROR) end
end
vim.keymap.set('n', 'gf', goto_file_line, { desc = 'Go to file, at line if path:N / path:LN' })

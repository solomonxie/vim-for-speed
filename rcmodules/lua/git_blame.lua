-- GitBlameToggle() (`tb`, see vimrc-keymappings.vim): blame of the cursor line as end-of-line virtual text.
-- The whole file is blamed once in the background and kept per buffer, so moving the cursor is instant.
-- Re-blamed after edits, from the buffer's current text (--contents -), so unsaved edits keep lines right.

local ns = vim.api.nvim_create_namespace('git_blame')
local group = vim.api.nvim_create_augroup('GitBlame', { clear = true })
local cache = {}  -- bufnr -> { tick = changedtick blamed, lines = { "author, N days ago - summary", ... } }

local function show()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    local blamed = cache[vim.fn.bufnr()]
    if blamed and vim.fn.mode() == 'n' then
        -- a line missing from the blame: a file git doesn't track yet
        local text = blamed.lines[vim.fn.line('.')] or 'Not committed yet'
        vim.api.nvim_buf_set_extmark(0, ns, vim.fn.line('.') - 1, 0, { virt_text = { { '  ' .. text, 'Comment' } } })
    end
end

local function blame()
    local buf, tick, file = vim.fn.bufnr(), vim.b.changedtick, vim.fn.expand('%:p')
    if vim.bo.buftype ~= '' or vim.b.bigfile or vim.fn.filereadable(file) == 0 or (cache[buf] and cache[buf].tick == tick) then
        return
    end
    local cmd = { 'git', '-C', vim.fn.fnamemodify(file, ':h'), 'blame', '--line-porcelain', '--contents', '-', '--', file }
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n') .. '\n'
    vim.system(cmd, { stdin = text, text = true }, vim.schedule_wrap(function(res)
        if res.code ~= 0 and not res.stderr:match('no such path') then
            return
        end
        -- One block per line, in order: header fields, then the line itself after a tab
        local lines, info = {}, {}
        for line in res.stdout:gmatch('[^\n]+') do
            if line:sub(1, 1) == '\t' then
                local days = math.floor((os.time() - info['author-time']) / 86400)
                -- uncommitted lines get the all-zero commit id
                table.insert(lines, info.commit:match('^0+$') and 'Not committed yet'
                    or string.format('%s, %s - %s', info.author, days == 0 and 'today' or days .. ' days ago', info.summary))
            else
                local key, value = line:match('^(%S+) (.*)')
                -- the block's first line is "<commit id> <line numbers>"
                info[#key == 40 and 'commit' or key] = #key == 40 and key or value
            end
        end
        cache[buf] = { tick = tick, lines = lines }
        if buf == vim.fn.bufnr() then
            show()
        end
    end))
end

function GitBlameToggle()
    local on = #vim.api.nvim_get_autocmds({ group = group }) == 0
    vim.api.nvim_clear_autocmds({ group = group })
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    if on then
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, { group = group, callback = blame })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter' }, { group = group, callback = show })
        blame()
    end
end

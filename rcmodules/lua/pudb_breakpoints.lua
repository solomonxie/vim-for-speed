-- Set pudb breakpoints from nvim without writing pudb.set_trace() into the code.
--
--   :PudbToggle     toggle a breakpoint on the current line
--   :PudbCond       set / edit a condition on the current line's breakpoint (empty = no condition)
--   :PudbClear      remove this file's breakpoints (! for every file)
--   :PudbList       list every breakpoint in the quickfix window
--
-- Breakpoints live in pudb's own saved-breakpoints file ($XDG_CONFIG_HOME/pudb/saved-breakpoints-3.X), which
-- every pudb Debugger loads when it starts, so they're hit by:
--   python -m pudb script.py                                then c
--   pytest --pdbcls=pudb.debugger:Debugger --trace ...      then c
--
-- pudb rewrites that file when it quits, so breakpoints set or removed inside pudb come back here: the file is
-- re-read on focus / buffer enter whenever it changed. Signs are extmarks, so they follow edits above them, and
-- the new line numbers are written out on save.
-- There is one file per python version; this writes to every one that exists (or the one for `python3` on PATH).
--
-- The same breakpoints also go into a marked block in ~/.pdbrc (anything outside the block is left alone), so plain
-- pdb / ipdb stop there too: python -m pdb script.py, breakpoint(), pytest --pdb / --trace. pdb never writes back.
--
-- BACKLOG (other languages; see the TARGETS placeholders below). Each is one more renderer of `bps`:
--   Go (delve):  `dlv debug|test --init FILE`, lines `break bpN /abs/f.go:42` + `condition bpN cond`. Tested with
--                delve 1.27: a location that's not in the binary only prints an error, the rest still get set.
--                Needs a wrapper (dlv has no global init file) and `go install github.com/go-delve/delve/cmd/dlv`.
--   C/C++/Rust (lldb):  `breakpoint set -f /abs/f.c -l 42 -c 'cond'`, sourced from ~/.lldbinit with
--                `command source -s 1 -e 0 FILE` (-e 0: don't stop on files from other projects). Tested with
--                Apple lldb: stops with the condition. gdb isn't installed; it would be `break f.c:42 if cond`
--                via `gdb -x FILE`.
--   Node:        no startup command file in `node inspect`; not worth it (use `debugger;` or DevTools).

local M = {}

local NS = vim.api.nvim_create_namespace('pudb_breakpoints')
local DIR = (vim.env.XDG_CONFIG_HOME or vim.fn.expand('~/.config')) .. '/pudb'

-- bps[path][lnum] = condition ('' for none)
local bps = {}
-- marks[bufnr][extmark id] = condition
local marks = {}
local last_mtime = 0

vim.api.nvim_set_hl(0, 'PudbBreakpoint', { default = true, link = 'DiagnosticError' })

local function bp_files()
    return vim.fn.glob(DIR .. '/saved-breakpoints-*', false, true)
end

local default_file
local function write_targets()
    local files = bp_files()
    if #files > 0 then
        return files
    end
    if not default_file then
        local ver = vim.trim(vim.fn.system({ 'python3', '-c', 'import sys; print("%d.%d" % sys.version_info[:2])' }))
        default_file = DIR .. '/saved-breakpoints-' .. ver
    end
    return { default_file }
end

local function mtime(path)
    local st = vim.uv.fs_stat(path)
    return st and st.mtime.sec + st.mtime.nsec / 1e9 or 0
end

-- The newest file is the one pudb (or this) wrote last.
local function newest_file()
    local best, best_t = nil, -1
    for _, f in ipairs(bp_files()) do
        local t = mtime(f)
        if t > best_t then
            best, best_t = f, t
        end
    end
    return best, best_t
end

local function buf_path(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == '' or vim.bo[bufnr].buftype ~= '' then
        return nil
    end
    return vim.fn.fnamemodify(name, ':p')
end

local function place(bufnr)
    local path = buf_path(bufnr)
    if not path then
        return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
    marks[bufnr] = {}
    local nlines = vim.api.nvim_buf_line_count(bufnr)
    for lnum, cond in pairs(bps[path] or {}) do
        if lnum <= nlines then
            local id = vim.api.nvim_buf_set_extmark(bufnr, NS, lnum - 1, 0, {
                sign_text = cond == '' and '●' or '◆',
                sign_hl_group = 'PudbBreakpoint',
            })
            marks[bufnr][id] = cond
        end
    end
end

local function place_all()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            place(bufnr)
        end
    end
end

-- Take the buffer's breakpoints from where its extmarks are now.
local function sync_buf(bufnr)
    local path = buf_path(bufnr)
    if not path or not marks[bufnr] then
        return
    end
    local lines = {}
    for _, m in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, NS, 0, -1, {})) do
        lines[m[2] + 1] = marks[bufnr][m[1]]
    end
    bps[path] = next(lines) and lines or nil
end

local function read()
    local file, t = newest_file()
    bps = {}
    last_mtime = t
    if not file then
        return
    end
    for _, line in ipairs(vim.fn.readfile(file)) do
        local path, lnum, rest = line:match('^b%s+(.-):(%d+)%s*(.*)$')
        if path then
            bps[path] = bps[path] or {}
            bps[path][tonumber(lnum)] = vim.trim((rest:gsub('^,', '')))
        end
    end
end

-- One line per breakpoint, sorted, from fmt(path, lnum, cond).
local function render(fmt)
    local out = {}
    for path, lines in pairs(bps) do
        for lnum, cond in pairs(lines) do
            table.insert(out, fmt(path, lnum, cond))
        end
    end
    table.sort(out)
    return out
end

local PDBRC = vim.fn.expand('~/.pdbrc')
local PDBRC_BEGIN = '# >>> nvim pudb_breakpoints (generated, edits inside are overwritten)'
local PDBRC_END = '# <<< nvim pudb_breakpoints'

local function write_pdbrc()
    local keep = {}
    local inside = false
    local old = vim.uv.fs_stat(PDBRC) and vim.fn.readfile(PDBRC) or nil
    if old then
        for _, line in ipairs(old) do
            if line == PDBRC_BEGIN then
                inside = true
            elseif line == PDBRC_END then
                inside = false
            elseif not inside then
                table.insert(keep, line)
            end
        end
    end
    local block = render(function(path, lnum, cond)
        return ('break %s:%d%s'):format(path, lnum, cond == '' and '' or ', ' .. cond)
    end)
    if #block == 0 and #keep == 0 then
        if old then
            vim.fn.delete(PDBRC)
        end
        return
    end
    if #block > 0 then
        table.insert(keep, PDBRC_BEGIN)
        vim.list_extend(keep, block)
        table.insert(keep, PDBRC_END)
    end
    if not vim.deep_equal(keep, old) then
        vim.fn.writefile(keep, PDBRC)
    end
end

-- TARGETS: every debugger that gets the breakpoints; pudb's file is the source of truth, the rest write-only.
local TARGETS = {
    write_pdbrc,
    -- write_delve_init,   -- placeholder: Go
    -- write_lldb_cmds,    -- placeholder: C / C++ / Rust
}

local function write_others()
    for _, target in ipairs(TARGETS) do
        target()
    end
end

local function write()
    local out = render(function(path, lnum, cond)
        return ('b %s:%d%s'):format(path, lnum, cond == '' and '' or ', ' .. cond)
    end)
    vim.fn.mkdir(DIR, 'p', tonumber('700', 8))
    for _, f in ipairs(write_targets()) do
        vim.fn.writefile(out, f)
    end
    last_mtime = select(2, newest_file())
    write_others()
end

local function reload_if_changed()
    local _, t = newest_file()
    if t ~= last_mtime then
        read()
        place_all()
        -- pudb changed its file: bring the write-only targets up to date (not pudb's files, that would loop)
        write_others()
    end
end

local function current()
    local bufnr = vim.api.nvim_get_current_buf()
    local path = buf_path(bufnr)
    if not path then
        vim.notify('pudb breakpoints: not a file buffer', vim.log.levels.WARN)
        return nil
    end
    reload_if_changed()
    sync_buf(bufnr)
    return bufnr, path, vim.fn.line('.')
end

function M.toggle()
    local bufnr, path, lnum = current()
    if not bufnr then
        return
    end
    bps[path] = bps[path] or {}
    bps[path][lnum] = not bps[path][lnum] and '' or nil
    if not next(bps[path]) then
        bps[path] = nil
    end
    place(bufnr)
    write()
end

function M.cond()
    local bufnr, path, lnum = current()
    if not bufnr then
        return
    end
    local old = bps[path] and bps[path][lnum] or ''
    vim.ui.input({ prompt = 'Break condition: ', default = old }, function(cond)
        if cond == nil then
            return
        end
        bps[path] = bps[path] or {}
        bps[path][lnum] = vim.trim(cond)
        place(bufnr)
        write()
    end)
end

function M.clear(all)
    if all then
        bps = {}
        place_all()
    else
        local bufnr, path = current()
        if not bufnr then
            return
        end
        bps[path] = nil
        place(bufnr)
    end
    write()
end

function M.list()
    reload_if_changed()
    local items = {}
    for path, lines in pairs(bps) do
        for lnum, cond in pairs(lines) do
            table.insert(items, { filename = path, lnum = lnum, text = cond == '' and 'breakpoint' or 'if ' .. cond })
        end
    end
    table.sort(items, function(a, b)
        return a.filename == b.filename and a.lnum < b.lnum or a.filename < b.filename
    end)
    vim.fn.setqflist({}, ' ', { title = 'pudb breakpoints', items = items })
    vim.cmd('copen')
end

vim.api.nvim_create_user_command('PudbToggle', M.toggle, {})
vim.api.nvim_create_user_command('PudbCond', M.cond, {})
vim.api.nvim_create_user_command('PudbClear', function(o) M.clear(o.bang) end, { bang = true })
vim.api.nvim_create_user_command('PudbList', M.list, {})

local group = vim.api.nvim_create_augroup('PudbBreakpoints', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(ev) place(ev.buf) end,
})
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
    group = group,
    callback = reload_if_changed,
})
vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = function(ev)
        if marks[ev.buf] and next(marks[ev.buf]) then
            reload_if_changed()
            sync_buf(ev.buf)
            write()
        end
    end,
})

read()
-- pudb may have changed its file while nvim wasn't running
write_others()

return M

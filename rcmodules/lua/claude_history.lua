-- Browse Claude Code session history of the current repo in nvim.
--
--   :ClaudeHistory        toggle the history pane: every session of this repo, from any of its worktrees, as a
--                         folded tree: repo -> worktree -> worktrees made from it (a plan's impl worktrees)
--                         -> session -> your prompts. Opens at your newest session in the worktree you're in.
--   :ClaudeHistory!       same, for every project
--   :ClaudeHistoryGrep    fzf search through every prompt typed in this repo (! for every project)
--   :ClaudeSend           (also on a visual range) pick a running session in tmux, type a prompt, and send it
--                         with <file>:L<lines>; that transcript then opens in this window at your prompt.
--                         Lists this repo's sessions like the pane does; :ClaudeSend! lists every project's
--   ,k                    same, but skips the list for the last session sent to (or the only one in this repo)
--
-- In the pane, moving the cursor shows that session (at that prompt) in the window above:
--   ● / ○      session running / not running
--   <CR> / <Space> / o   open / close a worktree or a session's prompts
--   p          up to the parent row
--   <CR> on a prompt     close the pane and jump into the transcript at it
--   q / ft     close
--   ?          show / hide help at the top of the pane (keys, commands, how it works); q also hides it
--
-- Each session <id>.jsonl is rendered right next to it as <yyyymmdd>-<HHMM>-<folder>-<title>.md, and re-rendered
-- whenever the jsonl changes (on open, and every 1.5s while the transcript is loaded), so a live
-- session follows. The file is renamed if the session gets (re)titled.
--
-- In a transcript ('## N. ...' headings are your prompts):
--   ft         toggle the history pane, opened at this session and prompt
--   ]] / [[    next / previous prompt
--   Claude's replies are folded, your prompts stay visible:
--   za / zo / zc   toggle / open / close the reply under the cursor
--   zR / zM        open / close every reply
--   q          close the transcript

local M = {}

local PROJECTS = vim.fn.expand('~/.claude/projects')
local MARKER = 'nvim-claude-history'
-- A rendered md older than this file was made by an older renderer, so it's re-rendered.
local SELF = debug.getinfo(1, 'S').source:sub(2)
local SKIP_PREFIXES = { '<local-command', '<command-message>', '<system-reminder>', 'Caveat:', '[Request interrupted' }
local UTC_OFFSET = os.time() - os.time(os.date('!*t'))

---------------------------------------------------------------------------
-- jsonl -> markdown
---------------------------------------------------------------------------

local function decode(line)
    local ok, rec = pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
    return ok and type(rec) == 'table' and rec or nil
end

-- Human-typed text of a user record, or nil if it isn't one.
local function prompt_text(rec)
    if rec.type ~= 'user' or rec.isMeta or rec.isSidechain then return nil end
    -- system-injected turns (e.g. background task notifications) aren't something you typed
    if rec.promptSource == 'system' or (rec.origin and rec.origin.kind and rec.origin.kind ~= 'human') then return nil end
    local content = rec.message and rec.message.content
    if type(content) == 'table' then
        local parts = {}
        for _, b in ipairs(content) do
            if type(b) == 'table' then
                if b.type == 'tool_result' then return nil end
                if b.type == 'text' then parts[#parts + 1] = b.text end
            end
        end
        content = table.concat(parts, '\n')
    end
    if type(content) ~= 'string' then return nil end
    content = vim.trim(content)
    if content == '' then return nil end
    if vim.startswith(content, '<command-name>') then
        -- slash command: keep just "/name args"
        local name = content:match('<command%-name>(.-)</command%-name>') or ''
        local args = content:match('<command%-args>(.-)</command%-args>') or ''
        local cmd = vim.trim(name .. ' ' .. args)
        if cmd == '/clear' then return nil end
        return cmd
    end
    for _, p in ipairs(SKIP_PREFIXES) do
        if vim.startswith(content, p) then return nil end
    end
    return content
end

local function one_line(s, n)
    s = vim.trim(s:gsub('%s+', ' '))
    if vim.fn.strchars(s) > n then s = vim.fn.strcharpart(s, 0, n - 1) .. '…' end
    return s
end

local function local_ts(iso)
    local y, mo, d, h, mi, sec = (iso or ''):match('(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)')
    if not y then return '' end
    local t = os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = sec }) + UTC_OFFSET
    return os.date('%Y-%m-%d %H:%M', t)
end

-- Push assistant markdown headings down two levels so only prompts are '## '.
local function demote(text, out)
    local fence = false
    for _, l in ipairs(vim.split(text, '\n', { plain = true })) do
        if l:match('^%s*```') then fence = not fence end
        out[#out + 1] = (not fence and l:match('^#')) and ('##' .. l) or l
    end
end

-- Cheap scan for pickers: prompts and title without decoding every record.
-- Worktrees a `git worktree add` run by the Bash tool in this jsonl line made: adds[folder name] = the cwd
-- it ran in. Any other path argument's last component goes in too, and just won't match a worktree.
local function worktree_adds(line, adds)
    if not (line:find('git worktree add', 1, true) and line:find('"name":"Bash"', 1, true)) then return end
    local cwd = line:match('"cwd":"([^"]*)"')
    if not cwd then return end
    for cmd in line:gmatch('git worktree add[^"]*') do
        for tok in cmd:match('^[^;&|\\]*'):gmatch('[%w_.~/-]+') do
            if tok:find('/', 1, true) then adds[vim.fn.fnamemodify(tok, ':t')] = cwd end
        end
    end
end

local function scan_file(path)
    -- cwds: cwd -> number of prompts typed there; adds: see worktree_adds()
    local res = { prompts = {}, title = nil, cwds = {}, adds = {} }
    local f = io.open(path, 'r')
    if not f then return res end
    for line in f:lines() do
        worktree_adds(line, res.adds)
        if line:find('"type":"user"', 1, true) and not line:find('"tool_result"', 1, true) then
            local rec = decode(line)
            local t = rec and prompt_text(rec)
            if rec and rec.cwd then
                res.cwd = rec.cwd
                res.cwds[rec.cwd] = (res.cwds[rec.cwd] or 0) + 1
            end
            if t then res.prompts[#res.prompts + 1] = { ts = rec.timestamp or '', text = t } end
        elseif line:find('"type":"custom-title"', 1, true) then
            local rec = decode(line)
            res.custom = rec and rec.customTitle or res.custom
        elseif line:find('"type":"ai-title"', 1, true) then
            local rec = decode(line)
            res.title = rec and rec.aiTitle or res.title
        end
    end
    f:close()
    -- worktrees made by its subagents count as made by the session
    for _, sub in ipairs(vim.fn.glob(path:gsub('%.jsonl$', '') .. '/subagents/*.jsonl', false, true)) do
        local sf = io.open(sub, 'r')
        if sf then
            for line in sf:lines() do worktree_adds(line, res.adds) end
            sf:close()
        end
    end
    res.title = res.custom or res.title
    return res
end

-- scan(), cached until the file changes: big sessions take a while to read.
local scan_cache = {}
local function scan(path)
    local st = vim.uv.fs_stat(path)
    local stamp = st and (st.size .. ':' .. st.mtime.sec .. '.' .. st.mtime.nsec)
    local hit = scan_cache[path]
    if hit and hit.stamp == stamp then return hit.res end
    local res = scan_file(path)
    scan_cache[path] = { stamp = stamp, res = res }
    return res
end

-- Returns the transcript lines and { title, date, cwd } for naming the file.
local function render(path)
    local out, n, title, custom, first_ts, cwd = {}, 0, nil, nil, nil, nil
    local f = assert(io.open(path, 'r'))
    for line in f:lines() do
        local r = decode(line)
        local t = r and prompt_text(r)
        cwd = r and r.cwd or cwd
        if not r then
        elseif r.type == 'ai-title' then
            title = r.aiTitle
        elseif r.type == 'custom-title' then
            custom = r.customTitle
        elseif t then
            n = n + 1
            local ts = local_ts(r.timestamp)
            first_ts = first_ts or ts
            vim.list_extend(out, { '', ('## %d. %s'):format(n, one_line(t, 90)), '', '*' .. ts .. '*', '' })
            for _, l in ipairs(vim.split(t, '\n', { plain = true })) do out[#out + 1] = '> ' .. l end
            out[#out + 1] = ''
        elseif r.type == 'assistant' and not r.isSidechain and type(r.message) == 'table' then
            for _, b in ipairs(type(r.message.content) == 'table' and r.message.content or {}) do
                if b.type == 'text' and vim.trim(b.text or '') ~= '' then
                    out[#out + 1] = ''
                    demote(b.text:gsub('%s+$', ''), out)
                    out[#out + 1] = ''
                elseif b.type == 'tool_use' then
                    local inp = type(b.input) == 'table' and b.input or {}
                    local desc = inp.description or inp.file_path or inp.pattern or inp.command or ''
                    out[#out + 1] = ('- `%s` %s'):format(b.name, one_line(tostring(desc), 100))
                end
            end
        end
    end
    f:close()
    title = custom or title
    local id = vim.fn.fnamemodify(path, ':t:r')
    local header = {
        '# ' .. (title or ('Session ' .. id)),
        ('*%s  ·  %s  ·  %d prompts*  ·  `claude --resume %s`'):format(
            vim.fn.fnamemodify(cwd or '', ':t'), first_ts or '?', n, id),
        ('<!-- %s -->'):format(MARKER),
    }
    -- first_ts is 'YYYY-MM-DD HH:MM' -> 'YYYYMMDD-HHMM'
    local date = first_ts and (first_ts:gsub('[-:]', ''):gsub(' ', '-')) or os.date('%Y%m%d-%H%M')
    return vim.list_extend(header, out), { title = title, date = date, cwd = cwd }
end

local function mtime(p)
    local st = vim.uv.fs_stat(p)
    return st and (st.mtime.sec * 1e9 + st.mtime.nsec) or 0
end

local UUID = '%x+%-%x+%-%x+%-%x+%-%x+'

local function slug(s)
    s = (s or ''):lower():gsub('[^%w]+', '-'):gsub('^%-+', ''):gsub('%-+$', '')
    return (s:sub(1, 60):gsub('%-+$', ''))
end

-- Session id of a rendered md, read from its header ('claude --resume <id>').
local function md_session_id(md)
    local f = io.open(md, 'r')
    if not f then return nil end
    f:read('l')
    local info, version = f:read('l') or '', f:read('l') or ''
    f:close()
    return version:find(MARKER, 1, true) and info:match('resume (' .. UUID .. ')') or nil
end

local function jsonl_of(md)
    local id = md_session_id(md)
    return id and (vim.fn.fnamemodify(md, ':h') .. '/' .. id .. '.jsonl') or nil
end

-- The rendered md of a jsonl, if one exists.
local function find_md(jsonl)
    local id = vim.fn.fnamemodify(jsonl, ':t:r')
    for _, md in ipairs(vim.fn.glob(vim.fn.fnamemodify(jsonl, ':h') .. '/*.md', false, true)) do
        if md_session_id(md) == id then return md end
    end
end

-- <yyyymmdd>-<HHMM>-<folder>-<title>.md; the short session id stands in for a missing title or breaks a tie.
local function md_name(jsonl, meta)
    local id = vim.fn.fnamemodify(jsonl, ':t:r')
    local parts = { meta.date, slug(meta.cwd and vim.fn.fnamemodify(meta.cwd, ':t') or ''), slug(meta.title) }
    if parts[3] == '' then parts[3] = id:sub(1, 8) end
    parts = vim.tbl_filter(function(x) return x ~= '' end, parts)
    local base = vim.fn.fnamemodify(jsonl, ':h') .. '/' .. table.concat(parts, '-')
    local other = md_session_id(base .. '.md')
    if other and other ~= id then base = base .. '-' .. id:sub(1, 8) end
    return base .. '.md'
end

local function is_stale(jsonl, md)
    local t = mtime(md)
    return t < mtime(jsonl) or t < mtime(SELF) or not md_session_id(md)
end

-- Re-render the md of a jsonl if the jsonl changed. Returns (md path, rewritten?).
local function ensure_md(jsonl, old)
    old = old or find_md(jsonl)
    if old and not is_stale(jsonl, old) then return old, false end
    local lines, meta = render(jsonl)
    local md = md_name(jsonl, meta)
    local tmp = md .. '.tmp'
    local f = assert(io.open(tmp, 'w'))
    f:write(table.concat(lines, '\n'), '\n')
    f:close()
    vim.uv.fs_rename(tmp, md)
    if old and old ~= md then os.remove(old) end
    return md, true
end

---------------------------------------------------------------------------
-- session discovery
---------------------------------------------------------------------------

local function encode(dir) return (dir:gsub('[^%w]', '-')) end

-- Where we are: { top = checkout root, main = whether it's the repo's main checkout, roots = all worktrees }.
local function repo_scope()
    local git = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel', '--git-dir', '--git-common-dir' })
    if vim.v.shell_error ~= 0 or #git < 3 then
        local cwd = vim.fn.getcwd()
        return { top = cwd, main = true, roots = { cwd } }
    end
    local top = git[1]
    local abs = function(d) return vim.fn.fnamemodify(vim.fs.joinpath(top, d), ':p'):gsub('/$', '') end
    local scope = { top = top, main = abs(git[2]) == abs(git[3]), roots = {} }
    for _, l in ipairs(vim.fn.systemlist({ 'git', '-C', top, 'worktree', 'list', '--porcelain' })) do
        local wt = l:match('^worktree (.+)')
        if wt then scope.roots[#scope.roots + 1] = wt end
    end
    if #scope.roots == 0 then scope.roots = { top } end
    return scope
end

-- Project dirs of the given checkouts, plus the Claude-made worktrees nested in them.
local function project_dirs(roots)
    local dirs, seen = {}, {}
    for _, root in ipairs(roots) do
        local enc = encode(root)
        for _, d in ipairs(vim.fn.glob(PROJECTS .. '/' .. enc, false, true)) do dirs[#dirs + 1] = d end
        for _, d in ipairs(vim.fn.glob(PROJECTS .. '/' .. enc .. '--claude-worktrees-*', false, true)) do
            dirs[#dirs + 1] = d
        end
    end
    return vim.tbl_filter(function(d)
        if seen[d] then return false end
        seen[d] = true
        return true
    end, dirs)
end

local function short_project(f)
    local name = vim.fn.fnamemodify(f, ':h:t'):gsub('^' .. vim.pesc(encode(vim.fn.expand('~'))) .. '%-?', '')
    return (name:gsub('^workspace%-', ''))
end

local function inside(path, root)
    return path == root or vim.startswith(path, root .. '/')
end

-- The worktree of the repo a path is in: the innermost of scope.roots holding it, or a removed
-- worktree, a <main checkout>-* sibling that's no longer on disk. nil if it's outside the repo.
local function node_of(path, scope)
    local best
    for _, root in ipairs(scope.roots) do
        if inside(path, root) and (not best or #root > #best) then best = root end
    end
    if best then return best end
    local gone = path:match('^(' .. vim.pesc(scope.roots[1]) .. '%-[^/]+)')
    if gone and not vim.uv.fs_stat(gone) then return gone end
end

-- The worktree a session is shown under: where you typed most of its prompts. `outside` sessions are
-- stored outside the repo, so those with no prompt in it get nil; the rest fall back to their project dir.
local function session_home(f, s, scope, outside)
    local counts, home, most = {}, nil, 0
    for cwd, n in pairs(s.cwds) do
        local node = node_of(cwd, scope)
        if node then counts[node] = (counts[node] or 0) + n end
    end
    for node, n in pairs(counts) do
        if n > most then home, most = node, n end
    end
    if home or outside then return home end
    local dir = vim.fn.fnamemodify(f, ':h:t')
    for _, root in ipairs(scope.roots) do
        if dir == encode(root) then return root end
    end
    return scope.roots[1]
end

-- Running Claude processes, by session id: { pid, cwd, tmux pane id } from ~/.claude/sessions/<pid>.json.
-- Those files can outlive a crashed process, so the pid is checked too.
local function live_sessions()
    local live = {}
    for _, f in ipairs(vim.fn.glob(vim.fn.expand('~/.claude/sessions') .. '/*.json', false, true)) do
        local ok, s = pcall(vim.json.decode, table.concat(vim.fn.readfile(f), '\n'))
        if ok and type(s) == 'table' and s.sessionId and s.pid and vim.uv.kill(s.pid, 0) == 0 then
            live[s.sessionId] = { pid = s.pid, cwd = s.cwd, pane = s.tmux and s.tmux:match('(%%%d+)$') }
        end
    end
    return live
end

local function session_id(jsonl) return vim.fn.fnamemodify(jsonl, ':t:r') end

-- Sessions newest first, each with its worktree folder, title and prompts: every session of the repo
-- and its worktrees (also removed ones), from any of them, each with the worktree it's shown under
-- (`home`). `all`: every project. Also returns the repo scope, nil with `all`.
local function session_entries(all)
    local files, scope = {}, nil
    if all then
        files = vim.fn.glob(PROJECTS .. '/*/*.jsonl', false, true)
    else
        scope = repo_scope()
        -- sessions that moved into a worktree are stored under the checkout they started in
        for _, d in ipairs(project_dirs(scope.roots)) do
            vim.list_extend(files, vim.fn.glob(d .. '/*.jsonl', false, true))
        end
    end
    -- and sessions started outside the repo (e.g. in its parent dir) that cd'd into it later, or of removed
    -- worktrees: they're stored under the dir they started in. grep is a quick prefilter; session_home() decides.
    local outside = {}
    if scope then
        local listed = {}
        for _, f in ipairs(files) do listed[f] = true end
        -- one pattern, the worktrees' common path prefix: grep with one -e per worktree is ~10x slower
        local prefix = scope.roots[1]
        for _, root in ipairs(scope.roots) do
            while not vim.startswith(root, prefix) do prefix = prefix:sub(1, -2) end
        end
        local cmd = { 'grep', '-lF', '-e', '"cwd":"' .. prefix, '--' }
        vim.list_extend(cmd, vim.fn.glob(PROJECTS .. '/*/*.jsonl', false, true))
        for _, f in ipairs(vim.fn.systemlist(cmd)) do
            if not listed[f] then
                files[#files + 1] = f
                outside[f] = true
            end
        end
    end
    local entries = {}
    for _, f in ipairs(files) do
        local s = scan(f)
        -- skip empty sessions, e.g. the stub left behind by /clear
        local real = vim.tbl_filter(function(p) return not vim.startswith(p.text, '/') end, s.prompts)
        local home = scope and session_home(f, s, scope, outside[f])
        if #real > 0 and (not scope or home) then
            entries[#entries + 1] = {
                file = f,
                mtime = mtime(f),
                folder = s.cwd and vim.fn.fnamemodify(s.cwd, ':t') or short_project(f),
                title = s.title or one_line(s.prompts[1].text, 80),
                prompts = s.prompts,
                home = home,
                adds = s.adds,
            }
        end
    end
    table.sort(entries, function(a, b) return a.mtime > b.mtime end)
    return entries, scope
end

-- The repo as a tree of worktrees, the main checkout at the top. A worktree goes under the one whose
-- session made it (`git worktree add`), e.g. a plan's impl worktrees; if that ran in the main checkout,
-- under the worktree it's named after (<that>-<suffix>), but <X>-plan not under X: a plan starts a new
-- branch of the tree. Removed worktrees stay while they have sessions.
-- Node: { path, gone, sessions (newest first), kids (latest activity first), total, latest }.
local function session_tree(entries, scope)
    local main, nodes = scope.roots[1], {}
    local function node(path)
        nodes[path] = nodes[path] or { path = path, gone = not vim.uv.fs_stat(path), sessions = {}, kids = {} }
        return nodes[path]
    end
    for _, root in ipairs(scope.roots) do node(root) end
    for _, e in ipairs(entries) do table.insert(node(e.home).sessions, e) end
    -- worktree folder name -> worktree it was made in; oldest first, so the newest session's add wins
    local made_in = {}
    for i = #entries, 1, -1 do
        for name, cwd in pairs(entries[i].adds) do made_in[name] = node_of(cwd, scope) end
    end
    local by_name = {}
    for path in pairs(nodes) do by_name[vim.fn.fnamemodify(path, ':t')] = path end
    local function parent_of(path)
        local name = vim.fn.fnamemodify(path, ':t')
        local by = made_in[name]
        if by and by ~= path and by ~= main and nodes[by] then return by end
        local plan = name:match('^(.+)%-plan$')
        local base = name:match('^(.+)%-[^-]+$')
        while base do
            if by_name[base] and base ~= plan then return by_name[base] end
            base = base:match('^(.+)%-[^-]+$')
        end
        return main
    end
    local paths, parent = vim.tbl_keys(nodes), {}
    table.sort(paths)
    for _, path in ipairs(paths) do
        if path ~= main then parent[path] = parent_of(path) end
    end
    -- a worktree made in its own descendant: the first of the cycle goes under the main checkout instead
    for _, path in ipairs(paths) do
        local seen, p = {}, parent[path]
        while p and p ~= main and not seen[p] do
            if p == path then
                parent[path] = main
                break
            end
            seen[p] = true
            p = parent[p]
        end
    end
    for _, path in ipairs(paths) do
        if parent[path] then table.insert(nodes[parent[path]].kids, nodes[path]) end
    end
    local function finish(n)
        n.total, n.latest = #n.sessions, n.sessions[1] and n.sessions[1].mtime or 0
        local kids = {}
        for _, k in ipairs(n.kids) do
            finish(k)
            if not (k.gone and k.total == 0) then kids[#kids + 1] = k end
            n.total, n.latest = n.total + k.total, math.max(n.latest, k.latest)
        end
        table.sort(kids, function(a, b)
            if a.latest ~= b.latest then return a.latest > b.latest end
            return a.path < b.path
        end)
        n.kids = kids
    end
    finish(nodes[main])
    return nodes[main]
end

-- Where to put the pane's cursor for a location in worktree node `n`: its newest session, else the
-- newest one in the worktrees under it, else the worktree's own row.
local function nearest(n)
    if n.sessions[1] then return { jsonl = n.sessions[1].file, shut = true } end
    for _, k in ipairs(n.kids) do
        if k.total > 0 then return nearest(k) end
    end
    return { node = n.path }
end

local function find_node(n, path)
    if n.path == path then return n end
    for _, k in ipairs(n.kids) do
        local hit = find_node(k, path)
        if hit then return hit end
    end
end

---------------------------------------------------------------------------
-- transcript buffers
---------------------------------------------------------------------------

-- One scratch buffer named BUFNAME shows whichever session is selected: switching session loads
-- the other rendered md into it, and b:claude_md says which one it holds. A rendered md opened
-- directly (:e) is a normal file buffer instead.
local BUFNAME = 'Claude history'
local transcript = { buf = nil }

-- The rendered md a transcript buffer shows.
local function md_of(buf)
    return vim.b[buf].claude_md or vim.api.nvim_buf_get_name(buf)
end

local function is_transcript(buf)
    local jsonl = jsonl_of(vim.api.nvim_buf_get_name(buf))
    return jsonl ~= nil and vim.uv.fs_stat(jsonl) ~= nil
end

-- Fold level per line: your prompts (heading, timestamp, quoted text) stay open and everything
-- Claude wrote after each one is a fold. Cached per changedtick.
local fold_cache = {}
local TIMESTAMP = '^%*%d%d%d%d%-%d%d%-%d%d %d%d:%d%d%*$'

-- 0 for the title block and each prompt block (heading, timestamp, quoted prompt), 1 for the
-- reply that follows it. A prompt block ends at the first line after its quote that isn't '>'.
local function fold_levels(buf)
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local cached = fold_cache[buf]
    if cached and cached.tick == tick then return cached.levels end
    local levels, state = {}, 'header'  -- header | heading | quote | reply
    for i, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if l:match('^## %d+%. ') then
            state = 'heading'
        elseif state == 'heading' and l:match('^>') then
            state = 'quote'
        elseif state == 'quote' and not l:match('^>') then
            state = 'reply'
        end
        -- blank line right before the next prompt stays open as a separator
        levels[i] = state == 'reply' and 1 or 0
    end
    -- trailing blank line of each reply belongs to the gap, not the fold
    for i = 1, #levels - 1 do
        if levels[i] == 1 and levels[i + 1] == 0 then
            local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
            if line == '' then levels[i] = 0 end
        end
    end
    fold_cache[buf] = { tick = tick, levels = levels }
    return levels
end

function _G.ClaudeHistoryFoldExpr()
    return fold_levels(vim.api.nvim_get_current_buf())[vim.v.lnum] or 0
end

-- Closed reply: its first line and size.
function _G.ClaudeHistoryFoldText()
    local first = ''
    for l = vim.v.foldstart, vim.v.foldend do
        first = vim.trim(vim.fn.getline(l))
        if first ~= '' then break end
    end
    return ('    ⋯ %s  (%d lines)'):format(one_line(first, 100), vim.v.foldend - vim.v.foldstart + 1)
end

-- Window options for showing the transcript (window-local, so set per window). Replies start folded.
local function style_window(win)
    local fillchars = vim.o.fillchars:gsub('fold:[^,]*,?', ''):gsub(',$', '')
    for opt, val in pairs({
        wrap = true, linebreak = true, foldmethod = 'expr', foldlevel = 0,
        foldexpr = 'v:lua.ClaudeHistoryFoldExpr()', foldtext = 'v:lua.ClaudeHistoryFoldText()',
        fillchars = (fillchars ~= '' and fillchars .. ',' or '') .. 'fold: ',
    }) do
        vim.wo[win][opt] = val
    end
end

-- Call fn(prompt_no, first_reply_line) for each prompt that has a reply, inside win.
local function each_reply(win, fn)
    vim.api.nvim_win_call(win, function()
        local n
        for l = 1, vim.fn.line('$') do
            local m = vim.fn.getline(l):match('^## (%d+)%. ')
            if m then
                n = m
            elseif n and vim.fn.foldlevel(l) > 0 then
                fn(n, l)
                n = nil
            end
        end
    end)
end

-- Buffer-local setup, run every time a rendered md is read into a buffer.
local function setup_transcript(buf)
    vim.b[buf].claude_history = true
    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
    vim.bo[buf].swapfile = false
    local function jump(flags)
        return function()
            vim.fn.search('^## ', flags)
            vim.cmd('normal! zt')
        end
    end
    -- Set now so the keys work the moment the transcript shows, and again once
    -- nvim-treesitter-textobjects has clobbered buffer-local ]]/[[ after FileType (see python.lua).
    local function map_keys()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        local o = { buffer = buf, silent = true, nowait = true }
        vim.keymap.set('n', ']]', jump('W'), o)
        vim.keymap.set('n', '[[', jump('bW'), o)
        vim.keymap.set('n', 'ft', function() M.pane_toggle(false) end, o)
        vim.keymap.set('n', 'q', '<cmd>quit<CR>', o)
    end
    map_keys()
    vim.defer_fn(map_keys, 0)
    vim.defer_fn(map_keys, 200)
    vim.schedule(function()
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            if vim.wo[win].foldexpr ~= 'v:lua.ClaudeHistoryFoldExpr()' then style_window(win) end
        end
    end)
end

-- Point buf at md and (re)read it from disk.
local function load_into(buf, md)
    if vim.b[buf].claude_md then
        -- Stop treesitter first, so an async parse of the old text can't read past the new end
        -- ("treesitter.lua: Index out of bounds"). Setting the filetype restarts it.
        pcall(vim.treesitter.stop, buf)
        vim.bo[buf].readonly = false
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(md))
        vim.bo[buf].modified = false
        vim.b[buf].claude_md = md
        vim.bo[buf].filetype = 'markdown'
        setup_transcript(buf)
        return
    end
    local old = vim.api.nvim_buf_get_name(buf)
    if old ~= md then
        -- a stale buffer already holding this md (e.g. opened directly) would block the rename
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if b ~= buf and vim.api.nvim_buf_get_name(b) == md then pcall(vim.api.nvim_buf_delete, b, { force = true }) end
        end
        vim.api.nvim_buf_set_name(buf, md)
        -- renaming leaves an unlisted buffer behind for the old name; drop it
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if b ~= buf and old ~= '' and vim.api.nvim_buf_get_name(b) == old and not vim.api.nvim_buf_is_loaded(b) then
                pcall(vim.api.nvim_buf_delete, b, { force = true })
            end
        end
    end
    -- Stop treesitter first: an async parse of the old text still running after edit! swaps
    -- the lines reads past the new end ("treesitter.lua: Index out of bounds"). FileType restarts it.
    pcall(vim.treesitter.stop, buf)
    vim.api.nvim_buf_call(buf, function()
        vim.bo.modifiable = true
        vim.cmd('silent! keepjumps edit!')
    end)
end

-- Re-read the transcript after its md was rewritten, keeping each window's view
-- (or sticking to the bottom if that's where it was).
local function reload(buf, md)
    local views = {}
    local last = vim.api.nvim_buf_line_count(buf)
    for _, w in ipairs(vim.fn.win_findbuf(buf)) do
        local view = vim.api.nvim_win_call(w, vim.fn.winsaveview)
        local open = {}
        each_reply(w, function(n, l)
            if vim.fn.foldclosed(l) == -1 then open[n] = true end
        end)
        views[w] = { view = view, at_end = view.lnum >= last - 3, open = open }
    end
    load_into(buf, md)
    for w, v in pairs(views) do
        each_reply(w, function(n, l)
            if v.open[n] then vim.cmd(l .. 'foldopen') end
        end)
        vim.api.nvim_win_call(w, function()
            if v.at_end then vim.cmd('normal! G') else vim.fn.winrestview(v.view) end
        end)
    end
    M.pane_rerender()
end

local watcher
local function watch()
    if watcher then return end
    watcher = vim.uv.new_timer()
    watcher:start(1500, 1500, vim.schedule_wrap(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].claude_history then
                local name = md_of(buf)
                local jsonl = jsonl_of(name)
                if jsonl and vim.uv.fs_stat(jsonl) then
                    local md, changed = ensure_md(jsonl, name)
                    if changed then reload(buf, md) end
                end
            end
        end
    end))
end

-- Show a session in win, at prompt n (or the top).
local function show_in(win, jsonl, n)
    local md = ensure_md(jsonl)
    local buf = transcript.buf
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
        buf = vim.api.nvim_create_buf(true, false)
        transcript.buf = buf
        vim.bo[buf].buftype = 'nofile'
        vim.bo[buf].bufhidden = 'hide'
        vim.b[buf].claude_md = ''
        pcall(vim.api.nvim_buf_set_name, buf, BUFNAME)
    end
    if md_of(buf) ~= md then load_into(buf, md) end
    if vim.api.nvim_win_get_buf(win) ~= buf then vim.api.nvim_win_set_buf(win, buf) end
    style_window(win)
    vim.api.nvim_win_call(win, function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        if n then vim.fn.search('^## ' .. n .. '\\. ', 'W') end
        vim.cmd('normal! zvzt')
    end)
    watch()
end

-- A window that can take another buffer: the current one unless it's pinned (e.g. the NERDTree side tree).
local function edit_window()
    if not vim.wo.winfixbuf then return vim.api.nvim_get_current_win() end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not vim.wo[w].winfixbuf and vim.api.nvim_win_get_config(w).relative == '' then return w end
    end
    vim.cmd('rightbelow vnew')
    return vim.api.nvim_get_current_win()
end

function M.open(jsonl, n)
    local win = edit_window()
    vim.api.nvim_set_current_win(win)
    show_in(win, jsonl, n)
end

---------------------------------------------------------------------------
-- send file:lines + a prompt to a running session
---------------------------------------------------------------------------

local last_sent -- session id last sent to, preferred next time

-- Running sessions in tmux among the pane's sessions (this repo and its worktrees, or every project
-- with `all`): the last one sent to first, then those whose cwd holds `path`, then most recently active.
local function send_candidates(path, all)
    local live, list = live_sessions(), {}
    for _, e in ipairs(session_entries(all)) do
        local id = session_id(e.file)
        local s = live[id]
        if s and s.pane then
            list[#list + 1] = {
                id = id, pane = s.pane, cwd = s.cwd, jsonl = e.file, mtime = e.mtime,
                here = s.cwd and inside(path, s.cwd),
                label = ('%s  %s'):format(e.folder, e.title),
            }
        end
    end
    table.sort(list, function(a, b)
        if (a.id == last_sent) ~= (b.id == last_sent) then return a.id == last_sent end
        if a.here ~= b.here then return a.here end
        return a.mtime > b.mtime
    end)
    return list
end

-- Once the session has recorded the prompt just sent (it has more than `before` prompts), show its
-- transcript in this window at that prompt. Gives up after ~15s, e.g. if the paste never got submitted.
local function show_sent(jsonl, before, win)
    local tries = 0
    local timer = vim.uv.new_timer()
    timer:start(300, 300, vim.schedule_wrap(function()
        tries = tries + 1
        local n = #scan(jsonl).prompts
        if n <= before and tries < 50 then return end
        timer:stop()
        timer:close()
        if n <= before then
            return vim.notify('claude_history: the session hasn\'t recorded the prompt yet', vim.log.levels.WARN)
        end
        if not vim.api.nvim_win_is_valid(win) then win = edit_window() end
        vim.api.nvim_set_current_win(win)
        show_in(win, jsonl, n)
    end))
end

local function paste_to(s, text)
    local before = #scan(s.jsonl).prompts
    local win = edit_window()
    vim.fn.system({ 'tmux', 'load-buffer', '-b', 'claude_send', '-' }, text)
    -- -p: bracketed paste, so newlines in the text don't submit early
    vim.fn.system({ 'tmux', 'paste-buffer', '-p', '-d', '-b', 'claude_send', '-t', s.pane })
    vim.defer_fn(function() vim.fn.system({ 'tmux', 'send-keys', '-t', s.pane, 'Enter' }) end, 150)
    last_sent = s.id
    show_sent(s.jsonl, before, win)
end

-- Ask for a prompt and send "<file>:L<l1>-<l2>" plus it to a running session.
-- `pick`: always choose from the list of running sessions. `all`: from every project, not just this repo's.
function M.send(l1, l2, pick, all)
    local path = vim.api.nvim_buf_get_name(0)
    local cands = send_candidates(path ~= '' and path or vim.fn.getcwd(), all)
    if #cands == 0 then
        return vim.notify('claude_history: no running Claude session in tmux for '
            .. (all and 'any project' or vim.fn.getcwd()) .. (all and '' or ' (:ClaudeSend! for every project)'),
            vim.log.levels.WARN)
    end
    local function go(s)
        if not s then return end
        local ref = ''
        if path ~= '' then
            local rel = s.cwd and inside(path, s.cwd) and path:sub(#s.cwd + 2) or path
            ref = rel .. ':L' .. l1 .. (l2 ~= l1 and ('-' .. l2) or '')
        end
        vim.ui.input({ prompt = ('Claude [%s] %s> '):format(s.label, ref) }, function(prompt)
            if prompt == nil then return end
            local text = vim.trim(ref .. '\n' .. prompt)
            if text ~= '' then paste_to(s, text) end
        end)
    end
    -- the usual target needs no picking; otherwise pick when it's ambiguous
    if not pick and (cands[1].id == last_sent or #cands == 1 or (cands[1].here and not cands[2].here)) then
        go(cands[1])
    else
        vim.ui.select(cands, { prompt = 'Send to Claude session', format_item = function(s) return s.label end }, go)
    end
end

---------------------------------------------------------------------------
-- history pane: one folded row per session, opening to its prompts
---------------------------------------------------------------------------

local NS = vim.api.nvim_create_namespace('claude_history')
local pane = { win = nil, buf = nil, src_win = nil, items = {}, all = false, last = nil }

local function set_highlights()
    for name, target in pairs({
        ClaudeHistoryDate = 'Comment',
        ClaudeHistoryFolder = 'Directory',
        ClaudeHistoryTitle = 'Title',
        ClaudeHistoryCount = 'Comment',
        ClaudeHistoryPromptNo = 'Number',
        ClaudeHistoryTime = 'Comment',
        ClaudeHistoryPrompt = 'Normal',
        ClaudeHistoryFold = 'Normal',
        ClaudeHistoryBar = 'StatusLine',
        ClaudeHistoryKey = 'Special',
        ClaudeHistoryAlive = 'DiagnosticOk',
        ClaudeHistoryGone = 'Comment',
        ClaudeHistoryHere = 'DiagnosticWarn',
    }) do
        vim.api.nvim_set_hl(0, name, { link = target, default = true })
    end
end

local function pane_open() return pane.win ~= nil and vim.api.nvim_win_is_valid(pane.win) end
-- Row identity, kept across redraws: a session (n = 0) or prompt, or a worktree row.
local function key_of(it)
    if not it then return nil end
    if it.jsonl then return it.jsonl .. ':' .. (it.n or 0) end
    return it.node and ('node:' .. it.node)
end

-- Shown at the top of the pane with ?, like NERDTree's quick help.
local HELP = {
    'Claude history',
    '',
    'In this pane',
    '  j / k              move; the window above shows that session, at that prompt',
    '  <CR> / <Space> / o open / close a worktree, or a session\'s prompts',
    '  <CR> on a prompt   close the pane and jump into the transcript at it',
    '  p                  up to the parent row (prompt -> session -> worktree)',
    '  q / ft            close the pane',
    '  ?                  show / hide this help (q also hides it)',
    '',
    '  ● / ○              session running / not running',
    '  (N)                number of prompts in the session',
    '  [N]                number of sessions in the worktree and those under it',
    '',
    'The tree',
    '  repo -> worktree -> worktrees made from it -> session -> prompts. A worktree',
    '  goes under the one whose session ran its `git worktree add`, else under the',
    '  one it\'s named after (<that>-<suffix>). A session goes under the worktree',
    '  you typed most of its prompts in. Removed worktrees stay while they have',
    '  sessions. It opens at your newest session in the worktree you\'re in.',
    '',
    'In a transcript',
    '  ft                 toggle this pane, opened at that session and prompt',
    '  ]] / [[            next / previous prompt',
    '  za / zo / zc       toggle / open / close the reply under the cursor',
    '  zR / zM            open / close every reply',
    '  q                  close the transcript',
    '',
    'Commands',
    '  :ClaudeHistory          this repo\'s sessions, as a tree of its worktrees',
    '  :ClaudeHistory!         every project\'s sessions',
    '  :ClaudeHistoryGrep[!]   fzf search through every prompt typed here (! every project)',
    '  :ClaudeSend[!] / ,k     send <file>:L<lines> + a prompt to a running session in tmux',
    '',
    'How it works',
    '  Sessions come from ~/.claude/projects/<project>/<id>.jsonl, newest first.',
    '  Each is rendered next to it as <yyyymmdd>-<HHMM>-<folder>-<title>.md and',
    '  re-rendered whenever the jsonl changes (every 1.5s while shown), so a live',
    '  session follows. Running = a live pid in ~/.claude/sessions/<pid>.json.',
}

-- Lines, highlight spans and per-line items for the pane (help lines get a { help = true } item).
-- Every row's item has its fold level: worktree rows open at their depth, a session one deeper,
-- its prompts one deeper than that. With `all` (no tree) sessions are at level 1.
local function build(entries, tree)
    local lines, marks, items = {}, {}, {}
    local function add(segments, item)
        local text = ''
        for _, seg in ipairs(segments) do
            if seg[2] then marks[#marks + 1] = { #lines, #text, #text + #seg[1], seg[2] } end
            text = text .. seg[1]
        end
        lines[#lines + 1] = text
        items[#items + 1] = item
    end
    if pane.help then
        for _, l in ipairs(HELP) do
            local text = l == '' and '"' or ('" ' .. l)
            local s, e = text:find('^"   %S.-%s%s')
            if l ~= '' and not l:match('^%s') then
                add({ { text, 'ClaudeHistoryTitle' } }, { help = true, level = 0 })
            elseif s then
                -- key column: the text before the first run of 2+ spaces after the indent
                add({ { text:sub(1, 4), 'Comment' }, { text:sub(5, e - 2), 'ClaudeHistoryKey' }, { text:sub(e - 1), 'Comment' } }, { help = true, level = 0 })
            else
                add({ { text, 'Comment' } }, { help = true, level = 0 })
            end
        end
        add({ { '' } }, { help = true, level = 0 })
    end
    local live = live_sessions()
    local function sessions(list, depth, show_folder)
        local width = 0
        if show_folder then
            for _, e in ipairs(list) do width = math.max(width, vim.fn.strdisplaywidth(e.folder)) end
        end
        local pad = string.rep('  ', depth)
        for _, e in ipairs(list) do
            local alive = live[session_id(e.file)] ~= nil
            add({
                { pad },
                alive and { '● ', 'ClaudeHistoryAlive' } or { '○ ', 'ClaudeHistoryGone' },
                { os.date('%m-%d %H:%M', math.floor(e.mtime / 1e9)), 'ClaudeHistoryDate' }, { '  ' },
                show_folder and { e.folder .. string.rep(' ', width - vim.fn.strdisplaywidth(e.folder)) .. '  ', 'ClaudeHistoryFolder' } or { '' },
                { e.title, 'ClaudeHistoryTitle' }, { '  ' },
                { ('(%d)'):format(#e.prompts), 'ClaudeHistoryCount' },
            }, { jsonl = e.file, level = depth + 1 })
            for i, p in ipairs(e.prompts) do
                add({
                    { pad .. '   ' }, { ('%3d'):format(i), 'ClaudeHistoryPromptNo' }, { '  ' },
                    { local_ts(p.ts):sub(12), 'ClaudeHistoryTime' }, { '  ' },
                    { one_line(p.text, 160), 'ClaudeHistoryPrompt' },
                }, { jsonl = e.file, n = i, level = depth + 2 })
            end
        end
    end
    if not tree then
        sessions(entries, 0, true)
        return lines, marks, items
    end
    local here = pane.here
    local function worktree(n, depth)
        local name = vim.fn.fnamemodify(n.path, ':t')
        add({
            { string.rep('  ', depth) },
            { name, n.path == here and 'ClaudeHistoryHere' or 'ClaudeHistoryFolder' },
            n.gone and { '  (removed)', 'Comment' } or { '' },
            { ('  [%d]'):format(n.total), 'ClaudeHistoryCount' },
            n.path == here and { '  ← you are here', 'ClaudeHistoryHere' } or { '' },
        }, { node = n.path, level = depth + 1 })
        sessions(n.sessions, depth + 1, false)
        for _, k in ipairs(n.kids) do worktree(k, depth + 1) end
    end
    worktree(tree, 0)
    return lines, marks, items
end

local function line_of(key)
    for i, it in ipairs(pane.items) do
        if key_of(it) == key then return i end
    end
end

-- Pane folds come from the rows' levels: worktree and session rows start a fold, prompts sit in their session's.
function _G.ClaudeHistoryPaneFold()
    local it = pane.items[vim.v.lnum]
    if not it or it.level == 0 then return '0' end
    return it.n and tostring(it.level - 1) or ('>' .. it.level)
end

-- (Re)draw the pane. Keeps open folds and the cursor; `target` puts the cursor there instead:
-- { jsonl, n } a session or prompt (`shut`: leave the session's prompts folded), or { node } a worktree.
-- Only the folds holding the cursor are open the first time.
local function render_pane(target)
    local opened, cur = {}, nil
    vim.api.nvim_win_call(pane.win, function()
        for i, it in ipairs(pane.items) do
            if it.level > 0 and not it.n and vim.fn.foldclosed(i) == -1 then opened[key_of(it)] = true end
        end
        cur = key_of(pane.items[vim.fn.line('.')])
    end)
    local entries, scope = session_entries(pane.all)
    pane.tree = scope and session_tree(entries, scope) or nil
    local lines, marks, items = build(entries, pane.tree)
    pane.items = items
    vim.bo[pane.buf].modifiable = true
    vim.api.nvim_buf_set_lines(pane.buf, 0, -1, false, #lines > 0 and lines or { '  (no Claude sessions here)' })
    vim.bo[pane.buf].modifiable = false
    if #lines == 0 then pane.items = { { level = 0 } } end
    vim.api.nvim_buf_clear_namespace(pane.buf, NS, 0, -1)
    for _, m in ipairs(marks) do
        vim.api.nvim_buf_set_extmark(pane.buf, NS, m[1], m[2], { end_col = m[3], hl_group = m[4] })
    end
    if target then cur = key_of(target) end
    vim.api.nvim_win_call(pane.win, function()
        vim.cmd('normal! zXzR')
        -- bottom-up, so each :foldclose closes the fold starting on that row, not an enclosing one
        for i = #pane.items, 1, -1 do
            local it = pane.items[i]
            if it.level > 0 and not it.n and not opened[key_of(it)] then vim.cmd(i .. 'foldclose') end
        end
        local l = cur and line_of(cur) or 1
        pane.last = key_of(pane.items[l])
        vim.api.nvim_win_set_cursor(0, { l, 0 })
        if target then
            vim.cmd('normal! zv')
            if target.shut then vim.cmd('normal! zc') end
        end
    end)
end

function M.pane_rerender()
    if pane_open() then render_pane() end
end

-- ? : show / hide the help at the top of the pane. Showing it moves the cursor up to it.
local function toggle_help()
    pane.help = not pane.help
    render_pane()
    if pane.help then vim.api.nvim_win_set_cursor(pane.win, { 1, 0 }) end
end

-- Window the pane shows sessions in; made next to the first window if every other one is pinned.
local function target_window()
    if pane.src_win and vim.api.nvim_win_is_valid(pane.src_win) then return pane.src_win end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if w ~= pane.win and not vim.wo[w].winfixbuf and vim.api.nvim_win_get_config(w).relative == '' then
            pane.src_win = w
            return w
        end
    end
    vim.api.nvim_win_call(vim.api.nvim_tabpage_list_wins(0)[1], function()
        vim.cmd('rightbelow vnew')
        pane.src_win = vim.api.nvim_get_current_win()
    end)
    return pane.src_win
end

-- Follow the pane cursor: show that session (at that prompt). `focus` also closes the pane and jumps there.
local function follow(focus)
    local it = pane.items[vim.api.nvim_win_get_cursor(pane.win)[1]]
    if not it or not it.jsonl then return end
    if focus or key_of(it) ~= pane.last then
        pane.last = key_of(it)
        show_in(target_window(), it.jsonl, it.n)
    end
    if focus then
        local win = pane.src_win
        M.pane_close()
        vim.api.nvim_set_current_win(win)
    end
end

function M.pane_close()
    if pane_open() then
        if #vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(pane.win)) > 1 then
            vim.api.nvim_win_close(pane.win, true)
        else
            -- every other window is gone; don't leave the pane as the last window
            vim.api.nvim_win_call(pane.win, function() vim.cmd('enew') end)
        end
    end
    pane.win, pane.buf = nil, nil
end

-- Session and prompt the cursor is on, if the current buffer is a transcript.
local function transcript_position()
    if not vim.b.claude_history then return nil end
    local jsonl = jsonl_of(md_of(0))
    if not jsonl then return nil end
    local l = vim.fn.search('^## \\d\\+\\. ', 'bcnW')
    return { jsonl = jsonl, n = l > 0 and tonumber(vim.fn.getline(l):match('^## (%d+)')) or nil }
end


function M.pane_toggle(all)
    if pane_open() then return M.pane_close() end
    local target = transcript_position()
    pane.src_win = not vim.wo.winfixbuf and vim.api.nvim_get_current_win() or nil
    pane.all, pane.items, pane.help = all, {}, false
    local scope = repo_scope()
    -- where you are: the current file, or the cwd for a buffer that isn't one
    local file = vim.api.nvim_buf_get_name(0)
    local here = vim.bo.buftype == '' and file ~= '' and file or vim.fn.getcwd()
    pane.here = node_of(here, scope) or scope.top
    pane.scope_label = vim.fn.fnamemodify(scope.roots[1], ':t') .. ' + all worktrees'
    pane.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[pane.buf].bufhidden = 'wipe'
    vim.bo[pane.buf].filetype = 'claudehistory'
    vim.cmd('botright 15split')
    pane.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(pane.win, pane.buf)
    for opt, val in pairs({
        number = false, relativenumber = false, signcolumn = 'no', wrap = false, cursorline = true,
        winfixheight = true, foldcolumn = '0', foldmethod = 'expr', foldlevel = 0, foldtext = '',
        foldexpr = 'v:lua.ClaudeHistoryPaneFold()', fillchars = 'fold: ,eob: ',
        winhighlight = 'Folded:ClaudeHistoryFold,StatusLine:ClaudeHistoryBar',
        statusline = ' %#ClaudeHistoryTitle#Claude history%#ClaudeHistoryBar#'
            .. (all and '  (all projects)' or ('  ' .. pane.scope_label))
            .. '   %#ClaudeHistoryKey#<CR>/<Space>/o%#ClaudeHistoryBar# fold  %#ClaudeHistoryKey#<CR>%#ClaudeHistoryBar# on a prompt: jump in'
            .. '  %#ClaudeHistoryKey#q%#ClaudeHistoryBar# close  %#ClaudeHistoryKey#?%#ClaudeHistoryBar# help',
    }) do
        vim.wo[pane.win][opt] = val
    end
    render_pane(target or { node = pane.here })
    if target and not line_of(key_of(target)) and not all then
        -- a transcript from another project isn't in this repo's tree
        pane.all = true
        render_pane(target)
    elseif not target and pane.tree then
        -- not in a transcript: the newest session of the worktree you're in (or of those under it)
        local n = find_node(pane.tree, pane.here)
        if n then render_pane(nearest(n)) end
    end

    local o = { buffer = pane.buf, silent = true, nowait = true }
    vim.keymap.set('n', '<CR>', function()
        local it = pane.items[vim.fn.line('.')]
        if not it or it.level == 0 then return end
        if it.n then follow(true) else vim.cmd('normal! za') end
    end, o)
    for _, k in ipairs({ '<Space>', 'o' }) do vim.keymap.set('n', k, 'za', o) end
    -- up to the parent row: a prompt's session, a session's worktree, a worktree's parent worktree
    vim.keymap.set('n', 'p', function()
        local l = vim.fn.line('.')
        local it = pane.items[l]
        if not it or it.level == 0 then return end
        for i = l - 1, 1, -1 do
            local up = pane.items[i]
            if up.level > 0 and up.level < it.level then return vim.api.nvim_win_set_cursor(0, { i, 0 }) end
        end
    end, o)
    vim.keymap.set('n', 'ft', M.pane_close, o)
    vim.keymap.set('n', 'q', function() if pane.help then toggle_help() else M.pane_close() end end, o)
    vim.keymap.set('n', '?', toggle_help, o)
    -- Scheduled: autocmds don't nest, so loading the transcript from inside CursorMoved
    -- would skip its BufRead/FileType handlers (no markdown highlighting, no keys).
    vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = pane.buf,
        callback = function() vim.schedule(function() if pane_open() then follow(false) end end) end,
    })
    -- Show the row under the cursor (the latest session) right away; render_pane marked it as
    -- already shown, so the first follow() would skip it until the cursor moved.
    pane.last = nil
    vim.schedule(function() if pane_open() then follow(false) end end)
end

vim.api.nvim_create_autocmd('WinClosed', {
    group = vim.api.nvim_create_augroup('claude_history_pane', { clear = true }),
    callback = function(ev)
        if tonumber(ev.match) == pane.src_win then pane.src_win = nil end
        vim.schedule(function()
            if pane_open() and #vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(pane.win)) == 1 then
                M.pane_close()
            end
        end)
    end,
})

---------------------------------------------------------------------------
-- prompt search
---------------------------------------------------------------------------

function M.grep_prompts(all)
    local rows = {}
    for _, e in ipairs(session_entries(all)) do
        for i, p in ipairs(e.prompts) do
            rows[#rows + 1] = ('%s\t%d\t\27[90m%s\27[0m  \27[34m%s\27[0m  %s'):format(
                e.file, i, local_ts(p.ts):sub(6), e.folder, one_line(p.text, 160))
        end
    end
    if #rows == 0 then
        return vim.notify('claude_history: no Claude sessions found for ' .. vim.fn.getcwd(), vim.log.levels.WARN)
    end
    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
        source = rows,
        sink = function(line)
            local f, n = unpack(vim.split(line, '\t'))
            M.open(f, tonumber(n))
        end,
        options = { '--ansi', '--delimiter=\t', '--with-nth=3..', '--no-sort', '--prompt', 'Prompts> ' },
    }))
end

---------------------------------------------------------------------------

set_highlights()
local group = vim.api.nvim_create_augroup('claude_history', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlights })
vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    pattern = PROJECTS .. '/*/*.md',
    callback = function(ev)
        -- only rendered transcripts, not e.g. <project>/memory/*.md
        if not is_transcript(ev.buf) then return end
        setup_transcript(ev.buf)
        watch()
    end,
})

vim.api.nvim_create_user_command('ClaudeHistory', function(o) M.pane_toggle(o.bang) end, { bang = true })
vim.api.nvim_create_user_command('ClaudeHistoryGrep', function(o) M.grep_prompts(o.bang) end, { bang = true })
-- nvim's built-in commenting also lives on gc/gcc; commenting is on ,c (vim-commentary, see misc.vim)
for _, m in ipairs({ { 'n', 'gcc' }, { 'x', 'gc' }, { 'o', 'gc' } }) do pcall(vim.keymap.del, m[1], m[2]) end
vim.api.nvim_create_user_command('ClaudeSend', function(o) M.send(o.line1, o.line2, true, o.bang) end, { range = true, bang = true })
vim.keymap.set('n', '<leader>k', function() M.send(vim.fn.line('.'), vim.fn.line('.')) end,
    { silent = true, desc = 'Send file:line + prompt to Claude' })
vim.keymap.set('x', '<leader>k', function()
    local a, b = vim.fn.line('v'), vim.fn.line('.')
    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
    M.send(math.min(a, b), math.max(a, b))
end, { silent = true, desc = 'Send file:lines + prompt to Claude' })

return M

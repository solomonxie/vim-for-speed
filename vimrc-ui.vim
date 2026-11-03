"-----------------------------------------------------------------------
"          __     ___             _____ _                              -
"          \ \   / (_)_ __ ___   |_   _| |__   ___ _ __ ___   ___      -
"           \ \ / /| | '_ ` _ \    | | | '_ \ / _ \ '_ ` _ \ / _ \     -
"            \ V / | | | | | | |   | | | | | |  __/ | | | | |  __/     -
"             \_/  |_|_| |_| |_|   |_| |_| |_|\___|_| |_| |_|\___|     -
"                                                                      -
"----------------------------GENERATED-BY-FIGLET------------------------

"REF: http://bytefluent.com/devify/

" --- COLORS SCHEME / THEMES ---

"==========> GRUVBOX ============>>>>
" colorscheme gruvbox ">> grubox is slow for old machine
"let g:gruvbox_contrast_dark='hard' "[hard|medium|soft]

"==========> BADWOLF ============>>>>
" Plug 'solomonxie/badwolf'
"FILE: ./colors/badwolf.vim
let g:enable_badwolf_plugin = 0
let g:enable_badwolf_filetype = 1
let g:enable_badwolf_vim = 0
let g:enable_badwolf_python = 0
let g:enable_badwolf_ctrlp = 0
let g:enable_badwolf_easymotion = 0
let g:enable_badwolf_intersting_words = 0
let g:enable_badwolf_makegreen = 0
let g:enable_badwolf_rainbow_parentheses = 0
let g:enable_badwolf_show_marks = 0
let g:enable_badwolf_clojure = 0
let g:enable_badwolf_common_lisp = 0
let g:enable_badwolf_css = 0
let g:enable_badwolf_diff = 0
let g:enable_badwolf_django_templates = 0
let g:enable_badwolf_html = 0
let g:enable_badwolf_java = 0
let g:enable_badwolf_latex = 0
let g:enable_badwolf_less_css = 0
let g:enable_badwolf_lispyscript = 0
let g:enable_badwolf_repls = 0
let g:enable_badwolf_mail = 0
let g:enable_badwolf_markdown = 0
let g:enable_badwolf_mysql = 0
let g:enable_badwolf_slimv = 0
colorscheme badwolf  "16ms after my fork

" Diff mode (:DiffSplit, nvim -d): badwolf's DiffAdd is a gray bg with black text, and DiffDelete
" is solid black, so added lines read as greyed out. Green = added, red filler = deleted,
" amber = changed line, brighter amber = the changed words. Same tints as the gitgutter line colors.
function! s:DiffColors() abort
    highlight DiffAdd    cterm=NONE ctermfg=NONE ctermbg=22  gui=NONE guifg=NONE guibg=#1a3a24
    highlight DiffDelete cterm=NONE ctermfg=52   ctermbg=52  gui=NONE guifg=#3a1a1a guibg=#3a1a1a
    highlight DiffChange cterm=NONE ctermfg=NONE ctermbg=58  gui=NONE guifg=NONE guibg=#3a3a1a
    highlight DiffText   cterm=bold ctermfg=NONE ctermbg=94  gui=bold guifg=NONE guibg=#5f4a00
endfunction
call s:DiffColors()
autocmd ColorScheme * call s:DiffColors()

" ==========> ALTERNATIVES ===========>
    "colorscheme gruvbox  "20ms
    "colorscheme cobalt2 "100ms
    "colorscheme monokai "7ms. Fast (sickill/vim-monokai)
    "colorscheme shades_of_purple ">> Require the plugin

" ==========> Colorscheme based on filetype ===========>
    "autocmd FileType python colorscheme gruvbox
    "autocmd FileType vim,tmux,sh,txt,dockerfile colorscheme badwolf


" --- GENERAL UI / COLOR SCHEME ---
function SetSyntax()
    let b:max_line = 5000
    if line('$') <= b:max_line "&& &syntax != 'manual'
        syntax manual
        set syntax=on
        filetype plugin on    " [essential]
        filetype plugin indent on
    else
        set syntax=off
        filetype plugin off    " [essential]
        filetype plugin indent off
    endif
endfunction

" <Syntax Highlighting>  Better to be in the front
    syntax on  "Speed: off > manual > on > enable

    ""ULTIMATE PERFORMANCE STRATEGY: disable syntax at start, then lazy load on buffer level
    "syntax off  "Speed: off > manual > on > enable
    " autocmd BufEnter *.py,*.js,*.md,*.sql,*.json,*.json.gz,*.yaml,*.yml,*.csv,*.csv.gz,*.vim,*.sh,*.zsh,zshrc*,Makefile*,*.snippets call SetSyntax()
    " autocmd FileType nerdtree call SetSyntax()
    " autocmd FileType vista call SetSyntax()
    autocmd BufRead *.json.gz set filetype=json
    autocmd BufRead *.sh,envfile*,.bashrc*,.zshrc* set filetype=bash
    autocmd BufRead,BufNewFile *.snippets set filetype=snippets
    autocmd BufRead *.ini,*rc,*.service,*.conf,*.config,*.cfg set syntax=config  "or syntax=config
    autocmd BufRead requirements*.txt set syntax=requirements

    let python_highlight_all = 1  "FOR vim/syntax/python.vim (FROM WEB)
"<FileType>
    " filetype plugin on    " [essential]
    " filetype plugin indent on

" <Basic Settings>
    set t_Co=256   ">> Overwriting Alert !!
    " set termguicolors  "{True Color Support} Vim-specific sequences for RGB colors
    set notermguicolors  "Turn off -> when on, bg-color will affect the whole look
    set background=dark   ">> Overwriting Alert !!

    "[CAREFUL!!!] >> Ugly when working with other themes & syntax highlighting plugins
    set fillchars+=vert:\|  "Bar character for VERTical Split Pane

    "Text wrapping
    " set nowrap
    set wrap linebreak nolist

" =={NUMBER LINE}==
    " turn hybrid line numbers on
    " set number relativenumber
    set number norelativenumber
    " highlight! LineNr ctermfg=gray ctermbg=black cterm=NONE guibg=black guifg=gray
    " highlight! SignColumn ctermfg=gray ctermbg=black cterm=NONE guibg=black guifg=gray
    " Automatic toggling between line number modes
    " augroup AutoToggleRelativeNumber
    "   autocmd!
    "   autocmd FocusGained,InsertLeave * set relativenumber
    "   autocmd FocusLost,InsertEnter   * set norelativenumber
    " augroup END

    "MUST GO BEFORE `colorscheme` and after `autocmd`
    " autocmd ColorScheme * highlight Normal ctermbg=None
    " autocmd ColorScheme * highlight NonText ctermbg=None

" <Spell Check>
    " autocmd BufRead,BufNewFile *.txt,*.md setlocal spell spelllang=en,en_us,cjk
    autocmd FileType gitcommit setlocal spell spelllang=en,en_us,cjk

" <Length Marker>
    " highlight OverLength ctermbg=red ctermfg=white  "> Warning color
    " let &colorcolumn=join(range(120,999),",")  "> Warning Column

    "match OverLength /\%81v.\+/

    "> or
    " let &colorcolumn="120,".join(range(400,999),",")
    "> or
    "set colorcolumn=80
    "highlight ColorColumn guibg=#155460
    "> or
    "highlight ColorColumn ctermbg=grey
    "> or
    "highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

    set jumpoptions-=clean  "After nvim 0.10.+, Ctrl-O can't jump back (buffer removed from jumplist) (REF: issues/28968)

" --- HIGHLIGHTING ---
" >>
    set showmatch
    set matchtime=3
    highlight Search guibg='Purple' guifg='NONE'
    highlight IncSearch gui=underline,bold guifg=White guibg=Red3
    "highlight IncSearch ctermbg=black ctermfg=yellow
"Cancel Highlighting when mouse on idle
    "autocmd cursorhold * set nohlsearch
"Highlight on paired braket
    "highlight MatchParen cterm=underline ctermbg=NONE ctermfg=NONE"

" <Highlight Settings>  --> Overwriting Alert!
    "-----> Has to be after loading colorscheme
    " highlight! Normal ctermbg=NONE
    "highlight! nonText ctermbg=NONE
    "highlight! VertSplit guifg=red guibg=blue term=None
    "highlight! Normal ctermbg=White ctermfg=Black guifg=Black guibg=White
    " highlight! Normal ctermfg=grey ctermbg=black  "Set background color
    " highlight Normal guibg=black

" =={CURSOR LINE}==
    " REF: https://jonasjacek.github.io/colors/
    " REF: https://vi.stackexchange.com/questions/23066/change-cursorline-style
    set cursorline  "Highlighting current line
    " autocmd WinEnter * set cursorline
    " autocmd WinLeave * set nocursorline
    highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=237  "Grey
    highlight! CursorLineNr cterm=NONE ctermfg=11 gui=bold guifg=Yellow
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=214  "Orange
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=161  "Deep Pink
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=8  "Grey
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=88  "Dark Red
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=89  "Pink
    " highlight! CursorLine cterm=NONE ctermfg=NONE ctermbg=90  "Dark Magenta
    " highlight! CursorLine cterm=underline ctermfg=NONE ctermbg=236  "Dark Magenta
    " highlight! CursorLineNR cterm=NONE ctermfg=NONE ctermbg=89  "Pink

" =={TRAILING WHITESPACE}==
highlight TrailingWhitespace ctermbg=red guibg=red
autocmd BufRead,BufNewFile * match TrailingWhitespace /\s\+$/

" --- PLUGIN RELATED ---
" THIS IS REQUIRED BY PLUGIN TO LOAD AFTER SETTING COLORSCHEME

highlight HighlightedyankRegion cterm=reverse gui=reverse



" --- NEOVIM UI ---
" Change Linter result colors
highlight DiagnosticsError ctermfg=4 guifg=Red
highlight DiagnosticsWarning ctermfg=4 guifg=Orange
highlight DiagnosticsInformation ctermfg=4 guifg=Grey
highlight DiagnosticsHint ctermfg=4 guifg=Grey
highlight DiagnosticsVirtualTextError ctermfg=4 guifg=Red
highlight DiagnosticsVirtualTextWarning ctermfg=4 guifg=Orange
highlight DiagnosticsVirtualTextInformation ctermfg=4 guifg=Grey
highlight DiagnosticsVirtualTextHint ctermfg=4 guifg=Grey

lua <<EOF
local diagnostic_config = {
    virtual_text = {
        severity = {
            min = vim.diagnostic.severity.WARN,
        },
        source = "always",
        prefix = '●', -- Could be '■', '▎', 'x'
    },
    signs = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
}
vim.diagnostic.config(diagnostic_config)
EOF



" --- PYTHON HIGHLIGHTS ---
" Semshi-style syntax highlighting for Python using Tree-sitter and LSP
hi semshiLocal           ctermfg=209 guifg=#ff875f " Salmon
hi semshiGlobal          ctermfg=214 guifg=#ffaf00 " Orange
hi semshiImported        ctermfg=214 guifg=#ffaf00 cterm=bold gui=bold " Orange (Bold)
hi semshiParameter       ctermfg=75  guifg=#5fafff " Blue
hi semshiParameterUnused ctermfg=117 guifg=#87d7ff cterm=underline gui=underline " Light Blue (Underline)
hi semshiFree            ctermfg=218 guifg=#ffafd7 " Pink
hi semshiBuiltin         ctermfg=207 guifg=#ff5fff " Magenta
hi semshiAttribute       ctermfg=44  guifg=#00d7d7 " Turquoise
hi semshiSelf            ctermfg=249 guifg=#b2b2b2 " Grey
hi semshiUnresolved      ctermfg=226 guifg=#ffff00 cterm=underline gui=underline " Yellow (Underline)
hi semshiSelected        ctermfg=16  guifg=#000000 ctermbg=221 guibg=#fade3e cterm=bold gui=bold " Black on Gold (Search style)
function! s:ApplyPythonSemshiHighlights()
    " Map Tree-sitter captures to Semshi groups
    hi! link @variable          semshiLocal
    hi! link @variable.python   Normal
    hi! link @variable.global   semshiGlobal
    hi! link @variable.builtin.python  semshiSelf
    hi! link @variable.parameter semshiParameter
    hi! link @variable.parameter.python semshiParameter
    hi! link @function          semshiGlobal
    hi! link @function.builtin  semshiBuiltin
    hi! link @function.call     Normal
    hi! link @function.python   semshiGlobal
    hi! link @method            semshiAttribute
    hi! link @method.call       semshiAttribute
    hi! link @property          semshiAttribute
    hi! link @attribute         semshiAttribute
    hi! link @variable.member   Normal
    hi! link @variable.field    semshiAttribute
    hi! link @module            semshiImported
    hi! link @module.python     semshiImported
    hi! link @constant          semshiGlobal
    hi! link @constant.builtin  semshiBuiltin
    hi! link @constant.python    semshiGlobal
    hi! link @constructor.python semshiGlobal
    hi! link @type.python semshiGlobal
    hi! link @function.method.call.python Normal
    hi! link @variable.member.python Normal
    " Map LSP semantic tokens
    hi! link @lsp.type.namespace.python   semshiImported
    hi! link @lsp.type.namespace          semshiImported
    hi! link @lsp.type.variable.python    Normal
    hi! link @lsp.type.parameter.python   semshiParameter
    hi! link @lsp.type.function.python    semshiGlobal
    hi! link @lsp.type.method.python      semshiAttribute
    hi! link @lsp.type.property.python    semshiAttribute
    " Special/Advanced Mappings
    hi! link DiagnosticUnused             semshiParameterUnused
    " Not linked: @lsp.mod.readonly.python would overlay on top of the type
    " highlight (e.g. params/locals never reassigned), clobbering param blue
    " with global orange/yellow for every non-reassigned name.
endfunction

augroup PythonSemshi
    autocmd!
    autocmd ColorScheme,FileType python call s:ApplyPythonSemshiHighlights()
augroup END

function! s:ApplyDocumentHighlightColors()
    hi! link LspReferenceText  semshiSelected
    hi! link LspReferenceRead  semshiSelected
    hi! link LspReferenceWrite semshiSelected
endfunction

augroup DocumentHighlightColors
    autocmd!
    autocmd ColorScheme * call s:ApplyDocumentHighlightColors()
augroup END
call s:ApplyDocumentHighlightColors()

lua <<EOF
-- Document highlight (occurrences of word under cursor), debounced on
-- CursorMoved instead of CursorHold so it's not tied to 'updatetime'.
local HIGHLIGHT_DEBOUNCE_MS = 120

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not (client and client.server_capabilities.documentHighlightProvider) then
            return
        end

        local group = vim.api.nvim_create_augroup('LspDocumentHighlight', { clear = false })
        vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })

        local timer = nil
        local function schedule_highlight()
            if timer then
                timer:stop()
                timer:close()
            end
            timer = vim.uv.new_timer()
            timer:start(HIGHLIGHT_DEBOUNCE_MS, 0, vim.schedule_wrap(function()
                timer = nil
                -- vim.lsp.buf.document_highlight() renders whatever the server
                -- returns verbatim. gopls's own documentHighlight sometimes
                -- includes more than literal occurrences of the word under the
                -- cursor (e.g. return statements when on "func", or other
                -- same-purpose functions) -- filter to exact-text matches only.
                local bufnr = ev.buf
                local word = vim.fn.expand('<cword>')
                local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                vim.lsp.buf_request(bufnr, 'textDocument/documentHighlight', params, function(err, result, ctx)
                    if err or not result then
                        return
                    end
                    local hl_client = vim.lsp.get_client_by_id(ctx.client_id)
                    if not hl_client then
                        return
                    end
                    local filtered = vim.tbl_filter(function(ref)
                        local r = ref.range
                        if r.start.line ~= r['end'].line then
                            return false
                        end
                        local line = vim.api.nvim_buf_get_lines(bufnr, r.start.line, r.start.line + 1, false)[1] or ''
                        return line:sub(r.start.character + 1, r['end'].character) == word
                    end, result)
                    vim.lsp.util.buf_highlight_references(bufnr, filtered, hl_client.offset_encoding)
                end)
            end))
        end

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            group = group,
            buffer = ev.buf,
            callback = function()
                vim.lsp.buf.clear_references()
                schedule_highlight()
            end,
        })
        vim.api.nvim_create_autocmd('BufLeave', {
            group = group,
            buffer = ev.buf,
            callback = function()
                if timer then
                    timer:stop()
                    timer:close()
                    timer = nil
                end
            end,
        })
    end,
})
EOF



" ============= End of File ==================
" echom 'Loaded ' . expand('<sfile>:t') |redraw

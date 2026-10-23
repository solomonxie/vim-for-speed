-- Markdown UI enhancement
-- This configures Neovim to show a more "preview-like" version of Markdown files.

-- Enable concealment to hide **bold**, _italic_, and `code` markers.
vim.opt.conceallevel = 0

-- Don't conceal in the current line while editing
vim.opt.concealcursor = 'nc'

-- Keep ``` fences and their language name visible: nvim-treesitter's markdown query conceals them
-- (whole lines too), and an `; extends` file can't undo that, so replace the query with a copy minus the conceals
pcall(function()
    local parts = {}
    for _, path in ipairs(vim.treesitter.query.get_files('markdown', 'highlights')) do
        table.insert(parts, table.concat(vim.fn.readfile(path), '\n'))
    end
    local query = table.concat(parts, '\n')
    query = query:gsub('%(#set! conceal_lines ""%)', '')
    query = query:gsub('%(#set! conceal ""%)', '')
    vim.treesitter.query.set('markdown', 'highlights', query)
end)

-- Set file-specific highlights for Markdown
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        -- Disable spell check for markdown
        vim.opt_local.spell = false
        -- Hide the markers treesitter marks concealable: ** and * around bold/italic, ` around code, link URLs
        vim.opt_local.conceallevel = 2
        
        -- BOLD: Bright Yellow/Gold to be unmistakable
        vim.cmd([[hi! markdownBold gui=bold cterm=bold guifg=#f9e2af ctermfg=222]])
        
        -- ITALIC: Distinct Purple/Lavender
        vim.cmd([[hi! markdownItalic gui=italic cterm=italic guifg=#cba6f7 ctermfg=177]])

        -- CODE (Pinkish): For `` words
        vim.cmd([[hi! markdownCode guifg=#f5c2e7 ctermfg=211]])
        
        -- CODE BLOCKS: Soft Lavender/Grey
        vim.cmd([[hi! markdownCodeBlock guifg=#bac2de ctermfg=146]])

        -- Comprehensive links for both Treesitter and standard Syntax
        vim.cmd([[hi! link @markup.bold markdownBold]])
        vim.cmd([[hi! link @markup.italic markdownItalic]])
        vim.cmd([[hi! link @markup.raw markdownCode]])
        vim.cmd([[hi! link @markup.raw.block markdownCodeBlock]])
        
        -- Fallbacks for other syntax plugins
        vim.cmd([[hi! link htmlBold markdownBold]])
        vim.cmd([[hi! link htmlItalic markdownItalic]])
        vim.cmd([[hi! link htmlBoldItalic markdownBold]])

        -- Headers (Red/Orange/Yellow palette)
        vim.cmd([[hi! markdownH1 gui=bold,underline cterm=bold,underline guifg=#f38ba8 ctermfg=203]])
        vim.cmd([[hi! markdownH2 gui=bold cterm=bold guifg=#fab387 ctermfg=208]])
        vim.cmd([[hi! markdownH3 gui=bold cterm=bold guifg=#f9e2af ctermfg=222]])

        -- Links (Blue)
        vim.cmd([[hi! markdownLinkText gui=underline cterm=underline guifg=#89b4fa ctermfg=111]])
        vim.cmd([[hi! markdownUrl gui=italic cterm=italic guifg=#6c7086 ctermfg=243]])

        -- Quotes and tables: badwolf has no quote color and its Special (> and | markers) is plain white
        vim.cmd([[hi! @markup.quote.markdown gui=italic cterm=italic guifg=#a6adc8 ctermfg=146]])
        vim.cmd([[hi! @punctuation.special.markdown guifg=#94e2d5 ctermfg=116]])
    end
})

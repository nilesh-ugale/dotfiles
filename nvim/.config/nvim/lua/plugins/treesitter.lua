-- Parsers to keep installed. `install` skips any that are already present, so
-- listing them here is cheap; add a language and restart to pick it up.
local ensure_installed = {
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "vimdoc",
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        -- The main branch does not support lazy-loading.
        lazy = false,
        config = function()
            require('nvim-treesitter').setup()
            require('nvim-treesitter').install(ensure_installed)

            -- On the main branch, highlighting is Neovim's job rather than the
            -- plugin's: there is no `highlight.enable` any more.
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('TreesitterStart', {}),
                pattern = '*',
                callback = function(event)
                    local lang = vim.treesitter.language.get_lang(event.match)
                    if lang then
                        -- Fails when the parser isn't installed, which is fine:
                        -- we fall back to regex syntax for that filetype.
                        pcall(vim.treesitter.start, event.buf, lang)
                    end
                end,
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-context'
    },
}

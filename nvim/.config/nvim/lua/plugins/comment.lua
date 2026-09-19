return {
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({
                -- Comment.nvim resolves the commentstring through treesitter,
                -- guarding it with `pcall(vim.treesitter.get_parser, buf)`. Since
                -- Neovim 0.11 that call *returns nil* rather than raising when the
                -- filetype has no parser installed, so the `if not ok` guard never
                -- fires and the nil parser blows up one frame later. The error is
                -- swallowed into "[Comment.nvim] nil" and commenting silently does
                -- nothing -- in every filetype without a parser, which here means
                -- cpp (all .h files), sh, json and yaml.
                --
                -- pre_hook short-circuits that whole path: return a commentstring
                -- and the treesitter branch is never reached. The plugin's own
                -- filetype table is the source, so line and block comments both
                -- keep working; Neovim's 'commentstring' covers anything missing
                -- from it.
                pre_hook = function(ctx)
                    return require('Comment.ft').get(vim.bo.filetype, ctx.ctype)
                        or vim.bo.commentstring
                end,
            })
        end
    },
}

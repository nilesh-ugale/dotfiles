return {
    {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end
    },
    {
        'nvim-treesitter/playground'
    },
    {
        'nvim-treesitter/nvim-treesitter-context'
    },
}

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                background = {
                    -- :h background
                    light = "latte",
                    dark = "mocha",
                },
                transparent_background = true
            })
            vim.cmd.colorscheme('catppuccin')
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

            vim.cmd('hi CursorLineNr guifg=#ffffaf')
            vim.cmd('hi LineNr guibg=none guifg=#7f6faf')
            vim.cmd('set cursorline')
            vim.cmd('set cursorlineopt=number')
        end,
    },
}

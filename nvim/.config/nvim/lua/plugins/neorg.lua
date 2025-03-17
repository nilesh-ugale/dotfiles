return {
    {
        "nvim-neorg/neorg",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-neorg/neorg-telescope" },
            { "luarocks.nvim" },
        },
        version = "*",
        config = function()
            require("neorg").setup {
                load = {
                    ["external.telescope"] = {},
                    ["core.integrations.telescope"] = {},
                    ["core.summary"] = {},
                    ["core.export"] = {},
                    ["core.export.markdown"] = {},
                    ["core.defaults"] = {},
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                work = "~/notes/work",
                                personal = "~/notes/personal",
                                tasknotes = "~/notes/tasknotes",
                            },
                            default_workspace = "work",
                        },
                    },
                },
            }
            vim.wo.foldlevel = 99
            vim.wo.conceallevel = 3
        end,
    },
}

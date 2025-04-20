return {
    {
        'nvim-orgmode/orgmode',
        event = 'VeryLazy',
        ft = { 'org' },
        config = function()
            -- Setup orgmode
            require('orgmode').setup({
                org_agenda_files = '~/org/orgmode/**/*',
                org_default_notes_file = '~/org/orgmode/refile.org',
                org_todo_keywords = { 'TODO', 'WAITING', '|', 'DONE', 'DELEGATED' },
                ---@diagnostic disable-next-line: assign-type-mismatch
                win_split_mode = { 'float', 0.9 },
                org_log_done = 'note',
                org_log_into_drawer = 'LOGBOOK',

            })

            -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
            -- add ~org~ to ignore_install
            -- require('nvim-treesitter.configs').setup({
            --   ensure_installed = 'all',
            --   ignore_install = { 'org' },
            -- })
        end,
    },
    {
        "chipsenkbeil/org-roam.nvim",
        tag = "0.1.1",
        dependencies = {
            {
                "nvim-orgmode/orgmode",
                -- tag = "0.3.7",
            },
        },
        config = function()
            require("org-roam").setup({
                directory = "~/org/orgroam",
                -- optional
                org_files = {
                    "~/org/orgmode",
                }
            })
        end
    }
}

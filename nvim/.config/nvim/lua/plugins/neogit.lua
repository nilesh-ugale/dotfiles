return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",  -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            "nvim-tree/nvim-web-devicons",
            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
            -- "ibhagwan/fzf-lua",      -- optional
            -- "echasnovski/mini.pick", -- optional
        },
        config = function()
            require('neogit').setup({
                kind = "replace",
                commit_editor = {
                    kind = "replace",
                    show_staged_Vdiff = true,
                    -- Accepted values:
                    -- "split" to show the staged diff below the commit editor
                    -- "vsplit" to show it to the right
                    -- "split_above" Like :top split
                    -- "vsplit_left" like :vsplit, but open to the left
                    -- "auto" "vsplit" if window would have 80 cols, otherwise "split"
                    staged_diff_split_kind = "split",
                    spell_check = true,
                },
                commit_select_view = {
                    kind = "replace",
                },
                commit_view = {
                    kind = "vsplit",
                    verify_commit = vim.fn.executable("gpg") == 1, -- Can be set to true or false, otherwise we try to find the binary
                },
                log_view = {
                    kind = "replace",
                },
                rebase_editor = {
                    kind = "auto",
                },
                reflog_view = {
                    kind = "replace",
                },
                merge_editor = {
                    kind = "auto",
                },
                description_editor = {
                    kind = "auto",
                },
                tag_editor = {
                    kind = "auto",
                },
                preview_buffer = {
                    kind = "floating_console",
                },
                popup = {
                    kind = "split",
                },
                stash = {
                    kind = "replace",
                },
                refs_view = {
                    kind = "replace",
                },
            })
        end
    }
}

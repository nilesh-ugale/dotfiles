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
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup()
            local gitsigns = require('gitsigns')

            -- Navigation
            vim.keymap.set('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ ']c', bang = true })
                else
                    gitsigns.nav_hunk('next')
                end
            end)

            vim.keymap.set('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ '[c', bang = true })
                else
                    gitsigns.nav_hunk('prev')
                end
            end)

            -- Actions
            vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk)
            vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk)

            vim.keymap.set('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            vim.keymap.set('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer)
            vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer)
            vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk)
            vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline)

            vim.keymap.set('n', '<leader>hb', function()
                gitsigns.blame_line({ full = true })
            end)

            vim.keymap.set('n', '<leader>hd', gitsigns.diffthis)

            vim.keymap.set('n', '<leader>hD', function()
                gitsigns.diffthis('~')
            end)

            vim.keymap.set('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
            vim.keymap.set('n', '<leader>hq', gitsigns.setqflist)

            -- Toggles
            vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame)
            vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff)

            -- Text object
            vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end,
    }
}

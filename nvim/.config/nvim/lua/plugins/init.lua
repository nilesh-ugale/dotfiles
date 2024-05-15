return {
    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- We'd like this plugin to load first out of the rest
        config = true,   -- This automatically runs `require("luarocks-nvim").setup()`
    },
    {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        version = "*",
        config = function()
            require("neorg").setup {
                load = {
                    ["core.manoeuvre"] = {},
                    ["core.summary"] = {},
                    ["core.export"] = {},
                    ["core.export.markdown"] = {},
                    ["core.defaults"] = {},
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                notes = "~/notes",
                            },
                            default_workspace = "notes",
                        },
                    },
                },
            }

            vim.wo.foldlevel = 99
            vim.wo.conceallevel = 2
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            { 'nvim-lua/plenary.nvim' }
        }
    },
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    },
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {
                icons = false,
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },
            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    },
    {
        "catppuccin/nvim",
        name = "catppuccin"
    },
    {
        "vimwiki/vimwiki",
        config = function()
            vim.g.vimwiki_list = {
                {
                    path = '~/wiki',
                    syntax = 'markdown',
                    ext = '.md',
                },
            }
        end
    },
    {
        'renerocksai/telekasten.nvim',
        dependencies = {
            { 'nvim-telescope/telescope.nvim' }
        },
        config = function()
            require('telekasten').setup({
                home = vim.fn.expand("~/wiki"), -- Put the name of your notes directory here
            })
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    vim.cmd('hi tkTag ctermfg=175 guifg=#8e44ad')
                    vim.cmd('hi link CalNavi CalRuler')
                    vim.cmd('hi tkHighlight ctermbg=214 ctermfg=124 cterm=bold guibg=#fabd2f guifg=#9d0006 gui=bold')
                    vim.cmd('hi tkBrackets ctermfg=gray guifg=gray')
                    vim.cmd('hi tklink ctermfg=72 guifg=#0096FF cterm=bold,underline gui=bold')
                end,
            })
        end
    },
    { "renerocksai/calendar-vim" },
    { "tools-life/taskwiki" },
    { "nvim-treesitter/playground" },
    { "theprimeagen/harpoon" },
    { "theprimeagen/refactoring.nvim" },
    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },
    { "nvim-treesitter/nvim-treesitter-context" },
    { "folke/zen-mode.nvim" },
    { "eandrju/cellular-automaton.nvim" },
    { "laytan/cloak.nvim" },
    -- { "github/copilot.vim" },
}


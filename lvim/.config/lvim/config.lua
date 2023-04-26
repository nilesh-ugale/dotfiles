
--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "gruvbox"
lvim.transparent_window = true
lvim.lsp.diagnostics.virtual_text = false

-- lvim.lang.c.lsp = {}
-- lvim.lang.cpp = {}

lvim.builtin.lualine.extensions = {
   "fugitive",
   "fzf",
   "nvim-tree",
   "quickfix"
}

lvim.builtin.lualine.options = {
    theme = "onedark",
    icons_enabled = true,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "NvimTree", "Outline" }
}

lvim.builtin.lualine.tabline = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { require('tabline').tabline_buffers },
    lualine_x = { require('tabline').tabline_tabs },
    lualine_y = {},
    lualine_z = {},
}

lvim.builtin.lualine.sections.lualine_a = {
    {
        function()
            local alias = {
                n      = 'NORMAL',
                i      = 'INSERT',
                c      = 'COMMAND',
                V      = 'V-LINE',
                [''] = 'V-BLOCK',
                v      = 'VISUAL',
                ['r?'] = ':CONFIRM',
                rm     = '--MORE',
                R      = 'REPLACE',
                Rv     = 'VIRTUAL',
                s      = 'SELECT',
                S      = 'SELECT',
                ['r']  = 'HIT-ENTER',
                [''] = 'SELECT',
                t      = 'TERMINAL',
                ['!']  = 'SHELL'
            }

            local vim_mode = vim.fn.mode()

            return " " .. alias[vim_mode]
        end,
        padding = { left = 1, right = 0 },
        color = { gui = "bold" },
        cond = nil
    }
}

lvim.builtin.lualine.sections.lualine_y = {
    {
        function()
            local current_line = vim.fn.line "."
            local total_lines = vim.fn.line "$"
            return current_line .. ":" .. total_lines
        end,
        padding = { left = 1, right = 1 },
        color = {},
        cond = nil
    }
}

lvim.builtin.lualine.sections.lualine_z = {
    {
        function()
            local current_line = vim.fn.line "."
            local total_lines = vim.fn.line "$"
            local line_ratio = current_line / total_lines
            local index = math.floor(line_ratio * 100)
            return index .. "%%"
        end,
        padding = { left = 1, right = 1 },
        color = {
            gui = "bold"
        },
        cond = nil
    }
}

vim.g.tokyonight_style = "night"
vim.o.backspace = "indent,eol,start"
vim.o.timeoutlen = 400
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.relativenumber = true
vim.o.listchars = "tab:→\\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»"
vim.o.cmdheight = 1
vim.api.nvim_set_keymap("n", "Y", "y$", { noremap = true, silent = true } )

vim.api.nvim_set_keymap( "n", "n", "nzzzv", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "N", "Nzzzv", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "J", "mzJ`z", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "k", "(v:count > 5 ? \"m'\" . v:count : \"\") . 'k'", { noremap = true, silent = true, expr = true } )
vim.api.nvim_set_keymap( "n", "j", "(v:count > 5 ? \"m'\" . v:count : \"\") . 'j'", { noremap = true, silent = true, expr = true } )
-- Toggle relative line numbers and regular line numbers.
vim.api.nvim_set_keymap( "n", "<F6>", ":set invrelativenumber<CR>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "i", "<F6>", "<ESC>:set invrelativenumber<CR>li", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "v", "<F6>", "<ESC>:set invrelativenumber<CR>v", { noremap = true, silent = true } )
-- Toggle visually showi ng all whitespace characters.
vim.api.nvim_set_keymap( "n", "<F7>", ":set list!<CR>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "<F3>", ":noh<CR>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "i", "<F7>", "<ESC>:set list!<CR>li", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "v", "<F7>", "<ESC>:set list!<CR>v", { noremap = true, silent = true } )

vim.api.nvim_set_keymap( "n", "<F5>", ":set invspell<CR>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "i", "<F5>", "<ESC>:set invspell<CR>li", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "v", "<F5>", "<ESC>:set invspell<CR>v", { noremap = true, silent = true } )

-- Prevent x from overriding what's in the clipboard.
vim.api.nvim_set_keymap( "n", "x", "\"_x", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "X", "\"_x", { noremap = true, silent = true } )

vim.api.nvim_set_keymap( "i", "jk", "<ESC>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "i", "kj", "<ESC>", { noremap = true, silent = true } )

vim.api.nvim_set_keymap( "n", "<leader>ss", ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"Grep For >> \")})<CR>", { noremap = true, silent = true } )
vim.api.nvim_set_keymap( "n", "<leader>sw", ":lua require(\"telescope.builtin\").grep_string { search = vim.fn.expand(\"<cword>\") }<CR>", { noremap = true, silent =  true } )
vim.api.nvim_set_keymap( "n",
                         "<leader>si",
                         ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"Grep For >> \"), vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>",
                         { noremap = true, silent = true })
vim.api.nvim_set_keymap( "n",
                         "<leader>sd",
                         ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"For >> \"), search_dirs = vim.fn.input(\"In >> \"), vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>",
                         { noremap = true, silent = true })
vim.api.nvim_set_keymap( "n",
                         "<leader>sn",
                         ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"For >> \"), search_dirs = { vim.fn.input(\"In >> \") }, vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>",
                         { noremap = true, silent = true })

lvim.keys.normal_mode = vim.tbl_deep_extend("force", lvim.keys.normal_mode, {
    ["<S-l>"] = ":TablineBufferNext<CR>",
    ["<S-h>"] = ":TablineBufferPrevious<CR>",
})

local mappings = {
    s = {
        s = { ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"Grep For >> \")})<CR>", "Search For" },
        w = { ":lua require(\"telescope.builtin\").grep_string { search = vim.fn.expand(\"<cword>\") }<CR>", "CWord" },
        i = { ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"Grep For >> \"), vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>", "Search All Files" },
        d = { ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.expand(\"<cword>\"), search_dirs = { vim.fn.input(\"In >> \") }, vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>", "Search In" },
        n = { ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"For >> \"), search_dirs = { vim.fn.input(\"In >> \") }, vimgrep_arguments = { 'rg','--color=never','--no-heading','--with-filename','--line-number','--column','--smart-case','-u' } })<CR>", "Search In" }
    }
}
lvim.builtin.which_key.mappings = vim.tbl_deep_extend("keep", lvim.builtin.which_key.mappings, mappings)

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.view.relativenumber = true
-- lvim.builtin.nvimtree.show_icons.git = 1
lvim.builtin.bufferline.active = false
-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skiipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "black", filetypes = { "python" } },
--   { command = "isort", filetypes = { "python" } },
--   {
--     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "prettier",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--print-with", "100" },
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
-- lvim.plugins = {
--     {"folke/tokyonight.nvim"},
--     {
--       "folke/trouble.nvim",
--       cmd = "TroubleToggle",
--     },
-- }

lvim.plugins = {
    { 'gruvbox-community/gruvbox' },
    { 'folke/tokyonight.nvim' },
    {'nvim-treesitter/playground'},
    {
        'kdheepak/tabline.nvim',
        config = function()
            require'tabline'.setup {
                enable = false,
                options = {
                    show_filename_only = true
                }
            }
        end,
        requires = {'shadmansaleh/lualine.nvim', 'kyazdani42/nvim-web-devicons'}
    },
    {
        'tools-life/taskwiki',
        config = function()
            require'taskwiki'.setup{}
        end,
    },
    { 'blindFS/vim-taskwarrior' },
    { 'vimwiki/vimwiki', branch = 'dev' },
    { 'preservim/tagbar' },
    { 'powerman/vim-plugin-AnsiEsc' },
    -- { 'github/copilot.vim' },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*" },
  command = "%s/\\s\\+$//e",
})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*" },
  command = "%s/\r//e",
})
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })


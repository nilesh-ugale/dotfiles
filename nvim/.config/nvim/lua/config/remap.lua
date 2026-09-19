vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- <C-o> runs one command and returns to insert at the same spot; <ESC>...li
-- shifted the cursor whenever it sat in column 1. gv restores the selection
-- that a bare v would have discarded.
vim.keymap.set("n", "<F6>", ":set invrelativenumber<CR>", { silent = true })
vim.keymap.set("v", "<F6>", ":<C-u>set invrelativenumber<CR>gv", { silent = true })
vim.keymap.set("i", "<F6>", "<C-o>:set invrelativenumber<CR>", { silent = true })

vim.keymap.set("n", "<F7>", ":set list!<CR>", { silent = true })
vim.keymap.set("i", "<F7>", "<C-o>:set list!<CR>", { silent = true })
vim.keymap.set("v", "<F7>", ":<C-u>set list!<CR>gv", { silent = true })

vim.keymap.set("n", "<F5>", ":set invspell<CR>", { silent = true })
vim.keymap.set("i", "<F5>", "<C-o>:set invspell<CR>", { silent = true })
vim.keymap.set("v", "<F5>", ":<C-u>set invspell<CR>gv", { silent = true })

-- Prevent x from overriding what's in the clipboard.
vim.keymap.set("n", "x", "\"_x", { silent = true })
vim.keymap.set("n", "X", "\"_X", { silent = true })

vim.keymap.set("i", "jk", "<ESC>", { silent = true })
vim.keymap.set("i", "kj", "<ESC>", { silent = true })

vim.keymap.set("n", "<leader>ss", function()
    require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For >> ") })
end, { silent = true })

vim.keymap.set("n", "<leader>sb", function()
    require("telescope.builtin").buffers()
end, { silent = true })

vim.keymap.set("n", "<leader>sw", function()
    require("telescope.builtin").grep_string { search = vim.fn.expand("<cword>") }
end, { silent = true })

vim.keymap.set("n", "<leader>si", function()
    require("telescope.builtin").grep_string({
        search = vim.fn.input("Grep For >> "),
        vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column',
            '--smart-case', '-u' }
    })
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>sd", function()
    require("telescope.builtin").grep_string({
        search = vim.fn.input("For >> "),
        search_dirs = { vim.fn.input("In >> ") },
        vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column',
            '--smart-case', '-u' }
    })
end, { silent = true })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<F1>", "<nop>")
vim.keymap.set("i", "<F1>", "<nop>")

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- <leader>S rather than <leader>s: as a prefix of <leader>ss/sb/sw/si/sd it had
-- to wait out 'timeoutlen' on every invocation.
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

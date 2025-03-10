vim.api.nvim_create_autocmd("Filetype", {
    pattern = "norg",
    callback = function()
        vim.keymap.set("n", "<C-b>", "<Plug>(neorg.telescope.backlinks.file_backlinks)", { buffer = true })
        vim.keymap.set("n", "<C-h>b", "<Plug>(neorg.telescope.backlinks.header_backlinks)", { buffer = true })
        vim.keymap.set("n", "<C-s>", "<Plug>(neorg.telescope.find_linkable)", { buffer = true })
        vim.keymap.set("n", "<C-f>", ":Neorg find_friend<CR>", { buffer = true })
        vim.keymap.set("n", "<C-t>", ":Neorg find_tags<CR>", { buffer = true })

        vim.keymap.set("n", "<C-p>", "<Plug>(neorg.telescope.find_norg_files)", { buffer = true })
        vim.keymap.set("n", "<C-h>h", "<Plug>(neorg.telescope.search_headings)", { buffer = true })
        vim.keymap.set("n", "<C-n>", "<Plug>(neorg.telescope.switch_workspace)", { buffer = true })

        vim.keymap.set("i", "<C-f>", "<ESC><Plug>(neorg.telescope.insert_file_link)", { buffer = true })
        vim.keymap.set("i", "<C-l>", "<ESC><Plug>(neorg.telescope.insert_link)", { buffer = true })
        vim.keymap.set("i", "<C-t>", "<ESC>:Neorg insert_tag<CR>", { buffer = true })
    end,
})

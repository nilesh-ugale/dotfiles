local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', function()
    builtin.find_files()
end)

vim.keymap.set('n', '<leader>ph', function()
    builtin.find_files({ hidden = true })
end)

vim.keymap.set('n', '<C-p>', function()
    builtin.git_files({ recurse_submodules = true, show_untracked = false })
end)

vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.keymap.set('n', '<leader>vh', function()
    builtin.help_tags({})
end)

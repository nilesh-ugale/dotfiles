vim.g.maplocalleader = "\\"
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")

require("config")

do
    local _, neorg = pcall(require, "neorg.core")
    local dirman = neorg.modules.get_module("core.dirman")
    local function get_todos(states)
---@diagnostic disable-next-line: need-check-nil
        local current_workspace = dirman.get_current_workspace()
        local dir = tostring(current_workspace[2])
        require('telescope.builtin').live_grep { cwd = dir }
        vim.fn.feedkeys('^ *([*]+|[-]+) +[(]' .. states .. '[)]')
    end

    -- This can be bound to a key
    vim.keymap.set('n', '<leader><C-t>', function() get_todos('[^*]') end)
    vim.keymap.set('n', '<leader><C-p>', function() get_todos('[^x_]') end)
    vim.keymap.set('n', '<leader><C-d>', function() get_todos('[x]') end)
    vim.keymap.set('n', '<leader><C-u>', function() get_todos('[!]') end)
    vim.keymap.set('n', '<leader><C-h>', function() get_todos('[=]') end)
    vim.keymap.set('n', '<leader><C-x>', function() get_todos('[_]') end)
    -- vim.keymap.set('n', '<C-f>', function() neorg_findlinks() end)
end

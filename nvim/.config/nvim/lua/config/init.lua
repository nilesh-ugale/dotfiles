require("config.set")
require("config.remap")

local augroup = vim.api.nvim_create_augroup
local MyGroup = augroup('MyGroup', {})
local remember_folds = augroup('remember_folds', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = MyGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd({ "BufWinLeave" }, {
    group = remember_folds,
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= 'org' then
            vim.cmd([[silent! mkview]])
        end
    end,
})

autocmd({ "BufWinEnter" }, {
    group = remember_folds,
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= 'org' then
            vim.cmd([[silent! loadview]])
        end
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25


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
        vim.hl.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- Filetypes where trailing whitespace carries meaning.
local keep_trailing_ws = { markdown = true, diff = true, gitcommit = true }

autocmd({ "BufWritePre" }, {
    group = MyGroup,
    pattern = "*",
    callback = function()
        if keep_trailing_ws[vim.bo.filetype] then
            return
        end
        -- :%s parks the cursor on the last substituted line, so save and
        -- restore the view around it.
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-- conceallevel only belongs where the syntax defines conceal rules. Set
-- globally it hid real characters in code buffers.
autocmd('FileType', {
    group = MyGroup,
    pattern = { 'markdown', 'help' },
    callback = function()
        vim.opt_local.conceallevel = 3
    end,
})

-- Default viewoptions include 'curdir', which makes the loadview below change
-- the window's directory as a side effect of restoring folds.
vim.opt.viewoptions = "folds,cursor"

-- Only real on-disk files get views. The buftype check rules out help and
-- terminals; filereadable rules out URI-backed buffers like oil:// and
-- fugitive://, which report an empty buftype but are not files.
local function is_file_buffer()
    return vim.bo.buftype == ''
        and vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1
end

autocmd({ "BufWinLeave" }, {
    group = remember_folds,
    pattern = "*",
    callback = function()
        if is_file_buffer() then
            vim.cmd([[silent! mkview]])
        end
    end,
})

autocmd({ "BufWinEnter" }, {
    group = remember_folds,
    pattern = "*",
    callback = function()
        if is_file_buffer() then
            vim.cmd([[silent! loadview]])
        end
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25


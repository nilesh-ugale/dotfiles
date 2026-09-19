vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local GrpFugitive = vim.api.nvim_create_augroup("GrpFugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = GrpFugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }

        -- All under <leader>g, matching <leader>gs above. A buffer-local map
        -- resolves immediately and shadows every global map it prefixes, so
        -- <leader>p and <leader>t here used to swallow <leader>pf/ph/ps
        -- (telescope) and <leader>tb/tw (gitsigns) inside fugitive buffers.
        vim.keymap.set("n", "<leader>gp", function()
            vim.cmd.Git('push')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>gP", function()
            vim.cmd.Git({ 'pull --rebase' })
        end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>gu", ":Git push -u origin ", opts)
    end,
})

require('mason').setup()
require('mason-lspconfig').setup({
    -- Replace the language servers listed here
    -- with the ones you want to install
    ensure_installed = { 'clangd' },
    handlers = {
        -- this first function is the "default handler"
        -- it applies to every language server without a "custom handler"
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    }
})

local set_sign_icons = function(opts)
    opts = opts or {}

    if vim.diagnostic.count then
        local ds = vim.diagnostic.severity
        local levels = {
            [ds.ERROR] = 'error',
            [ds.WARN] = 'warn',
            [ds.INFO] = 'info',
            [ds.HINT] = 'hint'
        }

        local text = {}

        for i, l in pairs(levels) do
            if type(opts[l]) == 'string' then
                text[i] = opts[l]
            end
        end

        vim.diagnostic.config({ signs = { text = text } })
        return
    end

    local sign = function(args)
        if opts[args.name] == nil then
            return
        end

        vim.fn.sign_define(args.hl, {
            texthl = args.hl,
            text = opts[args.name],
            numhl = ''
        })
    end

    sign({ name = 'error', hl = 'DiagnosticSignError' })
    sign({ name = 'warn', hl = 'DiagnosticSignWarn' })
    sign({ name = 'hint', hl = 'DiagnosticSignHint' })
    sign({ name = 'info', hl = 'DiagnosticSignInfo' })
end

set_sign_icons({
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
})

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf, remap = false }

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end
})

vim.diagnostic.config({
    virtual_text = true
})

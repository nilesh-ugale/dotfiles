require('mason').setup()

vim.lsp.config('harper_ls', {
    -- Server-specific settings. See `:help lsp-quickstart`
    -- harper only checks comments and strings in code files, never the code
    -- itself. The noise comes from identifiers written inside comments --
    -- wrap those in `backticks` and harper skips them.
    settings = {
        ['harper-ls'] = {
            -- Keep harper out of the virtual text, which is filtered to WARN
            -- and above. Hints still show in the sign column and <leader>vd.
            diagnosticSeverity = "hint",
            userDictPath = vim.fn.expand("~/.config/harper-ls/dictionary.txt"),
            linters = {
                -- Prose rules that misfire on terse code comments.
                SentenceCapitalization = false,
                SpelledNumbers = false,
                LongSentences = false,
                BoringWords = false,
                Dashes = false,
            }
        },
    },
})

vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
vim.lsp.enable('harper_ls')

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf, remap = false }

        vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
        vim.keymap.set("n", "gp",  "<cmd>Lspsaga peek_definition<cr>", opts)
        vim.keymap.set("n", "gt",  "<cmd>Lspsaga peek_type_definition<cr>", opts)
        vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
        vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
        vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", opts)
        vim.keymap.set("n", "<leader>ro", "<cmd>Lspsaga outline<cr>", opts)
        vim.keymap.set("n", "<leader>rr", "<cmd>Lspsaga finder<cr>", opts)
        vim.keymap.set("n", "<leader>rn",  "<cmd>Lspsaga rename<cr>", opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end
})

vim.diagnostic.config({
    underline = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN] = '▲',
            [vim.diagnostic.severity.HINT] = '⚑',
            [vim.diagnostic.severity.INFO] = '»',
        },
    },
    virtual_text = {
        current_line = true,
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 4,
        prefix = "●",
    },
    virtual_lines = false,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "single",
        spacing = 4,
        source = true,
        header = " Diagnostics:",
        prefix = "● ",
    },
})

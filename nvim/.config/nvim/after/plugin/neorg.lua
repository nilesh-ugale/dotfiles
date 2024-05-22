local neorg_callbacks = require("neorg.core.callbacks")

neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
    -- Map all the below keybinds only when the "norg" mode is active
    keybinds.map_event_to_mode("norg", {
        n = { -- Bind keys in normal mode
            { "<C-s>", "core.integrations.telescope.find_linkable" },
            { "<C-b>", "core.integrations.telescope.find_backlinks" },
            { "<C-h>", "core.integrations.telescope.find_header_backlinks" },
            { "<C-f>", "config.telescope.find_friend" },
            { "<C-t>", "config.telescope.find_tags" },

        },
        i = { -- Bind in insert mode
            { "<C-l>", "core.integrations.telescope.insert_link" },
            { "<C-f>", "core.integrations.telescope.insert_file_link" },
            { "<C-t>", "config.telescope.insert_tag" },
        },
    }, {
        silent = true,
        noremap = true,
    })
end)
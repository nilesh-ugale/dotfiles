
--[[
    A Neorg module designed to integrate telescope.nvim
--]]

local neorg = require("neorg.core")

local module = neorg.modules.create("config.telescope")

module.setup = function()
    return { success = true, requires = { "core.keybinds", "core.dirman" } }
end

module.load = function()
    local telescope_loaded, telescope = pcall(require, "telescope")

    assert(telescope_loaded, telescope)

    telescope.load_extension("neorg")

    module.required["core.keybinds"].register_keybinds(module.name, {
        "find_friend",
    })
end

module.public = {
    find_friend = function()
        local saved_reg = vim.fn.getreg('"0')
        vim.fn.setreg('"0', "")
        vim.cmd("normal yi{")

        local title = vim.fn.getreg('"0')
        vim.fn.setreg('"0', saved_reg)

        local current_workspace = require("neorg.telescope_utils").get_current_workspace()
        require("telescope.builtin").grep_string({
                search = title,
                -- use_regex = true,
                search_dirs = { tostring(current_workspace) },
                prompt_title = "Links",
                default_text = title,
        })
    end
}

module.on_event = function(event)
    if event.split_type[2] == "config.telescope.find_friend" then
        module.public.find_friend()
    end
end

module.events.subscribed = {
    ["core.keybinds"] = {
        ["config.telescope.find_friend"] = true,
    },
}

return module

--[[
    A Neorg module designed to integrate telescope.nvim
--]]

local Job = require("plenary.job")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local action_set = require("telescope.actions.set")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local neorg = require("neorg.core")

local module = neorg.modules.create("external.telescope")

module.setup = function()
    return {
        requires = {
            "core.neorgcmd"
        }
    }
end

module.load = function()
    local telescope_loaded, telescope = pcall(require, "telescope")

    assert(telescope_loaded, telescope)

    telescope.load_extension("neorg")

    module.required['core.neorgcmd'].add_commands_from_table({
        ["find_friend"] = {
            args = 0,
            condition = 'norg',
            name = 'external.telescope.find_friend'
        },
        ["find_tags"] = {
            args = 0,
            condition = 'norg',
            name = 'external.telescope.find_tags'
        },
        ["insert_tag"] = {
            args = 0,
            condition = 'norg',
            name = 'external.telescope.insert_tag'
        }
    })
end

local function command_find_all_tags(opts)
    opts.cwd = opts.cwd or tostring(require("neorg.telescope_utils").get_current_workspace())

    local re = "\\{#[^\\}]*\\}"

    local rg_args = {
        "--vimgrep",
        "-o",
        "-e",
        re,
        "--",
        opts.cwd,
    }

    return "rg", rg_args
end

local function trim(s)
    if s:sub(1, 1) == '"' or s:sub(1, 1) == "'" then
        s = s:sub(2)
    end
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function split(line, sep, n)
    local startpos = 0
    local endpos
    local ret = {}
    for _ = 1, n - 1 do
        endpos = line:find(sep, startpos + 1)
        ret[#ret + 1] = line:sub(startpos + 1, endpos - 1)
        startpos = endpos
    end
    -- now the remainder
    ret[n] = line:sub(startpos + 1)
    return ret
end

local function insert_tag(tbl, tag, entry)
    entry.t = tag
    if tbl[tag] == nil then
        tbl[tag] = { entry }
    else
        tbl[tag][#tbl[tag] + 1] = entry
    end
end

local function parse_entry(opts, line, ret)
    local s = split(line, ":", 4)
    local fn, l, c, t = s[1], s[2], s[3], s[4]

    t = trim(t)
    local entry = { fn = fn, l = l, c = c }
    insert_tag(ret, t, entry)
end

local function do_find_all_tags(opts)
    local cmd, args = command_find_all_tags(opts)
    local ret = {}

    local _ = Job:new({
        command = cmd,
        args = args,
        enable_recording = true,
        on_exit = function(j, return_val)
            if return_val == 0 then
                for _, line in pairs(j:result()) do
                    parse_entry(opts, line, ret)
                end
            else
                print(j:result()[1])
                print("rg return value: " .. tostring(return_val))
                print("stderr: ", vim.inspect(j:stderr_result()))
            end
        end,
        on_stderr = function(err, data, _)
            print("error: " .. tostring(err) .. "data: " .. data)
        end,
    }):sync()

    return ret
end

local function do_find_friend()
    local saved_reg = vim.fn.getreg('"0')
    vim.fn.setreg('"0', "")
    vim.cmd("normal yi{")

    local title = vim.fn.getreg('"0')
    vim.fn.setreg('"0', saved_reg)

    local current_workspace = require("neorg.telescope_utils").get_current_workspace()
    require("telescope.builtin").grep_string({
        search = title,
        use_regex = false,
        search_dirs = { tostring(current_workspace) },
        prompt_title = "Links",
    })
end

local function do_find_tags()
    local opts = {}
    local tag_map = do_find_all_tags(opts)

    local taglist = {}
    local max_tag_len = 0

    for k, v in pairs(tag_map) do
        taglist[#taglist + 1] = { tag = k, details = v }
        if #k > max_tag_len then
            max_tag_len = #k
        end
    end

    pickers
        .new(opts, {
            prompt_title = "Tags",
            finder = finders.new_table({
                results = taglist,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        -- display = entry.tag .. ' \t (' .. #entry.details .. ' matches)',
                        display = string.format(
                            "%" .. max_tag_len .. "s ... (%3d matches)",
                            entry.tag,
                            #entry.details
                        ),
                        ordinal = entry.tag,
                    }
                end,
            }),
            sorter = require("telescope.config").values.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    -- actions for insert tag, default action: search for tag
                    local selection =
                        action_state.get_selected_entry().value.tag

                    actions._close(prompt_bufnr, false)
                    vim.schedule(function()
                        local current_workspace = require("neorg.telescope_utils").get_current_workspace()
                        require("telescope.builtin").grep_string({
                            search = selection,
                            use_regex = false,
                            search_dirs = { tostring(current_workspace) },
                            prompt_title = "Tags",
                        })
                    end)
                end)
                return true
            end,
        })
        :find()
end

local function do_insert_tag()
    local opts = {}
    local tag_map = do_find_all_tags(opts)

    local taglist = {}
    local max_tag_len = 0

    for k, v in pairs(tag_map) do
        taglist[#taglist + 1] = { tag = k, details = v }
        if #k > max_tag_len then
            max_tag_len = #k
        end
    end

    pickers
        .new(opts, {
            prompt_title = "Insert Tag",
            finder = finders.new_table({
                results = taglist,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        -- display = entry.tag .. ' \t (' .. #entry.details .. ' matches)',
                        display = string.format(
                            "%" .. max_tag_len .. "s ... (%3d matches)",
                            entry.tag,
                            #entry.details
                        ),
                        ordinal = entry.tag,
                    }
                end,
            }),
            sorter = require("telescope.config").values.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    -- actions for insert tag, default action: search for tag
                    local selection =
                        action_state.get_selected_entry()

                    local search_text = action_state.get_current_line()

                    actions.close(prompt_bufnr)

                    if selection == nil then
                        vim.api.nvim_put({
                            "{" .. "# " .. search_text .. "}",
                        }, "c", false, true)
                    else
                        vim.api.nvim_put({
                            selection.value.tag,
                        }, "c", false, true)
                    end
                    vim.api.nvim_feedkeys("hf}a", "t", false)
                end)
                return true
            end,
        })
        :find()
end
module.private = {
    find_friend = do_find_friend,
    find_tags = do_find_tags,
    insert_tag = do_insert_tag,
}

module.on_event = function(event)
    if event.split_type[2] == "external.telescope.find_friend" then
        module.private.find_friend()
    end
    if event.split_type[2] == "external.telescope.find_tags" then
        module.private.find_tags()
    end
    if event.split_type[2] == "external.telescope.insert_tag" then
        module.private.insert_tag()
    end
end

module.events.subscribed = {
    ['core.neorgcmd'] = {
        ["external.telescope.find_friend"] = true,
        ["external.telescope.find_tags"] = true,
        ["external.telescope.insert_tag"] = true,
    }
}

return module

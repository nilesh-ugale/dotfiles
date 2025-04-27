return {
    {
        'nvim-orgmode/orgmode',
        dependencies = {
            'nvim-telescope/telescope.nvim',
            'nvim-orgmode/telescope-orgmode.nvim',
            'Saghen/blink.cmp',
            -- {
            --     'nvim-orgmode/org-bullets.nvim',
            --     config = function()
            --         require('org-bullets').setup()
            --     end
            -- }
        },
        event = 'VeryLazy',
        ft = { 'org' },
        config = function()
            -- Setup orgmode
            require('orgmode').setup({
                org_agenda_files = '~/org/orgmode/**/*',
                org_default_notes_file = '~/org/orgmode/refile.org',
                org_todo_keywords = {
                    'TODO(t!)',
                    'DELEGATED(d!)',
                    'NEXT(n!)',
                    'ACTIVE(a!)',
                    'WAITING(w!)',
                    'MEET(m)',
                    'HOLD(h)',
                    '|',
                    'DONE(x@)',
                    'CANCELLED(c@)',
                },
                org_todo_keyword_faces = {
                    TODO = ":foreground OrangeRed :weight bold :slant italic",
                    NEXT = ":foreground DeepSkyBlue :weight bold :slant italic",
                    DONE = ":foreground LightGreen :weight bold :slant italic",
                    CANCELLED = ":foreground LightGreen :weight bold :slant italic",
                    WAITING = ":foreground Yellow :weight bold :slant italic",
                    HOLD = ":foreground Magenta :weight bold :slant italic",
                    DELEGATED  = "foreground LightCoral :weight bold :slant italic",
                    ACTIVE = ":foreground LawnGreen :weight bold :slant italic",
                    MEET = ":foreground Gold :weight bold :slant italic",
                },
                ---@diagnostic disable-next-line: assign-type-mismatch
                win_split_mode = 'tabnew',
                org_log_done = 'note',
                org_log_repeat = 'note',
                org_log_into_drawer = 'LOGBOOK',
                calendar_week_start_day = 0,
                org_agenda_start_on_weekday = 0,
                org_tags_column = -100,
                org_startup_indented = true,
                org_hide_leading_stars = true,
                org_id_link_to_org_use_id = true,
                org_capture_templates = {

                    t = {
                        description = 'Task',
                        template = '* TODO %?',
                    },
                    j = {
                        description = 'Journal',
                        template = '* %?\n',
                        target = '~/org/orgmode/journal.org',
                        datetree = true,
                    },
                    m = {
                        description = 'Minutes of Meet',
                        template = '* %?\n:Created: %T\n** Notes\n** Action Items\n*** TODO ',
                        target = '~/org/orgmode/meetings.org',
                        ---@diagnostic disable-next-line: missing-fields
                        datetree = {
                            tree_type = 'week',
                        }
                    },
                    M = {
                        description = 'Minutes of Meet',
                        template = '* %?\n:Created: %^T\n** Notes\n** Action Items\n*** TODO ',
                        target = '~/org/orgmode/meetings.org',
                        ---@diagnostic disable-next-line: missing-fields
                        datetree = {
                            time_prompt = true,
                            tree_type = 'week',
                        }
                    },
                },
                org_agenda_custom_commands = {
                    -- "c" is the shortcut that will be used in the prompt
                    a = {
                        description = 'Combined view', -- Description shown in the prompt for the shortcut
                        types = {
                            {
                                type = 'tags_todo',                       -- Type can be agenda | tags | tags_todo
                                match = '+PRIORITY="A"',                  --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                                org_agenda_overriding_header = 'High priority todos',
                                org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
                            },
                            {
                                type = 'agenda',
                                org_agenda_overriding_header = 'My daily agenda',
                                org_agenda_span = 'day', -- can be any value as org_agenda_span
                                org_agenda_tag_filter_preset = '-hide',
                            },
                            {
                                type = 'tags_todo',
                                match = 'work',                           --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                                org_agenda_overriding_header = 'Todos',
                                org_agenda_todo_ignore_scheduled = 'all', -- Ignore all headlines that are scheduled. Possible values: past | future | all
                                org_agenda_files = { '~/org/orgmode/**/*' }
                            },
                            {
                                type = 'agenda',
                                org_agenda_overriding_header = 'Whole week overview',
                                org_agenda_span = 'week',      -- 'week' is default, so it's not necessary here, just an example
                                org_agenda_remove_tags = true, -- Do not show tags only for this view
                                org_agenda_tag_filter_preset = '-hide',
                            },
                        }
                    },
                    d = {
                        description = 'Deligated', -- Description shown in the prompt for the shortcut
                        types = {
                            {
                                type = 'tags_todo',                                -- Type can be agenda | tags | tags_todo
                                match = 'work+PRIORITY="A"&work+TODO="DELEGATED"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                                org_agenda_overriding_header = 'High priority',
                                org_agenda_todo_ignore_deadlines = 'far',          -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
                            },
                            {
                                type = 'tags_todo',              -- Type can be agenda | tags | tags_todo
                                match = 'work+TODO="DELEGATED"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                                org_agenda_overriding_header = 'All tasks',
                                -- org_agenda_todo_ignore_deadlines = 'far',          -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
                            },
                        }
                    },
                    p = {
                        description = 'Personal', -- Description shown in the prompt for the shortcut
                        types = {
                            {
                                type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                                match = 'personal',
                                org_agenda_overriding_header = 'All todos',
                            },
                        }
                    },
                },
                notifications = {
                    enabled = true,
                    cron_enabled = true,
                    repeater_reminder_time = 0,
                    deadline_warning_reminder_time = false,
                    reminder_time = 10,
                    deadline_reminder = true,
                    scheduled_reminder = true,
                    notifier = function(tasks)
                        local result = {}
                        for _, task in ipairs(tasks) do
                            require('orgmode.utils').concat(result, {
                                string.format('# %s (%s)', task.category, task.humanized_duration),
                                string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title),
                                string.format('%s: <%s>', task.type, task.time:to_string())
                            })
                        end

                        if not vim.tbl_isempty(result) then
                            require('orgmode.notifications.notification_popup'):new({ content = result })
                        end
                    end,
                    cron_notifier = function(tasks)
                        for _, task in ipairs(tasks) do
                            local title = string.format('%s (%s)', task.category, task.humanized_duration)
                            local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task
                                .title)
                            local date = string.format('%s: %s', task.type, task.time:to_string())

                            -- Linux
                            vim.system({
                                'wsl-notify-send.exe',
                                '--appId=orgmode',
                                '--category=Notify',
                                '--icon=C:\\Users\\nilesh.ugale\\nvim-orgmode.old.png',
                                string.format('%s\n%s\n%s', title, subtitle, date),
                            })
                        end
                    end
                },
            })
            -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
            -- add ~org~ to ignore_install
            -- require('nvim-treesitter.configs').setup({
            --   ensure_installed = 'all',
            --   ignore_install = { 'org' },
            -- })
        end,
    },
    {
        "chipsenkbeil/org-roam.nvim",
        -- tag = "0.1.1",
        dependencies = {
            {
                "nvim-orgmode/orgmode",
                -- tag = "0.3.7",
            },
        },
        config = function()
            require("org-roam").setup({
                directory = "~/org/orgroam",
                -- optional
                -- org_files = {
                --     "~/org/orgmode",
                -- }
            })
        end
    },
    {
        "nvim-orgmode/telescope-orgmode.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-orgmode/orgmode",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("telescope").load_extension("orgmode")

            vim.keymap.set("n", "<leader>r", require("telescope").extensions.orgmode.refile_heading)
            vim.keymap.set("n", "<leader>fh", require("telescope").extensions.orgmode.search_headings)
            vim.keymap.set("n", "<leader>li", require("telescope").extensions.orgmode.insert_link)
        end,
    }
}

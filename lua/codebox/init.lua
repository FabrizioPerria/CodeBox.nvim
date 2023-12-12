-- debug_plugin.lua

local plenary = require('plenary')
local Path = require('plenary.path')

local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require 'telescope.actions.state'
local sorters = require('telescope.sorters')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')

local data_path = vim.fn.stdpath("data")

M = {}

local code_blocks_dir = data_path .. "/codebox"

function M.box_block()
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    start_line = start_line - 1
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local title = vim.fn.input("Enter block title: ")
    if title == "" then
        return
    end
    local path = Path:new(code_blocks_dir, title)
    path:write(table.concat(lines, "\n"), "w")
end

function M.unbox_block()
    pickers.new({}, {
        prompt_title = 'Select a block from the Box',
        finder = finders.new_oneshot_job(
            { "ls", code_blocks_dir },
            { cwd = code_blocks_dir }
        ),
        sorter = sorters.get_fuzzy_file(),
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry, status)
                local file_path = code_blocks_dir .. '/' .. entry.value
                local content = Path:new(file_path):read()
                local lines = vim.split(content, "\n")
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end
        }),
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<C-d>', function()
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                local path = Path:new(code_blocks_dir, selection)
                path:rm()
                M.unbox_block()
            end)
            map('n', 'd', function()
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                local path = Path:new(code_blocks_dir, selection)
                path:rm()
                M.unbox_block()
            end)
            map('i', '<CR>', function()
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                local path = Path:new(code_blocks_dir, selection)
                local debug_content = path:read()
                local debug_lines = {}
                for line in debug_content:gmatch("[^\r\n]+") do
                    table.insert(debug_lines, line)
                end
                local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
                vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line, false, debug_lines)
            end)
            return true
        end,
    }):find()
end

function M.setup()
    Path:new(code_blocks_dir):mkdir({ parents = true, exists_ok = true })
    vim.api.nvim_command('command! -range CodeBox lua require("codebox").box_block()')
    vim.api.nvim_command('command! CodeUnbox lua require("codebox").unbox_block()')
end

return M

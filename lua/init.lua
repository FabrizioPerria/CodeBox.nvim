-- debug_plugin.lua

local plenary = require('plenary')
local Path = require('plenary.path')
local telescope = require('telescope')

local debug_blocks_dir = "./debug_blocks"

local function remove_debug_blocks()
    local start_line, end_line = unpack(vim.fn.getpos("'<"), 2, 3)
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local id = os.time()
    local path = Path:new(debug_blocks_dir, tostring(id))
    path:write(table.concat(lines, "\n"), "w")
end

local function insert_debug_blocks()
    telescope.pickers.new({}, {
        prompt_title = 'Select a debug block',
        finder = telescope.finders.new_oneshot_job(
            { "ls", debug_blocks_dir },
            { cwd = debug_blocks_dir }
        ),
        sorter = telescope.sorters.get_fuzzy_file(),
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<CR>', function()
                local selection = telescope.actions.get_selected_entry().value
                telescope.actions.close(prompt_bufnr)
                local path = Path:new(debug_blocks_dir, selection)
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

vim.api.nvim_command('command! -range CodeStashStore lua remove_debug_blocks()')
vim.api.nvim_command('command! CodeStashApply lua insert_debug_blocks()')

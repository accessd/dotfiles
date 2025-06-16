local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local fb = require("telescope").extensions.file_browser
local builtin = require("telescope.builtin")

local function select_dir_and_grep()
  fb.file_browser({
    files = false,
    depth = false,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local dir = entry and entry.Path and entry.Path:is_dir() and entry.Path:absolute() or entry[1]
        builtin.live_grep({ cwd = dir })
      end)
      return true
    end,
  })
end

vim.keymap.set('n', '<leader>sb', select_dir_and_grep, { desc = 'Choose dir and search with live_grep' })

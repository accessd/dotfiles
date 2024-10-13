-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- More comfortable keys for searching history in command line
vim.keymap.set('c', '<C-j>', '<Down>', { desc = 'Next command' })
vim.keymap.set('c', '<C-k>', '<Up>', { desc = 'Previous command' })

-- Map Enter to add the new line
vim.keymap.set('n', '<CR>', 'o<Esc>')

-- Close buffer with Q
vim.keymap.set('n', 'Q', ":lua require('bufdelete').bufdelete(0, true)<CR>")

-- map("n", "<leader>fe", ":Neotree focus<CR>")

-- Swith to the prev buffer
vim.keymap.set('n', '<C-p>', ':b#<CR>')

vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', {})
-- Reveal current dir of the file in neotree
vim.keymap.set('n', '<leader>nf', ':Neotree reveal<CR>', {})

-- Clear search highlights
vim.keymap.set('n', '//', function()
  vim.cmd 'nohlsearch'
end, {})

vim.keymap.set('n', '<leader>rl', ':TestNearest<CR>', {})
vim.keymap.set('n', '<leader>rs', ':TestFile<CR>', {})
vim.keymap.set('n', '<leader>l', ':TestLast<CR>', {})

vim.keymap.set('n', '<leader>vc', ':VimuxInterruptRunner<CR>', {})
vim.keymap.set('n', '<leader>wi', ':VimuxInspectRunner<CR>', {})
vim.keymap.set('n', '<leader>w', ':VimuxZoomRunner<CR>', {})

-- vim.keymap.set('i', '<C-h>', '<BS>', {})
-- vim.api.nvim_set_keymap('i', '<C-h>', '<BS>', { noremap = true, silent = true })
vim.keymap.set('i', '^H', '<BS>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>wm', ':MaximizerToggle<CR>', {})

-- quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- Resize window using <ctrl> arrow keys
vim.keymap.set('n', '<C-S-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-S-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-S-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-S-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- buffers
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
vim.keymap.set('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- vim: ts=2 sts=2 sw=2 et

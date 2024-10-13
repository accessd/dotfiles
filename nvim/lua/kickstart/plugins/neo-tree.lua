-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    enable_git_status = false,
    enable_diagnostics = false,
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['o'] = 'open',
          ['x'] = 'close_node',
        },
        fuzzy_finder_mappings = {
          ['<down>'] = 'move_cursor_down',
          ['<C-j>'] = 'move_cursor_down',
          ['<up>'] = 'move_cursor_up',
          ['<C-k>'] = 'move_cursor_up',
        },
      },
    },
  },
}

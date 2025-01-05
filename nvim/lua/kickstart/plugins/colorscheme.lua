return {
  {
    'shmerl/neogotham',
    lazy = false, -- to make sure it's loaded on startup
    priority = 1000, -- to load before other plugins
    config = function()
      -- require('neogotham'):setup { oldgotham = true }
      vim.cmd.colorscheme 'neogotham'
      -- vim.api.nvim_set_hl(0, 'Visual', { bg = '#206a75' })
    end,
  },

  -- {
  --   'catppuccin/nvim',
  --   lazy = false,
  --   name = 'catppuccin',
  --   priority = 1000,
  --
  --   config = function()
  --     require('catppuccin').setup {
  --       transparent_background = true,
  --     }
  --     vim.cmd.colorscheme 'catppuccin-mocha'
  --   end,
  -- },

  {
    'xiyaowong/transparent.nvim',
  },
}
-- vim: ts=2 sts=2 sw=2 et

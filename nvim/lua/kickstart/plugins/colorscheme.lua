return {
  -- {
  --   'shmerl/neogotham',
  --   lazy = false, -- to make sure it's loaded on startup
  --   priority = 1000, -- to load before other plugins
  --   config = function()
  --     -- require('neogotham'):setup { oldgotham = true }
  --     vim.cmd.colorscheme 'neogotham'
  --     -- vim.api.nvim_set_hl(0, 'Visual', { bg = '#206a75' })
  --   end,
  -- },
  -- {
  --   'shaunsingh/nord.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- Example config in lua
  --     vim.g.nord_contrast = true
  --     vim.g.nord_borders = false
  --     vim.g.nord_disable_background = true
  --     vim.g.nord_italic = false
  --     vim.g.nord_uniform_diff_background = true
  --     vim.g.nord_bold = false
  --
  --     -- Load the colorscheme
  --     require('nord').set()
  --
  --     -- Toggle background transparency
  --     local bg_transparent = true
  --
  --     local toggle_transparency = function()
  --       bg_transparent = not bg_transparent
  --       vim.g.nord_disable_background = bg_transparent
  --       vim.cmd [[colorscheme nord]]
  --     end
  --
  --     vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })
  --   end,
  -- },
  {
    "srt0/codescope.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("codescope").setup({
        transparent = true
      })
      vim.cmd.colorscheme("codescope")
    end,
  },

  -- {
  --   'kyazdani42/blue-moon',
  --   lazy = false, -- to make sure it's loaded on startup
  --   priority = 1000, -- to load before other plugins
  --   config = function()
  --     -- require('neogotham'):setup { oldgotham = true }
  --     vim.cmd.colorscheme 'blue-moon'
  --     -- vim.api.nvim_set_hl(0, 'Visual', { bg = '#206a75' })
  --   end,
  -- },

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

  -- {
  --   'xiyaowong/transparent.nvim',
  -- },
}
-- vim: ts=2 sts=2 sw=2 et

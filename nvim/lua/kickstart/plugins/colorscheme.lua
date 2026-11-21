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
    "pustota-theme/pustota.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("pustota-transparency", { clear = true }),
        pattern = "pustota",
        callback = function()
          for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "MsgArea" }) do
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            hl.bg = nil
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, group, hl)
          end
        end,
      })
      vim.cmd.colorscheme("pustota")
    end,
  },
  -- {
  --   "compline",
  --   dir = "~/.local/share/nvim/lazy/compline/compline",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- require("compline").setup({
  --     --   transparent = true
  --     -- })
  --     -- vim.cmd.colorscheme("compline")
  --   end,
  -- },

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

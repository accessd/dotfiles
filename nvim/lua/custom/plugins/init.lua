return {
  {
    'alexghergh/nvim-tmux-navigation',
    config = function()
      require('nvim-tmux-navigation').setup {
        keybindings = {
          left = '<C-h>',
          down = '<C-j>',
          up = '<C-k>',
          right = '<C-l>',
          last_active = '<C-\\>',
          next = '<C-Space>',
        },
      }
    end,
  },

  {
    'chrisgrieser/nvim-spider',
    dependencies = {
      'theHamsta/nvim_rocks',
      build = 'pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua',
      config = function()
        require('nvim_rocks').ensure_installed 'luautf8'
      end,
    },
    config = function()
      require('spider').setup {
        skipInsignificantPunctuation = false,
      }
    end,
    keys = {
      {
        'e',
        "<cmd>lua require('spider').motion('e', { skipInsignificantPunctuation = false })<CR>",
        mode = { 'n', 'o', 'x' },
      },
      {
        'w',
        "<cmd>lua require('spider').motion('w', { skipInsignificantPunctuation = false })<CR>",
        mode = { 'n', 'o', 'x' },
      },
      {
        'b',
        "<cmd>lua require('spider').motion('b', { skipInsignificantPunctuation = false })<CR>",
        mode = { 'n', 'o', 'x' },
      },
    },
  },

  { 'terryma/vim-expand-region' },
  { 'vim-test/vim-test' },
  { 'preservim/vimux' },
  { 'famiu/bufdelete.nvim' },
  { 'mg979/vim-visual-multi' },
  { 'itchyny/vim-qfedit' },
  {
    'zeioth/garbage-day.nvim',
    dependencies = 'neovim/nvim-lspconfig',
    opts = {},
  },

  {
    'gbprod/yanky.nvim',
    recommended = true,
    desc = 'Better Yank/Paste',
    -- event = 'LazyFile',
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        '<leader>p',
        function()
          require('telescope').extensions.yank_history.yank_history {}
        end,
        mode = { 'n', 'x' },
        desc = 'Open Yank History',
      },
      -- stylua: ignore
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Cursor' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Selection' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Selection' },
      { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle Forward Through Yank History' },
      { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle Backward Through Yank History' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and Indent Right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and Indent Left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put Before and Indent Right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put Before and Indent Left' },
      { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put After Applying a Filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put Before Applying a Filter' },
    },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local keys = {
        {
          '<leader>H',
          function()
            require('harpoon'):list():add()
          end,
          desc = 'Harpoon File',
        },
        {
          '<leader>h',
          function()
            local harpoon = require 'harpoon'
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = 'Harpoon Quick Menu',
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          '<leader>' .. i,
          function()
            require('harpoon'):list():select(i)
          end,
          desc = 'Harpoon to File ' .. i,
        })
      end
      return keys
    end,
  },

  {
    'ggandor/leap.nvim',
    enabled = true,
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, desc = 'Leap Forward to' },
      { 'S', mode = { 'n', 'x', 'o' }, desc = 'Leap Backward to' },
      { 'gs', mode = { 'n', 'x', 'o' }, desc = 'Leap from Windows' },
    },
    config = function(_, opts)
      local leap = require 'leap'
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ 'x', 'o' }, 'x')
      vim.keymap.del({ 'x', 'o' }, 'X')
    end,
  },

  { 'tpope/vim-repeat' },

  -- search/replace in multiple files
  {
    'MagicDuck/grug-far.nvim',
    opts = { headerMaxWidth = 80 },
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>sr',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },
  },

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  { 'szw/vim-maximizer' },

  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  {
    'folke/zen-mode.nvim',
    opts = {
      {
        window = {
          backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
          -- height and width can be:
          -- * an absolute number of cells when > 1
          -- * a percentage of the width / height of the editor when <= 1
          -- * a function that returns the width or the height
          width = 120, -- width of the Zen window
          height = 1, -- height of the Zen window
          -- by default, no options are changed for the Zen window
          -- uncomment any of the options below, or add other vim.wo options you want to apply
          options = {
            -- signcolumn = "no", -- disable signcolumn
            number = false, -- disable number column
            -- relativenumber = false, -- disable relative numbers
            cursorline = false, -- disable cursorline
            cursorcolumn = false, -- disable cursor column
            -- foldcolumn = "0", -- disable fold column
            -- list = false, -- disable whitespace characters
          },
        },
        plugins = {
          -- disable some global vim options (vim.o...)
          -- comment the lines to not apply the options
          options = {
            enabled = true,
            ruler = false, -- disables the ruler text in the cmd line area
            showcmd = false, -- disables the command in the last line of the screen
            -- you may turn on/off statusline in zen mode by setting 'laststatus'
            -- statusline will be shown only if 'laststatus' == 3
            laststatus = 0, -- turn off the statusline in zen mode
          },
          twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
          gitsigns = { enabled = false }, -- disables git signs
          tmux = { enabled = true }, -- disables the tmux statusline
          todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
          -- this will change the font size on kitty when in zen mode
          -- to make this work, you need to set the following kitty options:
          -- - allow_remote_control socket-only
          -- - listen_on unix:/tmp/kitty
          kitty = {
            enabled = false,
            font = '+4', -- font size increment
          },
          -- this will change the font size on alacritty when in zen mode
          -- requires  Alacritty Version 0.10.0 or higher
          -- uses `alacritty msg` subcommand to change font size
          alacritty = {
            enabled = true,
            font = '16', -- font size
          },
          -- this will change the font size on wezterm when in zen mode
          -- See alse also the Plugins/Wezterm section in this projects README
          wezterm = {
            enabled = false,
            -- can be either an absolute font size or the number of incremental steps
            font = '+4', -- (10% increase per step)
          },
        },
        -- callback where you can add custom code when the Zen window opens
        on_open = function(win) end,
        -- callback where you can add custom code when the Zen window closes
        on_close = function() end,
      },
    },
  },

  {
    'tpope/vim-rails',
  },
}

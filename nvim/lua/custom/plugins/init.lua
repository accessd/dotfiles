return {
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      require('smart-splits').setup {
        disable_multiplexer_nav_when_zoomed = false,
      }
      -- moving between splits
      vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
      vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
      vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
      vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
      vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
      -- swapping buffers between windows
      vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
      vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
      vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
      vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
    end,
  },
  -- {
  --   'chrisgrieser/nvim-spider',
  --   dependencies = {
  --     'theHamsta/nvim_rocks',
  --     build = 'pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua',
  --     config = function()
  --       require('nvim_rocks').ensure_installed 'luautf8'
  --     end,
  --   },
  --   config = function()
  --     require('spider').setup {
  --       skipInsignificantPunctuation = false,
  --     }
  --   end,
  --   keys = {
  --     {
  --       'e',
  --       "<cmd>lua require('spider').motion('e', { skipInsignificantPunctuation = false })<CR>",
  --       mode = { 'n', 'o', 'x' },
  --     },
  --     {
  --       'w',
  --       "<cmd>lua require('spider').motion('w', { skipInsignificantPunctuation = false })<CR>",
  --       mode = { 'n', 'o', 'x' },
  --     },
  --     {
  --       'b',
  --       "<cmd>lua require('spider').motion('b', { skipInsignificantPunctuation = false })<CR>",
  --       mode = { 'n', 'o', 'x' },
  --     },
  --   },
  -- },

  { 'terryma/vim-expand-region' },
  { 'vim-test/vim-test' },
  { 'preservim/vimux' },
  { 'famiu/bufdelete.nvim' },
  { 'mg979/vim-visual-multi' },
  { 'itchyny/vim-qfedit' },
  -- {
  --   'zeioth/garbage-day.nvim',
  --   dependencies = 'neovim/nvim-lspconfig',
  --   opts = {},
  -- },

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
      { "y",  "<Plug>(YankyYank)",                      mode = { "n", "x" },                           desc = "Yank Text" },
      { 'p',  '<Plug>(YankyPutAfter)',                  mode = { 'n', 'x' },                           desc = 'Put Text After Cursor' },
      { 'P',  '<Plug>(YankyPutBefore)',                 mode = { 'n', 'x' },                           desc = 'Put Text Before Cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)',                 mode = { 'n', 'x' },                           desc = 'Put Text After Selection' },
      { 'gP', '<Plug>(YankyGPutBefore)',                mode = { 'n', 'x' },                           desc = 'Put Text Before Selection' },
      { '[y', '<Plug>(YankyCycleForward)',              desc = 'Cycle Forward Through Yank History' },
      { ']y', '<Plug>(YankyCycleBackward)',             desc = 'Cycle Backward Through Yank History' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)',    desc = 'Put Indented After Cursor (Linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)',   desc = 'Put Indented Before Cursor (Linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)',    desc = 'Put Indented After Cursor (Linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)',   desc = 'Put Indented Before Cursor (Linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)',  desc = 'Put and Indent Right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)',   desc = 'Put and Indent Left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put Before and Indent Right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)',  desc = 'Put Before and Indent Left' },
      { '=p', '<Plug>(YankyPutAfterFilter)',            desc = 'Put After Applying a Filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)',           desc = 'Put Before Applying a Filter' },
    },
  },

  {
    'ggandor/leap.nvim',
    enabled = true,
    keys = {
      { 's',  mode = { 'n', 'x', 'o' }, desc = 'Leap Forward to' },
      { 'S',  mode = { 'n', 'x', 'o' }, desc = 'Leap Backward to' },
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
    opts = { headerMaxWidth = 80, maxLineLength = 10000 },
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
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,              desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
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

  -- {
  --   'tpope/vim-rails',
  -- },

  {
    'goolord/alpha-nvim',
    config = function()
      require('alpha').setup(require('alpha.themes.dashboard').config)

      local dashboard = require 'alpha.themes.dashboard'
      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
        dashboard.button('n', '  > Toggle file explorer', '<cmd>NvimTreeToggle<CR>'),
        dashboard.button('sf', '󰱼  > Find File', '<cmd>Telescope find_files<CR>'),
        dashboard.button('r', '󰁯  > Restore Session For Current Directory', '<cmd>lua require("persistence").load()<CR>'),
        dashboard.button('q', '  > Quit NVIM', '<cmd>qa<CR>'),
      }
    end,
  },

  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
    },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/Documents/tower/',
        },
      },
      new_notes_location = 'inbox',
    },
  },

  -- {
  --   'kristijanhusak/vim-dadbod-ui',
  --   dependencies = {
  --     { 'tpope/vim-dadbod', lazy = true },
  --     { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  --   },
  --   cmd = {
  --     'DBUI',
  --     'DBUIToggle',
  --     'DBUIAddConnection',
  --     'DBUIFindBuffer',
  --   },
  --   init = function()
  --     vim.g.db_ui_use_nerd_fonts = 1
  --   end,
  -- },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup()
    end,
  },

  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      require('blame').setup {}
    end,
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      -- indent = { enabled = true },
      input = { enabled = true },
      bufdelete = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      -- scroll = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        '<leader>hn',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Notification History',
      },
      {
        '<leader>un',
        function()
          Snacks.notifier.hide()
        end,
        desc = 'Dismiss All Notifications',
      },
    },
  },

  {
    'sindrets/diffview.nvim',
  },
  -- { 'danilamihailov/beacon.nvim' },

  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        '<leader>-',
        '<cmd>Yazi<cr>',
        desc = 'Open yazi at the current file',
      },
      {
        -- Open in the current working directory
        '<leader>cw',
        '<cmd>Yazi cwd<cr>',
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
  },
  {
    'lukas-reineke/virt-column.nvim',
    opts = {
      char = { '┆' },
      virtcolumn = '120',
      highlight = { 'NonText' },
    },
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        markdown = {
          headline_highlights = {
            "Headline1",
            "Headline2",
            "Headline3",
            "Headline4",
            "Headline5",
            "Headline6",
          },
          bullets = {},
          codeblock_highlight = "CodeBlock",
          dash_highlight = "Dash",
          quote_highlight = "Quote",
        },
      })
    end,
  },
  -- {
  --   'aidancz/buvvers.nvim',
  --   config = function()
  --     require("buvvers").setup()
  --   end,
  -- }
  -- {
  --   'chaoren/vim-wordmotion',
  -- },
}

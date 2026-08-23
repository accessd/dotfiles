-- nvim-treesitter `main` is a full rewrite: it only installs parsers and ships
-- queries. Highlighting, folds and injections come from Neovim itself, so there
-- is no `configs.setup` and no module table any more.
local languages = {
  'bash',
  'c',
  'css',
  'csv',
  'diff',
  'dockerfile',
  'embedded_template',
  'git_config',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'go',
  'gomod',
  'gosum',
  'hcl',
  'html',
  'htmldjango',
  'ini',
  'javascript',
  'json', -- also covers the jsonc filetype
  'kotlin',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'nginx',
  'pem',
  'php',
  'prisma',
  'proto',
  'python',
  'query',
  'ruby',
  'rust',
  'sql',
  'ssh_config',
  'terraform',
  -- no tmux parser on main; tmux.conf falls back to vim's regex syntax
  'toml',
  'tsv',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

-- Ruby's indent queries are still worse than the regex ones, and its highlights
-- depend on vim's regex engine for heredocs.
local regex_highlight = { ruby = true }
local no_treesitter_indent = { ruby = true }

return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- main does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()
      require('nvim-treesitter').install(languages)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not pcall(vim.treesitter.start, args.buf, lang) then
            return
          end

          if regex_highlight[lang] then
            vim.bo[args.buf].syntax = args.match
          end
          if not no_treesitter_indent[lang] then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'

      -- You can use the capture groups defined in textobjects.scm
      local selections = {
        ['af'] = { '@function.outer', 'textobjects', 'Select outer part of a function' },
        ['if'] = { '@function.inner', 'textobjects', 'Select inner part of a function' },
        ['ac'] = { '@class.outer', 'textobjects', 'Select outer part of a class' },
        ['ic'] = { '@class.inner', 'textobjects', 'Select inner part of a class region' },
        ['al'] = { '@loop.outer', 'textobjects', 'Select outer part of a loop' },
        ['il'] = { '@loop.inner', 'textobjects', 'Select inner part of a loop' },
        -- You can also use captures from other query groups like `locals.scm`
        ['as'] = { '@local.scope', 'locals', 'Select language scope' },
      }
      for key, spec in pairs(selections) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(spec[1], spec[2])
        end, { desc = spec[3] })
      end

      local movements = {
        [move.goto_next_start] = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
        [move.goto_next_end] = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
        [move.goto_previous_start] = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
        [move.goto_previous_end] = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
      }
      for goto_fn, keys in pairs(movements) do
        for key, query in pairs(keys) do
          vim.keymap.set({ 'n', 'x', 'o' }, key, function()
            goto_fn(query, 'textobjects')
          end, { desc = 'Go to ' .. query })
        end
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

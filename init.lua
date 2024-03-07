--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
vim.opt.guicursor = ""

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  'jiangmiao/auto-pairs',

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'tpope/vim-abolish',
  {
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ["q"] = "actions.close",
      },
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, bufnr)
          return vim.startswith(name, '__')
        end,
      }
    },
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 100, ignore_whitespace = true },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
        vim.keymap.set('n', '<leader>gj', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'Next hunk' })
        vim.keymap.set('n', '<leader>gk', require('gitsigns').prev_hunk, { buffer = bufnr, desc = 'Previous hunk' })
        vim.keymap.set('n', '<leader>gs', require('gitsigns').stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
        vim.keymap.set('n', '<leader>gr', require('gitsigns').reset_hunk, { buffer = bufnr, desc = 'Stage hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'onedark'
  --   end,
  -- },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    flavour = 'mocha',
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Setup tabline
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    opts = {
      animation = false,
      auto_hide = 1,
      insert_at_end = true,
      semantic_letters = true,
      exclude_ft = { 'qf' }
    }

  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },


  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      close_on_exit = true,
      start_in_insert = true,
      shade_terminals = true,
      insert_mappings = true,
      direction = 'horizontal',
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    },
  },

  -- Obsidian support
  -- {
  --   "epwalsh/obsidian.nvim",
  --   version = "*",
  --   ft = "markdown",
  --   -- Potentially use this to load only when in a vault
  --   -- event = {
  --   --   "BufReadPre path/to/my-vault/**.md",
  --   --   "BufNewFile path/to/my-vault/**.md",
  --   -- }
  --
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     'hrsh7th/nvim-cmp',
  --     "nvim-telescope/telescope.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --
  --   opts = {
  --     workspaces = {
  --       {
  --         name = "iBreadless",
  --         path = "Library/Mobile Documents/iCloud~md~obsidian/Documents/iBreadless"
  --       },
  --     }
  --   },
  --
  -- },

  -- {
  --   "epwalsh/pomo.nvim",
  --   version = "*",
  --   lazy = true,
  --   cmd = { "TimerStart", "TimerRepeat" },
  --   dependencies = {
  --     "rcarriga/nvim-notify",
  --   },
  --   opts = {
  --     -- How often the notifiers are updated.
  --     update_interval = 1000,
  --
  --     -- Configure the default notifiers to use for each timer.
  --     -- You can also configure different notifiers for timers given specific names, see
  --     -- the 'timers' field below.
  --     notifiers = {
  --       -- The "Default" notifier uses 'vim.notify' and works best when you have 'nvim-notify' installed.
  --       {
  --         name = "Default",
  --         opts = {
  --           -- With 'nvim-notify', when 'sticky = true' you'll have a live timer pop-up
  --           -- continuously displayed. If you only want a pop-up notification when the timer starts
  --           -- and finishes, set this to false.
  --           sticky = true,
  --
  --           -- Configure the display icons:
  --           title_icon = "󱎫",
  --           text_icon = "󰄉",
  --           -- Replace the above with these if you don't have a patched font:
  --           -- title_icon = "⏳",
  --           -- text_icon = "⏱️",
  --         },
  --       },
  --
  --       -- The "System" notifier sends a system notification when the timer is finished.
  --       -- Currently this is only available on MacOS.
  --       -- Tracking: https://github.com/epwalsh/pomo.nvim/issues/3
  --       -- { name = "System" },
  --
  --       -- You can also define custom notifiers by providing an "init" function instead of a name.
  --       -- See "Defining custom notifiers" below for an example 👇
  --       -- { init = function(timer) ... end }
  --     },
  --
  --     -- Override the notifiers for specific timer names.
  --     timers = {
  --       -- For example, use only the "System" notifier when you create a timer called "Break",
  --       -- e.g. ':TimerStart 2m Break'.
  --       Break = {
  --         { name = "System" },
  --       },
  --     },
  --   }
  --
  -- },


  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'JK', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- tabs
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })

-- Keymaps for window/buffer management
vim.keymap.set('n', '<leader>w', "<cmd>w!<CR>", { desc = 'Write Buffer' })
vim.keymap.set('n', '<leader>q', "<cmd>confirm q<CR>", { desc = 'Close Window' })
vim.keymap.set('n', '<leader>x', "<cmd>confirm wq<CR>", { desc = 'Write->Quit' })
vim.keymap.set('n', '<leader>X', "<cmd>wqa!<CR>", { desc = 'Write->QuitAll' })
vim.keymap.set('n', '<leader>c', '<cmd>BufferClose<CR>', { desc = 'Close Buffer' })

-- OIL Keymaps
vim.keymap.set('n', '-', "<cmd>Oil<CR>", { desc = "Open Parent Directory" })

-- Barbar tab management
vim.keymap.set('n', '<leader>bn', '<cmd>BufferNext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bb', '<cmd>BufferPrevious<CR>', { desc = 'Previous Buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>BufferPin<CR>', { desc = 'Pin Buffer' })
vim.keymap.set('n', '<leader>bj', '<cmd>BufferPick<CR>', { desc = 'Pick Buffer' })
vim.keymap.set('n', '<leader>bc', '<cmd>BufferPickDelete<CR>', { desc = 'Close Buffer' })
vim.keymap.set('n', '<leader>bh', '<cmd>BufferCloseBuffersLeft<CR>', { desc = 'Close Buffers to left' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferCloseBuffersRight<CR>', { desc = 'Close Buffers to right' })
vim.keymap.set('n', '<leader>br', '<cmd>BufferRestore<CR>', { desc = 'Restore Buffer' })
vim.keymap.set('n', '<leader>ba', '<cmd>BufferCloseAllButCurrentOrPinned<CR>', { desc = 'Clean up [A]ll Buffers' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlighting' })
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

function _G.lazygit_toggle()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) vim.cmd 'checkt' end,
    count = 99,
  }
  lazygit:toggle()
end

vim.keymap.set('n', '<leader>gg', '<cmd>lua lazygit_toggle()<CR>', { desc = 'Launch LazyGit' })
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<c-BS>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  -- nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ss', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch Workspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>b'] = { name = '[B]uffer', _ = 'which_key_ignore' },
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]iagnositcs', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  pyright = {
    settings= {
      python = {
        analysis = {
          extraPaths = {
"~/devel/sierra_ws/src/bg_robots/abb/abb_driver/src",
"~/devel/sierra_ws/src/bg_peripherals/acroname_brainstem/src",
"~/devel/sierra_ws/src/bg_core/perception/active_vision/src",
"~/devel/sierra_ws/src/bg_peripherals/adam/src",
"~/devel/sierra_ws/src/bg_core/perception/adaptis/src",
"~/devel/sierra_ws/src/bg_core/applications/application_base/src",
"~/devel/sierra_ws/src/bg_core/applications/application_msgs/src",
"~/devel/sierra_ws/src/bg_peripherals/applied_motion_products/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/auto_shuttle/auto_shuttle_description/src",
"~/devel/sierra_ws/src/bg_core/planning/autoswap_calibration/src",
"~/devel/sierra_ws/src/bg_peripherals/axis_camera_utils/src",
"~/devel/sierra_ws/src/bg_core/perception/barcodes/barcode_detector/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_bootstrap/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_cmake/src",
"~/devel/sierra_ws/src/bg_common/bg_common_assets/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_comms/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_data_types/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_debug/src",
"~/devel/sierra_ws/src/bg_core/messages/bg_diagnostics_msgs/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_event_aggregator/src",
"~/devel/sierra_ws/src/bg_core/metrics/bg_event_data/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_event_sourcing/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_event_stream/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_generic_protobuf_message/src",
"~/devel/sierra_ws/src/bg_core/grasping/bg_grasping/src",
"~/devel/sierra_ws/src/bg_peripherals/bg_high_flow_valve/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_id_broker/src",
"~/devel/sierra_ws/src/bg_robots/bg_industrial_robot_client_adapter/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_interventions/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_k8s/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_kafka/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_launch/src",
"~/devel/sierra_ws/src/bg_core/logging/bg_logging/src",
"~/devel/sierra_ws/src/bg_core/logging/bg_logging_sortation/src",
"~/devel/sierra_ws/src/bg_core/database/bg_models/src",
"~/devel/sierra_ws/src/bg_core/ui/bg_npm/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_npm_utils/src",
"~/devel/sierra_ws/src/bg_peripherals/bg_opcua/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_param/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_perception_debugger/src",
"~/devel/sierra_ws/src/bg_core/perception/bg_perception_params/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_perception_publisher/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_pick_anomaly_detector/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_pick_debugger/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_pick_tests/src",
"~/devel/sierra_ws/src/bg_core/planning/bg_planning/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_proto/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_rpc/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_rpc_example/src",
"~/devel/sierra_ws/src/bg_core/applications/bg_singulation_params/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_sku_estimator/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_system/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_tracing/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_ui_common/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_utils/src",
"~/devel/sierra_ws/src/bg_core/tools/bg_web/src",
"~/devel/sierra_ws/src/bg_core/wms/bg_wms/src",
"~/devel/sierra_ws/src/bg_peripherals/bg_wrist_3_0/src",
"~/devel/sierra_ws/src/bg_peripherals/bg_wrist_3_0_msgs/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/bg_wrist_msgs/src",
"~/devel/sierra_ws/src/bg_peripherals/bg_yawing_gripper/src",
"~/devel/sierra_ws/src/bg_core/perception/bin_contents_simulator/src",
"~/devel/sierra_ws/src/bg_peripherals/bin_lighting/src",
"~/devel/sierra_ws/src/bg_peripherals/blackflys_driver/src",
"~/devel/sierra_ws/src/bg_core/perception/model_based/cardboard_box_detectors/src",
"~/devel/sierra_ws/src/bg_peripherals/cbx500_scanner/src",
"~/devel/sierra_ws/src/bg_peripherals/cognex_dataman_scanner/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/common_gripper_components/src",
"~/devel/sierra_ws/src/bg_peripherals/common_industrial_protocol/src",
"~/devel/sierra_ws/src/bg_core/messages/common_msgs/src",
"~/devel/sierra_ws/src/bg_robots/common_robot_components/src",
"~/devel/sierra_ws/src/bg_core/perception/container_heightmap/src",
"~/devel/sierra_ws/src/bg_peripherals/conveylinx_ersc/src",
"~/devel/sierra_ws/src/bg_peripherals/conveyor_driver/src",
"~/devel/sierra_ws/src/bg_robots/fanuc/crx_25ia/crx_25ia_description/src",
"~/devel/sierra_ws/src/bg_robots/fanuc/crx_25ia/crx_25ia_kinematics/src",
"~/devel/sierra_ws/src/bg_peripherals/cubiscan_325/src",
"~/devel/sierra_ws/src/bg_core/test_helpers/database_test_helpers/src",
"~/devel/sierra_ws/src/bg_core/ui/database_ui_core/src",
"~/devel/sierra_ws/src/bg_peripherals/datalogic_scanner/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/decoupled_high_flow/decoupled_high_flow_description/src",
"~/devel/sierra_ws/src/bg_peripherals/drop_scanner/drop_scanner_monitor/src",
"~/devel/sierra_ws/src/bg_peripherals/drop_scanner/drop_scanner_server/src",
"~/devel/sierra_ws/src/bg_ecomm/ecomm_metrics/src",
"~/devel/sierra_ws/src/bg_ecomm/ecomm_params/src",
"~/devel/sierra_ws/src/bg_ecomm/ecomm_supervisor/src",
"~/devel/sierra_ws/src/bg_peripherals/emerson_epp/src",
"~/devel/sierra_ws/src/bg_peripherals/ezlight_k50/src",
"~/devel/sierra_ws/src/bg_robots/fanuc/fanuc_driver/src",
"~/devel/sierra_ws/src/bg_core/perception/model_based/feature_detectors/src",
"~/devel/sierra_ws/src/bg_peripherals/fuji_ace_vfd/src",
"~/devel/sierra_ws/src/bg_peripherals/goal_core/src",
"~/devel/sierra_ws/src/bg_peripherals/goal_eip/src",
"~/devel/sierra_ws/src/bg_peripherals/goal_profinet/src",
"~/devel/sierra_ws/src/bg_core/perception/grasp_planning/grasp_planner/src",
"~/devel/sierra_ws/src/bg_core/perception/graspnet/src",
"~/devel/sierra_ws/src/bg_core/planning/greedy_ik/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/gripper_addons/src",
"~/devel/sierra_ws/src/bg_peripherals/guardmaster_440c/src",
"~/devel/sierra_ws/src/bg_peripherals/hagstrom_usb_km232/src",
"~/devel/sierra_ws/src/bg_peripherals/handheld_barcode_scanner/src",
"~/devel/sierra_ws/src/bg_core/database/health_monitor/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/high_flow_4_0/high_flow_4_0_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/high_flow_4_0/high_flow_4_0_driver/src",
"~/devel/sierra_ws/src/bg_peripherals/hyper_scanner/src",
"~/devel/sierra_ws/src/bg_peripherals/ifm/src",
"~/devel/sierra_ws/src/bg_peripherals/ifm_al1x/src",
"~/devel/sierra_ws/src/bg_core/perception/instance_segmentation/src",
"~/devel/sierra_ws/src/bg_peripherals/intermec_rfid_reader/src",
"~/devel/sierra_ws/src/bg_peripherals/interroll_multicontrol/src",
"~/devel/sierra_ws/src/bg_peripherals/io_device/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1200_09/irb1200_09_description/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1200_09/irb1200_09_kinematics/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1200_09_rosi/irb1200_09_rosi_description/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1200_09_rosi/irb1200_09_rosi_kinematics/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1300/irb1300_description/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1300/irb1300_kinematics/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1600_145/irb1600_145_description/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb1600_145/irb1600_145_kinematics/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb6700_155_285/irb6700_155_285_description/src",
"~/devel/sierra_ws/src/bg_robots/abb/irb6700_155_285/irb6700_155_285_kinematics/src",
"~/devel/sierra_ws/src/bg_peripherals/jvl_mac/src",
"~/devel/sierra_ws/src/bg_peripherals/keyence_barcode_scanner/src",
"~/devel/sierra_ws/src/bg_peripherals/keyence_ix/src",
"~/devel/sierra_ws/src/bg_core/perception/labelnet/src",
"~/devel/sierra_ws/src/bg_core/perception/landmarks/landmark_detector/src",
"~/devel/sierra_ws/src/bg_robots/fanuc/m20id_35/m20id_35_description/src",
"~/devel/sierra_ws/src/bg_robots/fanuc/m20id_35/m20id_35_kinematics/src",
"~/devel/sierra_ws/src/bg_core/perception/mass_estimation/src",
"~/devel/sierra_ws/src/bg_core/test_helpers/metapackage_test_helpers/src",
"~/devel/sierra_ws/src/bg_peripherals/microscan_barcode_scanner/src",
"~/devel/sierra_ws/src/bg_core/perception/ml_based/ml_grasp_detector/src",
"~/devel/sierra_ws/src/bg_core/perception/ml_service/src",
"~/devel/sierra_ws/src/bg_peripherals/modbus/src",
"~/devel/sierra_ws/src/bg_core/database/mongo_to_sql/src",
"~/devel/sierra_ws/src/bg_core/control/motion_profiles/src",
"~/devel/sierra_ws/src/bg_core/planning/motion_profiling/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/null_gripper/null_gripper_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/null_gripper/null_gripper_driver/src",
"~/devel/sierra_ws/src/bg_core/perception/model_based/object_detector/src",
"~/devel/sierra_ws/src/bg_peripherals/openni2_power_control/src",
"~/devel/sierra_ws/src/bg_core/messages/openrave_msgs/src",
"~/devel/sierra_ws/src/bg_core/planning/or_tf/src",
"~/devel/sierra_ws/src/bg_core/planning/pack_planner/src",
"~/devel/sierra_ws/src/bg_peripherals/packed_data_utils/src",
"~/devel/sierra_ws/src/bg_core/parameter_estimator/src",
"~/devel/sierra_ws/src/bg_core/perception/model_free/part_segmentation/src",
"~/devel/sierra_ws/src/bg_core/perception/model_based/patch_matching/src",
"~/devel/sierra_ws/src/bg_core/perception/perception_bringup/src",
"~/devel/sierra_ws/src/bg_core/perception/perception_interface/src",
"~/devel/sierra_ws/src/bg_core/messages/perception_msgs/src",
"~/devel/sierra_ws/src/bg_core/perception/perception_utils/src",
"~/devel/sierra_ws/src/bg_peripherals/peripheral_msgs/src",
"~/devel/sierra_ws/src/bg_peripherals/peripheral_test_helpers/src",
"~/devel/sierra_ws/src/bg_peripherals/phidgets_driver/src",
"~/devel/sierra_ws/src/bg_core/ui/pick_inspector_app_server/src",
"~/devel/sierra_ws/src/bg_core/ui/pick_inspector_proto/src",
"~/devel/sierra_ws/src/bg_core/ui/pick_inspector_web_app/src",
"~/devel/sierra_ws/src/bg_core/perception/pick_verification/src",
"~/devel/sierra_ws/src/bg_peripherals/pixelink_camera_driver/src",
"~/devel/sierra_ws/src/bg_ecomm/ecomm_peripherals/place_conveyor/src",
"~/devel/sierra_ws/src/bg_ecomm/ecomm_peripherals/place_conveyor_proto/src",
"~/devel/sierra_ws/src/bg_core/perception/placement_detection/src",
"~/devel/sierra_ws/src/bg_core/planning/planning_server/src",
"~/devel/sierra_ws/src/bg_core/test_helpers/planning_test_helpers/src",
"~/devel/sierra_ws/src/bg_peripherals/point_io/src",
"~/devel/sierra_ws/src/bg_core/perception/pose_in_hand/src",
"~/devel/sierra_ws/src/bg_peripherals/powerflex_525/src",
"~/devel/sierra_ws/src/bg_peripherals/primary_scanner/src",
"~/devel/sierra_ws/src/bg_core/database/product_manager/src",
"~/devel/sierra_ws/src/bg_robots/robot_common/robot_common_msgs/src",
"~/devel/sierra_ws/src/bg_robots/robot_common/robot_common_proto/src",
"~/devel/sierra_ws/src/bg_robots/robot_common/robot_controller/src",
"~/devel/sierra_ws/src/bg_robots/robot_common/robot_driver/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_common/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_events/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_safety/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_stack_light/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_supervisor/src",
"~/devel/sierra_ws/src/bg_rpc_common/rpc_ui/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_circ_v0_5/rpu_gripper_circ_v0_5_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_circ_v0_5plus/rpu_gripper_circ_v0_5plus_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_rect_v0_5/rpu_gripper_rect_v0_5_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_rect_v1/rpu_gripper_rect_v1_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_rect_v2/rpu_gripper_rect_v2_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_gripper_rect_v3/rpu_gripper_rect_v3_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/rpu_rake/src",
"~/devel/sierra_ws/src/bg_peripherals/safety_controller/src",
"~/devel/sierra_ws/src/bg_peripherals/sato_printer/src",
"~/devel/sierra_ws/src/bg_peripherals/scale_device/src",
"~/devel/sierra_ws/src/bg_peripherals/scan_in_hand/src",
"~/devel/sierra_ws/src/bg_core/database/schema_tracker/src",
"~/devel/sierra_ws/src/bg_core/perception/sensor_filters/src",
"~/devel/sierra_ws/src/bg_peripherals/shuttle_lighting/src",
"~/devel/sierra_ws/src/bg_peripherals/sick_scanner/src",
"~/devel/sierra_ws/src/bg_peripherals/siemens_web_scraper/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_assets/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_launch/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_models/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_profinet/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_systems/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_utils/src",
"~/devel/sierra_ws/src/bg_sierra_ecomm/sierra_ecomm_wms/src",
"~/devel/sierra_ws/src/bg_core/test_helpers/singulation_test_helpers/src",
"~/devel/sierra_ws/src/bg_core/planning/snap_planner/src",
"~/devel/sierra_ws/src/bg_peripherals/stack_light/src",
"~/devel/sierra_ws/src/bg_peripherals/sweeper_driver/src",
"~/devel/sierra_ws/src/bg_peripherals/tcp_barcode_scanner/src",
"~/devel/sierra_ws/src/bg_core/planning/trajectory_tree/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/turbo_shuttle/turbo_shuttle_description/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/turbo_shuttle/turbo_shuttle_driver/src",
"~/devel/sierra_ws/src/bg_robots/ur/ur10/ur10_description/src",
"~/devel/sierra_ws/src/bg_robots/ur/ur10/ur10_kinematics/src",
"~/devel/sierra_ws/src/bg_robots/ur/ur_driver/src",
"~/devel/sierra_ws/src/bg_core/test_helpers/util_test_helpers/src",
"~/devel/sierra_ws/src/bg_peripherals/vecow_dio/src",
"~/devel/sierra_ws/src/bg_core/perception/video_detectors/src",
"~/devel/sierra_ws/src/bg_robots/epson/vt6_a901s/vt6_a901s_description/src",
"~/devel/sierra_ws/src/bg_robots/epson/vt6_a901s/vt6_a901s_kinematics/src",
"~/devel/sierra_ws/src/bg_core/planning/workspace_trajectory_warper/src",
"~/devel/sierra_ws/src/bg_robots/berkshire_grey/grippers/yawing/yawing_description/src",
          }
        }
      }
    }
  },
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}


function TrimWhitespace()
  -- Removes trailing whitespace from current buffer
  -- Saves and restores cursor position from before call
  vim.cmd("let cursor = winsaveview()")
  vim.cmd("keeppatterns %s/\\s\\+$//e")
  vim.cmd("call winrestview(cursor)")
end

vim.api.nvim_create_autocmd('BufWritePre', { callback = TrimWhitespace })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

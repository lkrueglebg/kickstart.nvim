-- Fuzzy Finder (files, lsp, etc)

local function live_grep_with_src()
  local cwd = vim.fn.getcwd()
  local dirs_to_search = {cwd}
  if vim.fn.isdirectory('src') then
    for submodule in vim.fs.dir('src') do
      if vim.fn.isdirectory(submodule) then
        table.insert(dirs_to_search, cwd .. '/' .. submodule)
      end
    end
  end
  vim.print(dirs_to_search)
  require('telescope.builtin').live_grep{search_dirs=dirs_to_search}
end

return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    {
      'nvim-telescope/telescope-live-grep-args.nvim' ,
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = '^1.0.0',
    },
    {
      'cljoly/telescope-repo.nvim',
    },
    {
      'airblade/vim-rooter'
    }

  },
  config = function ()
    require('telescope').load_extension('live_grep_args')
    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
    }

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')

    -- Telescope live_grep in git root
    -- Function to find the git root directory based on the current buffer's path
    local function find_git_root()
      -- Use the current buffer's path as the starting point for the git search
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_dir
      local cwd = vim.fn.getcwd()
      -- If the buffer is not associated with a file, return nil
      if current_file == '' then
        current_dir = cwd
      else
        -- Extract the directory from the current file's path
        current_dir = vim.fn.fnamemodify(current_file, ':h')
      end

      -- Find the Git root directory from the current file's path
      local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
      if vim.v.shell_error ~= 0 then
        print('Not a git repository. Searching on current working directory')
        return cwd
      end
      return git_root
    end

    -- Custom live_grep function to search in git root
    local function live_grep_git_root()
      local git_root = find_git_root()
      if git_root then
        require('telescope.builtin').live_grep({
          search_dirs = { git_root },
        })
      end
    end

    vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

    vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzy search in current buffer' })
    vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
    vim.keymap.set('n', '<leader>sg', function()
	require('telescope.builtin').git_files{recurse_submodules=true}
    end, { desc = '[S]earch [G]it Files' })
    vim.keymap.set('n', '<leader>sf', function ()
      require('telescope.builtin').find_files{}
    end , { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>st', live_grep_with_src, { desc = '[S]earch by Text' })
    vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
    vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sq', require('telescope.builtin').quickfixhistory, { desc = '[S]earch [Q]uickfix history' })
    vim.keymap.set('n', '<leader>sm', require('telescope.builtin').marks, { desc = '[S]earch [M]arks' })
    vim.keymap.set('n', '<leader>sp', function ()
      require('telescope').extensions.repo.list({search_dirs = {'~/devel', '~/code'}})
    end, { desc = '[S]earch [P]rojects' })

  end
}

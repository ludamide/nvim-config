-- OPTIONS
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to false if no Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- Set 2-space tab indentation
  vim.o.expandtab = true
  vim.o.tabstop = 2
  vim.o.softtabstop = 2
  vim.o.shiftwidth = 2

  -- Show line numbers
  vim.o.number = true
  -- Show which line your cursor is on
  vim.o.cursorline = true
  -- Minimal number of screen lines to keep above and below the cursor
  vim.o.scrolloff = 10

  -- Enable mouse mode
  vim.o.mouse = 'a'

  -- Don't show the mode, set to true if no status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Keep wrapped lines indented
  vim.o.breakindent = true

  -- Enable undo/redo even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true
  -- Preview substitutions as you type
  vim.o.inccommand = 'split'

  -- Keep signcolumn on
  vim.o.signcolumn = 'yes'

  -- Update time for swap file to be written
  vim.o.updatetime = 250
  -- Mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Set how certain whitespaces will be displayed
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Asks if you wish to save the current file due to unsaved changes in the buffer
  vim.o.confirm = true
end

-- KEYMAPS & AUTOCMDS
do
  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal pressing <Esc> twice
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Keybinds for split navigation
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- Highlight when yanking (copying) text
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- PLUGIN MANAGER INTRO
do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- Runs the appropriate build command after a plugin is installed or updated
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

--- Helper function for plugins hosted on GitHub.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- UI / CORE UX PLUGINS
do
  -- Detects and sets indentation automatically
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Shows pending keybinds
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- Colorscheme
  vim.pack.add { gh 'sainnhe/sonokai' }
  vim.g.sonokai_enable_italic = true
  vim.g.sonokai_style = 'maia' -- values: default | atlantis | andromeda | shusia | maia | espresso
  vim.cmd.colorscheme 'sonokai'

  -- Highlights todos in comments
  vim.pack.add {
    gh 'nvim-lua/plenary.nvim',
    gh 'folke/todo-comments.nvim',
  }
  require('todo-comments').setup {}
  vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Next todo comment' })
  vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Previous todo comment' })
  vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<CR>', { desc = '[S]earch [T]odos' })

  -- A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- Show pretty icons if a nerd font is available
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Better Around/Inside textobjects
  require('mini.ai').setup {
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings
  require('mini.surround').setup()

  -- Simple statusline
  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end
end

-- SEARCH & NAVIGATION
do
  ---@type (string | vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  vim.pack.add(telescope_plugins)
  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set(
    'n',
    '<leader>/',
    function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end,
    { desc = '[/] Fuzzily search in current buffer' }
  )
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )
  vim.keymap.set(
    'n',
    '<leader>sn',
    function()
      builtin.find_files {
        cwd = vim.fn.stdpath 'config',
        follow = true,
      }
    end,
    { desc = '[S]earch [N]eovim files' }
  )

  -- Telescope-based LSP pickers when an LSP attaches to a buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })
end

-- LSP
do
  -- Status updates for LSP
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  -- Runs when an LSP attaches to a particular buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
      --- Helper function to define LSP-related mappings.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Highlights references of the word under your cursor
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map(
          '<leader>th',
          function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
          '[T]oggle Inlay [H]ints'
        )
      end
    end,
  })

  -- Enable the following language servers
  ---@type table<string, vim.lsp.Config>
  local servers = {
    stylua = {},
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- formatting is done by stylua

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
            return
          end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.tbl_filter(
              function(d) return not d:match(vim.fn.stdpath 'config' .. '/?a?f?t?e?r?') end,
              vim.api.nvim_get_runtime_file('', true)
            ),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- formatting is done by stylua
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically installs LSPs and related tools
  require('mason').setup {}
  -- Translates between nvim-lspconfig server names and mason.nvim package names
  require('mason-lspconfig').setup {
    automatic_enable = false,
  }

  -- Ensure servers and tools above are installed
  local ensure_installed = vim.tbl_keys(servers or {})
  -- vim.list_extend(ensure_installed, {})
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- FORMATTING
do
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Specifies filetypes to autoformat on save
      local enabled_filetypes = {
        lua = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- uses external formatters if configured below, otherwise use LSP formatting
    },
    formatters_by_ft = {
      lua = { 'stylua' },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- AUTOCOMPLETE & SNIPPETS
do
  -- Snippet engine
  vim.pack.add {
    gh 'rafamadriz/friendly-snippets',
    { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  }
  require('luasnip').setup {}
  require('luasnip.loaders.from_vscode').lazy_load()

  -- Autocomplete engine
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      preset = 'default',
    },
    appearance = {
      nerd_font_variant = 'normal', -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    },
    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
  }
end

-- TREESITTER
do
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    if not vim.treesitter.language.add(language) then return end

    vim.treesitter.start(buf, language)

    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- enables the parser if already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- if a parser is available, auto-installs it and enables it after installation
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- tries to enable treesitter features if the parser exists but is not available
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- NEXT STEPS
do
  -- Neo-tree
  vim.pack.add {
    gh 'MunifTanjim/nui.nvim',
    gh 'nvim-lua/plenary.nvim',
    { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  }
  vim.keymap.set('n', '\\', '<cmd>Neotree toggle<CR>', { desc = 'Neotree reveal', silent = true })
  require('neo-tree').setup {}

  -- Terminal
  vim.pack.add { { src = gh 'akinsho/toggleterm.nvim', version = vim.version.range '*' } }
  require('toggleterm').setup {
    direction = 'float',
  }
  vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
end

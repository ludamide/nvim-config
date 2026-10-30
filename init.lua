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

  -- Show the mode, set to false if status line
  vim.o.showmode = true

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

-- KEYMAPS
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
end


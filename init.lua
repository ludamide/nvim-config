do
  vim.loader.enable()

  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = true

  vim.o.breakindent = true
  vim.o.confirm = true
  vim.o.cursorline = true
  vim.o.expandtab = true
  vim.o.ignorecase = true
  vim.o.inccommand = 'split'
  vim.o.list = true
  vim.o.mouse = 'a'
  vim.o.number = true
  vim.o.tabstop = 2
  vim.o.scrolloff = 10
  vim.o.shiftwidth = 2
  vim.o.showmode = true
  vim.o.signcolumn = 'yes'
  vim.o.smartcase = true
  vim.o.softtabstop = 2
  vim.o.splitbelow = true
  vim.o.splitright = true
  vim.o.timeoutlen = 300
  vim.o.undofile = true
  vim.o.updatetime = 250

  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
end

do
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    virtual_text = true,
    virtual_lines = false,

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


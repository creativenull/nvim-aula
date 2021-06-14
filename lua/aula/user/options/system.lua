local option = require 'aula.core.option'

local undodir = vim.env.HOME .. '/.cache/nvim-nightly/undodir'

option.set({
  -- Move swapfiles and backups into cache
  swapfile = false,
  backup = false,

  -- Enable the integrated undo features
  undofile = true,
  undodir = string.format('%s/.cache/nvim-nightly/undodir', vim.env.HOME),
  undolevels = 10000,
  history = 10000,

  -- Lazy redraw (improves performance)
  lazyredraw = true,

  -- no mouse support
  mouse = ''
})

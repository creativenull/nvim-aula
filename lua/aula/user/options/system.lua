local opt = require 'aula.core.option'
local undodir = vim.env.HOME .. '/.cache/nvim-aula/undodir'

opt.set({
  -- Move swapfiles and backups into cache
  swapfile = false,
  backup = false,

  -- Enable the integrated undo features
  undofile = true,
  undodir = undodir,
  undolevels = 10000,
  history = 10000,

  -- Lazy redraw (improves performance)
  lazyredraw = true,

  -- no mouse support
  mouse = 'a'
})

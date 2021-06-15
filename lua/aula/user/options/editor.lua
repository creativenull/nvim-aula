local event = require 'aula.core.event'
local opt = require 'aula.core.option'

opt.set({
  -- Search options
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  wrapscan = true,

  -- Indent options
  tabstop = 4,
  softtabstop = 4,
  shiftwidth = 0,
  expandtab = true,
  autoindent = true,
  smartindent = true,
  smarttab = true,

  -- Set spelling
  spell = false,

  -- backspace behaviour
  backspace = 'indent,eol,start',

  -- Auto reload file if changed outside vim, or just :e!
  autoread = true,

  -- Line options
  textwidth = 120,
  colorcolumn = '120',
  scrolloff = 5,
  linebreak = true,

  -- line numbers
  number = true
})

-- Set spelling only on markdown files
event.add({
  event = 'FileType',
  pattern = 'markdown',
  cmd = 'setlocal spell'
})

-- Show chars being highlighted
event.add({
  event = 'TextYankPost',
  cmd = function()
    vim.highlight.on_yank({ higroup = 'Search', timeout = 500 })
  end
})

-- Trim trailing whitespace
event.add({
  event = 'BufWritePre',
  cmd = [[%s/\s\+$//e]]
})

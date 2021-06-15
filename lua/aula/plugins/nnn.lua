local pkg = require 'aula.core.package'
local keymap = require 'aula.core.keymap'
local M = {}

-- Plugin Name
function M.init()
  pkg.add('mcchrish/nnn.vim')
end

-- Set options before loading plugin
function M.config()
  vim.g['nnn#layout'] = { right = '~25%' }
end

-- Set options after loading plugin
function M.setup()
  keymap.set('n', '<F3>', '<cmd>Np<CR>')
end

return M

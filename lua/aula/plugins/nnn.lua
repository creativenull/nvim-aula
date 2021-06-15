local pkg = require 'aula.core.package'
local keymap = require 'aula.core.keymap'
local M = {}

-- Plugin Name
function M.init()
  pkg.add('mcchrish/nnn.vim')
end

-- Set options after loading plugin
function M.setup()
  require 'nnn'.setup {
    layout = {
      window = {
        width = 0.9,
        height = 0.6,
        highlight = 'Debug'
      }
    }
  }

  keymap.set('n', '<F3>', '<cmd>Np<CR>')
end

return M

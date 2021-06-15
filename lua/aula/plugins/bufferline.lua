local pkg = require 'aula.core.package'
local M = {}

function M.init()
  pkg.add('akinsho/nvim-bufferline.lua')
end

function M.setup()
  require 'bufferline'.setup {
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false
    }
  }
end

return M

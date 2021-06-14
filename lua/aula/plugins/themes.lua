local pkg = require 'aula.core.package'
local M = {}

function M.init()
  pkg.add('glepnir/zephyr-nvim')
  pkg.add('sainnhe/gruvbox-material')
end

return M

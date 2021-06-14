local pkg = require 'aula.core.package'
local M = {}

function M.init()
  pkg.add_dep('Shougo/context_filetype.vim')
  pkg.add('tyru/caw.vim')
end

return M

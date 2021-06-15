local pkg = require 'aula.core.package'
local M = {}

-- Plugin Name
function M.init()
  -- Example,
  -- pkg.add('creativenull/diagnosticls-nvim')
end

-- Set options before loading plugin
function M.config()
  -- Example,
  -- vim.g.someoption = 'value'
end

-- Set options after loading plugin
function M.setup()
  -- Example,
  -- require 'plugin'.setup()
end

return M

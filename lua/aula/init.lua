local config = require 'aula.config'
local M = {}

function M.init()
  config.start()
  require 'aula.user'
  config.finish()
end

return M

local command = require 'aula.core.command'
local M = {}

function M.setup()
  command.set(
    '-nargs=1 AulaAddPlugin',
    string.format(
      [[execute "silent !cp %s/plugin_template.lua %s/<args>.lua" | edit %s/<args>.lua]],
      _G.aula.config.templates_dir,
      _G.aula.config.plugins_dir,
      _G.aula.config.plugins_dir
    )
  )
end

return M

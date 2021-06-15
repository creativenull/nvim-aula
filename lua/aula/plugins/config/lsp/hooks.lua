local completion = require 'completion'
local set_lsp_keymaps = require 'aula.plugins.config.lsp.keymaps'.set_lsp_keymaps
local M = {}

function M.on_attach(client)
  completion.on_attach(client)
  set_lsp_keymaps()

  print('Attached to ' .. client.name)
end

return M

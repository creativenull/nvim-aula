local completion = require 'completion'
local M = {}

function M.on_attach(client, bufnr)
  completion.on_attach(client)
  print('Attached to ' .. client.name)
end

return M

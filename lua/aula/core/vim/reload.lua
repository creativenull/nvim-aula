local command = require 'aula.core.command'
local keymap = require 'aula.core.keymap'
local M = {}

local function reload()
  for name,_ in pairs(package.loaded) do
    if name:match('^aula') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)

  print('[Aula] Config Reloaded!')
end

function M.setup()
  keymap.add('n', '<leader>vs', reload)
  command.add('ConfigReload', reload)
end

return M

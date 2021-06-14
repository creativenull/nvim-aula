local event = require 'aula.core.event'
local keymap = require 'aula.core.keymap'
local command = require 'aula.core.command'
local reload = require 'aula.core.vim.reload'
local pkg = require 'aula.core.package'
local theme = require 'aula.core.theme'
local M = {}

function M.start()
  keymap.init({ leader = ' ', localleader = ',' })
  event.init()
  pkg.init()
end

function M.finish()
  theme.setup()
  reload.setup()
  command.setup()
  keymap.setup()
  event.setup()
end

return M

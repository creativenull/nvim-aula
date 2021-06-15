local event = require 'aula.core.event'
local keymap = require 'aula.core.keymap'
local command = require 'aula.core.command'
local reload = require 'aula.core.vim.reload'
local pkg = require 'aula.core.package'
local theme = require 'aula.core.theme'
local templates = require 'aula.core.templates'
local M = {}

function M.start()
  local namespace = 'aula'

  _G.aula = {
    debug = false,

    config = {
      templates_dir = string.format('%s/.config/nvim-aula/lua/%s/core/templates', vim.env.HOME, namespace),
      plugins_dir = string.format('%s/.config/nvim-aula/lua/%s/plugins', vim.env.HOME, namespace)
    },

    theme = {},

    commands = {
      set = {},
      queue = {}
    },

    keymaps = {
      set = {},
      queue = {}
    },

    events = {
      set = {},
      queue = {}
    },

    package = {
      plugin_deps = {},
      plugins = {}
    }
  }

  keymap.init({ leader = ' ', localleader = ',' })
  event.init()
  pkg.init()
end

function M.finish()
  theme.setup()
  reload.setup()
  templates.setup()
  command.setup()
  keymap.setup()
  event.setup()
end

return M

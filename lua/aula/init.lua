local M = {}

_G.aula = {
  debug = false,

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

function M.init()
  require 'aula.config'.start()
  require 'aula.user'
  require 'aula.config'.finish()
end

return M

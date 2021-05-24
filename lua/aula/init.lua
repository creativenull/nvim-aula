local M = {}

_G.aula = {
    debug = false,
    commands = {
        set = {},
        queue = {}
    },

    keymaps = {
        set = {},
        queue = {}
    },

    events = {
        queue = {}
    }
}

function M.run()
    require 'aula.config'.start()
    require 'aula.user'
    require 'aula.config'.finish()
end

return M

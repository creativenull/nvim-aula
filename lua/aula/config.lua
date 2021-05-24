local event = require 'aula.core.event'
local keymap = require 'aula.core.keymap'
local command = require 'aula.core.command'
local reload = require 'aula.core.vim.reload'
local package = require 'aula.core.package'
local M = {}

function M.start()
    local keymapConfig = {
        leader = ' ',
        localleader = ','
    }

    -- core init
    keymap.init(keymapConfig)
    event.init()
    package.init()
end

function M.finish()
    -- user setup

    -------------
    -- core setup
    reload.setup()
    command.setup()
    keymap.setup()
    event.setup()
end

return M

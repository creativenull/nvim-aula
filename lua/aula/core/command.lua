local err = require 'aula.core.error'
local Command = {}

local function _makeCommand(name, cmd)
    return string.format('command! %s %s', name, cmd)
end

local function _makeCommandSetFn()
    local lastitem = #_G.aula.commands.set + 1
    return string.format('lua _G.aula.commands.set[%d].cb()', lastitem)
end

local function _makeCommandQueueFn()
    local lastitem = #_G.aula.commands.queue + 1
    return string.format('lua _G.aula.commands.queue[%d].cb()', lastitem)
end

local function _validate(name, cmd)
    assert(type(name) == 'string' and name ~= '', '[Command] 1st arg `name` cannot be empty string')
    assert(
        type(cmd) == 'string' or type(cmd) == 'function',
        '[Command] 2nd arg `cmd` should be a string or function'
    )
end

-- Add commands to the queue
-- @param name string
-- @param cmd string
function Command.add(name, cmd)
    local tryFn = function()
        _validate(name, cmd)

        local isFn = type(cmd) == 'function'
        local isStr = type(cmd) == 'string'
        local commandAdd = {}
        if isFn then
            commandAdd = {
                name = name,
                cb = cmd,
                cmd = _makeCommand(name, _makeCommandQueueFn())
            }
        elseif isStr then
            commandAdd = {
                name = name,
                cmd = _makeCommand(name, cmd)
            }
        end

        if not vim.tbl_isempty(commandAdd) then
            table.insert(_G.aula.commands.queue, commandAdd)
        end
    end

    err.handle(tryFn)
end

-- Set the command when called, different to add()
-- where this will be added to the command list when added
-- @param name string
-- @param cmd string
function Command.set(name, cmd)
    local tryFn = function()
        local success, results = pcall(_validate, name, cmd)
        if not success then
            vim.api.nvim_err_writeln(results)
            return
        end

        local isFn = type(cmd) == 'function'
        local isStr = type(cmd) == 'string'
        local commandSet = {}
        if isFn then
            commandSet = {
                name = name,
                cb = cmd,
                cmd = _makeCommand(name, _makeCommandSetFn())
            }
        elseif isFn then
            commandSet = {
                name = name,
                cmd = _makeCommand(name, cmd)
            }
        end

        if not vim.tbl_isempty(commandSet) then
            table.insert(_G.aula.commands.set, commandSet)
            vim.cmd(commandSet.cmd)
        end
    end

    err.handle(tryFn)
end

-- Register all commands stored in queue
-- and empty the queue
function Command.setup()
    local tryFn = function()
        local queue = _G.aula.commands.queue
        if #queue == 0 then
            return
        end

        for i = 1, #queue do
            local cmd = table.remove(_G.aula.commands.queue)
            vim.cmd(cmd)
        end

        _G.aula.commands.queue = {}
    end

    err.handle(tryFn)
end

return Command

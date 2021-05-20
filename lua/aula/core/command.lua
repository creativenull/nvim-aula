local queue = require('./core.queue')
local QUEUE_KEY = 'commands'
local Command = {}

local function _makeCommand(cmd, repl)
    return string.format('command! %s %s', cmd, repl)
end

-- Add commands to the queue
-- @param cmd string
-- @param repl string
function Command.add(cmd, repl) queue.push(QUEUE_KEY, _makeCommand(cmd, repl)) end

-- Set the command when called, different to add()
-- where this will be added to the command list when added
-- @param cmd string
-- @param repl string
function Command.set(cmd, repl) vim.cmd(_makeCommand(cmd, repl)) end

-- Register all commands stored in queue
-- and empty the queue
function Command.setup()
    for i = 1, #queue.storage[QUEUE_KEY] do
        -- print(vim.inspect(queue.pop('commands')))
        vim.cmd(queue.pop(QUEUE_KEY))
    end
    queue.storage.commands = nil
end

return Command

local err = require 'aula.core.error'
local DEFAULT_EVENT_ARGS = {
    pattern = '*',
    once = false,
    nested = false
}
local Event = {}

-- Build the autocmd command
-- @param opts table - in the format: { event, pattern, once, cmd }
-- @return table
local function _makeAutocmd(opts)
    local onceArg = ''
    if opts.once then
        onceArg = ' ++once'
    end

    local nestedArg = ''
    if opts.nested then
        nestedArg = ' ++nested'
    end

    return string.format('autocmd %s %s%s%s %s', opts.event, opts.pattern, onceArg, nestedArg, opts.cmd)
end

-- Validate options from set()
-- @param opts table
local function _validate(opts)
    assert(type(opts.event) == 'string' and opts.event ~= '', '[Event] `opts.event` cannot be empty string')
    assert(type(opts.cmd) == 'string' or type(opts.cmd) == 'function', '[Event] `opts.cmd` must be string or function')
end

-- Initialize config for events
-- @param config table - { group }
function Event.init(config)
    Event.events = {}
    if type(config) == 'table' then
        Event.config = vim.tbl_extend('force', Event.config, config)
    end
end

-- Register all the events defined from set()
function Event.setup()
    vim.cmd('augroup aula_user_events')
    vim.cmd('au!')
    for _,event in pairs(_G.aula.events.queue) do
        vim.cmd(event.cmd)
    end
    vim.cmd('augroup end')
end

-- Define the events to be registered via init()
-- @param opts table - { event, pattern, once, cmd }
function Event.add(opts)
    local tryFn = function()
        _validate(opts)

        -- merge opts
        opts = vim.tbl_extend('force', DEFAULT_EVENT_ARGS, opts)

        if type(opts.cmd) == 'string' then
            local autocmd = _makeAutocmd({
                event = opts.event,
                pattern = opts.pattern,
                once = opts.once,
                nested = opts.nested,
                cmd = opts.cmd
            })
            table.insert(_G.aula.events.queue, { cmd = autocmd })
        elseif type(opts.cmd) == 'function' then
            local lastItem = #_G.aula.events.queue + 1
            local autocmd = _makeAutocmd({
                event = opts.event,
                pattern = opts.pattern,
                once = opts.once,
                nested = opts.nested,
                cmd = string.format('lua _G.aula.events.queue[%d].cb()', lastItem)
            })
            table.insert(_G.aula.events.queue, { cmd = autocmd, cb = opts.cmd })
        end
    end

    err.handle(tryFn)
end

function Event.group(name, fn)
end

return Event

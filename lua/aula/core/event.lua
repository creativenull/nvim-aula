local DEFAULT_EVENT_ARGS = {
    pattern = '*',
    once = false,
    nested = false
}
local Event = {
    config = {
        group = 'user_events'
    },
    events = {}
}

-- Build the autocmd command
-- @param opts table - in the format: { event, pattern, once, cmd }
-- @return table
local function makeAutoCmd(opts)
    local onceArg = ''
    if opts.once then onceArg = ' ++once' end

    local nestedArg = ''
    if opts.nested then nestedArg = ' ++nested' end

    local autocmd = string.format('autocmd %s %s%s%s %s', opts.event, opts.pattern, onceArg, nestedArg, opts.cmd)
    autocmd = vim.trim(autocmd)

    return autocmd
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
    _G[Event.config.group] = Event.events

    -- Attach the list of autocmds to the group
    vim.cmd('augroup ' .. Event.config.group)
    vim.cmd('au!')
    for event,handlers in pairs(_G[Event.config.group]) do
        for _,handle in pairs(handlers) do
            vim.cmd(handle.cmd)
        end
    end
    vim.cmd('augroup end')
end

-- Define the events to be registered via init()
-- @param opts table - { event, pattern, once, cmd }
function Event.add(opts)
    xpcall(
        function()
            _validate(opts)

            -- Default opts
            opts = vim.tbl_extend('force', DEFAULT_EVENT_ARGS, opts)

            -- Set to empty array if not set
            if Event.events[opts.event] == nil then Event.events[opts.event] = {} end

            if type(opts.cmd) == 'string' then
                local autocmd = makeAutoCmd({
                    event = opts.event,
                    pattern = opts.pattern,
                    once = opts.once,
                    nested = opts.nested,
                    cmd = opts.cmd
                })
                table.insert(Event.events[opts.event], { cmd = autocmd })
            elseif type(opts.cmd) == 'function' then
                -- Assume the next item will be iterated by 1 - bad assumption, maybe a TODO?
                local lastItem = #Event.events[opts.event] + 1
                local autocmd = makeAutoCmd({
                    event = opts.event,
                    pattern = opts.pattern,
                    once = opts.once,
                    nested = opts.nested,
                    cmd = string.format(':lua _G.%s.%s[%d].callback()', Event.config.group, opts.event, lastItem)
                })
                table.insert(Event.events[opts.event], { callback = opts.cmd, cmd = autocmd })
            end
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

return Event

local queue = require('./core.queue')
local QUEUE_KEY = 'keymaps'
local DEFAULT_KEYMAP_OPTS = {
    noremap = true,
    silent = true
}
local Keymap = {
    config = {
        leader = ' ',
        localleader = ','
    }
}

local function _mergeOpts(opts, defaults)
    local hasOpt = opts ~= nil and not vim.tbl_isempty(opts)
    if hasOpt then
        opts = vim.tbl_extend('force', defaults, opts)
    else
        opts = defaults
    end

    return opts
end

local function _validate(mode, lhs, rhs, opts)
    assert(type(mode) == 'string', '[Keymap] `mode` must be string')
    assert(type(lhs) == 'string', '[Keymap] `lhs` Left-hand-side must be string')
    assert(type(rhs) == 'string', '[Keymap] `rhs` Right-hand-side must be string')
    assert(type(opts) == 'table' or opts == nil, '[Keymap] `opts` must be a table')
end

function Keymap.init(config)
    if type(config) == 'table' then
        Keymap.config = vim.tbl_extend('force', Keymap.config, config)
    end

    -- Set the leaders
    vim.g.mapleader = Keymap.config.leader
    vim.g.maplocalleader = Keymap.config.localleader
end

function Keymap.add(mode, lhs, rhs, opts)
    xpcall(
        function()
            _validate(mode, lhs, rhs, opts)
            queue.push(QUEUE_KEY, { mode, lhs, rhs, _mergeOpts(opts, DEFAULT_KEYMAP_OPTS) })
        end, 
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

function Keymap.set(mode, lhs, rhs, opts)
    xpcall(
        function()
            _validate(mode, lhs, rhs, opts)
            vim.api.nvim_set_keymap(mode, lhs, rhs, _mergeOpts(opts, DEFAULT_KEYMAP_OPTS))
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

-- Register all keymaps stored in queue
-- and empty the queue
function Keymap.setup()
    for i = 1, #queue.storage[QUEUE_KEY] do
        local map = queue.pop(QUEUE_KEY)
        local mode, lhs, rhs, opts = map[1], map[2], map[3], map[4]
        local success, results = pcall(vim.api.nvim_set_keymap, mode, lhs, rhs, opts)
        if not success then
            vim.api.nvim_err_writeln(results)
        end
    end
    queue.storage.keymaps = nil
end

return Keymap

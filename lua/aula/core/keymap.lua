local err = require 'aula.core.error'
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

local function _makeKeymapFn(mode, lhs, rhs, opts)
    return function()
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end

local function _makeRhsQueueFn()
    local lastItem = #_G.aula.keymaps.queue + 1
    return string.format('<cmd>lua _G.aula.keymaps.queue[%d].cb()<cr>', lastItem)
end

local function _makeRhsSetFn()
    local lastItem = #_G.aula.keymaps.set + 1
    return string.format('<cmd>lua _G.aula.keymaps.set[%d].cb()<cr>', lastItem)
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
local function _validate(mode, lhs, rhs, opts)
    assert(type(mode) == 'string', '[Keymap] `mode` must be string')
    assert(opts == nil or type(opts) == 'table', '[Keymap] `opts` must be a table')
    assert(type(lhs) == 'string' and lhs ~= '', '[Keymap] `lhs` Left-hand-side must be string')
    assert(
        (type(rhs) == 'string' and rhs ~= '') or type(rhs) == 'function',
        '[Keymap] `rhs` Right-hand-side must be string or function'
    )
end

-- @param config table or nil
function Keymap.init(config)
    if type(config) == 'table' then
        Keymap.config = vim.tbl_extend('force', Keymap.config, config)
    end

    -- Set the leaders
    vim.g.mapleader = Keymap.config.leader
    vim.g.maplocalleader = Keymap.config.localleader
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
function Keymap.add(mode, lhs, rhs, opts)
    local tryFn = function()
        _validate(mode, lhs, rhs, opts)

        if type(opts) == 'table' then
            opts = vim.tbl_extend('force', DEFAULT_KEYMAP_OPTS, opts)
        else
            opts = DEFAULT_KEYMAP_OPTS
        end

        local kmap = {}
        if type(rhs) == 'function' then
            kmap = {
                mode = mode,
                map = lhs,
                fn = _makeKeymapFn(mode, lhs, _makeRhsQueueFn(), opts),
                cb = rhs
            }
        elseif type(rhs) == 'string' then
            kmap = {
                mode = mode,
                map = lhs,
                fn = _makeKeymapFn(mode, lhs, rhs, opts)
            }
        end

        if not vim.tbl_isempty(kmap) then
            table.insert(_G.aula.keymaps.queue, kmap)
        end
    end

    err.handle(tryFn)
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
function Keymap.set(mode, lhs, rhs, opts)
    local tryFn = function()
        _validate(mode, lhs, rhs, opts)

        if type(opts) == 'table' then
            opts = vim.tbl_extend('force', DEFAULT_KEYMAP_OPTS, opts)
        else
            opts = DEFAULT_KEYMAP_OPTS
        end

        local kmap = {}
        if type(rhs) == 'function' then
            kmap = {
                mode = mode,
                map = lhs,
                fn = _makeKeymapFn(mode, lhs, _makeRhsSetFn(), opts),
                cb = rhs
            }
        elseif type(rhs) == 'string' then
            kmap = {
                mode = mode,
                map = lhs,
                fn = _makeKeymapFn(mode, lhs, rhs, opts)
            }
        end

        if not vim.tbl_isempty(kmap) then
            table.insert(_G.aula.keymaps.set, kmap)
            kmap.fn()
        end
    end

    err.handle(tryFn)
end

-- Register all keymaps stored in queue
-- and empty the queue
function Keymap.setup()
    local tryFn = function()
        local queue = _G.aula.keymaps.queue
        if #queue == 0 then
            return
        end

        for _,map in pairs(_G.aula.keymaps.queue) do
            map.fn()
        end
    end

    err.handle(tryFn)
end

return Keymap

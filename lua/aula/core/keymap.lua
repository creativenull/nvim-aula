local err = require 'aula.core.error'
local M = {
  config = {
    leader = ' ',
    localleader = ','
  }
}
local DEFAULT_KEYMAP_OPTS = {
  noremap = true,
  silent = true
}

local function make_keymap_fn(mode, lhs, rhs, opts)
  return function()
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

local function make_rhs_queue_fn()
  local last_item = #_G.aula.keymaps.queue + 1
  return string.format('<cmd>lua _G.aula.keymaps.queue[%d].cb()<cr>', last_item)
end

local function make_rhs_set_fn()
  local last_item = #_G.aula.keymaps.set + 1
  return string.format('<cmd>lua _G.aula.keymaps.set[%d].cb()<cr>', last_item)
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
local function validate(mode, lhs, rhs, opts)
  assert(type(mode) == 'string', '[Aula Keymap] `mode` must be string')
  assert(opts == nil or type(opts) == 'table', '[Aula Keymap] `opts` must be a table')
  assert(type(lhs) == 'string' and lhs ~= '', '[Aula Keymap] `lhs` Left-hand-side must be string')
  assert(
    (type(rhs) == 'string' and rhs ~= '') or type(rhs) == 'function',
    '[Aula Keymap] `rhs` Right-hand-side must be string or function'
  )
end

-- @param config table or nil
function M.init(config)
  if type(config) ~= 'nil' or type(config) == 'table' then
    M.config = vim.tbl_extend('force', M.config, config)
  end

  -- Set the leaders
  vim.g.mapleader = M.config.leader
  vim.g.maplocalleader = M.config.localleader
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
function M.add(mode, lhs, rhs, opts)
  local try_fn = function()
    validate(mode, lhs, rhs, opts)

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
        fn = make_keymap_fn(mode, lhs, make_rhs_queue_fn(), opts),
        cb = rhs
      }
    elseif type(rhs) == 'string' then
      kmap = {
        mode = mode,
        map = lhs,
        fn = make_keymap_fn(mode, lhs, rhs, opts)
      }
    end

    if not vim.tbl_isempty(kmap) then
      table.insert(_G.aula.keymaps.queue, kmap)
    end
  end

  err.handle(try_fn)
end

-- @param mode string
-- @param lhs string
-- @param rhs string or function
-- @param opts table
function M.set(mode, lhs, rhs, opts)
  local try_fn = function()
    validate(mode, lhs, rhs, opts)

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
        fn = make_keymap_fn(mode, lhs, make_rhs_set_fn(), opts),
        cb = rhs
      }
    elseif type(rhs) == 'string' then
      kmap = {
        mode = mode,
        map = lhs,
        fn = make_keymap_fn(mode, lhs, rhs, opts)
      }
    end

    if not vim.tbl_isempty(kmap) then
      table.insert(_G.aula.keymaps.set, kmap)
      kmap.fn()
    end
  end

  err.handle(try_fn)
end

function M.set_leader(leader)
  vim.g.mapleader = leader
end

function M.set_localleader(localleader)
  vim.g.maplocalleader = localleader
end

-- Register all keymaps stored in queue
-- and empty the queue
function M.setup()
  local try_fn = function()
    local queue = _G.aula.keymaps.queue
    if #queue == 0 then
      return
    end

    for _,map in pairs(queue) do
      map.fn()
    end
  end

  err.handle(try_fn)
end

return M

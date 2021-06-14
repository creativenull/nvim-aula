local err = require 'aula.core.error'
local M = {
  config = {
    group_name = 'aula_user_events'
  }
}
local DEFAULT_AUTOCMD_ARGS = {
  pattern = '*',
  once = false,
  nested = false
}

-- Make the autocmd string to be executed with vim.cmd()
-- which will not be part of any augroup
--
-- @param opts table in the format: { event (string), pattern (string), once (boolean), cmd (boolean) }
local function make_autocmd(opts)
  local once = ''
  if opts.once then
    once = ' ++once'
  end

  local nested = ''
  if opts.nested then
    nested = ' ++nested'
  end

  return string.format('autocmd! %s %s%s%s %s', opts.event, opts.pattern, once, nested, opts.cmd)
end

-- Make the autocmd string to be executed with vim.cmd()
-- as part of an augroup
--
-- @param opts table - in the format: { event (string), pattern (string), once (boolean), cmd (boolean) }
-- @return string
local function make_autocmd_group(opts)
  local once = ''
  if opts.once then
    once = ' ++once'
  end

  local nested = ''
  if opts.nested then
    nested = ' ++nested'
  end

  return string.format('autocmd %s %s%s%s %s', opts.event, opts.pattern, once, nested, opts.cmd)
end

-- Validate arguments for M.set()
-- @param opts table
local function validate(opts)
  assert(not vim.tbl_isempty(opts), '[Aula Events] Cannot have empty opts')
  assert(
    type(opts.event) == 'string' and opts.event ~= '',
    '[Aula Event] `event` cannot be empty string'
  )
  assert(
    type(opts.cmd) == 'string' or type(opts.cmd) == 'function',
    '[Aula Event] `cmd` must be string or function'
  )
  if opts.pattern then
    assert(opts.pattern ~= '', '[Aula Event] `pattern` must not be an empty string')
  end
end

-- Initialize config for events
-- @param config table - { group }
function M.init(config)
  if type(config) == 'table' and not vim.tbl_isempty(config) then
    M.config = vim.tbl_extend('force', M.config, config)
  end
end

-- Register all the events defined from set()
function M.setup()
  vim.cmd('augroup ' .. M.config.group_name)
  vim.cmd('autocmd!')
  for _,event in pairs(_G.aula.events.queue) do
    vim.cmd(event.cmd)
  end
  vim.cmd('augroup end')
end

-- Define the events to be registered via init()
-- @param opts table - { event, pattern, once, cmd }
function M.add(opts)
  local try_fn = function()
    validate(opts)

    -- merge opts
    opts = vim.tbl_extend('force', DEFAULT_AUTOCMD_ARGS, opts)

    if type(opts.cmd) == 'string' then
      local autocmd = make_autocmd_group({
        event = opts.event,
        pattern = opts.pattern,
        once = opts.once,
        nested = opts.nested,
        cmd = opts.cmd
      })
      table.insert(_G.aula.events.queue, { cmd = autocmd })
    elseif type(opts.cmd) == 'function' then
      local last_item = #_G.aula.events.queue + 1
      local autocmd = make_autocmd_group({
        event = opts.event,
        pattern = opts.pattern,
        once = opts.once,
        nested = opts.nested,
        cmd = string.format('lua _G.aula.events.queue[%d].cb()', last_item)
      })
      table.insert(_G.aula.events.queue, { cmd = autocmd, cb = opts.cmd })
    end
  end

  err.handle(try_fn)
end

local function set_autocmd(opts)
  validate(opts)
  opts = vim.tbl_extend('force', DEFAULT_AUTOCMD_ARGS, opts)

  if type(opts.cmd) == 'string' then
    local autocmd = make_autocmd({
      event = opts.event,
      pattern = opts.pattern,
      once = opts.once,
      nested = opts.nested,
      cmd = opts.cmd
    })
    vim.cmd(autocmd)
  elseif type(opts.cmd) == 'function' then
    local last_item = #_G.aula.events.set + 1
    local autocmd = make_autocmd({
      event = opts.event,
      pattern = opts.pattern,
      once = opts.once,
      nested = opts.nested,
      cmd = string.format('lua _G.aula.events.set[%d].cb()', last_item)
    })
    table.insert(_G.aula.events.set, { cmd = autocmd, cb = opts.cmd })
    vim.cmd(autocmd)
  end
end

function M.set_group(name, opts_list)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for opts in pairs(opts_list) do
    err.handle(function()
      set_autocmd(opts)
    end)
  end
  vim.cmd('augroup end')
end

-- Set an autocmd on-demand
function M.set(opts)
  err.handle(function()
    set_autocmd(opts)
  end)
end

return M

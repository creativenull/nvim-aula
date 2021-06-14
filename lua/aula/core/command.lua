local err = require 'aula.core.error'
local M = {}

local function get_command_str(name, cmd)
  return string.format('command! %s %s', name, cmd)
end

local function make_command_set_fn()
  local lastitem = #_G.aula.commands.set + 1
  return string.format('lua _G.aula.commands.set[%d].cb()', lastitem)
end

local function make_command_queue_fn()
  local lastitem = #_G.aula.commands.queue + 1
  return string.format('lua _G.aula.commands.queue[%d].cb()', lastitem)
end

local function validate(name, cmd)
  assert(type(name) == 'string' and name ~= '', '[Aula Command] 1st arg `name` cannot be empty string')
  assert(
    type(cmd) == 'string' or type(cmd) == 'function',
    '[Aula Command] 2nd arg `cmd` should be a string or function'
  )
end

-- Add commands to the queue
-- @param name string
-- @param cmd string
function M.add(name, cmd)
  local try_fn = function()
    validate(name, cmd)

    local is_fn = type(cmd) == 'function'
    local is_str = type(cmd) == 'string'
    local command_add = {}
    if is_fn then
      command_add = {
        name = name,
        cb = cmd,
        cmd = get_command_str(name, make_command_queue_fn())
      }
    elseif is_str then
      command_add = {
        name = name,
        cmd = get_command_str(name, cmd)
      }
    end

    if not vim.tbl_isempty(command_add) then
      table.insert(_G.aula.commands.queue, command_add)
    end
  end

  err.handle(try_fn)
end

-- Set the command when called, different to add()
-- where this will be added to the command list when added
-- @param name string
-- @param cmd string
function M.set(name, cmd)
  local try_fn = function()
    validate(name, cmd)

    local command_set = {}
    local is_fn = type(cmd) == 'function'
    local is_str = type(cmd) == 'string'
    if is_fn then
      command_set = {
        name = name,
        cb = cmd,
        cmd = get_command_str(name, make_command_set_fn())
      }
    elseif is_str then
      command_set = {
        name = name,
        cmd = get_command_str(name, cmd)
      }
    end

    if not vim.tbl_isempty(command_set) then
      table.insert(_G.aula.commands.set, command_set)
      vim.api.nvim_command(command_set.cmd)
    end
  end

  err.handle(try_fn)
end

-- Register all commands stored in queue
-- and empty the queue
function M.setup()
  local try_fn = function()
    local queue = _G.aula.commands.queue
    if #queue == 0 then
      return
    end

    for _,v in pairs(queue) do
      local command = v.cmd
      vim.api.nvim_command(command)
    end
  end

  err.handle(try_fn)
end

return M

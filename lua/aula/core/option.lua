local err = require 'aula.core.error'
local event = require 'aula.core.event'
local M = {}

-- @param option string
local function get_option_info(option)
  local success, results = pcall(vim.api.nvim_get_option_info, option)
  if not success then
    error(string.format('[Aula Option] No such option `%s`', option))
  end

  return results
end

local function set_global_option(option, value)
  local success = pcall(vim.api.nvim_set_option, option, value)
  if not success then
    error(
      string.format(
        '[Aula Option] Failed to set option `%s` to `%s`, check :h \'%s\'',
        option,
        value,
        option
      )
    )
  end
end

local function set_buffer_option(option, value)
  local bufnr = vim.fn.bufnr('%')
  local success = pcall(vim.api.nvim_buf_set_option, bufnr, option, value)
  if not success then
    error(
      string.format(
        '[Aula Option] Failed to set buffer option `%s` to `%s`, check :h \'%s\'',
        option,
        value,
        option
      )
    )
  end
end

-- @param option string
-- @param value string|boolean|number
local function set_window_option(option, value)
  local winid = vim.fn.win_getid()
  local success = pcall(vim.api.nvim_win_set_option, winid, option, value)
  if not success then
    error(
      string.format(
        '[Aula Option] Failed to set window option `%s` to `%s`, check :h \'%s\'',
        option,
        value,
        option
      )
    )
  end
end

-- Append a value string to the comma separated option list
-- TODO:
-- This is a bad assumption, but it's assumed the option is a global option
-- maybe look into adding extra checks
--
-- @param option string
-- @param value string|boolean|number
local function append_commalist(option, value)
  local value_str = vim.api.nvim_get_option(option)
  local values = vim.split(value_str, ',')
  table.insert(values, value)
  value_str = table.concat(values, ',')
  set_global_option(option, value_str)
end

-- Append a value string to the flag string
-- TODO:
-- This is a bad assumption, but it's assumed the option is a global option
-- maybe look into adding extra checks
--
-- @param option string
-- @param value string|boolean|number
local function append_flaglist(option, value)
  local value_str = vim.api.nvim_get_option(option)
  if value_str:match(value) then
    return
  end

  value_str = value_str .. value
  set_global_option(option, value_str)
end

-- Prepend a value string to the comma separated option list
-- TODO:
-- This is a bad assumption, but it's assumed the option is a global option
-- maybe look into adding extra checks
--
-- @param option string
-- @param value string|boolean|number
local function prepend_commalist(option, value)
  local value_str = vim.api.nvim_get_option(option)
  local values = vim.split(value_str, ',')
  table.insert(values, 1, value)
  value_str = table.concat(values, ',')
  set_global_option(option, value_str)
end

-- Prepend a value string to the flag string
-- TODO:
-- This is a bad assumption, but it's assumed the option is a global option
-- maybe look into adding extra checks
--
-- @param option string
-- @param value string|boolean|number
local function prepend_flaglist(option, value)
  local value_str = vim.api.nvim_get_option(option)
  if value_str:match(value) then
    return
  end

  value_str = value .. value_str
  set_global_option(option, value_str)
end

-- Remove a value from an option comma/flag list
-- TODO:
-- This is a bad assumption, but it's assumed the option is a global option
-- maybe look into adding extra checks
--
-- @param option string
-- @param value string|boolean|number
-- @param delimiter string
local function remove_list(option, value, delimiter)
  local value_str = vim.api.nvim_get_option(option)
  local values = vim.split(value_str, delimiter)
  for k,_ in pairs(values) do
    if values[k] == value then
      table.remove(values, k)
      break
    end
  end

  value_str = table.concat(values, delimiter)
  set_global_option(option, value_str)
end

-- @param optionFn function
-- @param option string
-- @param value string|boolean|number
-- @param isGlobal boolean
local function set_local_option(set_local_option_fn, option, value, is_global)
  if is_global then
    set_global_option(option, value)
  end

  set_local_option_fn(option, value)
end

-- @param option string
-- @param value string|boolean|number
local function validate(option, value)
  assert(option ~= '', '[Aula Option] `option` must be a string and not empty')
end

local function validate_join_remove_option(option, value)
  assert(option ~= '', '[Aula Option] `option` must be a string and not empty')
  assert(type(value) == 'string', '[Aula Option] `option` must be a string and not empty')
end

-- Set the option with the given value if it exists on the
-- global, buffer, or window scope, respectively
-- @param option string
-- @param value string|boolean|number
local function set_option(option, value)
  local option_info = get_option_info(option)
  if option_info.scope == 'global' then
    set_global_option(option, value)
  elseif option_info.scope == 'buf' then
    set_local_option(set_buffer_option, option, value, option_info.global_local)
  elseif option_info.scope == 'win' then
    set_local_option(set_window_option, option, value, option_info.global_local)
  end
end

-- @param options table
local function validate_group(options)
  assert(
    vim.tbl_count(options) > 0,
    '[Aula Option] `options` must be a table in the format: { option1 = value, option2 = value, ... }'
  )
end

-- Set a list of options together
-- @param options table - in the format: { option1 = value, option2 = value, ... }
local function set_option_group(options)
  for option,value in pairs(options) do
    set_option(option, value)
  end
end

-- Set the option with the given value if it exists on the
-- global, buffer, or window scope, respectively
-- @param option string
-- @param value string|boolean|number
function M.set(option, value)
  local try_fn = function()
    if type(option) == 'table' and not vim.tbl_isempty(option) and value == nil then
      validate_group(option)
      set_option_group(option)
    elseif type(option) == 'string' then
      validate(option, value)
      set_option(option, value)
    end
  end

  err.handle(try_fn)
end

-- @param option string
-- @param value string|boolean|number
function M.append(option, value)
  local try_fn = function()
    validate_join_remove_option(option, value)
    local option_info = get_option_info(option)
    if option_info.commalist then
      append_commalist(option, value)
    elseif option_info.flaglist then
      append_flaglist(option, value)
    else
      error(string.format('[Aula Option] `%s` is not a commalist or a flaglist option', option))
    end
  end

  err.handle(try_fn)
end

-- @param option string
-- @param value string|boolean|number
function M.prepend(option, value)
  local try_fn = function()
    validate_join_remove_option(option, value)
    local option_info = get_option_info(option)
    if option_info.commalist then
      prepend_commalist(option, value)
    elseif optionInfo.flaglist then
      prepend_flaglist(option, value)
    else
      error(string.format('[Aula Option] `%s` is not a commalist or a flaglist option', option))
    end
  end

  err.handle(try_fn)
end

-- @param option string
-- @param value string|boolean|number
function M.remove(option, value)
  local try_fn = function()
    validate_join_remove_option(option, value)
    local option_info = get_option_info(option)
    if option_info.commalist then
      remove_list(option, value, ',')
    elseif option_info.flaglist then
      remove_list(option, value, '')
    else
      error(string.format('[Aula Option] `%s` is not a commalist or a flaglist option', option))
    end
  end

  err.handle(try_fn)
end

return M

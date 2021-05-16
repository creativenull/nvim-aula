local Option = {}

local function _setGlobalOption(option, value) vim.o[option]  = value end
local function _setBufferOption(option, value) vim.bo[option] = value end
local function _setWindowOption(option, value) vim.wo[option] = value end

-- Set the option, first on the global scope, if it exists
-- then on the local scope
--
-- @param option string
-- @param value string|boolean|number
-- @param optionFn function
-- @param isGlobal boolean
local function _setOptionByInfo(option, value, optionFn, isGlobal)
  -- Set the global option first if it exists
  if isGlobal then
    local success, results = pcall(_setGlobalOption, option, value)
    if not success then
      vim.api.nvim_err_writeln(results)
      return
    end
  end

  local success, results = pcall(optionFn, option, value)
  if not success then
    vim.api.nvim_err_writeln(results)
    return
  end
end

-- Validate the options passed to set()
local function validate(option, value)
  local optionValidation = type(option) == 'string' and option ~= ''
  local valueValidation = type(value) == 'string' or type(value) == 'boolean' or type(value) == 'number'
  assert(optionValidation, '[Option] `option` must be string and not empty')
  assert(valueValidation, '[Option] `value` must be string|boolean|number')
end

-- Set the option with the given value if it exists on the
-- global, buffer, or window scope, respectively
--
-- @param option string
-- @param value string|boolean|number
local function _set(option, value)
  local success, results = pcall(validate, option, value)
  if not success then
    vim.api.nvim_err_writeln(results)
    return
  end

  -- Get info for the option and set according to the
  -- scope of the option
  local optionInfo = vim.api.nvim_get_option_info(option)
  if optionInfo.scope == 'global' then
    local success, results = pcall(_setGlobalOption, option, value)
    if not success then
      vim.api.nvim_err_writeln(results)
      return
    end
  elseif optionInfo.scope == 'buf' then
    _setOptionByInfo(option, value, _setBufferOption, optionInfo.global_local)
  elseif optionInfo.scope == 'win' then
    _setOptionByInfo(option, value, _setWindowOption, optionInfo.global_local)
  end
end

-- Set a list of options together
--
-- @param optionList table - in the format: { { option, value }, { option, value }, {...} }
local function _setGroup(optionList)
  local success, results = pcall(
    assert,
    type(optionList) == 'table',
    '[Option] `optionList` must be a table in the format: { { option, value }, {...} }'
  )
  if not success then
    vim.api.nvim_err_writeln(results)
    return
  end

  for k,v in pairs(optionList) do
    local option, value = v[1], v[2]
    _set(option, value)
  end
end

-- API and aliases to be used
Option.set = _set
Option.setOption = _set
Option.setGroup = _setGroup
Option.setOptionGroup = _setGroup

return Option

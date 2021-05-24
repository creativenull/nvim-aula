local Option = {}

-- @param option string
-- @param value string|boolean|number
local function _makeErrMsg(option, value)
    return string.format([[[Option] Failed setting `%s` to `%s`, try :h '%s' for proper use]], option, value, option)
end

-- @param option string
local function _getOptionInfo(option)
    local success, results = pcall(vim.api.nvim_get_option_info, option)
    if not success then
        error(string.format('[Option] No such option `%s`', option))
    end

    return results
end

-- @param option string
-- @param value string|boolean|number
local function _setGlobalOption(option, value)
    local success, results = pcall(function(o, v) vim.o[o] = v end, option, value)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _setBufferOption(option, value)
    local success, results = pcall(function(o, v) vim.bo[o] = v end, option, value)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _setWindowOption(option, value)
    local success, results = pcall(function(o, v) vim.wo[o] = v end, option, value)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _appendCommaList(option, value)
    local optionValue = vim.api.nvim_get_option(option)
    local optionList = vim.split(optionValue, ',')
    table.insert(optionList, value)
    local newValue = table.concat(optionList, ',')
    local success = pcall(vim.api.nvim_set_option, option, newValue)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _appendFlagList(option, value)
    local optionValue = vim.api.nvim_get_option(option)
    local newValue = optionValue .. value
    local success = pcall(vim.api.nvim_set_option, option, newValue)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _prependCommaList(option, value)
    local optionValue = vim.api.nvim_get_option(option)
    local optionList = vim.split(optionValue, ',')
    table.insert(optionList, 1, value)
    local newValue = table.concat(optionList, ',')
    local success = pcall(vim.api.nvim_set_option, option, newValue)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
local function _prependFlagList(option, value)
    local optionValue = vim.api.nvim_get_option(option)
    local newValue = value .. newValue
    local success = pcall(vim.api.nvim_set_option, option, newValue)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param option string
-- @param value string|boolean|number
-- @param delimiter string
local function _removeList(option, value, delimiter)
    local optionValue = vim.api.nvim_get_option(option)
    local optionList = vim.split(optionValue, delimiter)
    for k,v in pairs(optionList) do
        if optionList[k] == value then
            table.remove(optionList, k)
            break
        end
    end

    local newValue = table.concat(optionList, delimiter)
    local success = pcall(vim.api.nvim_set_option, option, value)
    if not success then
        error(_makeErrMsg(option, value))
    end
end

-- @param optionFn function
-- @param option string
-- @param value string|boolean|number
-- @param isGlobal boolean
local function _setLocalOption(setLocalOptionFn, option, value, isGlobal)
    if isGlobal then
        _setGlobalOption(option, value)
    end

    setLocalOptionFn(option, value)
end

-- @param option string
-- @param value string|boolean|number
local function _validate(option, value)
    local optionValidation = option ~= ''
    local valueValidation = type(value) == 'string' or type(value) == 'boolean' or type(value) == 'number'
    assert(optionValidation, '[Option] `option` must be string and not empty')
    assert(valueValidation, '[Option] `value` must be string, boolean, number')
end

-- Set the option with the given value if it exists on the
-- global, buffer, or window scope, respectively
-- @param option string
-- @param value string|boolean|number
local function _set(option, value)
    local optionInfo = _getOptionInfo(option)
    if optionInfo.scope == 'global' then
        _setGlobalOption(option, value)
    elseif optionInfo.scope == 'buf' then
        _setLocalOption(_setBufferOption, option, value, optionInfo.global_local)
    elseif optionInfo.scope == 'win' then
        _setLocalOption(_setWindowOption, option, value, optionInfo.global_local)
    end
end

-- @param options table
local function _validateGroup(options)
    assert(
        vim.tbl_count(options) > 0,
        '[Option] `options` must be a table in the format: { option1 = value, option2 = value, ... }'
    )
end

-- Set a list of options together
-- @param options table - in the format: { option1 = value, option2 = value, ... }
local function _setGroup(options)
    for option,value in pairs(options) do
        _set(option, value)
    end
end

-- Set the option with the given value if it exists on the
-- global, buffer, or window scope, respectively
-- @param option string
-- @param value string|boolean|number
function Option.set(option, value)
    xpcall(
        function()
            if type(option) == 'table' and value == nil then
                _validateGroup(option)
                _setGroup(option)
            elseif type(option) == 'string' then
                _validate(option, value)
                _set(option, value)
            end
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

-- @param option string
-- @param value string|boolean|number
function Option.append(option, value)
    xpcall(
        function()
            _validate(option, value)
            local optionInfo = _getOptionInfo(option)
            if optionInfo.commalist then
                _appendCommaList(option, value)
            elseif optionInfo.flaglist then
                _appendFlagList(option, value)
            else
                error(string.format('[Option] `%s` is not a commalist or a flaglist option', option))
            end
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

-- @param option string
-- @param value string|boolean|number
function Option.prepend(option, value)
    xpcall(
        function()
            _validate(option, value)
            local optionInfo = _getOptionInfo(option)
            if optionInfo.commalist then
                _prependCommaList(option, value)
            elseif optionInfo.flaglist then
                _prependFlagList(option, value)
            else
                error(string.format('[Option] `%s` is not a commalist or a flaglist option', option))
            end
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

-- @param option string
-- @param value string|boolean|number
function Option.remove(option, value)
    xpcall(
        function()
            _validate(option, value)
            local optionInfo = _getOptionInfo(option)
            if optionInfo.commalist then
                _removeList(option, value, ',')
            elseif optionInfo.flaglist then
                _removeList(option, value, '')
            else
                error(string.format('[Option] `%s` is not a commalist or a flaglist option', option))
            end
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

return Option

local M = {}

function M.typeOrNil(valueType, value)
    return function()
        return type(value) == valueType or type(value) == 'nil'
    end
end

function M.tableOrString(value)
    return function()
        return type(value) == 'table' or type(value) == 'string'
    end
end

return M

local M = {}

function M.type_or_nil(value_type, value)
  return function()
    return type(value) == value_type or type(value) == 'nil'
  end
end

function M.table_or_string(value)
  return function()
    return type(value) == 'table' or type(value) == 'string'
  end
end

return M

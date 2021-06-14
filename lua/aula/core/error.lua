local M = {}

-- @param err function
local function errorfn(err)
  vim.api.nvim_err_writeln(err)
end

-- @param fn function
function M.handle(fn)
  xpcall(fn, errorfn)
end

return M

local M = {}

local function _error(err)
    vim.api.nvim_err_writeln(err)
end

-- @param fn function
function M.handle(fn)
    xpcall(fn, _error)
end

return M

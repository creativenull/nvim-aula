local M = {}

function M.load(mpath)
  local success, results = pcall(require, mpath)
  if not success then
    vim.api.nvim_err_writeln(results)
    return
  end

  return results
end

return M

local DEFAULT_KEYMAP_OPTS = {
  noremap = true,
  silent = true
}
local Keymap = {
  maps = {}
}

-- Setup the global keymaps
function Keymap:init()
  for _,args in pairs(self.maps) do
    local success = pcall(vim.api.nvim_set_keymap, args[1], args[2], args[3], args[4])

    -- Show the error when it fails
    -- but do not fail the whole init
    if not success then
      local errmsg = string.format([[Could not map `%s`]], args[2])
      vim.api.nvim_err_writeln(errmsg)
    end
  end

  print(vim.inspect(self.maps))
end

-- Register the keymaps to be set on init
-- @param mode string
-- @param lhs string
-- @param rhs string
-- @param opts table
function Keymap:set(mode, lhs, rhs, opts)
  local hasOpt = opts ~= nil and not vim.tbl_isempty(opts)
  if hasOpt then
    table.insert(self.maps, { mode, lhs, rhs, vim.tbl_extend('force', DEFAULT_KEYMAP_OPTS, opts) })
  else
    table.insert(self.maps, { mode, lhs, rhs, DEFAULT_KEYMAP_OPTS })
  end
end

-- Register the buffer keymaps on demand
-- @param bufnr number
-- @param mode string
-- @param lhs string
-- @param opts table
function Keymap:setBuf(bufnr, mode, lhs, rhs, opts)
  local hasOpt = opts ~= nil and not vim.tbl_isempty(opts)
  local args = {}
  if hasOpt then
    opts = vim.tbl_extend('force', DEFAULT_KEYMAP_OPTS, opts)
  else
    opts = DEFAULT_KEYMAP_OPTS
  end

  local success = pcall(vim.api.nvim_buf_set_keymap, bufnr, mode, lhs, rhs, opts)

  -- Show the error when it fails
  -- but do not fail the whole init
  if not success then
    local errmsg = string.format([[Could not map `%s`]], args[3])
    vim.api.nvim_err_writeln(errmsg)
  end

end
return Keymap

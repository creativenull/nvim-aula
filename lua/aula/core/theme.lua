local err = require 'aula.core.error'
local option = require 'aula.core.option'
local event = require 'aula.core.event'
local DEFAULT_OPTS = {
  background = 'dark',
  termguicolors = true
}
local M = {}

local function validate(opts)
  assert(type(opts.name) == 'string' and opts.name ~= '', '[Aula Theme] `name` cannot be empty string')
end

-- @param opts table in the format: { name, background, guicolors }
function M.set(opts)
  local themefn =  function()
    validate(opts)
    opts = vim.tbl_extend('force', DEFAULT_OPTS, opts)

    option.set({
      background = opts.background,
      termguicolors = opts.termguicolors
    })

    vim.api.nvim_command('colorscheme ' .. opts.name)

    if vim.g.colors_name ~= opts.name then
      vim.g.colors_name = opts.name
    end
  end

  _G.aula.theme.cb = themefn
end

function M.colorscheme(name)
  M.set({ name = name })
end

-- @param fn function of vim.cmd
function M.set_theme_highlights(fn)
  event.add({
    event = 'ColorScheme',
    cmd = function()
      err.handle(fn)
    end
  })
end

function M.setup()
  err.handle(function()
    _G.aula.theme.cb()
  end)
end

return M

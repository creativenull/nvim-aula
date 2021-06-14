local err = require 'aula.core.error'
local option = require 'aula.core.option'
local event = require 'aula.core.event'

local M = {}
local DEFAULT_OPTS = {
  background = 'dark',
  termguicolors = true
}

local function merge_with_defaults(opts)
  return vim.tbl_extend('force', DEFAULT_OPTS, opts)
end

local function validate(opts)
  assert(type(opts.name) == 'string' and opts.name ~= '', '[Aula Theme] `name` cannot be empty string')
end

-- @param opts table in the format: { name, background, guicolors }
function M.set(opts)
  local themefn =  function()
    validate(opts)
    opts = merge_with_defaults(opts)

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
  local hl_fn = function()
    err.handle(fn)
  end

  event.add({ event = 'ColorScheme', cmd = hl_fn })
end

function M.setup()
  err.handle(function()
    _G.aula.theme.cb()
  end)
end

return M

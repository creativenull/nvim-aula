local pkg = require 'aula.core.package'
local M = {}

-- Plugin Name
function M.init()
  pkg.add('neovim/nvim-lspconfig')
  pkg.add('nvim-lua/completion-nvim')
  pkg.add('glepnir/lspsaga.nvim')
end

-- Set options before loading plugin
function M.config()
  -- Example,
  -- vim.g.someoption = 'value'
end

-- Set options after loading plugin
function M.setup()
  -- Example,
  -- require 'plugin'.setup()

  -- _G.SetupLSP = require 'aula.plugins.lsp.setup'
end

return M

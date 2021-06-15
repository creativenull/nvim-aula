local opt = require 'aula.core.option'
local pkg = require 'aula.core.package'
local M = {}

-- Plugin Name
function M.init()
  -- `do` is a reserved keyword
  pkg.add('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
  pkg.add('nvim-treesitter/nvim-treesitter-textobjects')
end

-- Set options after loading plugin
function M.setup()
  require 'nvim-treesitter.configs'.setup({
    ensure_installed = {
      'css',
      'graphql',
      'html',
      'javascript',
      'json',
      'lua',
      'python',
      'tsx',
      'typescript',
      'svelte',
    },
    highlight = { enable = true },
    indent = { enable = true }
  })
end

return M

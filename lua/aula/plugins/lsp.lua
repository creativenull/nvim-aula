local pkg = require 'aula.core.package'
local keymap = require 'aula.core.keymap'
local M = {}

-- Plugin Name
function M.init()
  pkg.add('neovim/nvim-lspconfig')
  pkg.add('nvim-lua/completion-nvim')
  pkg.add('glepnir/lspsaga.nvim')
  pkg.add('creativenull/diagnosticls-nvim')
end

-- Set options after loading plugin
function M.setup()
  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = true,
  })

  _G.SetupLSP = require 'aula.plugins.config.lsp.setup'
  SetupLSP('sumneko_lua')

  keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
  keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
  keymap.set('i', '<Enter>', [[pumvisible() ? "\<C-y>" : "\<Enter>"]], { expr = true })
  keymap.set('i', '<C-Space>', [[<Plug>(completion_trigger)]], { noremap = false })
end

return M

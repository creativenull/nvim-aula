local lspconfig = require 'lspconfig'
local on_attach = require 'aula.plugins.config.lsp.hooks'.on_attach
local tsserver_opts = require 'aula.plugins.config.lsp.tsserver'
local sumneko_opts = require 'aula.plugins.config.lsp.sumneko'

-- Handle diagnostic langserver with this plugin
require 'diagnosticls-nvim'.init { on_attach = on_attach }

-- Default setup
return function(name, opts)
  if lspconfig[name] == nil then
    vim.api.nvim_err_writeln(string.format('"%s" does not exist in nvim-lspconfig', name))
    return
  end

  -- Managed by creativenull/diagnosticls-nvim plugin
  if name == 'diagnosticls' then
    return
  end

  local default_opts = {
    on_attach = on_attach
  }

  -- Extra LSP options not available in lspconfig
  -- =======
  if name == 'tsserver' then
    default_opts = vim.tbl_extend('force', default_opts, tsserver_opts)
  elseif name == 'sumneko_lua' then
    default_opts = vim.tbl_extend('force', default_opts, sumneko_opts)
  end

  -- =======
  if opts ~= nil and not vim.tbl_isempty(opts) then
    -- Merge 'opts' w/ 'default_opts'. If keys are the same, then override key from 'opts'
    -- no need to deep copy
    local merged_opts = vim.tbl_extend('force', default_opts, opts)
    lspconfig[name].setup(merged_opts)
  else
    lspconfig[name].setup(default_opts)
  end
end

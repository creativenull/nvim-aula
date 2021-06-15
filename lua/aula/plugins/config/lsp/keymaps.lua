local keymap = require('aula.core.keymap')
local M = {}

function M.set_lsp_keymaps()
  keymap.set('n', '<leader>lc', [[<Cmd>Lspsaga rename<CR>]])
  keymap.set('n', '<leader>la', [[<Cmd>Lspsaga code_action<CR>]])
  keymap.set('n', '<leader>ld', [[<Cmd>lua vim.lsp.buf.definition()<CR>]])
  keymap.set('n', '<leader>le', [[<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>]])
  keymap.set('n', '<leader>lf', [[<Cmd>lua vim.lsp.buf.formatting()<CR>]])
  keymap.set('n', '<leader>lh', [[<Cmd>Lspsaga hover_doc<CR>]])
  keymap.set('n', '<leader>lw', [[<Cmd>Lspsaga show_line_diagnostics<CR>]])
end

return M

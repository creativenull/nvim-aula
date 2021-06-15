local pkg = require 'aula.core.package'
local M = {}

function M.init()
  pkg.add('tbastos/vim-lua')
  pkg.add('plasticboy/vim-markdown')
end

function M.config()
  vim.g.vim_markdown_conceal = 0
  vim.g.vim_markdown_conceal_code_blocks = 0
  vim.g.vim_markdown_fenced_languages = { 'vim=vim', 'lua=lua', 'sh=sh', }
end

return M

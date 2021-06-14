local theme = require 'aula.core.theme'

theme.colorscheme('zephyr')

theme.set_theme_highlights(function()
  vim.cmd 'highlight! Normal guibg=NONE'
  vim.cmd 'highlight! SignColumn guibg=NONE'
  vim.cmd 'highlight! LineNr guibg=NONE guifg=#aaaaaa'
  vim.cmd 'highlight! CursorLineNr guibg=NONE'
end)

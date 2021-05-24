local colorscheme = require 'aula.core.colorscheme'

colorscheme.set {
    name = 'slate'
}

colorscheme.highlights(function()
    -- Custom highlights here
    -- eg. vim.cmd('highlight Normal guibg=#888')
    vim.cmd 'hi! Normal guibg=NONE'
    vim.cmd 'hi! SignColumn guibg=NONE'
    vim.cmd 'hi! LineNr guibg=NONE guifg=#aaaaaa'
    vim.cmd 'hi! CursorLineNr guibg=NONE'
end)

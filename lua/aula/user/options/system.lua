local option = require 'aula.core.option'

-- local undodir = vim.env.HOME .. '/.cache/nvim-nightly/undodir'
-- if vim.fn.isdirectory(undodir) == 0 then
--     vim.cmd(':silent !mkdir -p ' .. undodir)
-- end

option.set({
    -- Move swapfiles and backups into cache
    swapfile = false,
    backup = false,
    
    -- Enable the integrated undo features
    undofile = true,
    undodir = os.getenv('HOME') .. '/.cache/nvim-nightly/undodir',
    undolevels = 10000,
    history = 10000,
    
    -- Lazy redraw (improves performance)
    lazyredraw = true,
})

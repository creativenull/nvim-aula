local option = require 'aula.core.option'

option.set({
    -- Line option
    showmatch = true, 
    colorcolumn = '120', -- some prefer 80, but I just like to break the rules :)
    
    -- Buffers/Tabs/Windows
    hidden = true, 
    
    -- Status line
    showmode = false,
    
    -- Tab line
    showtabline = 2,
    
    -- Better display
    cmdheight = 2,

    -- For git
    signcolumn = 'yes',
    
    -- No mouse support
    mouse = '',
    
    -- Cursor
    guicursor = 'n-v-c-ci-sm-ve-i:block,r-cr-o:hor20',
})

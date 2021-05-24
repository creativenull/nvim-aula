local event = require 'aula.core.event'
local option = require 'aula.core.option'

option.set({
    -- Search options
    hlsearch = true,
    incsearch = true,
    ignorecase = true,
    smartcase = true,
    wrapscan = true,

    -- Indent options
    tabstop = 4,
    shiftwidth = 0,
    softtabstop = 4,
    expandtab = true,
    autoindent = true,
    smartindent = true,
    smarttab = true,

    -- Set spelling
    spell = false,

    -- backspace behaviour
    backspace = 'indent,eol,start',

    -- Auto reload file if changed outside vim, or just :e!
    autoread = true,

    -- Line options
    textwidth = 120,
    scrolloff = 5,
    linebreak = true,

    -- line numbers
    number = true
})

-- TODO:
-- Find out a way to let option.set
-- set for each buffer and not just the current
-- buffer, so we can omit this pattern
local function bufferEditorOptions()
    local nr = vim.fn.bufnr()
    vim.bo[nr].tabstop = 4
    vim.bo[nr].shiftwidth = 0
    vim.bo[nr].softtabstop = 4
    vim.bo[nr].expandtab = true
    vim.bo[nr].autoindent = true
    vim.bo[nr].smartindent = true
end

event.add({
    event = 'BufEnter,BufNew',
    cmd = bufferEditorOptions
})

-- set spelling only on markdown files
event.add({
    event = 'FileType',
    pattern = 'markdown',
    cmd = 'setlocal spell'
})

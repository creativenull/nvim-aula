local keymap = require 'aula.core.keymap'

-- Unbind default bindings for arrow keys, trust me this is for your own good
keymap.set('v', '<up>', '<nop>')
keymap.set('v', '<down>', '<nop>')
keymap.set('v', '<left>', '<nop>')
keymap.set('v', '<right>', '<nop>')
keymap.set('i', '<up>', '<nop>')
keymap.set('i', '<down>', '<nop>')
keymap.set('i', '<left>', '<nop>')
keymap.set('i', '<right>', '<nop>')

-- Map Esc, to perform quick switching between Normal and Insert mode
keymap.set('i', 'jk', '<ESC>')

-- Map escape from terminal input to Normal mode
keymap.set('t', '<ESC>', [[<C-\><C-n>]])
keymap.set('t', '<C-[>', [[<C-\><C-n>]])

-- Omnifunc
keymap.set('i', '<C-Space>', '<C-x><C-o>')

-- Disable highlights
keymap.set('n', '<leader><CR>', '<cmd>noh<CR>')

-- Buffer maps
-- -----------
-- List all buffers
keymap.set('n', '<leader>bl', [[<cmd>buffers<CR>]])
-- Next buffer
keymap.set('n', '<C-l>', '<cmd>bnext<CR>')
-- Previous buffer
keymap.set('n', '<C-h>', '<cmd>bprevious<CR>')
-- Close buffer, and more?
keymap.set('n', '<leader>bd', '<cmd>bp<BAR>sp<BAR>bn<BAR>bd<CR>')

-- Resize window panes, we can use those arrow keys
-- to help use resize windows - at least we give them some purpose
keymap.set('n', '<up>', '<cmd>resize +2<CR>')
keymap.set('n', '<down>', '<cmd>resize -2<CR>')
keymap.set('n', '<left>', '<cmd>vertical resize -2<CR>')
keymap.set('n', '<right>', '<cmd>vertical resize +2<CR>')

-- Text maps
-- ---------
-- Move a line of text Alt+[j/k]
keymap.set('n', '<M-j>', [[mz:m+<CR>`z]])
keymap.set('n', '<M-k>', [[mz:m-2<CR>`z]])
keymap.set('v', '<M-j>', [[:m'>+<CR>`<my`>mzgv`yo`z]])
keymap.set('v', '<M-k>', [[:m'<-2<CR>`>my`<mzgv`yo`z]])

-- Tab completion
keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
keymap.set('i', '<Enter>', [[pumvisible() ? "\<C-y>" : "\<Enter>"]], { expr = true })

-- Reload file
keymap.set('n', '<leader>r', '<cmd>edit!<CR>')

-- DO NOT DO THIS, check the link
-- https://dev.to/creativenull/installing-neovim-nightly-alongside-stable-10d0
-- Runtime Path
vim.cmd 'set runtimepath-=~/.config/nvim'
vim.cmd 'set runtimepath-=~/.config/nvim/after'
vim.cmd 'set runtimepath-=~/.local/share/nvim/site'
vim.cmd 'set runtimepath-=~/.local/share/nvim/site/after'
vim.cmd 'set runtimepath-=/etc/xdg/nvim'
vim.cmd 'set runtimepath-=/etc/xdg/nvim/after'
vim.cmd 'set runtimepath-=/usr/share/nvim/site'
vim.cmd 'set runtimepath-=/usr/share/nvim/site/after'
vim.cmd 'set runtimepath-=/usr/local/share/nvim/site'
vim.cmd 'set runtimepath-=/usr/local/share/nvim/site/after'

vim.cmd 'set runtimepath+=~/.config/nvim-aula/after'
vim.cmd 'set runtimepath^=~/.config/nvim-aula'
vim.cmd 'set runtimepath+=~/.local/share/nvim-aula/site/after'
vim.cmd 'set runtimepath^=~/.local/share/nvim-aula/site'

-- Pack Path
vim.cmd 'set packpath-=~/.config/nvim'
vim.cmd 'set packpath-=~/.config/nvim/after'
vim.cmd 'set packpath-=~/.local/share/nvim/site'
vim.cmd 'set packpath-=~/.local/share/nvim/site/after'
vim.cmd 'set packpath-=/etc/xdg/nvim'
vim.cmd 'set packpath-=/etc/xdg/nvim/after'
vim.cmd 'set packpath-=/usr/local/share/nvim/site'
vim.cmd 'set packpath-=/usr/local/share/nvim/site/after'
vim.cmd 'set packpath-=/usr/share/nvim/site'
vim.cmd 'set packpath-=/usr/share/nvim/site/after'

vim.cmd 'set packpath^=~/.config/nvim-aula'
vim.cmd 'set packpath+=~/.config/nvim-aula/after'
vim.cmd 'set packpath^=~/.local/share/nvim-aula/site'
vim.cmd 'set packpath+=~/.local/share/nvim-aula/site/after'

-- =============================================================================
-- = Aula Initial Start =
-- =============================================================================
local aula = require 'aula'
aula.init()

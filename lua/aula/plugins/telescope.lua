local pkg = require 'aula.core.package'
local keymap = require 'aula.core.keymap'
local M = {}

function M.init()
  pkg.add_dep('nvim-lua/popup.nvim')
  pkg.add_dep('nvim-lua/plenary.nvim')
  pkg.add('nvim-telescope/telescope.nvim')
end

function M.setup()
  local telescope = require 'telescope'
  local telescope_builtin = require 'telescope.builtin'
  local telescope_actions = require 'telescope.actions'

  telescope.setup {
    defaults = {
      prompt_position = 'top',
      layout_strategy = 'horizontal',
      sorting_strategy = 'ascending',
      use_less = false
    }
  }

  local find_files = function()
    telescope_builtin.find_files {
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
      previewer = false
    }
  end
  keymap.add('n', '<C-p>', find_files)

  local find_config_files = function()
    local configdir = vim.env.HOME .. '/.config/nvim-aula/lua/aula/user'
    telescope_builtin.find_files {
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden', configdir },
      previewer = false
    }
  end
  keymap.add('n', '<leader>vf', find_config_files)

  local live_grep = function()
    telescope_builtin.live_grep {}
  end
  keymap.add('n', '<C-t>', live_grep)

  local file_browser = function()
    telescope_builtin.file_browser {}
  end
  keymap.add('n', '<leader>ff', file_browser)

  local find_buffers = function()
    telescope_builtin.buffers {
      previewer = false
    }
  end
  keymap.add('n', '<leader>bb', find_buffers)
end

return M

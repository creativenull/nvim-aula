local package = require 'aula.core.package'
local keymap = require 'aula.core.keymap'
local M = {}

function M.init()
    package.addDep('nvim-lua/popup.nvim')
    package.addDep('nvim-lua/plenary.nvim')
    package.add('nvim-telescope/telescope.nvim')
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

    local find_config_files = function()
        local configdir = vim.env.HOME .. '/.config/nvim-nightly'
        telescope_builtin.find_files {
            find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden', configdir },
            previewer = false
        }
    end

    local live_grep = function()
        telescope_builtin.live_grep {}
    end

    local file_browser = function()
        telescope_builtin.file_browser {}
    end

    local buffers = function()
        telescope_builtin.buffers {
            previewer = false
        }
    end

    keymap.add('n', '<leader>ff', find_files)
end

return M

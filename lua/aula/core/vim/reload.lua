local keymap = require 'aula.core.keymap'
local Reload = {}

local function _reload()
    for k, v in pairs(package.loaded) do
        if string.match(k, '^aula') then
            package.loaded[k] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
end

function Reload.setup()
    keymap.add('n', '<leader>vs', _reload)
end

return Reload

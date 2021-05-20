local option = requre('./core.option')
local event = require('./core.event')
local ColorScheme = {}

local function _mergeDefaultOpts(opts)
    if not opts.background then
        opts.background = 'dark'
    end

    return opts
end

local function _validate(opts)
    assert(type(opts.name) == 'string' and opts.name ~= '', '[ColorScheme] `name` cannot be empty string')
end

-- @param opts table - { name, background }
function ColorScheme.setup(opts)
    xpcall(
        function()
            _validate(opts)
            opts = _mergeDefaultOpts(opts)
            option.set('background', opts.background)
            vim.cmd('colorscheme ' .. opts.name)
        end,
        function(err)
            vim.api.nvim_err_writeln(err)
        end
    )
end

-- @param fn function
function ColorScheme.custom_highlights(fn)
    event.add({ event = 'ColorScheme', cmd = fn })
end

return ColorScheme

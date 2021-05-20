local queue = require('./core.queue')
local Package = {}

function Package.init()

end

-- Add to the package manager
-- @param name string
-- @param opts table
function Package.add(name, opts)
    queue.push('packages', { [name] = opts })
end

-- Configurations to run before loading the plugin
-- @param fn function
function Package.config(fn)
    if type(fn) ~= 'function' then
        vim.api.nvim_err_writeln('[Package] `config()` argument passed is not a function')
        return
    end
end

-- Configurations to run after loading the plugin
-- @param fn function
function Package.setup(fn)
    if type(fn) ~= 'function' then
        vim.api.nvim_err_writeln('[Package] `setup()` argument passed is not a function')
        return
    end
end

return Package

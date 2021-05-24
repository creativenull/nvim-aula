local queue = require 'aula.core.queue'
local validation = require 'aula.core.validation'
local err = require 'aula.core.error'
local command = require 'aula.core.command'
local dir = require 'aula.core.fs.dir'
local uv = vim.loop

local pluginsDir = vim.env.HOME .. '/.config/nvim-aula/lua/aula/plugins'
local localDir = vim.env.HOME .. '/.local/share/nvim-aula'
local Package = {
    config = {
        pluginsDir = pluginsDir,
        localDir = localDir,
        manager = {
            name = 'packager',
            packname = 'vim-packager',
            git = 'https://github.com/kristijanhusak/vim-packager.git',
            opts = {
                dir = localDir .. '/site/pack/packager'
            }
        }
    },

    queue = {
        key = 'packages',
        depsKey = 'packages_deps'
    },

    plugins = {}
}


-- @returns string
local function _getSelfPluginName()
    local urlSplit = vim.split(Package.config.manager.git, '/')

    -- Get "<username>/<repo>.git"
    local gitName = table.concat(vim.list_slice(urlSplit, 4), '/')

    -- Get only "<username>/<repo>"
    local packageName = vim.split(gitName, '.', true)[1]
    return packageName
end

-- @param config table
local function _validate(config)
    if config == nil then
        return
    end

    vim.validate {
        pluginsDir = { config.pluginsDir, validation.typeOrNil('string', config.pluginsDir) },
        sharedDir = { config.sharedDir, validation.typeOrNil('string', config.sharedDir) },
        manager = { config.manager, validation.typeOrNil('table', config.manager) },
        ['manager.name'] = { manager.name, validation.typeOrNil('string', config.manager.name) },
        ['manager.packname'] = { manager.packname, validation.typeOrNil('string', config.manager.packname) },
        ['manager.git'] = { manager.git, validation.typeOrNil('string', config.manager.git) },
        ['manager.opts'] = { manager.opts, validation.typeOrNil('table', config.manager.opts) },
    }
end

local function _validatePackage(name, opts)
    vim.validate {
        name = { name, 'string' },
        opts = { opts, validation.typeOrNil('table', opts) }
    }
end

-- @returns string
local function _getInstallPath()
    local config = Package.config
    local path = string.format(
        '%s/site/pack/%s/opt/%s',
        config.localDir,
        config.manager.name,
        config.manager.packname
    )
    return path
end

local function _notInstalled()
    return vim.fn.isdirectory(_getInstallPath()) == 0
end

local function _loadPlugins()
    local manager = Package.config.manager
    vim.cmd('packadd ' .. manager.packname)

    require 'packager'.setup(function(packager)
        packager.add(_getSelfPluginName(), { type = 'opt' })

        -- Load dependencies
        local deps = queue.get(Package.queue.depsKey)
        for i = 1, #deps do
            local depPlugin = queue.pop(Package.queue.depsKey)
            if depPlugin.opts then
                packager.add(depPlugin.name, depPlugin.opts)
            else
                packager.add(depPlugin.name)
            end
        end

        -- Load plugins
        local plugins = queue.get(Package.queue.key)
        for i = 1, #plugins do
            local plugin = queue.pop(Package.queue.key)
            if plugin.opts then
                packager.add(plugin.name, plugin.opts)
            else
                packager.add(plugin.name)
            end
        end

        -- queue.clean(Package.queue.depsKey)
        -- queue.clean(Package.queue.key)
    end, manager.opts)
end

local function _forEachPluginCall(fn)
    local config = Package.config
    local modulepath = 'aula.plugins'
    local pluginModules = dir.getFilesAsModules(config.pluginsDir, modulepath)

    for _,module in pairs(pluginModules) do
        local plugin = require(module)
        if plugin.init == nil then
            vim.api.nvim_err_writeln('[Package] Cannot setup `' .. plugin .. '` options without `init()`')
        else
            fn(plugin)
        end
    end
end

local function _install()
    local config = Package.config
    local manager = config.manager
    print('[Package] Installing a plugin manager')
    vim.cmd(string.format('silent !git clone %s %s', manager.git, _getInstallPath()))
    print('[Package] Done!')

    -- Add the plugins and setup options before loading plugins
    _forEachPluginCall(function(plugin)
        plugin.init()
    end)

    -- Load the plugins and setup the plugin manager
    _loadPlugins()
    vim.cmd(':PackagerInstall')
end

-- @param config table
function Package.init(config)
    local tryFn = function()
        if type(config) == 'table' and not vim.tbl_isempty(config) then
            Package.config = vim.tbl_extend('force', Package.config, config)
        end

        _validate(config)

        if _notInstalled() then
            _install()
            return
        end

        -- Add the plugins and setup options before loading plugins
        _forEachPluginCall(function(plugin)
            plugin.init()
            if plugin.config ~= nil then
                plugin.config()
            end
        end)

        -- Load the plugins and setup the plugin manager
        _loadPlugins()

        -- Setup options after loading plugins
        _forEachPluginCall(function(plugin)
            if plugin.setup ~= nil then
                plugin.setup()
            end
        end)
    end

    err.handle(tryFn)
end

function Package.addDep(name, opts)
    local tryFn = function()
        _validatePackage(name, opts)
        queue.push(Package.queue.depsKey, { name = name, opts = opts })
    end

    err.handle(tryFn)
end

function Package.add(name, opts)
    local tryFn = function()
        _validatePackage(name, opts)
        queue.push(Package.queue.key, { name = name, opts = opts })
    end

    err.handle(tryFn)
end

return Package

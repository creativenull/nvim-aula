local validation = require 'aula.core.validation'
local err = require 'aula.core.error'
local command = require 'aula.core.command'
local fs_dir = require 'aula.core.fs.dir'
local uv = vim.loop
local plugins_dir = string.format('%s/.config/nvim-aula/lua/aula/plugins', vim.env.HOME)
local local_dir = string.format('%s/.local/share/nvim-aula', vim.env.HOME)
local M = {
  config = {
    plugins_dir = plugins_dir,
    local_dir = local_dir,
    manager = {
      name = 'packager',
      packname = 'vim-packager',
      git = 'https://github.com/kristijanhusak/vim-packager.git',
      opts = {
        dir = local_dir .. '/site/pack/packager'
      }
    }
  }
}

-- Get the plugin manager name to be used to
-- maintain itself
-- @returns string
local function get_plugin_manager_name()
  local datalist = vim.split(M.config.manager.git, '/')

  -- Get "<username>/<repo>.git"
  local git_repo = table.concat(vim.list_slice(datalist, 4), '/')

  -- Get only "<username>/<repo>"
  local plugin_name = vim.split(git_repo, '.', true)[1]
  return plugin_name
end

-- Validate config options
-- @param config table
local function validate(config)
  if config == nil then
    return
  end

  assert(validation.type_or_nil('string', config.plugins_dir), '[Aula Package] Invalid `plugins_dir`')
  assert(validation.type_or_nil('string', config.shared_dir), '[Aula Package] Invalid `shared_dir`')
  assert(validation.type_or_nil('string', config.manager), '[Aula Package] Invalid `manager`')
  assert(validation.type_or_nil('string', config.manager.name), '[Aula Package] Invalid `manager.name`')
  assert(validation.type_or_nil('string', config.manager.packname), '[Aula Package] Invalid `manager.packname`')
  assert(validation.type_or_nil('string', config.manager.git), '[Aula Package] Invalid `manager.git`')
  assert(validation.type_or_nil('string', config.manager.opts), '[Aula Package] Invalid `manager.opts`')
end

local function validate_pkg(name, opts)
  assert(type(name) == 'string' and name ~= '', '[Aula Package] Cannot add empty plugin name')
  assert(type(opts) == 'table' or opts == nil, '[Aula Package] Plugin opts must be table')
end

-- Get the install path of plugin manager
-- @returns string
local function get_plugin_manager_installpath()
  local config = M.config
  local manager = config.manager
  local path = string.format('%s/site/pack/%s/opt/%s', config.local_dir, manager.name, manager.packname)
  return path
end

-- Check if the plugin manager is installed
-- @returns boolean
local function is_plugin_manager_installed()
  return vim.fn.isdirectory(get_plugin_manager_installpath()) > 0
end

-- Load all the plugins listed in the config.plugins_dir directory
local function load_plugins()
  local manager = M.config.manager
  vim.api.nvim_command('packadd ' .. manager.packname)

  require 'packager'.setup(function(packager)
    packager.add(get_plugin_manager_name(), { type = 'opt' })

    -- Load dependencies
    local plugin_deps = _G.aula.package.plugin_deps
    for _,plugin_dep in pairs(plugin_deps) do
      if plugin_dep.opts then
        packager.add(plugin_dep.name, plugin_dep.opts)
      else
        packager.add(plugin_dep.name)
      end
    end

    -- Load plugins
    local plugins = _G.aula.package.plugins
    for _,plugin in pairs(plugins) do
      if plugin.opts then
        packager.add(plugin.name, plugin.opts)
      else
        packager.add(plugin.name)
      end
    end
  end, manager.opts)
end

-- Run a function for each plugin loaded from the
-- config.plugins_dir directory
-- @param callback function
local function for_each_plugin(callback)
  local config = M.config
  local modulepath = 'aula.plugins'
  local plugins = fs_dir.get_files_as_modules(config.plugins_dir, modulepath)

  for _,module in pairs(plugins) do
    local success, plugin = pcall(require, module)
    if not success or type(plugin) ~= 'table' then
      vim.api.nvim_err_writeln(string.format('[Aula Package] `%s` not setup properly', module))
    else
      if plugin.init == nil then
        vim.api.nvim_err_writeln(
          string.format('[Aula Package] Cannot setup `%s` options without `init()`', module)
        )
      else
        callback(plugin)
      end
    end
  end
end

-- Install the plugin manager
local function install_manager()
  local config = M.config
  local manager = config.manager
  print('[Aula Package] Installing a plugin manager')
  vim.api.nvim_command(string.format('silent !git clone %s %s', manager.git, get_install_path()))
  print('[Aula Package] Done!')

  -- Add the plugins and setup options before loading plugins
  for_each_plugin(function(plugin)
    plugin.init()
  end)

  -- Load the plugins and setup the plugin manager
  load_plugins()
  vim.api.nvim_command(':PackagerInstall')
end

-- Initialize the package module to setup plugins
-- @param config table
function M.init(config)
  local try_fn = function()
    if type(config) == 'table' and not vim.tbl_isempty(config) then
      M.config = vim.tbl_extend('force', M.config, config)
    end

    validate(config)

    if not is_plugin_manager_installed() then
      install_manager()
      return
    end

    -- Add the plugins and setup options before loading plugins
    for_each_plugin(function(plugin)
      plugin.init()
      if plugin.config ~= nil then
        plugin.config()
      end
    end)

    -- Load the plugins and setup the plugin manager
    load_plugins()

    -- Setup options after loading plugins
    for_each_plugin(function(plugin)
      if plugin.setup ~= nil then
        plugin.setup()
      end
    end)
  end

  err.handle(try_fn)
end

-- Add a plugin dependency of a plugin
-- @param name string
-- @param opts table
function M.add_dependency(name, opts)
  local try_fn = function()
    validate_pkg(name, opts)
    table.insert(_G.aula.package.plugin_deps, { name = name, opts = opts })
  end

  err.handle(try_fn)
end

-- Alias, so we type less
M.add_dep = M.add_dependency

-- Add a plugin
-- @param name string
-- @param opts table
function M.add(name, opts)
  local try_fn = function()
    validate_pkg(name, opts)
    table.insert(_G.aula.package.plugins, { name = name, opts = opts })
  end

  err.handle(try_fn)
end

return M

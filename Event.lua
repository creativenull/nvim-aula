local DEFAULT_CONFIG = {
  group = 'creativenull_events'
}
local Event = {
  config = {},
  events = {}
}

-- Build the autocmd command
--
-- @param opts table - { group, event, pattern, once, cmd }
-- @return table
local function makeAutoCmd(opts)
  assert(type(opts) == 'table', '[event_autocmd_maker] `opts` must be table')
  assert(type(opts.group) == 'string', '[event_autocmd_maker] `opts.group` must be string')
  assert(type(opts.event) == 'string', '[event_autocmd_maker] `opts.event` must be string')
  assert(type(opts.pattern) == 'string', '[event_autocmd_maker] `opts.pat` must be string')
  assert(type(opts.once) == 'boolean', '[event_autocmd_maker] `opts.once` must be boolean')
  assert(type(opts.cmd) == 'string', '[event_autocmd_maker] `opts.cmd` must be string')

  local onceOpt = ''
  if once then
    onceOpt = '++once'
  end

  local autocmd = string.format('autocmd! %s %s %s %s %s', opts.group, opts.event, opts.pattern, onceOpt, opts.cmd)
  autocmd = vim.trim(autocmd)

  return autocmd
end

-- Set defaults for the Event:set() function
--
-- @param opts table - { event, pattern, once, cmd }
-- @return table
local function makeSetDefaults(opts)
  assert(type(opts.event) == 'string', '[event_set_maker] `opts.event` must be string')
  assert(
    type(opts.cmd) == 'string' or type(opts.cmd) == 'function',
    '[event_set_maker] `opts.cmd` must be string or function'
  )

  if opts.pattern == nil then
    opts.pattern = '*'
  end

  if opts.once == nil then
    opts.once = false
  end

  return opts
end

-- Initialize config for events
--
-- @param config table - { group }
function Event:init(config)
  if config == nil or vim.tbl_isempty(config) then
    config = DEFAULT_CONFIG
  end

  self.config = config
end

-- Register all the events defined from set()
function Event:setup()
  _G[self.config.group] = self.events

  -- Attach the list of autocmds to the group
  vim.cmd('augroup ' .. self.config.group)
  vim.cmd('au!')
  for event,handlers in pairs(_G[self.config.group]) do
    for _,handle in pairs(handlers) do
      vim.cmd(handle.cmd)
    end
  end
  vim.cmd('augroup end')
end

-- Define the events to be registered via init()
-- @param opts table - { event, pattern, once, cmd }
function Event:set(opts)
  if type(opts) ~= 'table' then
    vim.api.nvim_err_writeln('[Event] `opts` must be a table')
    return
  end

  -- Default opts
  -- Safe calls to make sure we don't stop execution of other commands
  local success, results = pcall(makeSetDefaults, opts)
  if not success then
    vim.api.nvim_err_writeln(results)
    return
  end

  opts = results

  -- Set to empty array if not set
  if self.events[opts.event] == nil then
    self.events[opts.event] = {}
  end

  if type(opts.cmd) == 'string' then
    -- Safe calls to make sure we don't stop execution of other commands
    local success, results = pcall(makeAutoCmd, {
      group = self.config.group,
      event = opts.event,
      pattern = opts.pattern,
      once = opts.once,
      cmd = opts.cmd
    })
    if not success then
      vim.api.nvim_err_writeln(results)
      return
    end

    local autocmd = results
    table.insert(self.events[opts.event], { handler = nil, cmd = autocmd })
  elseif type(opts.cmd) == 'function' then
    -- Assume the next item will be iterated by 1 - bad assumption, maybe a TODO?
    local lastItem = #self.events[opts.event] + 1

    -- Safe calls to make sure we don't stop execution of other commands
    local success, results = pcall(makeAutoCmd, {
      group = self.config.group,
      event = opts.event,
      pattern = opts.pattern,
      once = opts.once,
      cmd = string.format('lua _G.%s.%s[%d].handler()', self.config.group, opts.event, lastItem)
    })
    if not success then
      vim.api.nvim_err_writeln(results)
      return
    end

    local autocmd = results
    table.insert(self.events[opts.event], { handler = opts.cmd, cmd = autocmd })
  end
end

return Event

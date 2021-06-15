# Neovim Aula

A simple neovim config framework written in lua.

## Quick Note

**This is highly experimental and not ready for use yet as it is something I am actively developing on, at this point
this repo is setup to work in my environment, separate from the actual nvim config and data directories.**

## Description

Aula is a neovim config framework for nvim nightly (v0.5 and above) built to help you create your own configuration and
provide you with the APIs to properly setup your options, keymaps, commands etc.

With the introduction of lua support in nvim nightly, it is now possible to write plugins in a faster language, we can
also leverage that into our custom nvim configuations. However, when you write lua code, you may start making
syntactical or runtime mistakes which effectively stops the execution of lua code afterwards. This means that, for
example, if you had some keymaps (maybe to open the config file itself, or some telescope.nvim keymap) that were set
after the line where the error happened, you are now stuck with nvim with no keymaps available and therefore have to
access your config file and other files inside your `~/.config/nvim` folder through default methods to fix the issue
mistake.

Aula solves this problem by making sure that the code you write doesn't affect your config in any way possible.
Thereby, allowing you to make mistakes and then easily fix them without you experiencing your keymaps reset or
colorscheme being set to default every time you hit an error while working on your config 🙂

## Getting Started

The main goal of Aula is to provide you with proper APIs to be able to write your config in a more organized manner.
Therefore, the folder structure is very important to note when it comes to writing your config with Aula.

```
├── lua
│   └── aula
│       ├── core
│       ├── plugins
│       ├── user
│       ├── config.lua
│       └── init.lua
├── init.lua
└── README.md
```

Under `lua/aula/core` is where you will find all the Aula APIs that will be used to write your config, which will be
done inside the `lua/aula/user` directory. Finally, `lua/aula/plugins` is where you will add your plugins as filenames,
these files can be named with each plugin or you can group a list of plugins into one file. For example, you may want
to have all the LSP plugins into `lua/aula/plugins/lsp.lua` file, and don't need the hassle to write a `lspconfig.lua`,
`compe.lua`, or `lsp-status.lua` for each plugin.

Within the `user/` directory it's **REQUIRED** to have an `user/init.lua` file that will be exposed to Aula to load.
In the `plugins/` directory, however, there is no need to have a `plugins/init.lua` file, as the files will be
automatically be loaded by Aula and be loaded before your `user/init.lua` is loaded. *Note:* directories inside the
`plugins` directory will **NOT** be loaded, it's up to the files in the `plugins` directory to explicitly require them.

Let's start by taking a look at the core APIs that will be used to create your user config inside the `user` and
`plugins` directory.

## Core

There are 6 core modules you can user to generate your user config, and install plugins.

1. Option
2. Keymap
3. Event (autocmds)
4. Theme
5. Module
6. Package

### Option

```lua
local opt = require 'aula.core.option'
```

The `option` module gives you the functionality to set your vim options (`:h options`), this is equivalent to setting
your options using `vim.o`, `vim.wo` and `vim.bo`, but combined into one.

#### Set an option

To set an option:

```lua
opt.set(name, value)

-- Example
opt.set('colorcolumn', '100')
```

To set multiple options:

```lua
opt.set {
  option = value,
  anotheroption = value
}

-- Example
opt.set {
  tabstop = 4,
  softtabstop = 4,
  shiftwith = 4
}
```

#### Append, prepend and remove from option

You can also `append`, `prepend` and `remove` a value in an option, if it is comma separated, or set of flags. This
only works on options that are a commalist or a flaglist and are global options, at this point.

```lua
-- Examples
opt.append('shortmess', 'c')

opt.prepend('completeopt', 'noselect')

opt.remove('runtimepath', '/etc/xdg/nvim')
```

### Keymap

```lua
local keymap = require 'aula.core.keymap'
```

The `keymap` module is used to define your global keymaps (`:h key-mapping`) which is very similar to setting a keymap
using `vim.api.nvim_set_keymap()` (`:h nvim_set_keymap`). There are two variations to setting a
keymap:

+ `keymap.set(mode, lhs, rhs, opts)` - add the keymap instantly, the **recommended way** of setting a keymap
+ `keymap.add(mode, lhs, rhs, opts)` - add the keymap into a queue that will be sourced after your user config

You can also set your `<leader>` and `<localleader>` with the `keymap` module (a wrapper to `vim.g.mapleader` and
`vim.g.maplocalleader`, nothing is stopping you from using those instead), by default `<leader>` is <kbd>Space</kbd>
and `<localleader>` is <kbd>,</kbd>:

```lua
keymap.set_leader(' ')
keymap.set_localleader(',')
```

The right-hand-side (`rhs`) argument on setting a keymap can be a `string` or a `function`:

```lua
keymap.set('n', '<leader>ff', 'echom "Hello World from vimL"')

-- OR

keymap.set('n', '<leader>ff', function() print('Hello World from lua') end)
```

By default `opts` are set to `{ noremap = true, silent = true }` which is equivalent to setting a keymap with
`*noremap <silent> ...` where `*` is the mode (`mode`).

### Event

```lua
local event = require 'aula.core.event'
```

The `event` module is used to register events, also known as autocmds, to execute some command or function when that
event is called (`:h events`), at this point there is no official API from nvim nightly so it is a wrapper to running
the actual autocmd (`:h :autocmd`) command within an autogroup (`:h :autogroup`) using `vim.api.nvim_command()`
(`:h nvim_command`). There are three different variations to registering an event:

+ `event.add({ event, pattern, once, cmd })` - add the event into a queue that will be executed after user config, the
  **recommended** way to registering an event
+ `event.set({ event, pattern, once, cmd })` - add the event instantly using `autocmd!` without a group
+ `event.set_group(name, array of { event, pattern, once, cmd })` - add the event instantly but within a different
  `augroup` name. For advanced use only if you know what you are doing

Here are couple examples:

```lua
-- When entering a lua file, set the tab spacing to 2 and use actual spaces
event.add {
  event = 'FileType',
  pattern = 'lua',
  cmd = 'setlocal tabstop=2 softtabstop=2 shiftwidth=0 expandtab'
}
-- OR
local opt = require 'aula.core.option'
event.add {
  event = 'FileType',
  pattern = 'lua',
  cmd = function()
    opt.set { tabstop = 2, softtabstop = 2, shiftwidth = 0, expandtab = true }
  end
}

-- When entering into nvim, print out a message on the command line
event.add {
  event = 'VimEnter',
  cmd = function()
    print('Entered into nvim')
  end
}
```

The `event` and `cmd` keys are **required**, `cmd` can be a `string` or a `function`, `pattern` is set to `*` and
`once` is set to `false`, by default.




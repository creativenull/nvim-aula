local module = require 'aula.core.module'

-- Safely load user-defined modules, if fails then stop execution
module.load 'aula.user.options'
module.load 'aula.user.keymaps'
module.load 'aula.user.theme'
module.load 'aula.user.commands'

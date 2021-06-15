local module = require 'aula.core.module'

-- Safely load user-defined modules, if fails then stop execution
module.load('aula.user.options.completion')
module.load('aula.user.options.editor')
module.load('aula.user.options.system')
module.load('aula.user.options.ui')

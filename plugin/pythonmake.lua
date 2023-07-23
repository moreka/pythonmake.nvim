local maker = require "pythonmake.make"
vim.api.nvim_create_user_command("PyMake", maker.make, {})

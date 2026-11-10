-- Entry point. Load order matters: plain Neovim settings first, then plugins, and plugin
-- keymaps last (inside tan.plugins) so every plugin is set up before a key uses it.
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("tan.config.options")
require("tan.config.keymaps")
require("tan.config.autocmds")
require("tan.config.commands")
require("tan.plugins")

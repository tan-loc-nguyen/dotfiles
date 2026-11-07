-- Every plugin, installed by Neovim's built-in vim.pack in one call
-- (`:lua vim.pack.update()` to update). Group files only call setup(); all plugin keymaps
-- are in keymaps.lua, required last.
local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- UI
	{ src = gh("catppuccin/nvim"), name = "catppuccin" },
	{ src = gh("nvim-mini/mini.icons") },
	{ src = gh("folke/snacks.nvim") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("b0o/incline.nvim") },
	{ src = gh("rachartier/tiny-cmdline.nvim") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("brenoprata10/nvim-highlight-colors") },
	{ src = gh("folke/which-key.nvim") },
}, { confirm = false })

require("tan.plugins.ui")
require("tan.plugins.keymaps")

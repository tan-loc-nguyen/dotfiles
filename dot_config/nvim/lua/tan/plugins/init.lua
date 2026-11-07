-- Every plugin, installed by Neovim's built-in vim.pack in one call
-- (`:lua vim.pack.update()` to update). Group files only call setup(); all plugin keymaps
-- are in keymaps.lua, required last.
local function gh(repo)
	return "https://github.com/" .. repo
end

-- Build steps after install/update. Registered before vim.pack.add so first installs run them.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "markdown-preview.nvim" and (kind == "install" or kind == "update") then
			vim.cmd.packadd(name)
			vim.fn["mkdp#util#install"]() -- downloads the preview server binary
		end
	end,
})

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
	-- Editor
	{ src = gh("stevearc/oil.nvim") },
	{ src = gh("refractalize/oil-git-status.nvim") },
	{ src = gh("nvim-mini/mini.pairs") },
	{ src = gh("iamcco/markdown-preview.nvim") },
	-- Git
	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("esmuellert/codediff.nvim") }, -- note: other repos share this name
}, { confirm = false })

require("tan.plugins.ui")
require("tan.plugins.editor")
require("tan.plugins.git")
require("tan.plugins.keymaps")

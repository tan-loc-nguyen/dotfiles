-- Syntax: nvim-treesitter (main branch) only installs parsers; Neovim does the highlighting.
local parsers = {
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"git_config",
	"gitcommit",
	"git_rebase",
	"gitignore",
	"go",
	"gomod",
	"gosum",
	"html",
	"javascript",
	"jsdoc",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"prisma",
	"python",
	"query",
	"regex",
	"sql",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

-- Missing parsers are installed in the background (needs tree-sitter CLI + a C compiler)
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		if pcall(vim.treesitter.start, ev.buf) then
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- Every treesitter parser from decision log §3.10 must be installed and loadable.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")

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

t.run("parsers", function()
	-- Installs are async on first start; wait for them (no-op when already installed).
	require("nvim-treesitter").install(parsers):wait(300000)
	for _, lang in ipairs(parsers) do
		t.ok(pcall(vim.treesitter.language.add, lang) and vim.treesitter.language.add(lang), "parser missing: " .. lang)
	end
end)

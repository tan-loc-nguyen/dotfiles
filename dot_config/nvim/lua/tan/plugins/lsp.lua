-- Language servers, completion and formatting (decision log §3.6, §3.7, §3.10).
-- Servers come from Mason (installed automatically on first start); per-server settings
-- live in after/lsp/<name>.lua.

require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- language servers
		"vtsls",
		"eslint-lsp",
		"oxlint",
		"biome",
		"ty",
		"ruff",
		"gopls",
		"prisma-language-server",
		"sqls",
		"bash-language-server",
		"lua-language-server",
		"json-lsp",
		"yaml-language-server",
		-- formatters / linters used by conform and bashls
		"prettierd",
		"prettier",
		"oxfmt",
		"goimports",
		"shfmt",
		"shellcheck",
		"stylua",
	},
})

-- eslint / oxlint / biome only attach when the project has their config file
-- (nvim-lspconfig's root rules), so enabling them everywhere is safe.
vim.lsp.enable({
	"vtsls",
	"eslint",
	"oxlint",
	"biome",
	"ty",
	"ruff",
	"gopls",
	"prismals",
	"sqls",
	"bashls",
	"lua_ls",
	"jsonls",
	"yamlls",
})

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = { nerd_font_variant = "mono" },
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	completion = {
		documentation = { auto_show = true },
		menu = { draw = { treesitter = { "lsp" } } }, -- syntax-colored completion items
	},
	signature = { enabled = true }, -- parameter hints pop up while typing a call
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
local format = require("tan.utils.format")
require("conform").setup({
	formatters_by_ft = {
		-- "_" = every filetype: ask the per-project policy
		["_"] = function(bufnr)
			local list = format.formatters_for(bufnr)
			list.stop_after_first = true
			return list
		end,
	},
	format_on_save = function(bufnr)
		if #format.formatters_for(bufnr) == 0 then
			return nil -- project declares no formatter: leave the file alone
		end
		return { timeout_ms = 1000 }
	end,
})

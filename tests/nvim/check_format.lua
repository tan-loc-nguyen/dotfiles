-- Format-on-save policy (spec §5.4): use only the formatter a project declares; Go always
-- uses goimports; no declared formatter → nothing runs on save.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")
local dir = vim.env.TESTS_DIR .. "/fixtures/format/"
local prettier = { "prettierd", "prettier" }

local cases = {
	{ "prettier/a.ts", prettier },
	{ "pkgprettier/a.ts", prettier }, -- "prettier" key in package.json
	{ "pkgdep/a.ts", {} }, -- prettier only as a devDependency: not a config
	{ "prettier/a.vue", prettier },
	{ "biome/a.vue", {} }, -- biome only formats Vue's <script> part: not trusted with .vue
	{ "nested/packages/a/src/a.ts", prettier }, -- config in a parent folder (monorepo)
	{ "prettier-md/a.md", prettier },
	{ "monorepo-pkg/packages/a/src/a.ts", prettier }, -- "prettier" key in the ROOT package.json
	{ "uv-ws/packages/m/a.py", { "ruff_format" } }, -- [tool.ruff] in the workspace root pyproject
	{ "biome-lintonly/a.ts", prettier }, -- biome with formatter disabled → prettier formats
	{ "biome-lintonly-noprettier/a.ts", {} },
	{ "oxfmt/a.ts", { "oxfmt" } },
	{ "biome/a.ts", { "biome" } },
	{ "none/a.ts", {} },
	{ "none/a.md", {} },
	{ "go/main.go", { "goimports" } },
	{ "ruff/a.py", { "ruff_format" } },
	{ "pyproject-noruff/a.py", {} }, -- pyproject.toml without [tool.ruff]
	{ "nopy/a.py", {} },
	{ "shfmt/a.sh", { "shfmt" } },
	{ "nosh/a.sh", {} },
	{ "stylua/a.lua", { "stylua" } },
	{ "nolua/a.lua", {} },
}

t.run("format", function()
	local format = require("tan.utils.format")
	for _, c in ipairs(cases) do
		vim.cmd.edit(dir .. c[1])
		local got = format.formatters_for(0)
		t.eq(table.concat(got, ","), table.concat(c[2], ","), c[1])
	end

	-- conform is wired to the policy: no-config file → no formatter would run
	vim.cmd.edit(dir .. "none/a.ts")
	t.eq(#require("conform").list_formatters_to_run(0), 0, "conform runs nothing for none/a.ts")
	t.ok(vim.fn.maparg("<leader>cf", "n") ~= "", "<leader>cf manual format exists")

	-- <leader>cf runs only the first available formatter of the list (prettierd OR prettier)
	local conform = require("conform")
	local real_format, seen = conform.format, nil
	conform.format = function(opts)
		seen = opts
	end
	vim.cmd.edit(dir .. "prettier/a.ts")
	vim.api.nvim_feedkeys(vim.keycode("<leader>cf"), "x", false)
	conform.format = real_format
	t.eq(seen and seen.stop_after_first, true, "<leader>cf stops after the first formatter")
end)

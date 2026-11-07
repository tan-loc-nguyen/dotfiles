-- Format-on-save policy (spec §5.4): use only the formatter a project declares; Go always
-- uses goimports; no declared formatter → nothing runs on save.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")
local dir = vim.env.TESTS_DIR .. "/fixtures/format/"
local prettier = { "prettierd", "prettier" }

local cases = {
	{ "prettier/a.ts", prettier },
	{ "pkgprettier/a.ts", prettier }, -- "prettier" key in package.json
	{ "nested/packages/a/src/a.ts", prettier }, -- config in a parent folder (monorepo)
	{ "prettier-md/a.md", prettier },
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
end)

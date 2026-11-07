-- Language servers attach to sample files, LSP keymaps exist in attached buffers, and
-- SchemaStore validates a GitHub Actions workflow. Needs Mason installs (skipped on --cold).
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")
local dir = vim.env.TESTS_DIR .. "/fixtures/lsp/"

local cases = {
	{ "app.ts", "vtsls" },
	{ "main.go", "gopls" },
	{ "main.py", "ty" },
	{ "init.lua", "lua_ls" },
	{ "package.json", "jsonls" },
	{ ".github/workflows/ci.yml", "yamlls" },
}

local buffer_keys = { "gd", "gD", "grr", "gri", "grt", "<C-k>", "<leader>cr", "<leader>ca", "<leader>ci" }

local function attached(name)
	return vim.wait(30000, function()
		return #vim.lsp.get_clients({ bufnr = 0, name = name }) > 0
	end, 200)
end

t.run("lsp", function()
	for _, c in ipairs(cases) do
		vim.cmd.edit(dir .. c[1])
		t.ok(attached(c[2]), ("%s did not attach to %s"):format(c[2], c[1]))
	end

	vim.cmd.edit(dir .. "app.ts")
	attached("vtsls")
	for _, lhs in ipairs(buffer_keys) do
		t.ok(vim.fn.maparg(lhs, "n") ~= "", "missing LSP keymap in attached buffer: " .. lhs)
	end

	-- The workflow has a typo'd top-level key; the schema must flag it.
	vim.cmd.edit(dir .. ".github/workflows/ci.yml")
	attached("yamlls")
	local flagged = vim.wait(30000, function()
		return #vim.diagnostic.get(0) > 0
	end, 200)
	t.ok(flagged, "yamlls + SchemaStore reported no diagnostics for the invalid workflow")
end)

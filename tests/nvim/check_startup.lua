-- Startup must be clean: no error messages, and :checkhealth has no ERROR for the core
-- providers this config depends on.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")

t.run("startup", function()
	local messages = vim.fn.execute("messages")
	t.ok(
		not messages:find("E%d+:") and not messages:lower():find("error"),
		"startup messages contain an error:\n" .. messages
	)

	t.ok(
		vim.g.colors_name == "catppuccin-mocha" or vim.g.colors_name == "catppuccin",
		"colorscheme is catppuccin, got " .. tostring(vim.g.colors_name)
	)

	vim.cmd("checkhealth vim.pack vim.lsp vim.treesitter")
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local errors = {}
	for _, l in ipairs(lines) do
		if l:find("ERROR") then
			table.insert(errors, l)
		end
	end
	t.ok(#errors == 0, "checkhealth ERROR lines:\n" .. table.concat(errors, "\n"))
end)

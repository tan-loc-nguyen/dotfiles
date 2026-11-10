-- UI details: the tabline survives odd file names, and the active-window cursorline
-- leaves floating windows (pickers, oil float, which-key) to their plugins.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")

t.run("ui", function()
	-- `%` in a file name must not be read as a tabline format code
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. "/100%_done.md")
	vim.api.nvim_set_current_buf(buf)
	vim.cmd("tabnew")
	local ok, res = pcall(vim.api.nvim_eval_statusline, require("tan.utils.tabline").render(), { use_tabline = true })
	t.ok(ok, "tabline renders a name with %: " .. tostring(res))
	t.ok(ok and res.str:find("100%_done.md", 1, true) ~= nil, "tabline shows 100%_done.md")
	vim.cmd("tabonly")

	-- normal window gets cursorline; entering a float doesn't force it on
	vim.cmd("enew")
	t.eq(vim.wo.cursorline, true, "normal window: cursorline on")
	local fbuf = vim.api.nvim_create_buf(false, true)
	local float = vim.api.nvim_open_win(fbuf, true, { relative = "editor", row = 1, col = 1, width = 20, height = 3 })
	vim.wo[float].cursorline = false -- what a plugin would set
	vim.api.nvim_exec_autocmds("WinEnter", {})
	vim.api.nvim_exec_autocmds("BufEnter", {})
	t.eq(vim.wo[float].cursorline, false, "float: cursorline left as the plugin set it")
	vim.api.nvim_win_close(float, true)
end)

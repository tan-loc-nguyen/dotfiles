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

	-- an oil listing is labelled by its folder in the tabline and the incline tag
	vim.cmd.edit("oil://" .. vim.fn.fnamemodify("lsp", ":p"))
	vim.wait(5000, function()
		return vim.bo.filetype == "oil"
	end, 50)
	t.eq(require("tan.utils.editor").buf_label(0), "lsp/", "oil buffer label")
	-- Cmd+P (Ghostty sends <C-p>) finds files in oil too; oil's preview moves to gp
	t.eq(vim.fn.maparg("<C-p>", "n", false, true).desc, "Find files", "oil: <C-p> is the file finder")
	t.eq(vim.fn.maparg("gp", "n", false, true).buffer, 1, "oil: gp is oil's preview")
	for _, c in ipairs({ { "oil:///", "/" }, { "oil-trash:///", "trash/" }, { "oil-ssh://host//srv/app/", "app/" } }) do
		local b = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(b, c[1])
		t.eq(require("tan.utils.editor").buf_label(b), c[2], "label for " .. c[1])
	end
	vim.cmd("tabnew")
	local ok_oil, res_oil =
		pcall(vim.api.nvim_eval_statusline, require("tan.utils.tabline").render(), { use_tabline = true })
	t.ok(ok_oil and res_oil.str:find("lsp/", 1, true) ~= nil, "tabline labels the oil tab lsp/")
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
	vim.wo[float].cursorline = true -- e.g. a picker list highlights its current item
	vim.api.nvim_exec_autocmds("WinLeave", {})
	t.eq(vim.wo[float].cursorline, true, "float: leaving it keeps the plugin's cursorline")
	vim.api.nvim_win_close(float, true)
end)

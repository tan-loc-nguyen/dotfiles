-- <leader>bh (close hidden buffers) must close listed buffers not shown in any window,
-- keep visible ones, and never close a buffer with unsaved changes.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")

t.run("buffers", function()
	local editor = require("tan.utils.editor")
	vim.cmd("enew")
	local visible = vim.api.nvim_get_current_buf()
	vim.cmd("badd /tmp/tan-hidden-a.txt | badd /tmp/tan-hidden-b.txt")
	local hidden_a = vim.fn.bufnr("/tmp/tan-hidden-a.txt")
	local modified = vim.fn.bufnr("/tmp/tan-hidden-b.txt")
	vim.fn.bufload(modified)
	vim.api.nvim_buf_set_lines(modified, 0, -1, false, { "unsaved" })

	local deleted, skipped = editor.delete_hidden_buffers()

	t.ok(vim.api.nvim_buf_is_valid(visible) and vim.bo[visible].buflisted, "visible buffer kept")
	t.ok(not vim.api.nvim_buf_is_valid(hidden_a) or not vim.bo[hidden_a].buflisted, "hidden buffer closed")
	t.ok(vim.api.nvim_buf_is_valid(modified) and vim.bo[modified].buflisted, "unsaved hidden buffer kept")
	t.eq(deleted, 1, "deleted count")
	t.eq(skipped, 1, "skipped (unsaved) count")
end)

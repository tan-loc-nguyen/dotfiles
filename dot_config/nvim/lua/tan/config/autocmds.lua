local group = vim.api.nvim_create_augroup("tan", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Flash yanked text
autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Cursorline only in the active window. Floating windows (pickers, oil float, which-key)
-- keep whatever their plugin set.
autocmd({ "WinEnter", "BufEnter" }, {
	group = group,
	callback = function()
		if vim.api.nvim_win_get_config(0).relative == "" then
			vim.wo.cursorline = true
		end
	end,
})
autocmd("WinLeave", {
	group = group,
	callback = function()
		if vim.api.nvim_win_get_config(0).relative == "" then
			vim.wo.cursorline = false
		end
	end,
})

-- Reload files changed outside nvim (agents edit files while you read them)
autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	group = group,
	command = "if mode() != 'c' | checktime | endif",
})

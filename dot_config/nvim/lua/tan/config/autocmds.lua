local group = vim.api.nvim_create_augroup("tan", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Flash yanked text
autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Cursorline only in the active window
autocmd({ "WinEnter", "BufEnter" }, {
	group = group,
	callback = function()
		vim.wo.cursorline = true
	end,
})
autocmd("WinLeave", {
	group = group,
	callback = function()
		vim.wo.cursorline = false
	end,
})

-- Reload files changed outside nvim (agents edit files while you read them)
autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	group = group,
	command = "if mode() != 'c' | checktime | endif",
})

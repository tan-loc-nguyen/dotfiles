local M = {}

--- Short label for a buffer: its file name, "folder/" for an oil listing, or "[No Name]".
---@return string
function M.buf_label(buf)
	local name = vim.api.nvim_buf_get_name(buf == 0 and vim.api.nvim_get_current_buf() or buf)
	local scheme, path = name:match("^(oil[%w-]*)://(.*)$")
	if scheme then
		local folder = vim.fs.basename((path:gsub("/+$", "")))
		if folder ~= "" then
			return folder .. "/"
		end
		return scheme == "oil-trash" and "trash/" or "/"
	end
	name = vim.fn.fnamemodify(name, ":t")
	return name ~= "" and name or "[No Name]"
end

--- Close every listed buffer that isn't shown in any window. Unsaved buffers are skipped.
---@return integer deleted, integer skipped
function M.delete_hidden_buffers()
	local visible = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		visible[vim.api.nvim_win_get_buf(win)] = true
	end

	local deleted, skipped = 0, 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and not visible[buf] then
			if vim.bo[buf].modified then
				skipped = skipped + 1
			else
				vim.api.nvim_buf_delete(buf, {})
				deleted = deleted + 1
			end
		end
	end

	local msg = ("Closed %d hidden buffer%s"):format(deleted, deleted == 1 and "" or "s")
	if skipped > 0 then
		msg = msg .. (" (%d unsaved kept)"):format(skipped)
	end
	vim.notify(msg)
	return deleted, skipped
end

return M

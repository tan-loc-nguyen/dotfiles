-- Minimal tabline: only shown with 2+ tabs (showtabline=1, Neovim's default), e.g. while a
-- CodeDiff review tab is open. Active tab: bold dark text on yellow. Unsaved tabs show [+].
local M = {}

function M.render()
	local parts = {}
	local current = vim.fn.tabpagenr()
	for nr = 1, vim.fn.tabpagenr("$") do
		local win = vim.fn.tabpagewinnr(nr)
		local buf = vim.fn.tabpagebuflist(nr)[win]
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		if name == "" then
			name = "[No Name]"
		end
		local icon = MiniIcons.get("file", name)
		local modified = vim.bo[buf].modified and "[+] " or ""
		local hl = nr == current and "%#TanTabActive#" or "%#TanTabInactive#"
		table.insert(parts, ("%s%%%dT %s%s %s %%T"):format(hl, nr, modified, icon, name))
	end
	return table.concat(parts) .. "%#TabLineFill#"
end

function M.setup()
	local p = require("catppuccin.palettes").get_palette("mocha")
	local function set_hl()
		vim.api.nvim_set_hl(0, "TanTabActive", { fg = p.crust, bg = p.yellow, bold = true })
		vim.api.nvim_set_hl(0, "TanTabInactive", { fg = p.subtext0, bg = p.surface0 })
	end
	set_hl()
	vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
	vim.o.tabline = "%!v:lua.require'tan.utils.tabline'.render()"
end

return M

-- Navigation & editing helpers (decision log §3.1, §3.5). Setup only.

-- The picker and the lazygit float come from snacks (one setup call, in ui.lua).

require("oil").setup({
	default_file_explorer = true,
	columns = { "icon" },
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = { show_hidden = true },
	win_options = { signcolumn = "yes:2" }, -- room for oil-git-status
	-- <C-p> stays the file finder (Ghostty Cmd+P); oil's preview moves to gp
	keymaps = { q = "actions.close", ["<C-p>"] = false, gp = "actions.preview" },
})
require("oil-git-status").setup()

require("mini.pairs").setup()

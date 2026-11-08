-- Look & feel (decision log §2.2). Setup only — keymaps live in keymaps.lua.

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true, -- Ghostty provides the blurred background
	styles = { comments = { "italic" }, functions = { "bold" } },
	-- auto_integrations (default on) picks up gitsigns, snacks, which-key, blink, etc.
})
vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- plugins asking for nvim-web-devicons get mini.icons

require("snacks").setup({
	notifier = { enabled = true },
	indent = { enabled = true },
	words = { enabled = true }, -- highlight other uses of the symbol under the cursor
	-- [diagnostic/mark] [number] [git/fold]: git signs never hidden by diagnostics
	statuscolumn = { enabled = true, left = { "mark", "sign" }, right = { "fold", "git" } },
	picker = { enabled = true }, -- <leader>f* finders (keymaps.lua)
	lazygit = { enabled = true }, -- lazygit in a float
})

-- Floating ':' box, centered in the window (search keeps the native bottom line).
-- The blink adapter keeps blink's ':' completion menu attached to the box.
require("tiny-cmdline").setup({
	position = { x = "50%", y = "50%" },
	on_reposition = require("tiny-cmdline").adapters.blink,
})

local function macro()
	local reg = vim.fn.reg_recording()
	return reg ~= "" and ("@" .. reg) or ""
end

local function project_root()
	local root = vim.fs.root(0, ".git") or vim.uv.cwd()
	return vim.fs.basename(root)
end

require("lualine").setup({
	options = { theme = "auto", globalstatus = true },
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = {
			{ project_root, icon = "" },
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{ "filename", path = 1 },
		},
		-- cmdheight=0 hides Vim's "recording @q" message, so the bar must show it
		lualine_x = { macro, "diagnostics", "diff" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	callback = function()
		vim.schedule(require("lualine").refresh)
	end,
})

-- File name tag in the top-right of each split (the global bar only shows the active one)
require("incline").setup({
	render = function(props)
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
		if name == "" then
			name = "[No Name]"
		end
		local icon, hl = MiniIcons.get("file", name)
		local modified = vim.bo[props.buf].modified and " [+]" or ""
		return { { icon .. " ", group = hl }, name .. modified }
	end,
})

require("tan.utils.tabline").setup()

require("todo-comments").setup()
require("nvim-highlight-colors").setup()
require("which-key").setup()

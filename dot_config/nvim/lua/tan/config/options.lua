-- Plain Neovim options (decision log §2.1).
local opt = vim.opt

-- Lines & look
opt.number = true
opt.relativenumber = true -- hybrid: cursor line shows its real number
opt.cursorline = true -- only in the active window (see autocmds)
opt.signcolumn = "yes" -- text never jumps when git/diagnostic signs appear
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.title = true -- terminal/herdr tab shows the file name
opt.termguicolors = true
opt.winborder = "rounded" -- every floating window
opt.pumheight = 10
opt.pumblend = 10
opt.showmatch = true
opt.matchtime = 2
opt.laststatus = 3 -- one global statusline
opt.cmdheight = 0 -- messages go through ui2 (bottom of file)
opt.fillchars:append({ diff = "╱" })

-- Wrap everywhere, but readable: break at words and keep wrapped lines indented.
-- j/k still move by real lines (use gj/gk for screen lines).
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- Indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true

-- Search & command-line completion
opt.ignorecase = true
opt.smartcase = true -- case-sensitive once you type a capital
opt.path:append("**") -- :find searches subfolders
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*/node_modules/*", "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Files: persistent undo instead of swap files (git + undo cover recovery)
opt.swapfile = false
opt.writebackup = false
opt.undofile = true
opt.undodir = vim.fn.expand("~/.cache/nvim/undodir")
opt.autoread = true -- pick up agent edits (checktime autocmd triggers it)

-- Timing
opt.updatetime = 300
opt.timeoutlen = 500
opt.ttimeoutlen = 0

-- Splits & folds
opt.splitbelow = true
opt.splitright = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- start unfolded

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Diagnostics: full message as virtual lines under the cursor line only
vim.diagnostic.config({
	virtual_lines = { current_line = true },
	virtual_text = false,
	severity_sort = true,
})

-- Neovim 0.12 ui2 (experimental): short messages in a corner popup, long output in a pager,
-- search count / completion / confirm prompts stay in the command line.
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = {
			[""] = "msg",
			empty = "cmd",
			bufwrite = "msg",
			confirm = "cmd",
			emsg = "pager",
			echo = "msg",
			echomsg = "msg",
			echoerr = "pager",
			completion = "cmd",
			list_cmd = "pager",
			lua_error = "pager",
			lua_print = "msg",
			progress = "pager",
			rpc_error = "pager",
			quickfix = "msg",
			search_cmd = "cmd",
			search_count = "cmd",
			shell_cmd = "pager",
			shell_err = "pager",
			shell_out = "pager",
			shell_ret = "msg",
			undo = "msg",
			verbose = "pager",
			wildlist = "cmd",
			wmsg = "msg",
			typed_cmd = "cmd",
		},
		cmd = { height = 0.5 },
		dialog = { height = 0.5 },
		msg = { height = 0.3, timeout = 5000 },
		pager = { height = 0.5 },
	},
})

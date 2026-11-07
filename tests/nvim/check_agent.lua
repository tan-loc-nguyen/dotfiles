-- Agent helpers (decision log §3.4): <leader>yf / <leader>yp copy "@path#L.." references from
-- normal, visual and oil buffers; <leader>as sends to a picked herdr agent, refuses a blocked
-- one, never presses Enter, and falls back to the clipboard outside herdr.
-- run.sh starts this from tests/nvim/fixtures, so relative paths start at "lsp/".
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")
local saved_clipboard = vim.fn.getreg("+")

local function feed(keys)
	vim.api.nvim_feedkeys(vim.keycode(keys), "x", false)
end

local function clip()
	return vim.fn.getreg("+")
end

-- Open an oil listing and put the cursor on `name`
local function oil_cursor_on(dir, name)
	vim.cmd.edit("oil://" .. vim.fn.fnamemodify(dir, ":p"))
	vim.wait(5000, function()
		return vim.fn.search("\\V" .. name, "cw") > 0
	end, 50)
end

t.run("agent", function()
	for _, m in ipairs({
		{ "n", "<leader>yf" },
		{ "x", "<leader>yf" },
		{ "n", "<leader>yp" },
		{ "n", "<leader>as" },
		{ "x", "<leader>as" },
	}) do
		t.ok(vim.fn.maparg(m[2], m[1]) ~= "", ("missing %s-mode keymap %s"):format(m[1], m[2]))
	end

	-- normal mode: current line
	vim.cmd.edit("lsp/app.ts")
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	feed("<leader>yf")
	t.eq(clip(), "@lsp/app.ts#L2", "normal-mode reference")

	-- visual mode: line range
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	feed("Vjj<leader>yf")
	t.eq(clip(), "@lsp/app.ts#L1-3", "visual-mode reference")

	-- absolute variant
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	feed("<leader>yp")
	t.eq(clip(), "@" .. vim.fn.fnamemodify("lsp/app.ts", ":p") .. "#L2", "absolute reference")

	-- oil: file and folder under the cursor
	oil_cursor_on("lsp", "app.ts")
	feed("<leader>yf")
	t.eq(clip(), "@lsp/app.ts", "oil file reference")
	oil_cursor_on("lsp", ".github/")
	feed("<leader>yf")
	t.eq(clip(), "@lsp/.github/", "oil folder reference")

	-- send outside herdr → clipboard fallback
	local agent = require("tan.utils.agent")
	vim.env.HERDR_ENV = nil
	vim.cmd.edit("lsp/app.ts")
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	vim.fn.setreg("+", "")
	feed("<leader>as")
	t.eq(clip(), "@lsp/app.ts#L2", "outside herdr: reference copied instead")

	-- inside herdr (seams stubbed): blocked agent is refused, idle agent gets text + focus
	vim.env.HERDR_ENV = "1"
	local calls = {}
	agent.run = function(args)
		table.insert(calls, table.concat(args, " "))
		return true
	end
	local offered = 0
	agent.select = function(items, _, on_choice) -- same signature as vim.ui.select
		offered = offered + 1
		on_choice(items[1])
	end

	agent.list_agents = function()
		return { { agent = "claude", agent_status = "blocked", pane_id = "w1:p9", terminal_title = "x" } }
	end
	feed("<leader>as")
	t.eq(offered, 1, "blocked agent: picker was shown")
	t.eq(#calls, 0, "blocked agent: nothing sent")

	agent.list_agents = function()
		return { { agent = "claude", agent_status = "idle", pane_id = "w1:p9", terminal_title = "x" } }
	end
	feed("<leader>as")
	t.eq(calls[1], "herdr pane send-text w1:p9 @lsp/app.ts#L2 ", "idle agent: text sent without Enter")
	t.eq(calls[2], "herdr agent focus w1:p9", "idle agent: pane focused")
	vim.env.HERDR_ENV = nil

	vim.fn.setreg("+", saved_clipboard)
end)

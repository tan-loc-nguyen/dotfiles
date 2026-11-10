-- Keymaps that need no plugin (decision log §3.2, §3.5). Plugin keymaps live in
-- tan/plugins/keymaps.lua.
local map = vim.keymap.set

-- Registers: `x` doesn't overwrite the clipboard; <leader>p pastes the last *yank*
-- (register 0) even after deletes, also over a visual selection.
map("n", "x", '"_x', { desc = "Delete char (no copy)" })
map({ "n", "x" }, "<leader>p", '"0p', { desc = "Paste last yank" })

map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Buffers: Tab cycles. In most terminals <Tab> and <C-i> are the same key, so jump-forward
-- moves to <C-n> (its built-in meaning is just `j`).
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<C-n>", "<C-i>", { desc = "Jump forward" })

-- Splits (s-prefix; Vim's `s` = `cl`). herdr panes use ctrl+space h/j/k/l.
map("n", "ss", "<cmd>split<cr>", { desc = "Split below" })
map("n", "sv", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "sh", "<C-w>h", { desc = "Window left" })
map("n", "sj", "<C-w>j", { desc = "Window down" })
map("n", "sk", "<C-w>k", { desc = "Window up" })
map("n", "sl", "<C-w>l", { desc = "Window right" })

-- Tabs are for throwaway layouts (diff/review); gt/gT cycle.
map("n", "te", "<cmd>tabedit<cr>", { desc = "New tab" })

-- Diagnostics (]d/[d are built in)
local function jump(count, severity)
	return function()
		vim.diagnostic.jump({ count = count * vim.v.count1, severity = severity, float = true })
	end
end
map("n", "]e", jump(1, vim.diagnostic.severity.ERROR), { desc = "Next error" })
map("n", "[e", jump(-1, vim.diagnostic.severity.ERROR), { desc = "Previous error" })
map("n", "]w", jump(1, vim.diagnostic.severity.WARN), { desc = "Next warning" })
map("n", "[w", jump(-1, vim.diagnostic.severity.WARN), { desc = "Previous warning" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

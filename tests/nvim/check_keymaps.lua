-- Every key decided in docs/agentic-setup/decisions.md §3 must exist (global keymaps only;
-- LSP keys are buffer-local and are checked in check_lsp.lua). Built-in gr* keys must not be
-- shadowed by a bare `gr`.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")

local expected = {
	-- §3.5 editing basics
	{ "n", "x" },
	{ "n", "<leader>p" },
	{ "x", "<leader>p" },
	{ "n", "<C-a>" },
	-- §3.2 buffers / splits / tabs
	{ "n", "<Tab>" },
	{ "n", "<S-Tab>" },
	{ "n", "<C-n>" }, -- jump forward (Tab took <C-i>)
	{ "n", "ss" },
	{ "n", "sv" },
	{ "n", "sh" },
	{ "n", "sj" },
	{ "n", "sk" },
	{ "n", "sl" },
	{ "n", "te" },
	-- diagnostics (kept)
	{ "n", "]e" },
	{ "n", "[e" },
	{ "n", "]w" },
	{ "n", "[w" },
	{ "n", "<leader>cd" },
	-- which-key buffer-local help
	{ "n", "<leader>?" },
	-- §3.1 pickers
	{ "n", "<leader>ff" },
	{ "n", "<leader>fF" },
	{ "n", "<leader>fg" },
	{ "n", "<leader>fG" },
	{ "n", "<leader>fb" },
	{ "n", "<leader>fh" },
	{ "n", "<leader>fd" },
	{ "n", "<leader>fs" },
	{ "n", "<leader>fS" },
	{ "n", "<C-p>" },
	-- §3.2 buffers
	{ "n", "<leader>bd" },
	{ "n", "<leader>bh" },
	-- §3.5 oil
	{ "n", "-" },
	{ "n", "sf" },
	-- §3.3 git review
	{ "n", "]h" },
	{ "n", "[h" },
	{ "n", "<leader>gs" },
	{ "x", "<leader>gs" },
	{ "n", "<leader>gr" },
	{ "x", "<leader>gr" },
	{ "n", "<leader>gp" },
	{ "n", "<leader>gS" },
	{ "n", "<leader>gR" },
	{ "n", "<leader>gb" },
	{ "n", "<leader>gd" },
	{ "n", "<leader>gh" },
	{ "n", "<leader>gH" },
	{ "n", "<leader>gg" },
	{ "n", "<leader>gf" },
}

t.run("keymaps", function()
	for _, m in ipairs(expected) do
		t.ok(vim.fn.maparg(m[2], m[1]) ~= "", ("missing %s-mode keymap %s"):format(m[1], m[2]))
	end
	t.ok(vim.fn.maparg("gr", "n") == "", "bare `gr` is mapped; it would shadow built-in grr/gri/grt/grn/gra")
	t.eq(vim.g.mapleader, " ", "leader")
end)

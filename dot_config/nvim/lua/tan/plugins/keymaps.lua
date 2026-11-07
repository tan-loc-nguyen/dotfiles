-- Every keymap that uses a plugin. Required last, so all plugins are set up already.
local map = vim.keymap.set

map("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer-local keymaps (which-key)" })

-- Finders (snacks picker). Capital letter = include git-ignored files.
local pick = Snacks.picker
map("n", "<leader>ff", function()
	pick.files()
end, { desc = "Find files" })
map("n", "<leader>fF", function()
	pick.files({ ignored = true, hidden = true })
end, { desc = "Find files (incl. ignored)" })
map("n", "<leader>fg", function()
	pick.grep()
end, { desc = "Grep" })
map("n", "<leader>fG", function()
	pick.grep({ ignored = true, hidden = true })
end, { desc = "Grep (incl. ignored)" })
map("n", "<leader>fb", function()
	pick.buffers()
end, { desc = "Buffers" })
map("n", "<leader>fh", function()
	pick.help()
end, { desc = "Help" })
map("n", "<leader>fd", function()
	pick.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>fs", function()
	pick.lsp_symbols()
end, { desc = "Symbols (file)" })
map("n", "<leader>fS", function()
	pick.lsp_workspace_symbols()
end, { desc = "Symbols (project)" })
map("n", "<C-p>", function()
	pick.files()
end, { desc = "Find files" }) -- Ghostty Cmd+P sends <C-p>

-- Buffers
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Close buffer (keep layout)" })
map("n", "<leader>bh", function()
	require("tan.utils.editor").delete_hidden_buffers()
end, { desc = "Close hidden buffers" })

-- Files (oil): `-` walks in place, `sf` peeks in a float with preview (q closes)
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
map("n", "sf", function()
	require("oil").open_float(nil, { preview = {} })
end, { desc = "Files (float)" })

-- Git review: stage = accept an agent's change, reset = reject it
local gs = require("gitsigns")
map("n", "]h", function()
	gs.nav_hunk("next")
end, { desc = "Next hunk" })
map("n", "[h", function()
	gs.nav_hunk("prev")
end, { desc = "Previous hunk" })
map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk (accept)" })
map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk (reject)" })
map("x", "<leader>gs", function()
	gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage lines" })
map("x", "<leader>gr", function()
	gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset lines" })
map("n", "<leader>gp", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
map("n", "<leader>gb", function()
	gs.blame_line({ full = true })
end, { desc = "Blame line (popup)" })
map("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Review changes (CodeDiff tab)" })
map("n", "<leader>gh", "<cmd>CodeDiff history %<cr>", { desc = "File history" })
map("n", "<leader>gH", "<cmd>CodeDiff history<cr>", { desc = "Repo history" })
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gf", function()
	Snacks.lazygit.log_file()
end, { desc = "Lazygit: current file log" })

-- Format on demand, even where the project declares no formatter (then: the usual
-- formatter for this filetype, falling back to the language server).
local manual_formatters = {
	javascript = { "prettierd" },
	javascriptreact = { "prettierd" },
	typescript = { "prettierd" },
	typescriptreact = { "prettierd" },
	json = { "prettierd" },
	jsonc = { "prettierd" },
	css = { "prettierd" },
	html = { "prettierd" },
	markdown = { "prettierd" },
	yaml = { "prettierd" },
	python = { "ruff_format" },
	sh = { "shfmt" },
	bash = { "shfmt" },
	lua = { "stylua" },
	go = { "goimports" },
}
map({ "n", "x" }, "<leader>cf", function()
	local declared = require("tan.utils.format").formatters_for(0)
	local formatters = #declared > 0 and declared or manual_formatters[vim.bo.filetype]
	require("conform").format({ formatters = formatters, lsp_format = "fallback", timeout_ms = 1000 })
end, { desc = "Format" })

-- LSP keys exist only in buffers with a language server. gr* are Neovim's built-in names,
-- pointed at the snacks picker (list + preview; jumps straight when there's one result).
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function bmap(lhs, rhs, desc)
			map("n", lhs, rhs, { buffer = ev.buf, desc = desc })
		end
		bmap("gd", function()
			pick.lsp_definitions()
		end, "Go to definition")
		bmap("gD", function()
			pick.lsp_declarations()
		end, "Go to declaration")
		bmap("grr", function()
			pick.lsp_references()
		end, "References")
		bmap("gri", function()
			pick.lsp_implementations()
		end, "Implementations")
		bmap("grt", function()
			pick.lsp_type_definitions()
		end, "Type definition")
		bmap("<C-k>", vim.lsp.buf.signature_help, "Signature help")
		bmap("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action" })
		bmap("<leader>ci", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
		end, "Toggle inlay hints")
	end,
})

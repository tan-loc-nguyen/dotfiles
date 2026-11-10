-- Git review (decision log §3.3): gitsigns for signs / inline hunk preview / blame,
-- CodeDiff for the side-by-side review tab. Staging a hunk = accepting an agent's change,
-- resetting it = rejecting it.

require("gitsigns").setup({ current_line_blame = true })

-- One key scheme everywhere: CodeDiff's defaults (]c, <leader>h*, <leader>b) are remapped to
-- the same ]h / <leader>g* keys used in normal buffers.
require("codediff").setup({
	keymaps = {
		view = {
			next_hunk = "]h",
			prev_hunk = "[h",
			stage_hunk = "<leader>gs",
			unstage_hunk = "<leader>gu",
			discard_hunk = "<leader>gr",
			toggle_explorer = "<leader>ge", -- default <leader>b would clash with the buffer keys
		},
	},
})

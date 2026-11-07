-- Every keymap that uses a plugin. Required last, so all plugins are set up already.
local map = vim.keymap.set

map("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer-local keymaps (which-key)" })

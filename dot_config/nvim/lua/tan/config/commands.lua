-- :W saves without running format-on-save (or any other autocmd)
vim.api.nvim_create_user_command("W", "noautocmd write", { desc = "Write without formatting" })

-- Lua: know about Neovim's runtime and the `vim` global when editing this config.
return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim", "Snacks", "MiniIcons" } },
			workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
			hint = { enable = true },
		},
	},
}

-- TypeScript via vtsls: use the project's own TypeScript, update imports when files move
-- (oil renames go through LSP), inlay hints available via <leader>ci.
local hints = {
	parameterNames = { enabled = "literals" },
	parameterTypes = { enabled = true },
	variableTypes = { enabled = false },
	propertyDeclarationTypes = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
}

return {
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true,
			experimental = { completion = { enableServerSideFuzzyMatch = true } },
		},
		typescript = { updateImportsOnFileMove = { enabled = "always" }, inlayHints = hints },
		javascript = { updateImportsOnFileMove = { enabled = "always" }, inlayHints = hints },
	},
}

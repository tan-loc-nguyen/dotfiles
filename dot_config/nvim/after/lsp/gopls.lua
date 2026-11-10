-- Go: extra analyses + staticcheck, and inlay hints (toggle with <leader>ci).
return {
	settings = {
		gopls = {
			staticcheck = true,
			analyses = { unusedparams = true, unusedwrite = true, nilness = true, shadow = true },
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}

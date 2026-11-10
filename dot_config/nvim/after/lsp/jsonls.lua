-- JSON: validate package.json, tsconfig.json, etc. against their official schemas.
return {
	settings = {
		json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
	},
}

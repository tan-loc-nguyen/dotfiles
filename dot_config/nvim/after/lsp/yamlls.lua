-- YAML: validate GitHub Actions, docker-compose, k8s, etc. against SchemaStore schemas.
return {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" }, -- use SchemaStore.nvim's catalog instead
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}
